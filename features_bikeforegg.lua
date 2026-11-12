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
-- 🎯 AUTO THROW SYSTEM
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

    -- ═══ HELPER: ambil ThrowController, ClientState, TrainingController ═══
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

    -- ═══ HELPER: ambil animal tool yang sedang dipegang ═══
    local function getEquippedAnimal()
        local char = LocalPlayer.Character
        if not char then return nil end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:GetAttribute("AnimalId") ~= nil then
            return tool
        end
        return nil
    end

    -- ═══ HELPER: unequip tool ═══
    local function unequipTools()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        if not getEquippedAnimal() then return nil end
        pcall(function() hum:UnequipTools() end)
        return true
    end

    -- ═══ HELPER: cari StarterArea & CrossLine ═══
    local function getStarterArea()
        local sa = Workspace:FindFirstChild("StarterArea")
        if not sa then return nil, nil end
        local cl = sa:FindFirstChild("CrossLine")
        local crossZ = cl and cl.Position.Z or (sa.Position.Z + sa.Size.Z / 2)
        return sa, crossZ
    end

    -- ═══ HELPER: cek apakah player sudah di throw area ═══
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

    -- ═══ HELPER: teleport ke throw area ═══
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

    -- ═══ HELPER: cari power meter marker di PlayerGui ═══
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

       -- ═══ HELPER: deteksi teks reveal (case-insensitive) ═══
    local function isRevealText(txt)
        if type(txt) ~= "string" or txt == "" then return false end
        local lower = txt:lower()
        return lower:find("tap to continue", 1, true) ~= nil
            or lower:find("tap to skip", 1, true) ~= nil
            or lower:find("click to continue", 1, true) ~= nil
            or lower:find("click to skip", 1, true) ~= nil
    end

    -- ═══ HELPER: baca isi reveal screen (hasil yang didapat) ═══
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

    -- ═══ HELPER: scan reveal screen ═══
    local function scanRevealScreens()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") and isRevealText(v.Text) then
                ThrowState.revealCache[v] = true
            end
        end
    end

    -- ═══ LOOP: cari marker & reveal screen setiap 0.15s ═══
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

       -- ═══ REVEAL WATCHER v2: baca hasil → notify → skip pakai Spasi ═══
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

                        -- 1) tunggu teks result muncul, terus baca
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

                        -- 2) baru skip
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
    
    -- ═══ RENDER STEPPED: AUTO BEST THROW (tap meter di tapPoint) ═══
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

    -- ═══ LOOP: AUTO THROW (teleport → throw → unequip → skip → ulang) ═══
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

            -- Unequip dulu
            if Shared.UnequipDelay_Seconds and unequipTools() then
                task.wait(Shared.UnequipDelay_Seconds or ThrowState.unequipDelay)
            end

            local busy = ClientState and ClientState.Busy
            local isActive = ThrowController.IsActive and ThrowController.IsActive()
            if busy or isActive or getEquippedAnimal() then
                continue
            end

            -- Teleport kalo belum di area
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp.Anchored and not isInThrowArea(hrp) then
                teleportToThrowArea()
                task.wait(Shared.TpDelay_Seconds or ThrowState.tpDelay)
            end

            -- Throw!
            if ClientState and ClientState.Busy then continue end
            pcall(ThrowController.Start)
            task.wait(3)
        end
    end)

    -- ═══ SYNC STATE DARI SHARED ═══
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

        -- ═══ CAMERA PIN v2 — lock di base, anti-override dari game ═══
    local camera = Workspace.CurrentCamera
    local camAnchor = nil
    local savedSubject = nil
    local savedCameraType = nil

    local BASE_POS  = Vector3.new(2.23, 6.01, 20.29)
    local CAM_POS   = BASE_POS + Vector3.new(0, 6, 14) -- posisi kamera (khusus hard lock)
    local HARD_LOCK = true

    local BIND_SOFT = "VRILZ_CamPin_Soft"
    local BIND_HARD = "VRILZ_CamPin_Hard"

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
        a.CFrame = CFrame.new(BASE_POS)
        a.Parent = Workspace
        return a
    end

    -- SOFT: kamera tetap bisa digerakin mouse, tapi subject dipaksa ke anchor
    local function softStep()
        local cam = Workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Custom then
            cam.CameraType = Enum.CameraType.Custom
        end
        if cam.CameraSubject ~= camAnchor then
            cam.CameraSubject = camAnchor
        end
    end

    -- HARD: kamera dibekukan di titik fix, menang lawan cutscene game
    local LOOK_AT = Vector3.new(2.23, 6.01, 20.29) -- arah pandang kamera (bebas diganti)

    local function hardStep()
        local cam = Workspace.CurrentCamera
        -- blok game yang coba set first-person/lock
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end
        cam.CFrame = CFrame.lookAt(CAM_POS, LOOK_AT)
    end

    local function startCamPin()
        if camAnchor and camAnchor.Parent then return end
        if camAnchor then pcall(function() camAnchor:Destroy() end) end

        camAnchor = createCamAnchor()
        savedSubject    = camera.CameraSubject
        savedCameraType = camera.CameraType

            if HARD_LOCK then
            RunService:BindToRenderStep(BIND_HARD, Enum.RenderPriority.Last.Value + 1, hardStep)
        else
            RunService:BindToRenderStep(BIND_SOFT, Enum.RenderPriority.Camera.Value - 1, softStep)
        end
    end

    local function stopCamPin()
        if not camAnchor then return end
        pcall(function() RunService:UnbindFromRenderStep(BIND_SOFT) end)
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        camera.CameraType = savedCameraType or Enum.CameraType.Custom
        camera.CameraSubject = savedSubject or hum
        savedSubject, savedCameraType = nil, nil
        camAnchor:Destroy()
        camAnchor = nil
    end

    task.spawn(function()
        while true do
            task.wait(0.1)
            if ThrowState.autoThrow then
                if not camAnchor or not camAnchor.Parent then
                    startCamPin()
                elseif not HARD_LOCK then
                    softStep() -- safety net tambahan
                end
            else
                stopCamPin()
            end
        end
    end)

    -- Respawn safety: Roblox auto-reset subject pas character baru
    LocalPlayer.CharacterAdded:Connect(function()
        task.delay(0.5, function()
            if ThrowState.autoThrow then startCamPin() end
        end)
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
end
    
_G.VRILZ_Features = Features

return Features
