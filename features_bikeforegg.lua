-- ============================================================
-- VRILZHUB FEATURES — NAME GAME v1.0 — FULL FIXED v8
-- ON  : cinematic/animasi 0% keliatan (kamera nempel base + ghost)
-- OFF : INSTAN balik normal ke karakter (enforcer lawan game)
-- v8  : TANPA HOOK __namecall — pakai layer priority tertinggi
-- ============================================================

local Features = {}
local Shared = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- ANTI-AFK — gak ganggu throw
-- ============================================================
function Features.startAntiAFK()
    if Features._antiAFKStarted then return end
    Features._antiAFKStarted = true

    local VirtualUser = game:GetService("VirtualUser")
    if not Shared then Shared = {} end
    if Shared.AntiAFK_Enabled == nil then Shared.AntiAFK_Enabled = true end

    local _actionBusy = false

    local function isAnyFeatureBusy()
        if Shared and (Shared.AutoThrow_Enabled or Shared.AutoBestThrow_Enabled) then
            return true
        end
        return false
    end

    local function doAntiAFKAction()
        if Shared.AntiAFK_Enabled == false then return end
        if _actionBusy then return end
        _actionBusy = true

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(0, 0))
            task.wait(0.05)
            VirtualUser:Button2Up(Vector2.new(0, 0))
        end)

        if not isAnyFeatureBusy() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not hum.SeatPart and not hum.PlatformStand then
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
                local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h2 and not h2.SeatPart then
                    pcall(function() h2:Move(Vector3.new(0,0,0), false) end)
                end
            end
        end

        if not isAnyFeatureBusy() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not hum.SeatPart and not hum.PlatformStand then
                pcall(function() hum.Jump = true end)
            end
        end

        if type(mousemoverel) == "function" then
            pcall(function() mousemoverel(10, 10) end)
            task.wait(0.05)
            pcall(function() mousemoverel(-10, -10) end)
        end

        task.delay(0.3, function() _actionBusy = false end)
    end

    LocalPlayer.Idled:Connect(function()
        task.spawn(function()
            if Shared.AntiAFK_Enabled == false then return end
            doAntiAFKAction()
        end)
    end)

    task.spawn(function()
        task.wait(20)
        while true do
            task.wait(60)
            if Shared.AntiAFK_Enabled == false then continue end
            doAntiAFKAction()
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        _actionBusy = false
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 AUTO THROW SYSTEM — v8 (TANPA HOOK, layer priority)
-- ═══════════════════════════════════════════════════════════
local function initAutoThrow()
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local ThrowState = {
        autoThrow = false,
        autoBest = false,
        tapPoint = 0.93,
        unequipDelay = 0.3,
        tpDelay = 0.5,
        marker = nil,
        lastTap = 0,
        revealCache = setmetatable({}, { __mode = "k" }),
        camPinned = false,
    }

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

    local function getEquippedAnimal()
        local char = LocalPlayer.Character
        if not char then return nil end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool:GetAttribute("AnimalId") ~= nil then
            return tool
        end
        return nil
    end

    local function isThrowBusy()
        local busy = false
        pcall(function() busy = (ClientState and ClientState.Busy) or false end)
        local active = false
        pcall(function()
            active = (ThrowController and ThrowController.IsActive
                and ThrowController.IsActive()) or false
        end)
        return busy or active or getEquippedAnimal() ~= nil
    end

    local function tapSpace()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        end)
        task.delay(0.03, function()
            pcall(function()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end)
    end

    local function unequipTools()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        if not getEquippedAnimal() then return nil end
        pcall(function() hum:UnequipTools() end)
        return true
    end

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

    -- ═══ Marker tracker ═══
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

    -- ═══ Reveal screen handler ═══
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
                        tapSpace()
                    end
                else
                    ThrowState.revealCache[k] = nil
                end
            end
        end
    end)

    -- ═══ Auto best tap ═══
    RunService.RenderStepped:Connect(function()
        if not ThrowState.autoBest then return end
        local m = ThrowState.marker
        if not m or not m.Parent then return end
        if os.clock() - ThrowState.lastTap < 1.5 then return end
        local norm = 1 - m.Position.Y.Scale
        if norm >= ThrowState.tapPoint then
            ThrowState.lastTap = os.clock()
            tapSpace()
        end
    end)

    -- ═══ LOOP AUTO THROW ═══
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
            if not ThrowState.autoThrow then continue end
            pcall(ThrowController.Start)
            task.wait(3)
        end
    end)

    -- ═══ Sync flag ═══
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
    -- 🎥 CAMERA LOCK (saat ON)
    -- ═══════════════════════════════════════════════════════════
    local camAnchor = nil

    local BIND_HARD = "VRILZ_CamPin_Hard"
    local BIND_OFF  = "VRILZ_OffEnforce"
    local BIND_SUP  = "VRILZ_PostOffSuppress"
    local BIND_CINE = "VRILZ_CineKill"
    local BIND_BAR  = "VRILZ_BarKill"
    local BASE_POS   = Vector3.new(2.23, 6.01, 20.29)
    local CAM_OFFSET = Vector3.new(0, 6, 14)

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
        local target = getLockTarget()
        if not target or typeof(target) ~= "Vector3" then
            target = BASE_POS
        end
        a.CFrame = CFrame.new(target)
        a.Parent = Workspace
        return a
    end

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
        if camAnchor and camAnchor.Parent then
            if cam.CameraSubject ~= camAnchor then
                cam.CameraSubject = camAnchor
            end
        end
    end

    local function startCamPin()
        if ThrowState.camPinned then return end
        ThrowState.camPinned = true
        if camAnchor then pcall(function() camAnchor:Destroy() end) end
        camAnchor = createCamAnchor()
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        RunService:BindToRenderStep(BIND_HARD, Enum.RenderPriority.Last.Value + 10, hardStep)
    end

    -- ═══ INSTANT RESTORE — OFF = langsung normal ═══
    local function instantRestoreNormal()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)

        local cam = Workspace.CurrentCamera
        if cam then
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
            end
            cam.CameraType = Enum.CameraType.Custom
            if hum then
                cam.CameraSubject = hum
            end
        end

        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
            if ok and tracks then
                for _, t in ipairs(tracks) do
                    pcall(function() t:Stop(0) end)
                end
            end
        end

        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.LocalTransparencyModifier = 0
                end
            end
        end

        if camAnchor then
            pcall(function() camAnchor:Destroy() end)
            camAnchor = nil
        end
        ThrowState.camPinned = false

        if hum and hum.Health > 0 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end

    -- ═══ OFF ENFORCER — kamera dipaksa ngikutin char (10s) ═══
    local function startOffEnforcer()
        pcall(function() RunService:UnbindFromRenderStep(BIND_OFF) end)
        RunService:BindToRenderStep(BIND_OFF,
            Enum.RenderPriority.Last.Value + 11, function()
                if ThrowState.autoThrow then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local cam = Workspace.CurrentCamera
                if not (cam and hum) then return end
                if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                end
                if cam.CameraType ~= Enum.CameraType.Custom then
                    cam.CameraType = Enum.CameraType.Custom
                end
                if cam.CameraSubject ~= hum then
                    cam.CameraSubject = hum
                end
            end)

        task.spawn(function()
            local deadline = os.clock() + 10
            while os.clock() < deadline do
                task.wait(0.25)
                if ThrowState.autoThrow then break end
                if not isThrowBusy() then break end
            end
            pcall(function() RunService:UnbindFromRenderStep(BIND_OFF) end)
        end)
    end

    -- ═══════════════════════════════════════════════════════════
    -- ⭐ v8: BAR KILLER — bunuh bar hitam cinematic
    -- ═══════════════════════════════════════════════════════════
    local function killLetterboxBars()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local cam = Workspace.CurrentCamera
        if not pg or not cam then return end
        local vp = cam.ViewportSize
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, d in ipairs(gui:GetDescendants()) do
                    if (d:IsA("Frame") or d:IsA("ImageLabel")) and d.Visible then
                        local okPos, pos = pcall(function() return d.AbsolutePosition end)
                        local okSize, size = pcall(function() return d.AbsoluteSize end)
                        if okPos and okSize and size.Y > 0 then
                            local fullW   = size.X >= vp.X * 0.9
                            local thinH   = size.Y <= vp.Y * 0.25 and size.Y >= vp.Y * 0.02
                            local atTop   = pos.Y <= 4
                            local atBot   = (pos.Y + size.Y) >= vp.Y - 4
                            local dark    = true
                            if d:IsA("Frame") then
                                local c = d.BackgroundColor3
                                dark = (c.R + c.G + c.B) < 0.35
                                    and d.BackgroundTransparency < 0.5
                            end
                            if fullW and thinH and (atTop or atBot) and dark then
                                d.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end

    -- ═══════════════════════════════════════════════════════════
    -- ⭐⭐⭐ v8: CINEMATIC KILLER — aktif CUMA pas ON
    -- Priority Last+999 = jalan PALING AKHIR tiap frame
    -- (setelah semua script game selesai update animasi)
    -- Tanpa hook: pakai AdjustWeight(0.0001) supaya track gak auto-stop
    -- ═══════════════════════════════════════════════════════════
    pcall(function() RunService:UnbindFromRenderStep(BIND_CINE) end)
    RunService:BindToRenderStep(BIND_CINE,
        Enum.RenderPriority.Last.Value + 999, function()
            if not (Shared and Shared.AutoThrow_Enabled) then return end
            local char = LocalPlayer.Character
            if not char then return end

            -- 1) Animasi di-suppress (weight hampir nol, tapi tetap playing)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if animator then
                local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
                if ok and tracks then
                    for _, t in ipairs(tracks) do
                        pcall(function()
                            if t.Weight > 0 then
                                t:AdjustWeight(0.0001, 0)
                            end
                        end)
                    end
                end
            end

            -- 2) Sembunyikan semua part karakter
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") and d.LocalTransparencyModifier ~= 1 then
                    d.LocalTransparencyModifier = 1
                end
            end

            -- 3) Zero velocity + MoveDirection → cegah char geser/rebah
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp.AssemblyLinearVelocity.Magnitude > 0.01 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
                if hrp.AssemblyAngularVelocity.Magnitude > 0.01 then
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
            if hum and hum.MoveDirection.Magnitude > 0.01 then
                pcall(function() hum:Move(Vector3.zero, false) end)
            end
        end)

    -- ═══════════════════════════════════════════════════════════
    -- ⭐ v8: BAR KILLER per-frame — priority Last+998
    -- ═══════════════════════════════════════════════════════════
    pcall(function() RunService:UnbindFromRenderStep(BIND_BAR) end)
    RunService:BindToRenderStep(BIND_BAR,
        Enum.RenderPriority.Last.Value + 998, function()
            if not (Shared and Shared.AutoThrow_Enabled) then return end
            pcall(killLetterboxBars)
        end)

    -- ═══════════════════════════════════════════════════════════
    -- ⭐⭐⭐ v8: POST-OFF SUPPRESSOR — priority Last+997
    -- Jalan max 8s setelah OFF:
    --   1. Animasi ditahan weight ~0 SELAMA game masih busy
    --   2. Tap Space → cinematic di-skip cepet
    --   3. Bar hitam dibunuh tiap 0.15s
    --   4. Game idle → bersihin semua bekas → lepas → NORMAL TOTAL
    -- ═══════════════════════════════════════════════════════════
    local function startPostOffSuppressor()
        pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)

        RunService:BindToRenderStep(BIND_SUP,
            Enum.RenderPriority.Last.Value + 997, function()
                if ThrowState.autoThrow then return end
                if not isThrowBusy() then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then
                    local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
                    if ok and tracks then
                        for _, t in ipairs(tracks) do
                            pcall(function()
                                if t.Weight > 0 then
                                    t:AdjustWeight(0.0001, 0)
                                end
                            end)
                        end
                    end
                end
            end)

        task.spawn(function()
            local deadline = os.clock() + 8
            local lastTap, lastNudge = 0, 0
            while os.clock() < deadline do
                task.wait(0.15)
                if ThrowState.autoThrow then break end

                pcall(killLetterboxBars)

                if isThrowBusy() then
                    local tapped = false
                    for k in pairs(ThrowState.revealCache) do
                        if k.Parent and k.TextTransparency < 0.9 then
                            ThrowState.revealCache[k] = nil
                            tapSpace()
                            tapped = true
                        end
                    end
                    if not tapped and os.clock() - lastTap > 1.2 then
                        lastTap = os.clock()
                        tapSpace()
                    end
                    if os.clock() - lastNudge > 0.5 then
                        lastNudge = os.clock()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            pcall(function()
                                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                            end)
                        end
                    end
                else
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local animator = hum and hum:FindFirstChildOfClass("Animator")
                    if animator then
                        local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
                        if ok and tracks then
                            for _, t in ipairs(tracks) do
                                pcall(function() t:Stop(0) end)
                            end
                        end
                    end
                    if char then
                        for _, d in ipairs(char:GetDescendants()) do
                            if d:IsA("BasePart") then
                                d.LocalTransparencyModifier = 0
                            end
                        end
                    end
                    pcall(killLetterboxBars)
                    if hum and hum.Health > 0 then
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end)
                    end
                    break
                end
            end
            pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)
        end)
    end

    -- ═══ Transisi ON/OFF — v8 ═══
    task.spawn(function()
        local wasOn = false
        while true do
            task.wait(0.1)
            local on = ThrowState.autoThrow
            if on and not wasOn then
                pcall(function() RunService:UnbindFromRenderStep(BIND_OFF) end)
                pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)
                startCamPin()
            elseif not on and wasOn then
                if Shared then Shared.GhostMode_Enabled = false end
                instantRestoreNormal()
                startOffEnforcer()
                startPostOffSuppressor()
            end
            wasOn = on
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if ThrowState.autoThrow then
            ThrowState.camPinned = false
            if camAnchor then
                pcall(function() camAnchor:Destroy() end)
                camAnchor = nil
            end
            startCamPin()
        end
    end)

    -- ═══ Sync instan dari UI ═══
    Features.ForceSyncThrow = function()
        ThrowState.autoThrow = Shared.AutoThrow_Enabled == true
        ThrowState.autoBest = Shared.AutoBestThrow_Enabled == true
    end

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

    task.spawn(function()
        while true do
            task.wait(1.5)
            if State.autoBuy then pcall(runShopCycle) end
        end
    end)

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
-- 👻 GHOST MODE v6
-- ============================================================

local GHOST_CLONE_POS = Vector3.new(2.23, 6.01, 20.29) + Vector3.new(0, 3, 0)

local GhostState = {
    enabled      = false,
    clone        = nil,
    saved        = {},
    savedDisplay = nil,
    savedGuis    = {},
}

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

    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.PlatformStand      = true
        pcall(function() hum.EvaluateStateMachine = false end)
    end

    for _, cls in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
        local src = char:FindFirstChildOfClass(cls)
        if src then
            local old = clone:FindFirstChildOfClass(cls)
            if old then old:Destroy() end
            src:Clone().Parent = clone
        end
    end

    clone:PivotTo(CFrame.new(GHOST_CLONE_POS))

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.Massless = true
        end
    end

    clone.Name = char.Name .. "_Ghost"
    clone.Parent = Workspace
    GhostState.clone = clone
end

local function ghostCamToClone()
    local cam = Workspace.CurrentCamera
    local cloneHRP = GhostState.clone and GhostState.clone:FindFirstChild("HumanoidRootPart")
    if not (cam and cloneHRP) then return end

    if cam.CameraType ~= Enum.CameraType.Scriptable then
        cam.CameraType = Enum.CameraType.Scriptable
    end
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
    local cam = Workspace.CurrentCamera
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if cam then
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
        cam.CameraType = Enum.CameraType.Custom
        if hum then
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

    RunService:BindToRenderStep("VRILZ_GhostCamOverride",
        Enum.RenderPriority.Last.Value + 5, function()
            if not GhostState.enabled then return end
            if not (Shared and (Shared.GhostMode_Enabled or Shared.AutoThrow_Enabled)) then return end
            ghostCamToClone()
        end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            local wantOn = Shared and (Shared.GhostMode_Enabled == true
                or Shared.AutoThrow_Enabled == true)
            if wantOn and not GhostState.enabled then
                pcall(ghostEnable)
            elseif not wantOn and GhostState.enabled then
                pcall(ghostDisable)
            end

            if not wantOn then
                local busy = false
                pcall(function()
                    local cs = Shared and Shared.ClientState_Ref
                    busy = (cs and cs.Busy) or false
                end)
                local tc = Shared and Shared.ThrowController_Ref
                local active = false
                pcall(function() active = tc and tc.IsActive and tc.IsActive() end)

                if not (busy or active) then
                    local cam = Workspace.CurrentCamera
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if cam and hum then
                        if cam.CameraType ~= Enum.CameraType.Custom then
                            cam.CameraType = Enum.CameraType.Custom
                        end
                        if cam.CameraSubject ~= hum then
                            cam.CameraSubject = hum
                        end
                    end
                    local anchor = Workspace:FindFirstChild("VRILZ_CamAnchor")
                    if anchor then
                        pcall(function() anchor:Destroy() end)
                    end
                end
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

    if not Features._ghostStarted then
        Features._ghostStarted = true
        pcall(initGhostMode)
    end
end

_G.VRILZ_Features = Features

return Features
