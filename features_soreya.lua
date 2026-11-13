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
-- 🎣 AUTO FISH v5 — MULTI-TAP PER FRAME
-- ============================================================
local RS      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local VIM     = game:GetService("VirtualInputManager")

local FishSpeed = {
    reelMaxTime   = 8,
    castCooldown  = 0.15,
    castPowerWait = 0.15,
    loopDelay     = 0.05,
    tapsPerFrame  = 5,    -- ⚡⚡ 5 tap TIAP FRAME ≈ 300 tap/detik
}

local FishState = {
    enabled = false,
    autoEquip = true, autoCast = true, autoPerfect = true, autoReel = true,
    reeling = false, reelAbort = false,
    stats = { cast = 0, caught = 0, perfect = 0, fail = 0 },
    status = "Idle", lastCastTime = 0, lastBiteTime = 0,
}

local FishMiniGame, FishPowerBar
pcall(function() FishMiniGame  = require(RS.Modules.Fishing.MiniGameHandler)  end)
pcall(function() FishPowerBar = require(RS.Modules.Fishing.PowerBarHandler) end)

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

local function autoEquipRod()
    if getEquippedRod() then return true end
    local rod = findRodInBackpack()
    if not rod then FishState.status = "❌ Rod tidak terdeteksi"; return false end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    FishState.status = "Equipping " .. rod.Name
    pcall(function() hum:EquipTool(rod) end)
    task.wait(0.3)
    return getEquippedRod() ~= nil
end

local function autoCast()
    local rod = getEquippedRod()
    if not rod then return false end
    if getStatusValue(rod, "FishingActive") then return false end
    if getStatusValue(rod, "MiniGameActive") then return false end
    local remotes = getRodRemotes(rod)
    local castEvent = remotes and remotes:FindFirstChild("CastEvent")
    if not castEvent then FishState.status = "❌ CastEvent tidak ada"; return false end
    FishState.status = "Casting..."
    pcall(function()
        castEvent:FireServer(true)
        task.wait(FishSpeed.castPowerWait)
        castEvent:FireServer(false, 100, Vector3.new(0, 0, -1))
    end)
    FishState.stats.cast += 1
    FishState.lastCastTime = os.clock()
    return true
end

local function tapOnce()
    if FishMiniGame and FishMiniGame.MobileTap then
        pcall(function() FishMiniGame.MobileTap() end)
    else
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

-- ⚡⚡ REEL — 5 TAP PER FRAME (nembus batas 60 tap/detik)
local function doReelSpam()
    if FishState.reeling then return end
    FishState.reeling = true
    FishState.reelAbort = false
    local rod = getEquippedRod()
    local start = os.clock()
    local taps = 0
    FishState.status = "⚡⚡ MULTI-TAP REEL..."

    local miss = 0
    local minigameSeen = false

    while FishState.enabled
        and not FishState.reelAbort
        and os.clock() - start < FishSpeed.reelMaxTime do

        if rod then
            if getStatusValue(rod, "MiniGameActive") then
                minigameSeen = true
                miss = 0
            elseif minigameSeen then
                miss += 1
                if miss >= 2 then break end
            end
        end

        -- ⚡⚡ INTI: beberapa tap dalam 1 frame
        for _ = 1, FishSpeed.tapsPerFrame do
            tapOnce()
            taps += 1
        end

        RunService.Heartbeat:Wait()
    end

    local dur = os.clock() - start
    FishState.reeling = false
    FishState.status = string.format("✅ Reel %.1fs (%d tap) → cast lagi", dur, taps)
end

local fishHookedRods = {}
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
        if action == "Start" then
            FishState.lastBiteTime = os.clock()
            if not FishState.reeling then
                task.spawn(doReelSpam)
            end
        elseif action == "Stop" then
            FishState.reelAbort = true
            FishState.status = "Reel done"
        end
    end)

    notifyClient.OnClientEvent:Connect(function(action, info)
        if not FishState.enabled then return end
        if action == "Bite" then
            FishState.lastBiteTime = os.clock()
            FishState.status = "🐟 Ikan nyangkut! LANGSUNG REEL..."
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

local function startFishLoop()
    task.spawn(function()
        while true do
            task.wait(FishSpeed.loopDelay)
            if not FishState.enabled then continue end
            local char = LocalPlayer.Character
            if not char then FishState.status = "No character"; continue end
            if FishState.autoEquip and not getEquippedRod() then
                autoEquipRod()
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
                autoCast()
            end
            if FishState.autoReel
                and getStatusValue(rod, "MiniGameActive")
                and not FishState.reeling
                and os.clock() - FishState.lastBiteTime > 0 then
                FishState.lastBiteTime = os.clock()
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
                else
                    FishState.enabled   = false
                    FishState.reelAbort = true
                end
            end
        end
    end)
end

-- ============================================================
-- 🏔 AUTO SUMMIT BRIDGE — nyambungin toggle UI ke Auto CP script
-- ============================================================
local function initAutoSummit()
    local wasOn = false
    local VIM = game:GetService("VirtualInputManager")

    task.spawn(function()
        while true do
            task.wait(0.3)
            local wantOn = Shared and Shared.AutoSummit_Enabled == true

            if wantOn ~= wasOn then
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local gui = pg and pg:FindFirstChild("VrilzAutoCP")

                if gui then
                    for _, d in ipairs(gui:GetDescendants()) do
                        if d:IsA("TextButton") and d.Text then
                            local isStart = d.Text:find("START AUTO LOOP") ~= nil
                            local isStop  = d.Text:find("STOP AUTO LOOP")  ~= nil
                            if isStart or isStop then
                                local isRunning = isStop
                                if isRunning ~= wantOn then
                                    -- ⭐ Klik BENERAN pakai VirtualInputManager
                                    pcall(function()
                                        local pos = d.AbsolutePosition
                                        local size = d.AbsoluteSize
                                        local cx = pos.X + size.X / 2
                                        local cy = pos.Y + size.Y / 2
                                        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                                        task.wait(0.05)
                                        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                                    end)
                                end
                                break
                            end
                        end
                    end
                    wasOn = wantOn
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
end

    _G.VRILZ_Features = Features

return Features
