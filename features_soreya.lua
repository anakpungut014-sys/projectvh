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

-- ============================================================
-- 🎣 AUTO FISH v7 — HIDDEN MINIGAME (FORCE HIDE UI)
-- Mini game DIHIDE PAKSA: disable GUI, block VIM, no MobileTap.
-- ============================================================
local RS      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local VIM     = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FishSpeed = {
    reelMaxTime   = 8,
    castCooldown  = 0.15,
    castPowerWait = 0.15,
    loopDelay     = 0.05,
    tapsPerFrame  = 5,
}

local FishState = {
    enabled = false,
    autoEquip = true, autoCast = true, autoPerfect = true, autoReel = true,
    reeling = false, reelAbort = false,
    stats = { cast = 0, caught = 0, perfect = 0, fail = 0 },
    status = "Idle", lastCastTime = 0, lastBiteTime = 0,
}

-- ⛔ JANGAN require MiniGameHandler / PowerBarHandler sama sekali.
--    Itu yang bikin UI muncul. Kalau butuh, cuma buat baca state, tapi
--    di v7 kita baca state dari rod.Status aja (aman, no UI).

local function isFishingRod(tool)
    return tool and tool:IsA("Tool") and tool:FindFirstChild("Mechanics") ~= nil
end
local function getEquippedRod()
    local char = LocalPlayer.Character; if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if isFishingRod(t) then return t end
    end
end
local function findRodInBackpack()
    local bp = LocalPlayer:FindFirstChild("Backpack"); if not bp then return nil end
    for _, t in ipairs(bp:GetChildren()) do
        if isFishingRod(t) then return t end
    end
end
local function getStatusValue(rod, name)
    local mech = rod and rod:FindFirstChild("Mechanics")
    local s = mech and mech:FindFirstChild("Status")
    local v = s and s:FindFirstChild(name)
    return v and v.Value or false
end
local function getRodRemotes(rod)
    local mech = rod and rod:FindFirstChild("Mechanics")
    return mech and mech:FindFirstChild("Remotes")
end

-- ═══════════════════════════════════════════════════════════
-- 🔒 LAYER 1: FORCE HIDE MINIGAME UI
-- Scan PlayerGui tiap 0.2s, matiin GUI yang namanya berbau mini game
-- ═══════════════════════════════════════════════════════════
local HIDDEN_GUI_NAMES = {
    ["minigame"] = true, ["minigameui"] = true, ["minigamegui"] = true,
    ["powerbar"] = true, ["powerbarui"] = true, ["reelui"] = true,
    ["reelbar"]  = true, ["fishingui"] = true, ["fishingbar"] = true,
    ["catchbar"] = true, ["catchui"]   = true, ["fishgame"]   = true,
}

local hiddenGuiCache = setmetatable({}, { __mode = "k" })

local function forceHideMiniGameUI()
    local ok = pcall(function()
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("ScreenGui") or obj:IsA("BillboardGui")
                or obj:IsA("SurfaceGui") then
                local n = obj.Name:lower():gsub("%s+", "")
                if HIDDEN_GUI_NAMES[n]
                    or n:find("minigame")
                    or n:find("powerbar")
                    or n:find("reelbar")
                    or n:find("catchbar") then
                    if not hiddenGuiCache[obj] then
                        hiddenGuiCache[obj] = true
                    end
                    if obj.Enabled ~= false then obj.Enabled = false end
                    if obj.Visible ~= nil and obj.Visible ~= false then
                        pcall(function() obj.Visible = false end)
                    end
                    -- 1 = hidden (bukan 0, biar gak full invisible ke script)
                    pcall(function() obj.Enabled = false end)
                end
            end
        end
    end)
    return ok
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if FishState.enabled then
            pcall(forceHideMiniGameUI)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔒 LAYER 2: TAP TANPA VIM KE LAYAR
-- Pakai VirtualUser (bukan VIM) — gak klik koordinat layar,
-- jadi gak trigger GUI yang listen ke mouse click.
-- ═══════════════════════════════════════════════════════════
local VirtualUser = game:GetService("VirtualUser")

local function tapOnce()
    -- ⭐ VirtualUser gak butuh koordinat → gak nyentuh GUI
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        VirtualUser:Button1Up(Vector2.new(0, 0))
    end)
end

-- ═══ REEL ═══
local function doReelSpam()
    if FishState.reeling then return end
    FishState.reeling = true
    FishState.reelAbort = false
    local rod = getEquippedRod()
    local start = os.clock()
    local taps = 0
    FishState.status = "⚡ REEL (hidden)..."

    -- tunggu MiniGameActive muncul (max 2s)
    local waitStart = os.clock()
    while FishState.enabled and not FishState.reelAbort
        and os.clock() - waitStart < 2.0 do
        if rod and getStatusValue(rod, "MiniGameActive") then break end
        task.wait(0.05)
    end

    local miss, minigameSeen = 0, false
    while FishState.enabled
        and not FishState.reelAbort
        and os.clock() - start < FishSpeed.reelMaxTime do

        -- ⭐ tiap frame, pastiin UI hidden lagi (server bisa re-show)
        pcall(forceHideMiniGameUI)

        if rod then
            if getStatusValue(rod, "MiniGameActive") then
                minigameSeen, miss = true, 0
            elseif minigameSeen then
                miss += 1
                if miss >= 2 then break end
            end
        end

        for _ = 1, FishSpeed.tapsPerFrame do
            tapOnce(); taps += 1
        end
        RunService.Heartbeat:Wait()
    end

    local dur = os.clock() - start
    FishState.reeling = false
    FishState.reelAbort = false
    FishState.status = string.format("✅ Reel %.1fs (%d tap)", dur, taps)
end

-- ═══ HOOK ROD ═══
local fishHookedRods = setmetatable({}, { __mode = "k" })
local function hookRod(rod)
    if not rod or fishHookedRods[rod] then return end
    local remotes = getRodRemotes(rod)
    if not remotes then return end
    local miniGame     = remotes:FindFirstChild("MiniGame")
    local notifyClient = remotes:FindFirstChild("NotifyClient")
    if not miniGame or not notifyClient then return end
    fishHookedRods[rod] = true

    miniGame.OnClientEvent:Connect(function(action, info)
        if not FishState.enabled then return end
        -- ⭐ begitu Start, langsung paksa hide UI
        pcall(forceHideMiniGameUI)
        if action == "Start" then
            FishState.lastBiteTime = os.clock()
            if not FishState.reeling then task.spawn(doReelSpam) end
        elseif action == "Stop" then
            FishState.reelAbort = true
        end
    end)

    notifyClient.OnClientEvent:Connect(function(action, info)
        if not FishState.enabled then return end
        if action == "Bite" then
            FishState.lastBiteTime = os.clock()
            FishState.status = "🐟 Bite! REEL..."
            if FishState.autoReel and not FishState.reeling then
                task.spawn(doReelSpam)
            end
        elseif action == "GotFish" then
            FishState.stats.caught += 1
            local name = (typeof(info) == "table" and info.baseName) or tostring(info) or "Fish"
            FishState.status = "✅ Caught: " .. name
            if Shared and Shared.WebhookNotifyFish and _G.VRILZ_SendFishWebhook then
                task.spawn(function() _G.VRILZ_SendFishWebhook(info) end)
            end
        elseif action == "CastFailed" then
            FishState.stats.fail += 1
            FishState.status = "❌ Cast failed"
        elseif action == "NoFishingZone" then
            FishState.status = "⚠ Not in fishing zone"
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    fishHookedRods = setmetatable({}, { __mode = "k" })
end)

-- ═══ MAIN LOOP ═══
local function startFishLoop()
    task.spawn(function()
        while true do
            task.wait(FishSpeed.loopDelay)
            if not FishState.enabled then continue end
            local char = LocalPlayer.Character
            if not char then FishState.status = "No character"; continue end
            if FishState.autoEquip and not getEquippedRod() then
                local rod = findRodInBackpack()
                if rod then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(rod) end) end
                end
                continue
            end
            local rod = getEquippedRod()
            if not rod then FishState.status = "Waiting for rod..."; continue end
            if not fishHookedRods[rod] then hookRod(rod) end

            if FishState.autoCast
                and not getStatusValue(rod, "FishingActive")
                and not getStatusValue(rod, "MiniGameActive")
                and not FishState.reeling
                and os.clock() - FishState.lastCastTime > FishSpeed.castCooldown then
                local remotes = getRodRemotes(rod)
                local castEvent = remotes and remotes:FindFirstChild("CastEvent")
                if castEvent then
                    FishState.status = "Casting..."
                    pcall(function()
                        castEvent:FireServer(true)
                        task.wait(FishSpeed.castPowerWait)
                        castEvent:FireServer(false, 100, Vector3.new(0, 0, -1))
                    end)
                    FishState.stats.cast += 1
                    FishState.lastCastTime = os.clock()
                end
            end
            if FishState.autoReel
                and getStatusValue(rod, "MiniGameActive")
                and not FishState.reeling then
                task.spawn(doReelSpam)
            end
        end
    end)
end

_G.VRILZ_FishState = FishState
_G.VRILZ_FishUI = {
    setStatus  = function(s) FishState.status = s end,
    setEnabled = function(v) FishState.enabled = v and true or false end,
    toggle     = function() FishState.enabled = not FishState.enabled end,
    isEnabled  = function() return FishState.enabled end,
}

local function initAutoFish()
    startFishLoop()
    task.spawn(function()
        while true do
            task.wait(0.3)
            local wantOn = (Shared and Shared.AutoFish_Enabled == true)
            if wantOn ~= FishState.enabled then
                if wantOn then
                    FishState.autoEquip   = true
                    FishState.autoCast    = true
                    FishState.autoPerfect = true
                    FishState.autoReel    = true
                    FishState.reelAbort   = false
                    FishState.enabled     = true
                    Shared.GhostMode_Enabled = true
                    -- ⭐ langsung paksa hide pas ON
                    task.spawn(function()
                        for _ = 1, 20 do
                            pcall(forceHideMiniGameUI)
                            task.wait(0.1)
                        end
                    end)
                else
                    FishState.enabled   = false
                    FishState.reelAbort = true
                    Shared.GhostMode_Enabled = false
                end
            end
        end
    end)
end

-- ============================================================
-- 🏔 AUTO SUMMIT v2 — STANDALONE (Baca AutoSummit_StartCP dari UI)
-- ✅ Gak perlu soreyacp.txt
-- ✅ Validasi CP wajib kesentuh
-- ✅ Start CP dari dropdown UI
-- ✅ Auto-OFF Ghost biar TP jalan
-- ============================================================

local SummitCfg = {
    StepDistance = 40,
    TPHeight = 5,
    WaitBetweenStep = 0.03,
    WaitBetweenCP = 2.0,
    WaitAtBackBC = 0.8,
    SummitWaitBeforeReturn = 1.0,
    StartRenderDelay = 2.0,
    CPTolerance = 25,
    MaxRetryPerCP = 5,
}

local SummitCheckpoints = {
    {number = 1,  position = Vector3.new(464, 455, -8946)},
    {number = 2,  position = Vector3.new(450, 500, -9568)},
    {number = 3,  position = Vector3.new(398, 640, -10114)},
    {number = 4,  position = Vector3.new(487, 649, -10681)},
    {number = 5,  position = Vector3.new(1089, 736, -11156)},
    {number = 6,  position = Vector3.new(974, 746, -11809)},
    {number = 7,  position = Vector3.new(392, 896, -11839)},
    {number = 8,  position = Vector3.new(-326, 859, -11738)},
    {number = 9,  position = Vector3.new(-870, 864, -11737)},
    {number = 10, position = Vector3.new(-1282, 868, -12094)},
    {number = 11, position = Vector3.new(-1311, 900, -12834)},
    {number = 12, position = Vector3.new(-2327, 925, -12673)},
    {number = 13, position = Vector3.new(-2309, 928, -11857)},
    {number = 14, position = Vector3.new(-2445, 973, -11058)},
    {number = 15, position = Vector3.new(-3480, 993, -11015)},
    {number = 16, position = Vector3.new(-4226, 1012, -11018)},
    {number = 17, position = Vector3.new(-4651, 1091, -11665)},
    {number = 18, position = Vector3.new(-5544, 1113, -11652)},
    {number = 19, position = Vector3.new(-6767, 1106, -11507)},
    {number = 20, position = Vector3.new(-6761, 1115, -10801)},
}

local SummitTopPos = Vector3.new(-6767.21, 1340.40, -10082.37)
local SummitBackBCPos = Vector3.new(-6834.07, 1317.09, -9902.57)

local SummitRun = {
    enabled = false,
    status = "⏸️ Idle",
    loopCount = 0,
    summitCount = 0,
}

local function summitRoot()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

-- ═══ KUNCI char: FULL FREEZE ═══
local SummitSaved = {
    walk = nil, jump = nil, jumpHeight = nil,
    platformStand = nil, autoRotate = nil,
}

local function summitLockChar()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum then
        if SummitSaved.walk == nil then SummitSaved.walk = hum.WalkSpeed end
        if SummitSaved.jump == nil then SummitSaved.jump = hum.JumpPower end
        if SummitSaved.jumpHeight == nil then SummitSaved.jumpHeight = hum.JumpHeight end
        if SummitSaved.platformStand == nil then SummitSaved.platformStand = hum.PlatformStand end
        if SummitSaved.autoRotate == nil then SummitSaved.autoRotate = hum.AutoRotate end

        hum.WalkSpeed     = 0
        hum.JumpPower     = 0
        hum.JumpHeight    = 0
        hum.PlatformStand = true
        hum.AutoRotate    = false
    end
    if hrp then
        hrp.Anchored = true
        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function summitUnlockChar()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum then
        if SummitSaved.walk ~= nil then hum.WalkSpeed = SummitSaved.walk end
        if SummitSaved.jump ~= nil then hum.JumpPower = SummitSaved.jump end
        if SummitSaved.jumpHeight ~= nil then hum.JumpHeight = SummitSaved.jumpHeight end
        if SummitSaved.platformStand ~= nil then hum.PlatformStand = SummitSaved.platformStand end
        if SummitSaved.autoRotate ~= nil then hum.AutoRotate = SummitSaved.autoRotate end
    end
    if hrp then hrp.Anchored = false end

    SummitSaved.walk = nil
    SummitSaved.jump = nil
    SummitSaved.jumpHeight = nil
    SummitSaved.platformStand = nil
    SummitSaved.autoRotate = nil
end

-- ═══ DETEKSI CP: baca dari Leaderstats "Checkpoint" ═══
local function summitDetectCurrentCP()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return 1, false end

    local stat = ls:FindFirstChild("Checkpoint")
    if not stat then return 1, false end

    local cpNum = tonumber(stat.Value) or 1
    if cpNum < 1 then cpNum = 1 end
    if cpNum > #SummitCheckpoints then cpNum = #SummitCheckpoints end

    return cpNum, true
end

-- ═══ DETEKSI CP DARI POSISI REAL (TANPA RADIUS) ═══
-- Selalu return CP terdekat, gak peduli jaraknya
local function summitDetectCPByPosition()
    local root = summitRoot()
    if not root then return nil end

    local pos = root.Position
    local best, bestDist = nil, math.huge

    for _, cp in ipairs(SummitCheckpoints) do
        local d = (pos - cp.position).Magnitude
        if d < bestDist then
            bestDist = d
            best = cp
        end
    end

    if best then
        return best.number, bestDist
    end
    return nil
end

-- ═══ VALIDASI: posisi real vs leaderstats (PAKAI KOORDINAT CP) ═══
-- Logika: kalau posisi real lebih MAJU dari leaderstats → balik ke CP berikutnya
-- Contoh: leaderstats 9, posisi CP 11 → balik ke CP 10
--         leaderstats 7, posisi CP 9  → balik ke CP 8
--         leaderstats 4, posisi CP 6  → balik ke CP 5
local function summitResolveStartCP()
    local lsCP, lsValid = summitDetectCurrentCP()
    local posCP = summitDetectCPByPosition()

    -- Kalau leaderstats gak ada → pakai posisi / setting UI
    if not lsValid then
        if posCP then return posCP, "posisi (no leaderstats)" end
        return tonumber(Shared.AutoSummit_StartCP) or 1, "setting UI"
    end

    -- ⭐ KASUS UTAMA: posisi real lebih MAJU dari leaderstats
    -- → balik ke CP berikutnya (lsCP + 1)
    if posCP and posCP > lsCP then
        local harusnya = lsCP + 1
        if harusnya > #SummitCheckpoints then
            harusnya = #SummitCheckpoints
        end
        return harusnya, string.format(
            "posisi CP %d, leaderstats CP %d → balik ke CP %d",
            posCP, lsCP, harusnya
        )
    end

    -- ⭐ Posisi real di belakang / sama dengan leaderstats → pakai leaderstats
    return lsCP, "leaderstats"
end

-- ═══ NOTIF: "Lu lagi di CP X" ═══
local function summitNotifyCP(cpNum)
    local msg = "📍 You are now at CP " .. cpNum
    if _G.VRILZ_Notify then
        _G.VRILZ_Notify(msg, "info")
    end
end

local function summitTpFast(targetPos, label)
    local root = summitRoot()
    if not root then return false end

    -- ⭐ Fly ke CP asli (di atas CP, biar aman gak nyangkut)
    local target = targetPos + Vector3.new(0, SummitCfg.TPHeight, 0)

    -- ⭐ ANCHOR ON
    root.Anchored = true
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero

    -- ⭐ STEP-BY-STEP FLY ke CP
    local startPos  = root.Position
    local totalDist = (target - startPos).Magnitude
    local steps = math.ceil(totalDist / SummitCfg.StepDistance)
    if steps < 1 then steps = 1 end

    local dir = (target - startPos)
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 1 then
        dir = Vector3.new(0, 0, -1)
    else
        dir = dir.Unit
    end

    for i = 1, steps do
        if not SummitRun.enabled then return false end
        local r = summitRoot()
        if not r then return false end
        local dist = math.min(SummitCfg.StepDistance * i, totalDist)
        local pos = startPos + dir * dist + Vector3.new(0, SummitCfg.TPHeight, 0)
        pos = Vector3.new(pos.X, target.Y, pos.Z)
        r.CFrame = CFrame.new(pos)
        r.Velocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero
        SummitRun.status = string.format("%s [%d/%d]", label or "TP", i, steps)
        task.wait(SummitCfg.WaitBetweenStep)
    end

        -- ⭐ SAMPAI DI CP — langsung jatuh natural, TANPA diam
    local r = summitRoot()
    if r then
        r.CFrame = CFrame.new(target)
        r.Velocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero

        -- ⭐ UNANCHOR langsung biar jatuh natural (tanpa wait)
        r.Anchored = false

        local dropStartY = r.Position.Y
        local dropElapsed = 0
        local dropTimeout = 2.0  -- safety max 2 detik

        while dropElapsed < dropTimeout do
            if not SummitRun.enabled then break end
            local rr = summitRoot()
            if not rr then break end

            -- ⭐ Udah turun 12 studs? Berhenti
            if (dropStartY - rr.Position.Y) >= 12 then break end

            -- ⭐ Udah nyentuh tanah / diam? Berhenti
            local vel = rr.AssemblyLinearVelocity
            if vel.Magnitude < 0.5 and dropElapsed > 0.3 then break end

            task.wait(0.05)
            dropElapsed += 0.05
        end

        -- ⭐ Setelah jatuh (max 12 studs) → ANCHOR ON
        local rFinal = summitRoot()
        if rFinal and SummitRun.enabled then
            rFinal.Anchored = true
            rFinal.Velocity = Vector3.zero
            rFinal.AssemblyLinearVelocity = Vector3.zero
        end
    end
    return true
end

local function summitVerifyCP(cpPos, tolerance)
    tolerance = tolerance or SummitCfg.CPTolerance
    local root = summitRoot()
    if not root then return false, math.huge end
    local target = cpPos + Vector3.new(0, SummitCfg.TPHeight, 0)
    local dist = (root.Position - target).Magnitude
    return dist <= tolerance, dist
end

local function summitTpToCP(cp, label, maxRetry)
    maxRetry = maxRetry or SummitCfg.MaxRetryPerCP
    for attempt = 1, maxRetry do
        if not SummitRun.enabled then return false end
        summitTpFast(cp.position, label .. " (try " .. attempt .. ")")
        task.wait(0.15)
        local ok, dist = summitVerifyCP(cp.position)
        if ok then
            SummitRun.status = label .. " ✅ (dist: " .. math.floor(dist) .. ")"
            return true
        end
        SummitRun.status = string.format("%s ❌ missed (dist: %d), retry %d/%d",
            label, math.floor(dist), attempt, maxRetry)
        task.wait(0.2)
    end

    local root = summitRoot()
    if root then
        root.CFrame = CFrame.new(cp.position + Vector3.new(0, SummitCfg.TPHeight, 0))
        task.wait(0.3)
        local ok, dist = summitVerifyCP(cp.position, 30)
        return ok
    end
    return false
end

-- ═══ BALIK BC — nama objek: Workspace.BackBC.BackBC ═══
-- ═══ BALIK BC — nama objek: Workspace.BackBC.BackBC ═══
local function summitBackBC()
    local part = nil

    -- ⭐ Cari langsung ke path yang udah pasti
    local backBCFolder = workspace:FindFirstChild("BackBC")
    if backBCFolder then
        local bcPart = backBCFolder:FindFirstChild("BackBC")
        if bcPart and bcPart:IsA("BasePart") then
            part = bcPart
        end
    end

    -- ⭐ Fallback: scan kalau path gak ketemu
    if not part then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n == "backbc" or n:find("back to bc")
                    or n:find("backtobc") or n:find("back bc") then
                    part = obj
                    break
                end
            end
        end
    end

    if part then
        SummitBackBCPos = part.Position
    end

    summitTpFast(SummitBackBCPos, "🏠 BackBC")
    task.wait(SummitCfg.WaitAtBackBC)
end

local function summitMainLoop()
    for i = math.floor(SummitCfg.StartRenderDelay), 1, -1 do
        if not SummitRun.enabled then return end
        SummitRun.status = "⏳ Render... (" .. i .. "s)"
        task.wait(1)
    end

        -- ⭐ RESOLVE CP: leaderstats + validasi posisi real
    local startNum, reason = summitResolveStartCP()
    if startNum < 1 then startNum = 1 end
    if startNum > #SummitCheckpoints then startNum = #SummitCheckpoints end

    SummitRun.status = "🚀 Mulai dari CP " .. startNum .. " (" .. reason .. ")"
    
    -- ⭐ NOTIF: "Lu lagi di CP X"
    summitNotifyCP(startNum)

    while SummitRun.enabled do
        SummitRun.loopCount += 1
        local n = SummitRun.loopCount

        -- ⭐ Naik CP dari startNum sampai 20 — DELAY 2s PER CP
                for i = startNum, #SummitCheckpoints do
            if not SummitRun.enabled then return end
            local cp = SummitCheckpoints[i]

            SummitRun.status = "🏔️ Loop #" .. n .. " — CP " .. cp.number

            local ok = summitTpToCP(cp, "CP " .. cp.number, SummitCfg.MaxRetryPerCP)

            if not ok then
                SummitRun.status = "🔄 CP " .. cp.number .. " gagal, ulangi..."
                task.wait(1.0)
                i = i - 1
            else
            SummitRun.status = "⏱️ CP " .. cp.number .. " done, tunggu 2s..."
                task.wait(SummitCfg.WaitBetweenCP)
            end
        end

        if not SummitRun.enabled then return end

        -- ⭐ Summit
        SummitRun.status = "⭐ Loop #" .. n .. " — SUMMIT"
        local summitReached = false
        for attempt = 1, 5 do
            if not SummitRun.enabled then return end
            summitTpFast(SummitTopPos, "SUMMIT (try " .. attempt .. ")")
            task.wait(0.2)
            local root = summitRoot()
            if root then
                local dist = (root.Position - (SummitTopPos + Vector3.new(0, SummitCfg.TPHeight, 0))).Magnitude
                if dist <= 30 then
                    summitReached = true
                    break
                end
            end
        end
        if not summitReached then
            SummitRun.status = "⚠️ Summit gak kesentuh, skip"
        else
            SummitRun.summitCount += 1
        end

        task.wait(SummitCfg.SummitWaitBeforeReturn)
        if not SummitRun.enabled then return end

        -- ⭐ Back BC
        SummitRun.status = "🏠 Balik ke BackBC..."
        summitBackBC()

        if not SummitRun.enabled then return end

                -- ⭐ LOOP BERIKUTNYA: resolve ulang (leaderstats + posisi)
        local newCP, newReason = summitResolveStartCP()
        startNum = newCP
        SummitRun.status = "🔄 Loop berikutnya dari CP " .. newCP .. " (" .. newReason .. ")"
        summitNotifyCP(newCP)

        task.wait(0.5)
    end
end

local function initAutoSummit()
    -- Load saved CP
    if readfile and isfile then
        local ok, exists = pcall(isfile, "vrilz_summit_cp.txt")
        if ok and exists then
            local okRead, content = pcall(readfile, "vrilz_summit_cp.txt")
            if okRead and content then
                local num = tonumber(content)
                if num and num >= 1 and num <= 20 then
                    Shared.AutoSummit_StartCP = num
                end
            end
        end
    end
    if not Shared.AutoSummit_StartCP then
        Shared.AutoSummit_StartCP = 1
    end

    -- ⭐ Bridge: baca Shared.AutoSummit_Enabled → jalanin loop
    task.spawn(function()
        while true do
            task.wait(0.3)
            if not Shared then continue end
            local wantOn = Shared.AutoSummit_Enabled == true

            if wantOn and not SummitRun.enabled then
                if Shared.GhostMode_Enabled == true then
                    Shared.GhostMode_Enabled = false
                    task.wait(0.8)
                end
                -- ⭐ KUNCI char
                summitLockChar()
                SummitRun.enabled = true
                SummitRun.status = "🚀 Starting..."
                task.spawn(summitMainLoop)
            elseif not wantOn and SummitRun.enabled then
                SummitRun.enabled = false
                SummitRun.status = "⏹ Stopping..."
                -- ⭐ BUKA kunci char
                summitUnlockChar()
            end
        end
    end)

    -- ⭐ AUTO-UPDATE DROPDOWN UI sesuai leaderstats
    task.spawn(function()
        local lastCP = -1
        while true do
            task.wait(1.0)
            local cpNum, valid = summitDetectCurrentCP()
            if valid and cpNum ~= lastCP then
                lastCP = cpNum
                Shared.AutoSummit_StartCP = cpNum
                -- Update dropdown UI (kalau ada)
                if _G.VRILZ_UpdateSummitDropdown then
                    pcall(_G.VRILZ_UpdateSummitDropdown, cpNum)
                end
            end
        end
    end)

    -- ⭐ Respawn safety: re-lock kalau char respawn saat ON
    LocalPlayer.CharacterAdded:Connect(function()
        SummitSaved.walk = nil
        SummitSaved.jump = nil
        SummitSaved.jumpHeight = nil
        SummitSaved.platformStand = nil
        SummitSaved.autoRotate = nil
        if SummitRun.enabled then
            task.wait(2)
            summitLockChar()
        end
    end)

    
    -- ⭐ Save function (kalau UI panggil)
    _G.VRILZ_SaveSummitCP = function(num)
        num = tonumber(num) or 1
        if num < 1 then num = 1 end
        if num > 20 then num = 20 end
        Shared.AutoSummit_StartCP = num
        if writefile then
            pcall(writefile, "vrilz_summit_cp.txt", tostring(num))
        end
    end

    _G.VRILZ_SummitState = SummitRun
    _G.VRILZ_SummitDetectCP = summitDetectCurrentCP
end

-- ============================================================
-- 🛒 SHOP FEATURES — Auto Sell / Upgrade Rod / Buy Skin
-- Default: SEMUA RARITY = FALSE (user pilih sendiri)
-- ============================================================
local ShopSpeed = { loopDelay = 1.0 }

local ShopState = {
    autoSell      = false,
    autoUpgradeRod= false,
    autoBuySkin   = false,
    -- ⭐ DEFAULT NONE
    sellRarities  = {
        Common=false, Uncommon=false, Rare=false, Epic=false,
        Legendary=false, Mythic=false, SECRET=false, FORGOTTEN=false,
    },
    status = "Idle",
    stats  = { sold=0, koinsEarned=0, rodsUpgraded=0, skinsBought=0, lastError="" },
}

local RS = game:GetService("ReplicatedStorage")
local ShopRemotes = {}
pcall(function()
    local M = RS:WaitForChild("Remote"):WaitForChild("Mancing")
    ShopRemotes.JualPilihan = M:WaitForChild("JualPilihan")
    ShopRemotes.JualSatu    = M:WaitForChild("JualSatu")
    local K = RS:WaitForChild("Remote"):WaitForChild("KoinShop")
    ShopRemotes.KoinAmbilData = K:WaitForChild("AmbilData")
    ShopRemotes.KoinBeli      = K:WaitForChild("Beli")
    ShopRemotes.KoinPakai     = K:WaitForChild("Pakai")
    local S = RS:WaitForChild("Remote"):WaitForChild("SkinShop")
    ShopRemotes.SkinAmbilPunya = S:WaitForChild("AmbilPunya")
    ShopRemotes.SkinMintaBeli  = S:WaitForChild("MintaBeli")
end)

local function getFishTools()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return {} end
    local out = {}
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then
            local r = t:GetAttribute("Rarity")
            if r then
                table.insert(out, {
                    tool=t, uid=t:GetAttribute("UidIkan"), rarity=r,
                    harga=t:GetAttribute("Harga") or 0,
                })
            end
        end
    end
    return out
end

local function shouldSell(rarity)
    if not rarity then return false end
    local n = rarity
    if n:lower()=="secret" then n="SECRET" end
    if n:lower()=="mythical" then n="Mythic" end
    if n:lower()=="legend" then n="Legendary" end
    if n:lower()=="uncommon" then n="Uncommon" end
    if n:lower()=="forgotten" then n="FORGOTTEN" end
    return ShopState.sellRarities[n] == true
end

local function doAutoSell()
    -- Safety: kalau gak ada rarity dipilih → jangan jual
    local any = false
    for _, v in pairs(ShopState.sellRarities) do
        if v == true then any = true break end
    end
    if not any then
        ShopState.status = "⚠ Pilih rarity dulu di UI"
        return
    end

    local fishes = getFishTools()
    if #fishes == 0 then ShopState.status = "🐟 Backpack kosong" return end

    local toSell = {}
    for _, f in ipairs(fishes) do
        if shouldSell(f.rarity) then table.insert(toSell, f) end
    end
    if #toSell == 0 then
        ShopState.status = "✅ Tidak ada ikan cocok filter"
        return
    end

    ShopState.status = string.format("💰 Jual %d ikan...", #toSell)
    local uids = {}
    for _, f in ipairs(toSell) do if f.uid then table.insert(uids, f.uid) end end

    local ok, koin = false, 0
    if #uids > 0 and ShopRemotes.JualPilihan then
        local s, r = pcall(function() return ShopRemotes.JualPilihan:InvokeServer(uids) end)
        if s and type(r)=="number" and r>0 then koin=r; ok=true
        else ShopState.stats.lastError = "JualPilihan(uid): "..tostring(r) end
    end
    if not ok and ShopRemotes.JualSatu and #uids>0 then
        local total = 0
        for _, uid in ipairs(uids) do
            local s, r = pcall(function() return ShopRemotes.JualSatu:InvokeServer(uid) end)
            if s and type(r)=="number" then total += r end
            task.wait(0.1)
        end
        if total > 0 then koin=total; ok=true end
    end

    if ok then
        ShopState.stats.sold += #toSell
        ShopState.stats.koinsEarned += koin
        ShopState.status = string.format("✅ Jual %d → +%d Koin", #toSell, koin)
    else
        ShopState.status = "❌ Gagal: "..ShopState.stats.lastError
    end
end

local function doAutoUpgradeRod()
    if not ShopRemotes.KoinAmbilData then return end
    local s, data = pcall(function() return ShopRemotes.KoinAmbilData:InvokeServer() end)
    if not s or type(data)~="table" then return end
    local owned = data.rod or {}
    for name, isOwned in pairs(owned) do
        if not isOwned then
            ShopState.status = "🛒 Beli rod: "..name
            local s2, r = pcall(function() return ShopRemotes.KoinBeli:InvokeServer(name) end)
            if s2 and r then
                ShopState.stats.rodsUpgraded += 1
                ShopState.status = "✅ Beli rod: "..name
            else
                ShopState.status = "❌ Gagal beli rod: "..name
            end
            return
        end
    end
    ShopState.status = "✅ Semua rod udah punya"
end

local function doAutoBuySkin()
    if not ShopRemotes.SkinAmbilPunya then return end
    local s, owned = pcall(function() return ShopRemotes.SkinAmbilPunya:InvokeServer() end)
    if not s or type(owned)~="table" then return end
    local ItemDB = RS.Modules.Fishing.ItemDatabase
    local okDB, DB = pcall(require, ItemDB)
    if not okDB or not DB.GetAllSkins then return end
    local s2, skins = pcall(function() return DB.GetAllSkins() end)
    if not s2 or type(skins)~="table" then return end

    local koin = LocalPlayer:GetAttribute("Koin") or 0
    for _, sk in pairs(skins) do
        if type(sk)=="table" then
            local n = sk.Name or sk.nama or sk.id
            local p = sk.Price or sk.Harga or sk.price or 0
            if n and not owned[n] and p>0 and koin>=p then
                ShopState.status = "🛒 Beli skin: "..n
                local s3 = pcall(function() return ShopRemotes.SkinMintaBeli:InvokeServer(n) end)
                if s3 then
                    ShopState.stats.skinsBought += 1
                    ShopState.status = "✅ Beli skin: "..n
                    koin = koin - p
                end
                return
            end
        end
    end
end

local function startShopLoop()
    task.spawn(function()
        while true do
            task.wait(ShopSpeed.loopDelay)
            if not Shared then continue end
            ShopState.autoSell      = Shared.Shop_AutoSell_Enabled == true
            ShopState.autoUpgradeRod= Shared.Shop_AutoUpgradeRod_Enabled == true
            ShopState.autoBuySkin   = Shared.Shop_AutoBuySkin_Enabled == true
            if type(Shared.Shop_SellRarity) == "table" then
                for k, v in pairs(Shared.Shop_SellRarity) do
                    if ShopState.sellRarities[k] ~= nil then
                        ShopState.sellRarities[k] = v == true
                    end
                end
            end
            local fishBusy = _G.VRILZ_FishState and _G.VRILZ_FishState.reeling
            if fishBusy then continue end
            if ShopState.autoSell then pcall(doAutoSell) end
            if ShopState.autoUpgradeRod then pcall(doAutoUpgradeRod) end
            if ShopState.autoBuySkin then pcall(doAutoBuySkin) end
        end
    end)
end

_G.VRILZ_ShopState = ShopState
_G.VRILZ_ShopUI = {
    setStatus          = function(s) ShopState.status = s end,
    getStatus          = function() return ShopState.status end,
    setSellRarity      = function(r, e)
        if ShopState.sellRarities[r] ~= nil then ShopState.sellRarities[r] = e == true end
    end,
    getSellRarities    = function() return ShopState.sellRarities end,
    getStats           = function() return ShopState.stats end,
    listFishByRarity   = function()
        local fishes = getFishTools()
        local g = {}
        for _, f in ipairs(fishes) do
            g[f.rarity] = g[f.rarity] or {}
            table.insert(g[f.rarity], f.name or f.tool.Name)
        end
        return g, fishes
    end,
    sellNow = function() task.spawn(doAutoSell) end,
}
local function initShop() startShopLoop() end

-- ============================================================
-- 👻 GHOST MODE v3 — Real char invisible + DIKUNCI di tempat
-- Clone berbaju diem 15 studs + camera di clone
-- Real char gak bisa gerak/lompat sampai ghost di-OFF kan
-- ============================================================

local GHOST_DISTANCE = 15 -- jarak clone dari char asli (studs)

local GhostState = {
    enabled         = false,
    clone           = nil,
    saved           = {},
    savedDisplay    = nil,
    savedCamSubject = nil,
    savedWalk       = nil,
    savedJump       = nil,
}

-- ═══ KUNCI real char: anchor HRP + WalkSpeed/Jump 0 ═══
local function ghostLock(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum then
        if GhostState.savedWalk == nil then GhostState.savedWalk = hum.WalkSpeed end
        if GhostState.savedJump == nil then GhostState.savedJump = hum.JumpPower end
        hum.WalkSpeed  = 0
        hum.JumpPower  = 0
        hum.JumpHeight = 0 -- game yang pakai JumpHeight juga ke-cover
    end
    if hrp then hrp.Anchored = true end
end

-- ═══ BUKA kunci ═══
local function ghostUnlock(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum then
        if GhostState.savedWalk ~= nil then hum.WalkSpeed  = GhostState.savedWalk end
        if GhostState.savedJump ~= nil then hum.JumpPower  = GhostState.savedJump end
        hum.JumpHeight = GhostState.savedJump or hum.JumpHeight
    end
    if hrp then hrp.Anchored = false end
    GhostState.savedWalk = nil
    GhostState.savedJump = nil
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

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

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

    -- Humanoid clone dipertahankan (biar baju ke-render) tapi di-neuter
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.PlatformStand      = true
        pcall(function() hum.EvaluateStateMachine = false end)
    end

    -- safety ekstra: copy ulang baju dari char asli
    for _, cls in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
        local src = char:FindFirstChildOfClass(cls)
        if src then
            local old = clone:FindFirstChildOfClass(cls)
            if old then old:Destroy() end
            src:Clone().Parent = clone
        end
    end

    -- clone 15 studs di belakang char asli
    clone:PivotTo(hrp.CFrame * CFrame.new(0, 0, GHOST_DISTANCE))

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.Massless = true
        end
    end

    clone.Name = char.Name
    clone.Parent = workspace
    GhostState.clone = clone

    -- camera nempel ke clone
    local cam = workspace.CurrentCamera
    local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
    if cam and cloneHRP then
        cam.CameraSubject = cloneHRP
    end
end

local function ghostEnable()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    ghostCreateClone(char)
    task.wait(0.1)
    ghostHide(char)
    ghostLock(char)   -- ⭐ KUNCI real char
    GhostState.enabled = true
end

local function ghostDisable()
    local char = LocalPlayer.Character
    if char then
        ghostUnlock(char)  -- ⭐ BUKA kunci dulu
        ghostRestore(char)
    end
    if GhostState.clone then
        GhostState.clone:Destroy()
        GhostState.clone = nil
    end
    local cam = workspace.CurrentCamera
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if cam and hum then
        cam.CameraSubject = hum
    end
    GhostState.enabled = false
end

local function initGhostMode()
    LocalPlayer.CharacterAdded:Connect(function()
        if GhostState.clone then
            GhostState.clone:Destroy()
            GhostState.clone = nil
        end
        -- reset lock state (char baru = nilai default)
        GhostState.savedWalk = nil
        GhostState.savedJump = nil
        if GhostState.enabled then
            task.wait(2)
            pcall(ghostEnable)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            local wantOn = Shared and Shared.GhostMode_Enabled == true

            if wantOn and not GhostState.enabled then
                pcall(ghostEnable)
            elseif not wantOn and GhostState.enabled then
                pcall(ghostDisable)
            end

            if GhostState.enabled then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- clone kehapus → recreate
                    if GhostState.clone and not GhostState.clone.Parent then
                        pcall(ghostCreateClone, char)
                    end
                    -- server force-restore transparency → re-hide
                    if GhostState.clone and GhostState.clone.Parent
                        and hrp.Transparency < 1 then
                        pcall(ghostHide, char)
                    end
                    -- ⭐ RE-ASSERT LOCK: game/fitur lain ubah speed atau unanchor → balikin
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and (hum.WalkSpeed ~= 0 or not hrp.Anchored) then
                        pcall(ghostLock, char)
                    end
                end
                -- camera tetap nempel clone
                local cam = workspace.CurrentCamera
                local cloneHRP = GhostState.clone and GhostState.clone:FindFirstChild("HumanoidRootPart")
                if cam and cloneHRP and cam.CameraSubject ~= cloneHRP then
                    cam.CameraSubject = cloneHRP
                end
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

    -- ⭐ TAMBAH INI
    if not Features._autoFishStarted then
        Features._autoFishStarted = true
        pcall(initAutoFish)
    end

    -- ⭐ AUTO SUMMIT
    if not Features._autoSummitStarted then
        Features._autoSummitStarted = true
        pcall(initAutoSummit)
    end
        -- ⭐ SHOP
    if not Features._shopStarted then
        Features._shopStarted = true
        pcall(initShop)
    end
    -- ⭐ GHOST MODE  ← TAMBAH INI
    if not Features._ghostStarted then
        Features._ghostStarted = true
        pcall(initGhostMode)
    end
end

    _G.VRILZ_Features = Features

return Features
