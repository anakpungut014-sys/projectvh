-- ============================================================
-- VRILZHUB FEATURES — NAME GAME v1.1 — CLEAN & FIXED
-- ============================================================

local Features = {}
local Shared = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- ANTI-AFK
-- ============================================================
function Features.startAntiAFK()
    if Features._antiAFKStarted then return end
    Features._antiAFKStarted = true
    local VirtualUser = game:GetService("VirtualUser")
    if not Shared then Shared = {} end
    if Shared.AntiAFK_Enabled == nil then Shared.AntiAFK_Enabled = true end
    local _actionBusy = false
    local function isAnyFeatureBusy()
        return Shared and (Shared.AutoThrow_Enabled or Shared.AutoBestThrow_Enabled)
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

-- ============================================================
-- AUTO THROW
-- ============================================================
local function initAutoThrow()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ThrowState = {
        autoThrow = false, autoBest = false, tapPoint = 0.93, unequipDelay = 0.3, tpDelay = 0.5,
        marker = nil, lastTap = 0, revealCache = setmetatable({}, { __mode = "k" }), camPinned = false,
    }
    local savedTransparency = {}
    local savedConstraints = {}
    local savedAnimWeights = {}

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
        if tool and tool:GetAttribute("AnimalId") ~= nil then return tool end
        return nil
    end

    local function isThrowBusy()
        local busy = false
        pcall(function() busy = (ClientState and ClientState.Busy) or false end)
        local active = false
        pcall(function()
            active = (ThrowController and ThrowController.IsActive and ThrowController.IsActive()) or false
        end)
        return busy or active or getEquippedAnimal() ~= nil
    end

    local function tapSpace()
        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
        task.delay(0.03, function()
            pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
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
            if v.Name == "Marker" and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == "Meter" then
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
            if d:IsA("TextLabel") and d.Visible ~= false and d.Text ~= "" and not isRevealText(d.Text) then
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

    local function saveAndHideCharacter(char)
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                if savedTransparency[d] == nil then savedTransparency[d] = d.Transparency end
                if d.Transparency ~= 1 then d.Transparency = 1 end
                d.LocalTransparencyModifier = 1
            end
        end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("AnimationConstraint") then
                if savedConstraints[d] == nil then
                    savedConstraints[d] = { enabled = d.Enabled, transform = d.Transform }
                end
                d.Transform = CFrame.identity
                d.Enabled = false
            end
        end
    end

    local function restoreCharacter(char)
        for d, t in pairs(savedTransparency) do
            if d and d.Parent then
                d.Transparency = t
                d.LocalTransparencyModifier = 0
            end
        end
        savedTransparency = {}
        for d, s in pairs(savedConstraints) do
            if d and d.Parent then
                d.Enabled = s.enabled
                d.Transform = s.transform
            end
        end
        savedConstraints = {}
        for track, w in pairs(savedAnimWeights) do
            if track then pcall(function() track:AdjustWeight(w, 0) end) end
        end
        savedAnimWeights = {}
    end

    local function suppressAnimations(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
        if not ok or not tracks then return end
        for _, t in ipairs(tracks) do
            pcall(function()
                local w = t.Weight
                if type(w) == "number" and w > 0 then
                    if savedAnimWeights[t] == nil then savedAnimWeights[t] = w end
                    t:AdjustWeight(0.0001, 0)
                end
            end)
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.15)
            if ThrowState.autoBest then
                local m = ThrowState.marker
                if m and not m.Parent then ThrowState.marker = findMeterMarker()
                elseif not m then ThrowState.marker = findMeterMarker() end
            end
            if ThrowState.autoThrow then scanRevealScreens() end
        end
    end)

    task.spawn(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        pg.DescendantAdded:Connect(function(d)
            task.defer(function()
                if d:IsA("TextLabel") and isRevealText(d.Text) then ThrowState.revealCache[d] = true end
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
                        if k.Parent then result = readRevealResult(k) end
                        if result and Shared and Shared.Notify and (result ~= lastResult or os.clock() - lastResultTime > 3) then
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
            if busy or isActive or getEquippedAnimal() then continue end
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

    local camAnchor = nil
    local BIND_HARD, BIND_CINE, BIND_BAR, BIND_OFF, BIND_SUP = "VRILZ_CamPin_Hard", "VRILZ_CineKill", "VRILZ_BarKill", "VRILZ_OffEnforce", "VRILZ_PostOffSuppress"
    local BASE_POS, CAM_OFFSET = Vector3.new(2.23, 6.01, 20.29), Vector3.new(0, 6, 14)

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
        a.Name, a.Size, a.Transparency, a.CanCollide = "VRILZ_CamAnchor", Vector3.new(1, 1, 1), 1, false
        a.Anchored, a.CanQuery, a.CanTouch, a.Massless = true, false, false, true
        local target = getLockTarget()
        if not target or typeof(target) ~= "Vector3" then target = BASE_POS end
        a.CFrame = CFrame.new(target)
        a.Parent = Workspace
        return a
    end

    local function hardStep()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
        if cam.CameraType ~= Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Scriptable end
        local target = getLockTarget()
        cam.CFrame = CFrame.lookAt(target + CAM_OFFSET, target)
        if camAnchor and camAnchor.Parent and cam.CameraSubject ~= camAnchor then cam.CameraSubject = camAnchor end
    end

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
                            local fullW, thinH = size.X >= vp.X * 0.9, size.Y <= vp.Y * 0.25 and size.Y >= vp.Y * 0.02
                            local atTop, atBot = pos.Y <= 4, (pos.Y + size.Y) >= vp.Y - 4
                            local dark = true
                            if d:IsA("Frame") then
                                local c = d.BackgroundColor3
                                dark = (c.R + c.G + c.B) < 0.35 and d.BackgroundTransparency < 0.5
                            end
                            if fullW and thinH and (atTop or atBot) and dark then d.Visible = false end
                        end
                    end
                end
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

    local function stopCamPin()
        pcall(function() RunService:UnbindFromRenderStep(BIND_HARD) end)
        if camAnchor then pcall(function() camAnchor:Destroy() end) camAnchor = nil end
        ThrowState.camPinned = false
    end

    local function startCineKiller()
        pcall(function() RunService:UnbindFromRenderStep(BIND_CINE) end)
        RunService:BindToRenderStep(BIND_CINE, Enum.RenderPriority.Last.Value + 999, function()
            local char = LocalPlayer.Character
            if not char then return end
            saveAndHideCharacter(char)
            suppressAnimations(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp.AssemblyLinearVelocity.Magnitude > 0.01 then hrp.AssemblyLinearVelocity = Vector3.zero end
                if hrp.AssemblyAngularVelocity.Magnitude > 0.01 then hrp.AssemblyAngularVelocity = Vector3.zero end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0.01 then pcall(function() hum:Move(Vector3.zero, false) end) end
        end)
    end

    local function stopCineKiller()
        pcall(function() RunService:UnbindFromRenderStep(BIND_CINE) end)
        local char = LocalPlayer.Character
        if char then pcall(restoreCharacter, char) end
    end

    local function startBarKiller()
        pcall(function() RunService:UnbindFromRenderStep(BIND_BAR) end)
        RunService:BindToRenderStep(BIND_BAR, Enum.RenderPriority.Last.Value + 998, function() pcall(killLetterboxBars) end)
    end

    local function stopBarKiller() pcall(function() RunService:UnbindFromRenderStep(BIND_BAR) end) end

    local function instantRestoreNormal()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char then pcall(restoreCharacter, char) end
        stopCamPin()
        local cam = Workspace.CurrentCamera
        if cam then
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
            cam.CameraType = Enum.CameraType.Custom
            if hum then cam.CameraSubject = hum end
        end
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
            if ok and tracks then for _, t in ipairs(tracks) do pcall(function() t:Stop(0) end) end end
        end
        if hum and hum.Health > 0 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
    end

    local function startOffEnforcer()
        pcall(function() RunService:UnbindFromRenderStep(BIND_OFF) end)
        RunService:BindToRenderStep(BIND_OFF, Enum.RenderPriority.Last.Value + 11, function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local cam = Workspace.CurrentCamera
            if not (cam and hum) then return end
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
            if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
            if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
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

    local function startPostOffSuppressor()
        pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)
        RunService:BindToRenderStep(BIND_SUP, Enum.RenderPriority.Last.Value + 997, function()
            if ThrowState.autoThrow then return end
            if not isThrowBusy() then return end
            local char = LocalPlayer.Character
            if char then suppressAnimations(char) end
        end)
        task.spawn(function()
            local deadline = os.clock() + 8
            local lastTap, lastNudge = 0, 0
            local idleTicks = 0
            while os.clock() < deadline do
                task.wait(0.15)
                if ThrowState.autoThrow then break end
                pcall(killLetterboxBars)
                if isThrowBusy() then
                    idleTicks = 0
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
                        if hum and hum.Health > 0 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
                    end
                else
                    idleTicks = idleTicks + 1
                    if idleTicks >= 13 then
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local animator = hum and hum:FindFirstChildOfClass("Animator")
                        if animator then
                            local ok, tracks = pcall(animator.GetPlayingAnimationTracks, animator)
                            if ok and tracks then for _, t in ipairs(tracks) do pcall(function() t:Stop(0) end) end end
                        end
                        if char then pcall(restoreCharacter, char) end
                        pcall(killLetterboxBars)
                        if hum and hum.Health > 0 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
                        break
                    end
                end
            end
            pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)
        end)
    end

    local function setAutoThrow(on)
        on = on == true
        if on == ThrowState.autoThrow then return end
        ThrowState.autoThrow = on
        if on then
            pcall(function() RunService:UnbindFromRenderStep(BIND_OFF) end)
            pcall(function() RunService:UnbindFromRenderStep(BIND_SUP) end)
            startCamPin()
            startCineKiller()
            startBarKiller()
        else
            stopCineKiller()
            stopBarKiller()
            instantRestoreNormal()
            startOffEnforcer()
            startPostOffSuppressor()
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            local wantOn = Shared and Shared.AutoThrow_Enabled == true
            if wantOn ~= ThrowState.autoThrow then pcall(setAutoThrow, wantOn) end
            ThrowState.autoBest = Shared and Shared.AutoBestThrow_Enabled == true
            ThrowState.tapPoint = (Shared and Shared.TapPoint_Percent or 93) / 100
            ThrowState.unequipDelay = (Shared and Shared.UnequipDelay_Seconds) or 0.5
            ThrowState.tpDelay = (Shared and Shared.TpDelay_Seconds) or 0.6
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if LocalPlayer.Character and LocalPlayer.Character ~= newChar then pcall(restoreCharacter, LocalPlayer.Character) end
        savedTransparency, savedConstraints, savedAnimWeights = {}, {}, {}
        if ThrowState.autoThrow then
            ThrowState.camPinned = false
            if camAnchor then pcall(function() camAnchor:Destroy() end) camAnchor = nil end
            startCamPin()
        end
    end)

    Features.ForceSyncThrow = function()
        local wantOn = Shared and Shared.AutoThrow_Enabled == true
        pcall(setAutoThrow, wantOn)
        ThrowState.autoBest = Shared and Shared.AutoBestThrow_Enabled == true
    end
    Features.SetAutoThrow = setAutoThrow
    if Shared then
        Shared.ThrowController_Ref = ThrowController
        Shared.ClientState_Ref = ClientState
        Shared.SetAutoThrow_Ref = setAutoThrow
    end
end

-- ============================================================
-- AUTO BUY + AUTO UPGRADE
-- ============================================================
local function initAutoShop()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local State = { autoBuy = false, autoUpgrade = false, lastBuyNotify = 0, lastUpgradeNotify = 0 }
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
    local FoodsConfig, StandsConfig, Remotes = requireShared("Config", "FoodsConfig"), requireShared("Config", "StandsConfig"), requireShared("Shared", "Remotes")
    local DataController, PlotController = requirePlayerScript("Client", "Controllers", "DataController"), requirePlayerScript("Client", "Controllers", "PlotController")
    local TrainingController, ClientState = requirePlayerScript("Client", "Controllers", "TrainingController"), requirePlayerScript("Client", "Controllers", "ClientState")

    local function isBusy() return ClientState and ClientState.Busy == true end
    local function notifySafe(t, c) if Shared and Shared.Notify then pcall(Shared.Notify, t .. ": " .. c, "info") end end
    local function notifyThrottled(f, t, c, i)
        local n = os.clock()
        if n - (State[f] or 0) < (i or 5) then return end
        State[f] = n
        notifySafe(t, c)
    end
    local function stopTraining()
        if not TrainingController or not TrainingController.IsRunning then return end
        if not (TrainingController.IsRunning and TrainingController.IsRunning()) then return end
        pcall(function() TrainingController.Stop() end)
        local s = os.clock()
        while os.clock() - s < 6 do
            if not (TrainingController.IsRunning and TrainingController.IsRunning()) then break end
            task.wait(0.2)
        end
    end
    local function buildFoodList()
        local l = {}
        if not FoodsConfig then return l end
        local ok, t = pcall(FoodsConfig.CountAll)
        if not ok or type(t) ~= "number" then return l end
        for i = 1, t do
            local g, f = pcall(FoodsConfig.GetAny, i)
            if g and f then
                local lk = false
                pcall(function() lk = FoodsConfig.IsLocked(f.Index) and true or false end)
                if not lk then table.insert(l, { slot = i, food = f }) end
            end
        end
        table.sort(l, function(a, b)
            local ta, tb = a.food.Tier or 0, b.food.Tier or 0
            if ta == tb then return (a.food.Price or 0) > (b.food.Price or 0) end
            return tb < ta
        end)
        return l
    end
    local function isFoodOwned(f)
        if not DataController then return false end
        local ok, o = pcall(function() return DataController:GetPath("OwnedFoods." .. f.Index) == true end)
        return ok and o or false
    end
    local function runShopCycle()
        if not (FoodsConfig and DataController and Remotes) or isBusy() then return end
        local m = 0
        pcall(function() m = DataController:Get("Money") or 0 end)
        for _, e in ipairs(buildFoodList()) do
            if not isFoodOwned(e.food) and (e.food.Price or math.huge) <= m then
                local ok, res = pcall(Remotes.Invoke, "Shop_Buy", e.slot)
                if ok and res and res.Ok then
                    notifyThrottled("lastBuyNotify", "Auto Buy", "Bought " .. tostring(e.food.Name) .. "!", 3)
                    return
                end
            end
        end
    end
    local function tryUpgradeStand()
        if not (Remotes and DataController and StandsConfig) then return nil end
        local l, m = 0, 0
        pcall(function() l = DataController:Get("Stand") or 0; m = DataController:Get("Money") or 0 end)
        local ok, ns = pcall(StandsConfig.Get, l + 1)
        if not ok or not ns or m < (ns.Price or math.huge) then return nil end
        if TrainingController then stopTraining() end
        if isBusy() then return nil end
        local okU, res = pcall(Remotes.Invoke, "Stand_Upgrade")
        local u = okU and res and res.Ok
        if not u and PlotController and PlotController.TeleportToStand then
            pcall(PlotController.TeleportToStand, false)
            task.wait(0.6)
            local ok2, res2 = pcall(Remotes.Invoke, "Stand_Upgrade")
            u = ok2 and res2 and res2.Ok
            res = res2
        end
        if u and res then
            local okN, nst = pcall(StandsConfig.Get, res.NewIndex)
            notifyThrottled("lastUpgradeNotify", "Upgrade", "Upgraded to " .. tostring((okN and nst and nst.Name) or "a new stand") .. "!", 3)
        end
        return u
    end
    task.spawn(function() while true do task.wait(1.5) if State.autoBuy then pcall(runShopCycle) end end end)
    task.spawn(function() while true do task.wait(2) if State.autoUpgrade and not isBusy() and not (Shared and Shared.AutoThrow_Enabled) then pcall(tryUpgradeStand) end end end)
    task.spawn(function() while true do task.wait(0.3) if Shared then State.autoBuy = Shared.AutoBuy_Enabled == true; State.autoUpgrade = Shared.AutoUpgradeStand_Enabled == true end end end)
end

-- ============================================================
-- GHOST MODE
-- ============================================================
local GHOST_CLONE_POS = Vector3.new(2.23, 6.01, 20.29) + Vector3.new(0, 3, 0)
local GhostState = { enabled = false, clone = nil, saved = {}, savedDisplay = nil, savedGuis = {} }

local function ghostHideGuis()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    for _, g in ipairs(pg:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name:lower():find("vrilz") == nil then
            if GhostState.savedGuis[g] == nil then GhostState.savedGuis[g] = g.Enabled end
            g.Enabled = false
        end
    end
end

local function ghostRestoreGuis()
    for g, v in pairs(GhostState.savedGuis) do if g and g.Parent then g.Enabled = v end end
    GhostState.savedGuis = {}
end

local function ghostHide(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if GhostState.saved[d] == nil then GhostState.saved[d] = d.Transparency end
            d.Transparency, d.LocalTransparencyModifier = 1, 1
        elseif d:IsA("Decal") then
            if GhostState.saved[d] == nil then GhostState.saved[d] = d.Transparency end
            d.Transparency = 1
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            d.Enabled = false
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if GhostState.savedDisplay == nil then GhostState.savedDisplay = hum.DisplayDistanceType end
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    local hl = char:FindFirstChildOfClass("Highlight")
    if hl then hl.Enabled = false end
end

local function ghostRestore(char)
    for d, t in pairs(GhostState.saved) do
        if d and d.Parent then d.Transparency = t; d.LocalTransparencyModifier = 0 end
    end
    GhostState.saved = {}
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
            d.Enabled = true
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and GhostState.savedDisplay then hum.DisplayDistanceType = GhostState.savedDisplay; GhostState.savedDisplay = nil end
    local hl = char:FindFirstChildOfClass("Highlight")
    if hl then hl.Enabled = true end
end

local function ghostCreateClone(char)
    if GhostState.clone then GhostState.clone:Destroy(); GhostState.clone = nil end
    local oa = char.Archivable
    char.Archivable = true
    local ok, c = pcall(function() return char:Clone() end)
    char.Archivable = oa
    if not ok or not c then return end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then d:Destroy() end
    end
    for _, d in ipairs(c:GetChildren()) do if d:IsA("Tool") then d:Destroy() end end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.PlatformStand = true
        pcall(function() hum.EvaluateStateMachine = false end)
    end
    for _, cls in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
        local s = char:FindFirstChildOfClass(cls)
        if s then local o = c:FindFirstChildOfClass(cls); if o then o:Destroy() end; s:Clone().Parent = c end
    end
    c:PivotTo(CFrame.new(GHOST_CLONE_POS))
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.Massless = true end
    end
    c.Name = char.Name .. "_Ghost"
    c.Parent = Workspace
    GhostState.clone = c
end

local function ghostCamToClone()
    local cam = Workspace.CurrentCamera
    local chrp = GhostState.clone and GhostState.clone:FindFirstChild("HumanoidRootPart")
    if not (cam and chrp) then return end
    if cam.CameraType ~= Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Scriptable end
    if cam.CameraSubject ~= chrp then cam.CameraSubject = chrp end
    local t = chrp.Position
    cam.CFrame = CFrame.lookAt(t + Vector3.new(0, 6, 14), t)
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
    if GhostState.clone then GhostState.clone:Destroy(); GhostState.clone = nil end
    local cam = Workspace.CurrentCamera
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if cam then
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
        cam.CameraType = Enum.CameraType.Custom
        if hum then cam.CameraSubject = hum end
    end
    GhostState.enabled = false
end

local function initGhostMode()
    LocalPlayer.CharacterAdded:Connect(function()
        if GhostState.clone then GhostState.clone:Destroy(); GhostState.clone = nil end
        if GhostState.enabled then task.wait(2); pcall(ghostEnable) end
    end)
    RunService:BindToRenderStep("VRILZ_GhostCamOverride", Enum.RenderPriority.Last.Value + 5, function()
        if not GhostState.enabled then return end
        if not (Shared and (Shared.GhostMode_Enabled or Shared.AutoThrow_Enabled)) then return end
        ghostCamToClone()
    end)
    task.spawn(function()
        while true do
            task.wait(0.1)
            local w = Shared and (Shared.GhostMode_Enabled == true or Shared.AutoThrow_Enabled == true)
            if w and not GhostState.enabled then pcall(ghostEnable)
            elseif not w and GhostState.enabled then pcall(ghostDisable) end
            if not w then
                local b = false
                pcall(function() local cs = Shared and Shared.ClientState_Ref; b = (cs and cs.Busy) or false end)
                local tc = Shared and Shared.ThrowController_Ref
                local a = false
                pcall(function() a = tc and tc.IsActive and tc:IsActive() end)
                if not (b or a) then
                    local cam = Workspace.CurrentCamera
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if cam and hum then
                        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
                        if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
                    end
                    local anc = Workspace:FindFirstChild("VRILZ_CamAnchor")
                    if anc then pcall(function() anc:Destroy() end) end
                end
            end
            if GhostState.enabled then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if GhostState.clone and not GhostState.clone.Parent then pcall(ghostCreateClone, char) end
                    if GhostState.clone and GhostState.clone.Parent and hrp.Transparency < 1 then pcall(ghostHide, char) end
                end
                ghostHideGuis()
                ghostCamToClone()
            end
        end
    end)
end

-- ============================================================
-- INIT
-- ============================================================
function Features.Init(sharedState)
    Shared = sharedState
    _G.VRILZ_Shared = Shared
    _G.VRILZ_UI_Shared = Shared
    if not Features._antiAFKStarted then Features._antiAFKStarted = true; Features.startAntiAFK() end
    if not Features._autoThrowStarted then Features._autoThrowStarted = true; pcall(initAutoThrow) end
    if not Features._autoShopStarted then Features._autoShopStarted = true; pcall(initAutoShop) end
    if not Features._ghostStarted then Features._ghostStarted = true; pcall(initGhostMode) end
end

_G.VRILZ_Features = Features
return Features
