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
-- 🎯 AUTO THROW SYSTEM (AUTO STEAL STYLE — REMOTE BASED)
-- Sama persis fungsinya dengan throw food.txt:
--   paksa posisi → Throw_Start → Throw_Resolve(power) → Throw_Complete
-- ═══════════════════════════════════════════════════════════
local function initAutoThrow()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- ═══ KONFIGURASI STEAL (dari throw food.txt) ═══
    local STEAL_POS      = CFrame.new(-2, 6, -27)      -- posisi paksa karakter
    local STEAL_POWER    = 0.9731334256126336          -- power resolve
    local STEAL_INTERVAL = 0.75                        -- jeda antar siklus
    local KNOCKBACK_TOL  = 1.5                         -- toleransi geser posisi

    local ThrowState = {
        autoThrow = false,
        autoBest  = false,          -- dibiarkan biar UI lama gak error
        tapPoint  = 0.93,
        unequipDelay = 0.3,
        tpDelay   = 0.5,
        marker    = nil,
        lastTap   = 0,
        revealCache = setmetatable({}, { __mode = "k" }),
        camPinned = false,
    }

    -- ═══ AMBIL REMOTES ═══
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local Throw_Start    = Remotes and Remotes:FindFirstChild("Throw_Start")
    local Throw_Resolve  = Remotes and Remotes:FindFirstChild("Throw_Resolve")
    local Throw_Complete = Remotes and Remotes:FindFirstChild("Throw_Complete")

    -- ═══ HELPER ═══
    local function remotesReady()
        return Throw_Start and Throw_Resolve and Throw_Complete
    end

    local function getHRP()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function forcePosition()
        local hrp = getHRP()
        if not hrp then return false end
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = STEAL_POS
        return true
    end

    -- ═══ LOOP AUTO THROW (AUTO STEAL) ═══
    task.spawn(function()
        local lastThrow = 0
        while true do
            task.wait(0.1)

            if not ThrowState.autoThrow then
                lastThrow = 0
                continue
            end

            if os.clock() - lastThrow < STEAL_INTERVAL then continue end

            if not remotesReady() then
                if Shared and Shared.Notify then
                    Shared.Notify("Auto Steal", "Throw remotes tidak ditemukan.", "error")
                end
                ThrowState.autoThrow = false
                if Shared then Shared.AutoThrow_Enabled = false end
                continue
            end

            -- 1) Paksa posisi ke titik steal
            forcePosition()

            -- 2) Urutan remote — sama persis throw food.txt
            pcall(function() Throw_Start:InvokeServer() end)
            task.wait(0.1)
            pcall(function() Throw_Resolve:InvokeServer(STEAL_POWER) end)
            task.wait(0.1)
            pcall(function() Throw_Complete:InvokeServer() end)
            task.wait(0.1)

            -- 3) Reset kamera ke karakter
            local cam = Workspace.CurrentCamera
            local char = LocalPlayer.Character
            if cam and char then
                cam.CameraType = Enum.CameraType.Custom
                cam.CameraSubject = char:FindFirstChildOfClass("Humanoid")
            end

            task.wait(0.4) -- durasi status "STEALING..." (sama kayak asli)
            lastThrow = os.clock()
        end
    end)

    -- ═══ ANTI-KNOCKBACK (Heartbeat — sama kayak throw food.txt) ═══
    RunService.Heartbeat:Connect(function()
        if not ThrowState.autoThrow then return end
        local hrp = getHRP()
        if not hrp then return end
        if (hrp.Position - STEAL_POS.Position).Magnitude > KNOCKBACK_TOL then
            hrp.CFrame = STEAL_POS
        end
    end)

    -- ═══ SYNC FLAG ═══
    task.spawn(function()
        while true do
            task.wait(0.3)
            ThrowState.autoThrow = Shared and Shared.AutoThrow_Enabled == true
            -- autoBest/tapPoint dibiarkan sinkron biar UI lama gak error
            ThrowState.autoBest  = Shared and Shared.AutoBestThrow_Enabled == true
            ThrowState.tapPoint  = (Shared and Shared.TapPoint_Percent or 93) / 100
            ThrowState.unequipDelay = (Shared and Shared.UnequipDelay_Seconds) or 0.5
            ThrowState.tpDelay   = (Shared and Shared.TpDelay_Seconds) or 0.6
        end
    end)

    -- ═══════════════════════════════════════════════════════════
    -- 🎥 CAMERA LOCK (tetap sama, dipakai Ghost Mode)
    -- ═══════════════════════════════════════════════════════════
    local camera = Workspace.CurrentCamera
    local camAnchor = nil
    local savedSubject = nil
    local savedCameraType = nil
    local savedCamMode = nil

    local BIND_HARD = "VRILZ_CamPin_Hard"
    local BASE_POS   = Vector3.new(2.23, 6.01, 20.29)
    local CAM_OFFSET = Vector3.new(0, 6, 14)

    local function getLockTarget()
        local ghost = Workspace:FindFirstChild(LocalPlayer.Name .. "_Ghost")
        if ghost then
            local ghostHRP = ghost:FindFirstChild("HumanoidRootPart")
            if ghostHRP then return ghostHRP.Position end
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
        local target = getLockTarget()
        if not target or typeof(target) ~= "Vector3" then target = BASE_POS end
        a.CFrame = CFrame.new(target)
        a.Parent = Workspace
        return a
    end

    local function hardStep()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end
        local target = getLockTarget()
        cam.CFrame = CFrame.lookAt(target + CAM_OFFSET, target)
        if camAnchor and camAnchor.Parent and cam.CameraSubject ~= camAnchor then
            cam.CameraSubject = camAnchor
        end
    end

    local function startCamPin()
        if ThrowState.camPinned then return end
        ThrowState.camPinned = true
        if camAnchor then pcall(function() camAnchor:Destroy() end) end
        camAnchor = createCamAnchor()
        savedSubject    = camera.CameraSubject
        savedCameraType = camera.CameraType
        savedCamMode    = LocalPlayer.CameraMode
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        RunService:BindToRenderStep(BIND_HARD, Enum.RenderPriority.Last.Value + 10, hardStep)
    end

    local function stopCamPin()
        if not ThrowState.camPinned then return end
        ThrowState.camPinned = false
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        if camAnchor then
            pcall(function() camAnchor:Destroy() end)
            camAnchor = nil
        end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if savedCamMode then LocalPlayer.CameraMode = savedCamMode end
        if savedCameraType then camera.CameraType = savedCameraType end
        if savedSubject then
            camera.CameraSubject = savedSubject
        elseif hum then
            camera.CameraSubject = hum
        end
        savedSubject, savedCameraType, savedCamMode = nil, nil, nil
    end

    -- ═══════════════════════════════════════════════════════════
    -- 🧊 ANIMATION BLOCK (sembunyiin karakter)
    -- ═══════════════════════════════════════════════════════════
    local savedTransparency = {}

    local function hideCharacter(char)
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                if savedTransparency[d] == nil then
                    savedTransparency[d] = d.Transparency
                end
                d.Transparency = 1
                d.LocalTransparencyModifier = 1
            elseif d:IsA("Decal") then
                if savedTransparency[d] == nil then
                    savedTransparency[d] = d.Transparency
                end
                d.Transparency = 1
            end
        end
    end

    local function showCharacter(char)
        if not char then return end
        for d, t in pairs(savedTransparency) do
            if d and d.Parent then
                d.Transparency = t
                d.LocalTransparencyModifier = 0
            end
        end
        savedTransparency = {}
    end

    -- ═══════════════════════════════════════════════════════════
    -- 🔄 TRANSISI ON/OFF
    -- ═══════════════════════════════════════════════════════════
    task.spawn(function()
        local wasOn = false
        while true do
            task.wait(0.1)
            local isOn = ThrowState.autoThrow

            if isOn and not wasOn then
                hideCharacter(LocalPlayer.Character)
                startCamPin()
            elseif not isOn and wasOn then
                showCharacter(LocalPlayer.Character)
                stopCamPin()
            end

            if isOn and LocalPlayer.Character then
                for _, d in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if d:IsA("BasePart") and d.Transparency < 1 then
                        d.Transparency = 1
                    end
                end
            end

            wasOn = isOn
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        if ThrowState.autoThrow then
            if camAnchor then
                pcall(function() camAnchor:Destroy() end)
                camAnchor = nil
            end
            ThrowState.camPinned = false
            hideCharacter(newChar)
            startCamPin()
        else
            showCharacter(newChar)
        end
    end)

    -- ═══ EXPOSE ═══
    Features.SetAutoThrow = function(on)
        on = on == true
        if Shared then Shared.AutoThrow_Enabled = on end
        ThrowState.autoThrow = on
    end

    if Shared then
        Shared.SetAutoThrow_Ref = Features.SetAutoThrow
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

    -- ⭐ PRIORITY LEBIH TINGGI DARI hardStep (Last+10) BIAR NIMPA CINEMATIC GAME
    RunService:BindToRenderStep("VRILZ_GhostCamOverride",
        Enum.RenderPriority.Last.Value + 15, function()
            if not GhostState.enabled then return end
            local SharedNow = Shared
            if not SharedNow then return end
            if not (SharedNow.GhostMode_Enabled or SharedNow.AutoThrow_Enabled) then return end
            
            -- ⭐ PAKSA KAMERA NEMPEL KE CLONE, ABISIN CINEMATIC GAME
            local cam = Workspace.CurrentCamera
            local cloneHRP = GhostState.clone and GhostState.clone:FindFirstChild("HumanoidRootPart")
            if cam and cloneHRP then
                cam.CameraType = Enum.CameraType.Scriptable -- Paksa Scriptable
                local target = cloneHRP.Position
                cam.CFrame = CFrame.lookAt(target + Vector3.new(0, 6, 14), target)
                cam.CameraSubject = cloneHRP -- Paksa subject ke clone
            end
        end)
    -- pengawal Animator: jalan tiap 0.05s, tidak peduli transparency
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
