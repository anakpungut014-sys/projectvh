-- ============================================================
-- VRILZHUB FEATURES — NAME GAME v1.0
-- Halloween: Ambil SEMUA candy priority tertinggi → balik base → ulangi
-- ============================================================

local Features = {}
local Shared = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- ANTI-AFK (FINAL v5) — SAFE, ANTI-KICK, ANTI-DOUBLE-FIRE
-- ============================================================
function Features.startAntiAFK()
    if Features._antiAFKStarted then return end
    Features._antiAFKStarted = true

    local VirtualUser = game:GetService("VirtualUser")
    local UserInputService = game:GetService("UserInputService")
    if not Shared then Shared = {} end
    if Shared.AntiAFK_Enabled == nil then Shared.AntiAFK_Enabled = true end

    -- ⭐ State lokal, aman dari race condition
    local _actionBusy = false

local function isAnyFeatureBusy()
    return false
end

    -- ⭐ ACTION: NGASIH INPUT BENERAN (movement + jump + mouse)
    local function doAntiAFKAction()
        if Shared.AntiAFK_Enabled == false then return end
        if _actionBusy then return end
        _actionBusy = true

        -- ⭐ 1) VirtualUser capture (wajib, biar Roblox detect activity)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(0, 0))
            task.wait(0.05)
            VirtualUser:Button2Up(Vector2.new(0, 0))
        end)

        -- ⭐ 2) MOVEMENT BENERAN — gerak karakter, BUKAN cuma mouse
        if not isAnyFeatureBusy() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not hum.SeatPart and not hum.PlatformStand then
                -- Gerak ke 4 arah bergantian biar server detect movement
                local dirs = {
                    Vector3.new(0, 0, -1),
                    Vector3.new(1, 0, 0),
                    Vector3.new(0, 0, 1),
                    Vector3.new(-1, 0, 0),
                }
                for _, d in ipairs(dirs) do
                    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if not h or h.SeatPart or h.PlatformStand then break end
                    pcall(function() h:Move(d, false) end)
                    task.wait(0.15)
                end
                -- Reset movement
                local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h2 and not h2.SeatPart then
                    pcall(function() h2:Move(Vector3.new(0,0,0), false) end)
                end
            end
        end

        -- ⭐ 3) Jump sekali (kalo aman) — bikin server detect "player aktif"
        if not isAnyFeatureBusy() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not hum.SeatPart and not hum.PlatformStand then
                pcall(function() hum.Jump = true end)
            end
        end

        -- ⭐ 4) Mouse move (kalo ada)
        if type(mousemoverel) == "function" then
            pcall(function() mousemoverel(10, 10) end)
            task.wait(0.05)
            pcall(function() mousemoverel(-10, -10) end)
        end

        task.delay(0.3, function() _actionBusy = false end)
    end

    -- ═══ 1. IDLED LISTENER — TANPA THROTTLE 30s ═══
    -- ⭐ Roblox fire Idled ~20s sekali. Jangan pernah skip.
    LocalPlayer.Idled:Connect(function()
        task.spawn(function()
            if Shared.AntiAFK_Enabled == false then return end
            doAntiAFKAction()
        end)
    end)

    -- ═══ 2. PERIODIC 60s — lebih aman dari 90s ═══
    task.spawn(function()
        task.wait(20) -- delay awal
        while true do
            task.wait(60)
            if Shared.AntiAFK_Enabled == false then continue end
            doAntiAFKAction()  -- ⭐ LANGSUNG panggil, jangan task.spawn (biar gak numpuk)
        end
    end)

    -- ═══ 3. RESPAWN SAFETY ═══
    LocalPlayer.CharacterAdded:Connect(function()
        _actionBusy = false
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 AUTO THROW SYSTEM — CAMERA LOCK KE CLONE (FINAL)
-- Auto Throw ON = camera WAJIB lock di clone, lawan semua cinematic
-- Auto Throw OFF = normal (camera ikut char)
-- ═══════════════════════════════════════════════════════════
local function initAutoThrow()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    -- ═══ STATE ═══
    local ThrowState = {
        autoThrow = false,
        autoBest = false,
        tapPoint = 0.93,
        unequipDelay = 0.3,
        tpDelay = 0.5,
        marker = nil,
        lastTap = 0,
        revealCache = setmetatable({}, { __mode = "k" }),
    }

    -- ═══ HELPER: require ═══
    local function requirePlayerScript(...)
        local ps = LocalPlayer:WaitForChild("PlayerScripts", 5)
        if not ps then return nil end
        for _, name in ipairs({...}) do
            ps = ps:WaitForChild(name, 5)
            if not ps then return nil end
        end
        local ok, mod = pcall(require, ps)
        return ok and mod or nil
    end

    local ThrowController = requirePlayerScript("Client", "Controllers", "ThrowController")
    local ClientState = requirePlayerScript("Client", "Controllers", "ClientState")

    -- ═══ HELPER: ambil animal tool ═══
    local function getEquippedAnimal()
        local char = LocalPlayer.Character
        if not char then return nil end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:GetAttribute("AnimalId") ~= nil then
            return tool
        end
        return nil
    end

    -- ═══ HELPER: unequip ═══
    local function unequipTools()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        if not getEquippedAnimal() then return nil end
        pcall(function() hum:UnequipTools() end)
        return true
    end

    -- ═══ HELPER: StarterArea ═══
    local function getStarterArea()
        local sa = Workspace:FindFirstChild("StarterArea")
        if not sa then return nil, nil end
        local cl = sa:FindFirstChild("CrossLine")
        local crossZ = cl and cl.Position.Z or (sa.Position.Z + sa.Size.Z / 2)
        return sa, crossZ
    end

    local function isInThrowArea(hrp)
        local sa, crossZ = getStarterArea()
        if not (sa and hrp) then return false end
        local pos = sa.Position
        local half = sa.Size / 2
        local p = hrp.Position
        if p.Z >= crossZ then return false end
        if math.abs(p.X - pos.X) > half.X + 0.5 then return false end
        if p.Z < pos.Z - half.Z - 0.5 then return false end
        if p.Y < pos.Y + half.Y - 3 then return false end
        return true
    end

    local function teleportToThrowArea()
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local sa, crossZ = getStarterArea()
        if not (hrp and sa and hum) then return false end
        local pos = sa.Position
        local half = sa.Size / 2
        local x = math.clamp(hrp.Position.X, pos.X - half.X + 2, pos.X + half.X - 2)
        local z = math.clamp(crossZ - 3, pos.Z - half.Z + 1, crossZ - 1)
        local y = pos.Y + half.Y + hum.HipHeight + hrp.Size.Y / 2 + 0.1
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = CFrame.lookAt(Vector3.new(x, y, z), Vector3.new(x, y, z + 1))
        return true
    end

    -- ═══ HELPER: meter marker ═══
    local function findMeterMarker()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        for _, v in ipairs(pg:GetDescendants()) do
            if v.Name == "Marker" and v.Parent
                and v.Parent.Parent
                and v.Parent.Parent.Name == "Meter" then
                return v
            end
        end
        return nil
    end

    -- ═══ HELPER: reveal text ═══
    local function isRevealText(txt)
        if type(txt) ~= "string" or txt == "" then return false end
        local lower = txt:lower()
        return lower:find("tap to continue", 1, true) ~= nil
            or lower:find("tap to skip", 1, true) ~= nil
            or lower:find("click to continue", 1, true) ~= nil
            or lower:find("click to skip", 1, true) ~= nil
    end

    local function readRevealResult(label)
        local ok, gui = pcall(function() return label:FindFirstAncestorOfClass("ScreenGui") end)
        if not ok or not gui then return nil end
        local parts = {}
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible ~= false
                and d.Text ~= "" and not isRevealText(d.Text) then
                table.insert(parts, d.Text)
            end
        end
        if #parts == 0 then return nil end
        return table.concat(parts, " | ")
    end

    local function scanRevealScreens()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") and isRevealText(v.Text) then
                ThrowState.revealCache[v] = true
            end
        end
    end

    -- ═══ LOOP: marker & reveal ═══
    task.spawn(function()
        while true do
            task.wait(0.15)
            if ThrowState.autoBest then
                local m = ThrowState.marker
                if m and not m.Parent then
                    ThrowState.marker = findMeterMarker()
                elseif not m then
                    ThrowState.marker = findMeterMarker()
                end
            end
            if ThrowState.autoThrow then
                scanRevealScreens()
            end
        end
    end)

    -- ═══ REVEAL WATCHER ═══
    task.spawn(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        pg.DescendantAdded:Connect(function(d)
            task.defer(function()
                if d:IsA("TextLabel") and isRevealText(d.Text) then
                    ThrowState.revealCache[d] = true
                end
            end)
        end)
        local lastResult, lastResultTime = nil, 0
        while true do
            task.wait(0.2)
            if not ThrowState.autoThrow then continue end
            for k in pairs(ThrowState.revealCache) do
                if k.Parent then
                    if k.TextTransparency < 0.9 then
                        ThrowState.revealCache[k] = nil
                        task.wait(0.35)
                        local result = nil
                        if k.Parent then
                            result = readRevealResult(k)
                        end
                        if result and Shared and Shared.Notify
                            and (result ~= lastResult or os.clock() - lastResultTime > 3) then
                            lastResult = result
                            lastResultTime = os.clock()
                            Shared.Notify("Throw Result", result, "info")
                        end
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.delay(0.03, function()
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                    end
                else
                    ThrowState.revealCache[k] = nil
                end
            end
        end
    end)

    -- ═══ AUTO BEST THROW ═══
    RunService.RenderStepped:Connect(function()
        if not ThrowState.autoBest then return end
        local m = ThrowState.marker
        if not m or not m.Parent then return end
        if os.clock() - ThrowState.lastTap < 1.5 then return end
        local norm = 1 - m.Position.Y.Scale
        if norm >= ThrowState.tapPoint then
            ThrowState.lastTap = os.clock()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.delay(0.03, function()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end)

    -- ═══ LOOP: AUTO THROW ═══
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not ThrowState.autoThrow then continue end
            if not ThrowController or not ThrowController.Start then
                Shared.Notify("Auto Throw", "ThrowController tidak ditemukan.", "error")
                ThrowState.autoThrow = false
                Shared.AutoThrow_Enabled = false
                continue
            end
            if Shared.UnequipDelay_Seconds and unequipTools() then
                task.wait(Shared.UnequipDelay_Seconds or ThrowState.unequipDelay)
            end
            local busy = ClientState and ClientState.Busy
            local isActive = ThrowController.IsActive and ThrowController.IsActive()
            if busy or isActive or getEquippedAnimal() then
                continue
            end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp.Anchored and not isInThrowArea(hrp) then
                teleportToThrowArea()
                task.wait(Shared.TpDelay_Seconds or ThrowState.tpDelay)
            end
            if ClientState and ClientState.Busy then continue end
            pcall(ThrowController.Start)
            task.wait(3)
        end
    end)

    -- ═══ SYNC STATE ═══
    task.spawn(function()
        while true do
            task.wait(0.3)
            ThrowState.autoThrow = Shared.AutoThrow_Enabled == true
            ThrowState.autoBest = Shared.AutoBestThrow_Enabled == true
            ThrowState.tapPoint = (Shared.TapPoint_Percent or 93) / 100
            ThrowState.unequipDelay = Shared.UnequipDelay_Seconds or 0.5
            ThrowState.tpDelay = Shared.TpDelay_Seconds or 0.6
        end
    end)

    -- ═══════════════════════════════════════════════════════════
    -- 🎥 CAMERA LOCK — WAJIB LOCK SAAT AUTO THROW ON
    -- ═══════════════════════════════════════════════════════════
    local camera = Workspace.CurrentCamera
    local camAnchor = nil
    local savedSubject = nil
    local savedCameraType = nil

    local BIND_HARD = "VRILZ_CamPin_Hard"

    local BASE_POS   = Vector3.new(2.23, 6.01, 20.29)
    local CAM_OFFSET = Vector3.new(0, 6, 14)

    -- ⭐ Posisi lock: prioritas CLONE HRP → fallback BASE_POS
    local function getLockTarget()
        local ghost = Workspace:FindFirstChild(LocalPlayer.Name .. "_Ghost")
        if ghost then
            local ghostHRP = ghost:FindFirstChild("HumanoidRootPart")
            if ghostHRP then
                return ghostHRP.Position
            end
        end
        return BASE_POS
    end

    local function createCamAnchor()
        local a = Instance.new("Part")
        a.Name = "VRILZ_CamAnchor"
        a.Size = Vector3.new(1, 1, 1)
        a.Transparency = 1
        a.CanCollide = false
        a.Anchored = true
        a.CanQuery = false
        a.CanTouch = false
        a.Massless = true
        a.CFrame = CFrame.new(getLockTarget())
        a.Parent = Workspace
        return a
    end

    -- ⭐ HARD STEP — lock CFrame + CameraType tiap frame
    -- Subject di-handle ghostCamToClone (Last+5)
    local function hardStep()
        local cam = Workspace.CurrentCamera
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end
        local target = getLockTarget()
        local camPos = target + CAM_OFFSET
        cam.CFrame = CFrame.lookAt(camPos, target)
        -- ⭐ paksa subject ke anchor biar game gak pindah ke ThrowTarget
        if camAnchor and camAnchor.Parent then
            if cam.CameraSubject ~= camAnchor then
                cam.CameraSubject = camAnchor
            end
        end
    end

    local function startCamPin()
        if camAnchor and camAnchor.Parent then return end
        if camAnchor then pcall(function() camAnchor:Destroy() end) end
        camAnchor = createCamAnchor()
        savedSubject    = camera.CameraSubject
        savedCameraType = camera.CameraType
        RunService:BindToRenderStep(BIND_HARD, Enum.RenderPriority.Last.Value + 1, hardStep)
    end

    -- ⭐ stopCamPin — jangan balikin Custom kalau ghost masih ON
    local function stopCamPin()
        if not camAnchor then return end
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local ghostOn = Shared and (Shared.GhostMode_Enabled or Shared.AutoThrow_Enabled)
        if ghostOn then
            camera.CameraType = Enum.CameraType.Scriptable
        else
            camera.CameraType = savedCameraType or Enum.CameraType.Custom
            camera.CameraSubject = savedSubject or hum
        end
        savedSubject, savedCameraType = nil, nil
        camAnchor:Destroy()
        camAnchor = nil
    end

    -- ⭐ LOOP CAM
    task.spawn(function()
        while true do
            task.wait(0.1)
            if ThrowState.autoThrow then
                if not camAnchor or not camAnchor.Parent then
                    startCamPin()
                end
            else
                stopCamPin()
            end
        end
    end)

    -- ⭐ CharacterAdded: INSTANT re-lock, no delay
    LocalPlayer.CharacterAdded:Connect(function()
        if ThrowState.autoThrow then
            if camAnchor then
                pcall(function() camAnchor:Destroy() end)
                camAnchor = nil
            end
            startCamPin()
        end
    end)

    -- ⭐ expose ke ghost module
    if Shared then
        Shared.ThrowController_Ref = ThrowController
        Shared.ClientState_Ref = ClientState
    end
end

-- ═══════════════════════════════════════════════════════════
-- 🛒 AUTO BUY BEST FOOD + AUTO UPGRADE STAND
-- ═══════════════════════════════════════════════════════════
local function initAutoShop()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local State = {
        autoBuy = false,
        autoUpgrade = false,
        lastBuyNotify = 0,
        lastUpgradeNotify = 0,
    }

    local function requireShared(folder, ...)
        local node = ReplicatedStorage:WaitForChild(folder, 5)
        if not node then return nil end
        for _, name in ipairs({ ... }) do
            node = node:WaitForChild(name, 5)
            if not node then return nil end
        end
        local ok, mod = pcall(require, node)
        return ok and mod or nil
    end

    local function requirePlayerScript(...)
        local ps = LocalPlayer:WaitForChild("PlayerScripts", 5)
        if not ps then return nil end
        for _, name in ipairs({ ... }) do
            ps = ps:WaitForChild(name, 5)
            if not ps then return nil end
        end
        local ok, mod = pcall(require, ps)
        return ok and mod or nil
    end

    local FoodsConfig = requireShared("Config", "FoodsConfig")
    local StandsConfig = requireShared("Config", "StandsConfig")
    local Remotes = requireShared("Shared", "Remotes")

    local DataController = requirePlayerScript("Client", "Controllers", "DataController")
    local PlotController = requirePlayerScript("Client", "Controllers", "PlotController")
    local TrainingController = requirePlayerScript("Client", "Controllers", "TrainingController")
    local ClientState = requirePlayerScript("Client", "Controllers", "ClientState")

    local function isBusy()
        local busy = false
        if ClientState then
            pcall(function() busy = ClientState.Busy == true end)
        end
        return busy
    end

    local function notifySafe(title, content)
        if Shared and Shared.Notify then
            pcall(Shared.Notify, title .. ": " .. content, "info")
        end
    end

    local function notifyThrottled(field, title, content, interval)
        local now = os.clock()
        if now - (State[field] or 0) < (interval or 5) then return end
        State[field] = now
        notifySafe(title, content)
    end

    local function stopTraining()
        if not TrainingController or not TrainingController.IsRunning then return end
        local running = false
        pcall(function() running = TrainingController.IsRunning() end)
        if not running then return end
        pcall(function() TrainingController.Stop() end)
        local start = os.clock()
        while os.clock() - start < 6 do
            local still = false
            pcall(function() still = TrainingController.IsRunning() end)
            if not still then break end
            task.wait(0.2)
        end
    end

    -- ═══ FOOD ═══
    local function buildFoodList()
        local list = {}
        if not FoodsConfig then return list end
        local okCount, total = pcall(FoodsConfig.CountAll)
        if not okCount or type(total) ~= "number" then return list end
        for i = 1, total do
            local okGet, food = pcall(FoodsConfig.GetAny, i)
            if okGet and food then
                local locked = false
                pcall(function()
                    locked = FoodsConfig.IsLocked(food.Index) and true or false
                end)
                if not locked then
                    table.insert(list, { slot = i, food = food })
                end
            end
        end
        table.sort(list, function(a, b)
            local ta = a.food.Tier or 0
            local tb = b.food.Tier or 0
            if ta == tb then return (a.food.Price or 0) > (b.food.Price or 0) end
            return tb < ta
        end)
        return list
    end

    local function isFoodOwned(food)
        if not DataController then return false end
        local ok, owned = pcall(function()
            return DataController:GetPath("OwnedFoods." .. food.Index) == true
        end)
        return ok and owned or false
    end

    local function runShopCycle()
        if not (FoodsConfig and DataController and Remotes) then return end
        if isBusy() then return end
        local money = 0
        pcall(function() money = DataController:Get("Money") or 0 end)
        for _, entry in ipairs(buildFoodList()) do
            local food = entry.food
            if isFoodOwned(food) then return end
            if (food.Price or math.huge) <= money then
                local okBuy, res = pcall(Remotes.Invoke, "Shop_Buy", entry.slot)
                if okBuy and res and res.Ok then
                    notifyThrottled("lastBuyNotify", "Auto Buy", "Bought " .. tostring(food.Name) .. "!", 3)
                    return
                end
            end
        end
    end

    -- ═══ STAND ═══
    local function tryUpgradeStand()
        if not (Remotes and DataController and StandsConfig) then return nil end
        local level, money = 0, 0
        pcall(function()
            level = DataController:Get("Stand") or 0
            money = DataController:Get("Money") or 0
        end)
        local okNext, nextStand = pcall(StandsConfig.Get, level + 1)
        if not okNext or not nextStand then return nil end
        if money < (nextStand.Price or math.huge) then return nil end
        if TrainingController then stopTraining() end
        if isBusy() then return nil end
        local okUp, res = pcall(Remotes.Invoke, "Stand_Upgrade")
        local upgraded = okUp and res and res.Ok
        if not upgraded and PlotController and PlotController.TeleportToStand then
            pcall(PlotController.TeleportToStand, false)
            task.wait(0.6)
            local okUp2, res2 = pcall(Remotes.Invoke, "Stand_Upgrade")
            upgraded = okUp2 and res2 and res2.Ok
            res = res2
        end
        if upgraded and res then
            local okName, newStand = pcall(StandsConfig.Get, res.NewIndex)
            local standName = (okName and newStand and newStand.Name) or "a new stand"
            notifyThrottled("lastUpgradeNotify", "Upgrade", "Upgraded to " .. tostring(standName) .. "!", 3)
        end
        return upgraded
    end

    -- ═══ LOOP SHOP ═══
    task.spawn(function()
        while true do
            task.wait(1.5)
            if State.autoBuy then pcall(runShopCycle) end
        end
    end)

    -- ═══ LOOP STAND ═══
    task.spawn(function()
        while true do
            task.wait(2)
            if State.autoUpgrade
                and not isBusy()
                and not (Shared and Shared.AutoThrow_Enabled) then
                pcall(tryUpgradeStand)
            end
        end
    end)

    -- ═══ SYNC FLAG ═══
    task.spawn(function()
        while true do
            task.wait(0.3)
            if Shared then
                State.autoBuy = Shared.AutoBuy_Enabled == true
                State.autoUpgrade = Shared.AutoUpgradeStand_Enabled == true
            end
        end
    end)
end

-- ============================================================
-- 👻 GHOST MODE v5 (THROW) — char invisible + clone fix di base
-- Auto ON pas Auto Throw nyala. GUI game dihide. Camera di clone.
-- ============================================================

local GHOST_CLONE_POS = Vector3.new(2.23, 6.01, 20.29) + Vector3.new(0, 3, 0) -- base + tinggi HRP

local GhostState = {
    enabled      = false,
    clone        = nil,
    saved        = {},
    savedDisplay = nil,
    savedGuis    = {},
    savedAnimator = nil,
}

-- ═══ GUI: hide semua ScreenGui KECUALI yang mengandung "vrilz" ═══
local function ghostHideGuis()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    for _, g in ipairs(pg:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name:lower():find("vrilz") == nil then
            if GhostState.savedGuis[g] == nil then
                GhostState.savedGuis[g] = g.Enabled
            end
            g.Enabled = false
        end
    end
end

local function ghostRestoreGuis()
    for g, v in pairs(GhostState.savedGuis) do
        if g and g.Parent then g.Enabled = v end
    end
    GhostState.savedGuis = {}
end

-- ═══ Sembunyikan real char ═══
local function ghostHide(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if GhostState.saved[d] == nil then GhostState.saved[d] = d.Transparency end
            d.Transparency = 1
            d.LocalTransparencyModifier = 1
        elseif d:IsA("Decal") then
            if GhostState.saved[d] == nil then GhostState.saved[d] = d.Transparency end
            d.Transparency = 1
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
            or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
            d.Enabled = false
        elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            d.Enabled = false
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if GhostState.savedDisplay == nil then
            GhostState.savedDisplay = hum.DisplayDistanceType
        end
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        -- ⬇️⬇️ TAMBAH BLOK INI ⬇️⬇️
        local anim = hum:FindFirstChildOfClass("Animator")
        if anim and GhostState.savedAnimator == nil then
            GhostState.savedAnimator = { anim = anim, parent = anim.Parent }
            pcall(function()
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                    t:Stop(0)
                end
            end)
            anim.Parent = nil
        end
        -- ⬆️⬆️ SAMPAI SINI ⬆️⬆️
    end
    local hl = char:FindFirstChildOfClass("Highlight")
    if hl then hl.Enabled = false end
end

local function ghostRestore(char)
    for d, t in pairs(GhostState.saved) do
        if d and d.Parent then
            d.Transparency = t
            d.LocalTransparencyModifier = 0
        end
    end
    GhostState.saved = {}
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
            or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles")
            or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            d.Enabled = true
        end
    end
        local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and GhostState.savedDisplay then
        hum.DisplayDistanceType = GhostState.savedDisplay
        GhostState.savedDisplay = nil
    end

    -- ⬇️⬇️ TAMBAH BLOK INI ⬇️⬇️
    if GhostState.savedAnimator then
        local s = GhostState.savedAnimator
        if s.anim and s.parent then
            s.anim.Parent = s.parent
        end
        GhostState.savedAnimator = nil
    end
    -- ⬆️⬆️ SAMPAI SINI ⬆️⬆️

    local hl = char:FindFirstChildOfClass("Highlight")
    if hl then hl.Enabled = true end
end

-- ═══ Clone: fix di base, berbaju, diem ═══
local function ghostCreateClone(char)
    if GhostState.clone then
        GhostState.clone:Destroy()
        GhostState.clone = nil
    end

    local oldArch = char.Archivable
    char.Archivable = true
    local ok, clone = pcall(function() return char:Clone() end)
    char.Archivable = oldArch
    if not ok or not clone then return end

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
            d:Destroy()
        end
    end
    for _, d in ipairs(clone:GetChildren()) do
        if d:IsA("Tool") then d:Destroy() end
    end
    
    -- Humanoid dipertahankan biar BAJU ke-render, di-neuter
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.PlatformStand      = true
        pcall(function() hum.EvaluateStateMachine = false end)

        -- ⭐ FIX: cabut Animator — game gak bisa muter animasi lempar di clone
        local anim = hum:FindFirstChildOfClass("Animator")
        if anim then anim:Destroy() end
    end

    for _, cls in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
        local src = char:FindFirstChildOfClass(cls)
        if src then
            local old = clone:FindFirstChildOfClass(cls)
            if old then old:Destroy() end
            src:Clone().Parent = clone
        end
    end

    -- ⭐ POSISI FIX di base — gak ikut char yang teleport/lempar
    clone:PivotTo(CFrame.new(GHOST_CLONE_POS))

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.Massless = true
        end
    end

    -- ⭐ FIX: nama beda — workspace[namalu] selalu dapat char ASLI, bukan clone
    clone.Name = char.Name .. "_Ghost"
    clone.Parent = Workspace
    GhostState.clone = clone
end

-- ═══ Camera ikut clone (KECUALI throw cam pin lagi aktif) ═══
local function throwCamActive()
    return Workspace:FindFirstChild("VRILZ_CamAnchor") ~= nil
end

local function ghostCamToClone()
    local cam = Workspace.CurrentCamera
    local cloneHRP = GhostState.clone and GhostState.clone:FindFirstChild("HumanoidRootPart")
    if not (cam and cloneHRP) then return end

    -- game paksa Scriptable saat cinematic → kita ikut Scriptable,
    -- tapi CFrame-nya KITA yang isi, menghadap clone
    if cam.CameraType ~= Enum.CameraType.Scriptable then
        cam.CameraType = Enum.CameraType.Scriptable
    end

    -- ⭐ WAJIB: paksa subject ke clone HRP — biar game gak pindah ke ThrowTarget
    if cam.CameraSubject ~= cloneHRP then
        cam.CameraSubject = cloneHRP
    end

    local target = cloneHRP.Position
    local camPos = target + Vector3.new(0, 6, 14)
    cam.CFrame = CFrame.lookAt(camPos, target)
end
local function ghostEnable()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    ghostCreateClone(char)
    task.wait(0.1)
    ghostHide(char)
    ghostHideGuis()
    ghostCamToClone()
    GhostState.enabled = true
end

local function ghostDisable()
    local char = LocalPlayer.Character
    if char then ghostRestore(char) end
    ghostRestoreGuis()
    if GhostState.clone then
        GhostState.clone:Destroy()
        GhostState.clone = nil
    end
    if not throwCamActive() then
        local cam = Workspace.CurrentCamera
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if cam and hum then
            cam.CameraSubject = hum
        end
    end
    GhostState.enabled = false
end

local function initGhostMode()
    LocalPlayer.CharacterAdded:Connect(function()
        if GhostState.clone then
            GhostState.clone:Destroy()
            GhostState.clone = nil
        end
        if GhostState.enabled then
            task.wait(2)
            pcall(ghostEnable)
        end
    end)

    -- ⬇️⬇️ TAMBAH BLOK INI ⬇️⬇️
    -- Bind di priority Last+2 → jalan SETELAH hardStep (Last+1) di initAutoThrow,
    -- jadi menimpa Scriptable/CFrame fixed → camera ikut clone
    RunService:BindToRenderStep("VRILZ_GhostCamOverride",
        Enum.RenderPriority.Last.Value + 5, function()
            if not GhostState.enabled then return end
            local SharedNow = Shared
            if not SharedNow then return end
            if not (SharedNow.GhostMode_Enabled or SharedNow.AutoThrow_Enabled) then return end
            ghostCamToClone()
        end)
    -- pengawal Animator: jalan tiap 0.05s, tidak peduli transparency
    task.spawn(function()
        while true do
            task.wait(0.05)
            if not GhostState.enabled then continue end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = hum:FindFirstChildOfClass("Animator")
                if anim then
                    pcall(function()
                        for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                            t:Stop(0)
                        end
                    end)
                    if GhostState.savedAnimator == nil then
                        GhostState.savedAnimator = { anim = anim, parent = anim.Parent }
                    end
                    anim.Parent = nil
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            -- ⭐ ghost ON kalau: toggle manual ATAU Auto Throw nyala
            local wantOn = Shared and (Shared.GhostMode_Enabled == true
                or Shared.AutoThrow_Enabled == true)

            if wantOn and not GhostState.enabled then
                pcall(ghostEnable)
            elseif not wantOn and GhostState.enabled then
                pcall(ghostDisable)
            end

            if GhostState.enabled then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                    if GhostState.clone and not GhostState.clone.Parent then
                        pcall(ghostCreateClone, char)
                    end
                    if GhostState.clone and GhostState.clone.Parent
                        and hrp.Transparency < 1 then
                        pcall(ghostHide, char)
                    end
                                        -- cabut Animator SETIAP kali ada (jangan cek savedAnimator == nil)
                    local humNow = char:FindFirstChildOfClass("Humanoid")
                    if humNow then
                        local anNow = humNow:FindFirstChildOfClass("Animator")
                        if anNow then
                            pcall(function()
                                for _, t in ipairs(anNow:GetPlayingAnimationTracks()) do
                                    t:Stop(0)
                                end
                            end)
                            if GhostState.savedAnimator == nil then
                                GhostState.savedAnimator = { anim = anNow, parent = anNow.Parent }
                            end
                            anNow.Parent = nil
                        end
                    end
                end
                ghostHideGuis()
                ghostCamToClone()
            end
        end
    end)
end

-- ============================================================
-- FEATURES.INIT
-- ============================================================
function Features.Init(sharedState)
    Shared = sharedState

    -- ⭐ update _G refs SEKARANG (Shared udah beneran ada)
    _G.VRILZ_Shared = Shared
    _G.VRILZ_UI_Shared = Shared

    if not Features._antiAFKStarted then
        Features._antiAFKStarted = true
        Features.startAntiAFK()
    end

    if not Features._autoThrowStarted then
        Features._autoThrowStarted = true
        pcall(initAutoThrow)
    end
                if not Features._autoShopStarted then
        Features._autoShopStarted = true
        pcall(initAutoShop)
    end

    -- ⭐ GHOST MODE
    if not Features._ghostStarted then
        Features._ghostStarted = true
        pcall(initGhostMode)
    end
end
    
_G.VRILZ_Features = Features

return Features
