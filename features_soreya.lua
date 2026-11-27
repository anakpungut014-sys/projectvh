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
-- 🎣 AUTO FISH v8.1 — HIDE FISHING MINIGAME ONLY (CRASH FIX)
-- ============================================================
-- FIX v8.1:
--  ✅ CRASH FIX: "Visible is not a valid member of ScreenGui"
--     (ternary trap → sekarang cek tipe + pcall, mustahil error)
--  ✅ Auto-learn diperketat: cuma GUI yang BARU DIBUAT pas minigame
--     (Backpack yang cuma di-enable nggak kelearn lagi)
--  ✅ blacklist += "backpack"
--  ✅ Cuma GUI minigame mancing yang dihide, GUI lain aman
-- ============================================================

local RS         = game:GetService("ReplicatedStorage")
local VIM        = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
Shared = Shared or {}

-- ⚙ CONFIG
local SPEED_MIN = 0
local SPEED_MAX = 0.5
local SPEED_DEFAULT = 0.1

local function clampSpeed(v)
    v = tonumber(v) or SPEED_DEFAULT
    if v < SPEED_MIN then v = SPEED_MIN end
    if v > SPEED_MAX then v = SPEED_MAX end
    return v
end

local function isPremiumUser()
    if not Shared then return false end
    local kt = tostring(Shared.KeyType or ""):upper()
    return kt == "PREMIUM" or kt == "OWNER" or kt == "VIP"
end

local function isTurboOn()
    return isPremiumUser() and Shared and Shared.AutoFish_Turbo == true
end

local FishSpeed = {
    reelMaxTime = 8,
    castCooldown = SPEED_DEFAULT,
    castPowerWait = 0,
    loopDelay = 0.02,
    tapsPerFrame = 12,
}

local function applyTurboSpeed(v)
    v = clampSpeed(v)
    FishSpeed.castCooldown = 0
    FishSpeed.castPowerWait = 0
    FishSpeed.loopDelay = 0
    FishSpeed.tapsPerFrame = tonumber(Shared and Shared.AutoFish_Taps) or 10
end

-- ⭐ Speed normal (Turbo OFF / non-premium)
local function applyNormalSpeed()
    FishSpeed.castCooldown = 0.15
    FishSpeed.castPowerWait = 0.15
    FishSpeed.loopDelay = 0.05
    FishSpeed.tapsPerFrame = 5
end

-- ⭐ Recompute berdasarkan Turbo + premium
local function refreshSpeed()
    if isTurboOn() then
        applyTurboSpeed(Shared.AutoFish_Speed or SPEED_DEFAULT)
    else
        applyNormalSpeed()
    end
end

-- ⭐ Legacy (input manual)
_G.VRILZ_ApplyFishSpeed = function(v)
    if not isPremiumUser() then return end
    if Shared then
        Shared.AutoFish_Speed = clampSpeed(v)
        -- reset preset biar fallback
        Shared.AutoFish_Taps = nil
        Shared.AutoFish_Loop = nil
    end
    refreshSpeed()
end

-- ⭐ BARU: dipanggil dari dropdown preset
_G.VRILZ_ApplyFishPreset = function(cd, taps, loopDelay)
    if not isPremiumUser() then return end
    if Shared then
        Shared.AutoFish_Speed = clampSpeed(cd)
        Shared.AutoFish_Taps  = tonumber(taps) or 12
        Shared.AutoFish_Loop  = tonumber(loopDelay) or 0.02
        -- ⭐ TIDAK auto ON Turbo — user harus ON manual
    end
    -- Gak apply langsung — nunggu Turbo ON
    -- refreshSpeed() akan apply kalau isTurboOn() = true
end

-- Init awal
if Shared and Shared.AutoFish_Speed == nil then
    Shared.AutoFish_Speed = SPEED_DEFAULT
end
-- ⭐ Init AutoFish OFF
if Shared and Shared.AutoFish_Enabled == nil then
    Shared.AutoFish_Enabled = false
end
-- ⭐ Init Turbo OFF
if Shared and Shared.AutoFish_Turbo == nil then
    Shared.AutoFish_Turbo = false
end
refreshSpeed()

local FishState = {
    enabled = false,
    autoEquip = true, autoCast = true, autoPerfect = true, autoReel = true,
    reeling = false, reelAbort = false,
    stats = { cast = 0, caught = 0, perfect = 0, fail = 0 },
    status = "Idle", lastCastTime = 0, lastBiteTime = 0,
}

-- 📦 MODULE
local FishMiniGame, FishPowerBar
pcall(function() FishMiniGame  = require(RS.Modules.Fishing.MiniGameHandler)  end)
pcall(function() FishPowerBar = require(RS.Modules.Fishing.PowerBarHandler) end)

-- 🔧 ROD HELPERS
local function isFishingRod(tool)
    return tool and tool:IsA("Tool") and tool:FindFirstChild("Mechanics") ~= nil
end
local function getEquippedRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if isFishingRod(t) then return t end
    end
end
local function findRodInBackpack()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    for _, t in ipairs(bp:GetChildren()) do
        if isFishingRod(t) then return t end
    end
end
local function getStatusValue(rod, name)
    local mech = rod and rod:FindFirstChild("Mechanics")
    local s = mech and mech:FindFirstChild("Status")
    local v = s and s:FindFirstChild(name)
    return (v and v.Value) or false
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
    if getStatusValue(rod, "FishingActive") or getStatusValue(rod, "MiniGameActive") then return false end
    local remotes = getRodRemotes(rod)
    local castEvent = remotes and remotes:FindFirstChild("CastEvent")
    if not castEvent then FishState.status = "❌ CastEvent tidak ada"; return false end
    FishState.status = "Casting..."
    pcall(function()
        castEvent:FireServer(true)
        -- ⚡ kalau castPowerWait = 0 → langsung fire, gak nunggu frame
        if FishSpeed.castPowerWait > 0 then
            task.wait(FishSpeed.castPowerWait)
        end
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
            VIM:SendMouseButtonEvent(0, 0, 0, true,  game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

-- ============================================================
-- 🙈 HIDE — FISHING MINIGAME ONLY (CRASH-PROOF)
-- ============================================================
local HideMini = {
    enabled   = true,
    keywords  = { "minigame", "reel", "fishbar", "catch", "fishing" },
    blacklist = { "vrilz", "backpack" },  -- ⭐ GUI sendiri + backpack → JANGAN dihide
}

local knownExact = {}   -- [namaLower] = true
local hiddenNow  = {}   -- [instance] = {prop, val}
local hiding     = false
local prevSnap   = nil

local function isBlacklisted(n)
    n = n:lower()
    for _, b in ipairs(HideMini.blacklist) do
        if n:find(b:lower(), 1, true) then return true end
    end
    return false
end

local function isTarget(name)
    if isBlacklisted(name) then return false end
    local n = name:lower()
    if knownExact[n] then return true end
    for _, k in ipairs(HideMini.keywords) do
        if n:find(k:lower(), 1, true) then return true end
    end
    return false
end

local function learn(name)
    if isBlacklisted(name) then return end
    local n = name:lower()
    if not knownExact[n] then
        knownExact[n] = true
        print("[HideMini] 🧠 Learned:", name)
    end
end

-- ⭐ FIX CRASH: cek tipe dulu + pcall → ScreenGui nggak pernah kena "Visible"
local function hardHide(inst, prop)
    if hiddenNow[inst] then return end
    if prop == "Enabled" then
        if not inst:IsA("ScreenGui") then return end
        local ok, cur = pcall(function() return inst.Enabled end)
        if not ok then return end
        hiddenNow[inst] = { prop = "Enabled", val = cur }
        inst.Enabled = false
    else
        if not inst:IsA("GuiObject") then return end  -- ScreenGui bukan GuiObject → aman
        local ok, cur = pcall(function() return inst.Visible end)
        if not ok then return end
        hiddenNow[inst] = { prop = "Visible", val = cur }
        inst.Visible = false
    end
end

local function hideTargets()
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and not isBlacklisted(g.Name) then
            if isTarget(g.Name) then
                hardHide(g, "Enabled")
            end
            for _, c in ipairs(g:GetChildren()) do
                if c:IsA("ScreenGui") then
                    if isTarget(c.Name) then hardHide(c, "Enabled") end
                elseif c:IsA("GuiObject") then
                    if isTarget(g.Name .. "/" .. c.Name) or isTarget(c.Name) then
                        hardHide(c, "Visible")
                    end
                end
            end
        end
    end
end

local function restoreAll()
    for inst, st in pairs(hiddenNow) do
        pcall(function()
            if inst and inst.Parent then
                if st.prop == "Enabled" then inst.Enabled = st.val
                else inst.Visible = st.val end
            end
        end)
    end
    table.clear(hiddenNow)
end

-- snapshot: gui apa aja yang UDAH ADA (buat deteksi yang baru dibuat)
local function takeSnap()
    local snap = {}
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") then snap[g] = true end
    end
    return snap
end

-- 👀 WATCHER (tiap 0.05s)
task.spawn(function()
    while true do
        task.wait(0.05)
        local rod = getEquippedRod()
        local active = HideMini.enabled
            and ((rod and getStatusValue(rod, "MiniGameActive")) or false)

        if not active then
            if hiding then hiding = false; restoreAll() end  -- ⭐ minigame selesai → balik
            prevSnap = takeSnap()
        else
            hiding = true
            -- ⭐ cuma GUI yang BARU DIBUAT pas minigame → learn + hide
            --    (GUI lama yang cuma di-enable kayak Backpack → DIABAIKAN)
            if prevSnap then
                for _, g in ipairs(PlayerGui:GetChildren()) do
                    if g:IsA("ScreenGui") and not prevSnap[g] and not isBlacklisted(g.Name) then
                        learn(g.Name)
                        hardHide(g, "Enabled")
                    end
                end
            end
            prevSnap = takeSnap()
            hideTargets()  -- hide target: keyword / sniffed / manual
        end
    end
end)

-- 🧠 SNIFF: ambil nama GUI langsung dari MiniGameHandler (dicek tiap 2s)
task.spawn(function()
    local function reg(v)
        if typeof(v) == "Instance" then
            if v:IsA("ScreenGui") then
                if not isBlacklisted(v.Name) then learn(v.Name) end
            elseif v:IsA("GuiObject") then
                local sg = v:FindFirstAncestorOfClass("ScreenGui")
                if sg and not isBlacklisted(sg.Name) then
                    learn(sg.Name .. "/" .. v.Name)
                end
            end
        end
    end
    while true do
        if FishMiniGame then
            pcall(function() for _, v in pairs(FishMiniGame) do reg(v) end end)
            local getuv = getupvalues or getupvals
            if getuv then
                pcall(function()
                    for _, f in pairs(FishMiniGame) do
                        if type(f) == "function" then
                            for _, uv in ipairs(getuv(f)) do reg(uv) end
                        end
                    end
                end)
            end
        end
        task.wait(2)
    end
end)

-- 🔎 DEBUG: jalankan pas minigame muncul → liat semua nama GUI
_G.VRILZ_DebugGui = function()
    print("=== PlayerGui ===")
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") then
            print(("%-32s Enabled=%s"):format(g.Name, tostring(g.Enabled)))
            for _, c in ipairs(g:GetChildren()) do
                if c:IsA("GuiObject") then
                    print(("   └ %-30s Visible=%s"):format(c.Name, tostring(c.Visible)))
                end
            end
        end
    end
end
-- manual: _G.VRILZ_HideMiniAdd("NamaGui") / ("NamaGui/NamaFrame")
_G.VRILZ_HideMiniAdd = function(n) learn(n) end
-- kalau ada yang kelearn salah: _G.VRILZ_HideMiniRemove("NamaGui")
_G.VRILZ_HideMiniRemove = function(n)
    knownExact[n:lower()] = nil
    print("[HideMini] removed:", n)
end

local recasting = false
local function recastNow()
    if recasting or not FishState.enabled or not FishState.autoCast then return end
    recasting = true
    task.spawn(function()
        for _ = 1, 30 do
            local rod = getEquippedRod()
            if not FishState.enabled or not rod then break end
            if not getStatusValue(rod, "FishingActive")
               and not getStatusValue(rod, "MiniGameActive") then
                FishState.lastCastTime = 0
                if autoCast() then break end
            end
            RunService.Heartbeat:Wait()
        end
        recasting = false
    end)
end

-- ============================================================
-- ⚡ REEL — MULTI-TAP PER FRAME
-- ============================================================
local function doReelSpam()
    if FishState.reeling then return end
    FishState.reeling   = true
    FishState.reelAbort = false
    local rod   = getEquippedRod()
    local start = os.clock()
    local taps  = 0
    FishState.status = "⚡ MULTI-TAP REEL..."

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
                if miss >= 1 then break end
            end
        end

        for _ = 1, FishSpeed.tapsPerFrame do
            tapOnce()
            taps += 1
        end

        RunService.Heartbeat:Wait()
    end

    local dur = os.clock() - start
    FishState.reeling = false
    FishState.status = string.format("✅ Reel %.1fs (%d tap) → cast lagi", dur, taps)
    recastNow()
end

-- ============================================================
-- 🪝 HOOK EVENT ROD
-- ============================================================
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
        -- ⭐ hide INSTAN pas minigame mulai
        if action == "Start" and HideMini.enabled then
            hideTargets()
        end
        if not FishState.enabled then return end
        if action == "Start" then
            FishState.lastBiteTime = os.clock()
            if not FishState.reeling then
                task.spawn(doReelSpam)
            end
                elseif action == "Stop" then
            FishState.reelAbort = true
            FishState.status = "Reel done"
            recastNow()
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
            recastNow()
        elseif action == "CastFailed" then
            FishState.stats.fail += 1
            FishState.status = "❌ Cast failed"
        elseif action == "NoFishingZone" then
            FishState.status = "⚠ Not in fishing zone"
        end
    end)
end

-- ============================================================
-- 🔁 MAIN LOOP
-- ============================================================
local function startFishLoop()
    task.spawn(function()
        while true do
            -- ⚡ kalau loopDelay <= 0.01, pakai Heartbeat (lebih responsif)
            if FishSpeed.loopDelay <= 0.01 then
                RunService.Heartbeat:Wait()
            else
                task.wait(FishSpeed.loopDelay)
            end
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
                and not FishState.reeling then
                FishState.lastBiteTime = os.clock()
                task.spawn(doReelSpam)
            end
        end
    end)
end

-- ============================================================
-- 🌐 EXPORT API
-- ============================================================
_G.VRILZ_FishState = FishState
_G.VRILZ_HideMini  = HideMini
_G.VRILZ_FishUI = {
    setStatus  = function(s) FishState.status = s end,
    setEnabled = function(v) FishState.enabled = v and true or false end,
    toggle     = function() FishState.enabled = not FishState.enabled end,
    isEnabled  = function() return FishState.enabled end,
    setHideMinigame = function(v)
        HideMini.enabled = v and true or false
        if not HideMini.enabled then restoreAll() end
    end,
    isHideMinigame  = function() return HideMini.enabled end,
}

-- ============================================================
-- 🚀 INIT
-- ============================================================
local function initAutoFish()
    startFishLoop()

    -- 🔄 sinkron toggle AutoFish → HideMinigame (Ghost Mode TIDAK diaktifin)
    task.spawn(function()
        while true do
            task.wait(0.3)
            refreshSpeed()

            local wantOn = (Shared.AutoFish_Enabled == true)
            if wantOn ~= FishState.enabled then
                if wantOn then
                    FishState.autoEquip   = true
                    FishState.autoCast    = true
                    FishState.autoPerfect = true
                    FishState.autoReel    = true
                    FishState.reelAbort   = false
                    FishState.enabled     = true
                    -- ⭐ Ghost Mode TIDAK diaktifin (biar gak pake anchor + clone)
                    HideMini.enabled         = true   -- ⭐ Hide ON
                    local rod = getEquippedRod()
                    if rod and getStatusValue(rod, "MiniGameActive") then
                        hideTargets()
                    end
                else
                    FishState.enabled   = false
                    FishState.reelAbort = true
                    -- ⭐ Ghost Mode TIDAK dimatiin
                    HideMini.enabled         = false  -- ⭐ Hide OFF
                    restoreAll()                      -- ⭐ GUI minigame balik normal
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
-- 🌐 AUTO JOIN SERVER — SEPI + REJOIN + JOB ID
-- ============================================================
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local JoinState = {
    enabled     = false,
    mode        = "server",
    keyword     = "",
    placeId     = nil,
    maxServers  = 150,
    retryDelay  = 5,
    retryCount  = 0,
    maxRetry    = 60,
    status      = "Idle",
    joining     = false,
    userIdCache = {},
}

local REJOIN_FILE = "vrilz_last_jobid.txt"

local function joinHttpGet(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(function() return req({ Url = url, Method = "GET" }) end)
        if ok and res and res.Body then return res.Body end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok then return body end
    return nil
end

local function joinHttpPost(url, bodyTable)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end
    local ok, res = pcall(function()
        return req({
            Url = url, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(bodyTable),
        })
    end)
    if ok and res and res.Body then return res.Body end
    return nil
end

local function joinResolveUserId(username)
    if not username or username == "" then return nil end
    local key = username:lower()
    if JoinState.userIdCache[key] then return JoinState.userIdCache[key] end
    local body = joinHttpPost("https://users.roblox.com/v1/usernames/users", {
        usernames = { username }, excludeBannedUsers = false,
    })
    if not body then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data or #data.data == 0 then return nil end
    local uid = tonumber(data.data[1].id)
    if uid then JoinState.userIdCache[key] = uid end
    return uid
end

local function joinScanServers(placeId, cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?limit=100&sortOrder=Desc%s",
        placeId, cursor and ("&cursor=" .. cursor) or ""
    )
    local body = joinHttpGet(url)
    if not body then return nil, "HTTP failed" end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then return nil, "decode failed" end
    return data.data, nil, data.nextPageCursor
end

local function joinCheckPlayerInServer(placeId, jobId, targetUsername)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/%s/players",
        placeId, jobId
    )
    local body = joinHttpGet(url)
    if not body then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then return false end
    local kw = targetUsername:lower()
    for _, p in ipairs(data.data) do
        if tostring(p.name or ""):lower() == kw then return true, p end
        if tostring(p.displayName or ""):lower() == kw then return true, p end
    end
    return false
end

local function joinFindServer(placeId, mode, keyword, maxScan)
    maxScan = maxScan or 150

        if mode == "jobid" then
        if not keyword or keyword == "" then return nil, "Server ID empty" end
        local raw = keyword:gsub("%s+", "")
        local isValid = raw:match(
            "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
        )
        if not isValid then
            return nil, "Invalid Server ID format (must be UUID)"
        end
        return { id = raw, name = "Manual Server ID", playing = 0, maxPlayers = 0 }, nil, 1
    end
    
    if mode == "server" then
        local scanned, cursor, candidates = 0, nil, {}
        while scanned < maxScan do
            local servers, err, nextCursor = joinScanServers(placeId, cursor)
            if not servers then return nil, err end
            if #servers == 0 then break end
            for _, srv in ipairs(servers) do
                scanned = scanned + 1
                local playing = tonumber(srv.playing) or 0
                local maxP = tonumber(srv.maxPlayers) or 0
                if playing >= 1 and playing < maxP then
                    table.insert(candidates, srv)
                end
                if scanned >= maxScan then break end
            end
            if not nextCursor or nextCursor == "" then break end
            cursor = nextCursor
            task.wait(0.25)
        end
        if #candidates == 0 then
            return nil, string.format("Tidak ada server sepi (scan %d)", scanned)
        end
        table.sort(candidates, function(a, b)
            local pa = tonumber(a.playing) or 0
            local pb = tonumber(b.playing) or 0
            if pa ~= pb then return pa < pb end
            return (tonumber(a.maxPlayers) or 0) > (tonumber(b.maxPlayers) or 0)
        end)
        return candidates[1], nil, #candidates
    end

    if mode == "player" then
        local scanned, cursor = 0, nil
        while scanned < maxScan do
            local servers, err, nextCursor = joinScanServers(placeId, cursor)
            if not servers then return nil, err end
            if #servers == 0 then break end
            for _, srv in ipairs(servers) do
                scanned = scanned + 1
                if (tonumber(srv.playing) or 0) > 0 and srv.id then
                    local found = joinCheckPlayerInServer(placeId, srv.id, keyword)
                    if found then
                        JoinState.status = "🎯 Ketemu '" .. keyword .. "' di " .. tostring(srv.id):sub(1, 8)
                        return srv, nil, 1
                    end
                end
                if scanned >= maxScan then break end
                task.wait(0.15)
            end
            if not nextCursor or nextCursor == "" then break end
            cursor = nextCursor
            task.wait(0.3)
        end
        return nil, string.format("Player '%s' tidak ketemu (scan %d)", keyword, scanned)
    end

    return nil, "Mode invalid"
end

local function saveLastJobId(jobId, placeId)
    if not jobId then return end
    _G.VRILZ_LastJobId = { jobId = jobId, placeId = placeId or game.PlaceId }
    if writefile then
        pcall(writefile, REJOIN_FILE, jobId .. "|" .. tostring(placeId or game.PlaceId))
    end
end

local function loadLastJobId()
    if _G.VRILZ_LastJobId then return _G.VRILZ_LastJobId end
    if readfile and isfile then
        local ok, exists = pcall(isfile, REJOIN_FILE)
        if ok and exists then
            local okR, content = pcall(readfile, REJOIN_FILE)
            if okR and content then
                local jid, pid = content:match("^([^|]+)|(%d+)$")
                if jid then
                    _G.VRILZ_LastJobId = { jobId = jid, placeId = tonumber(pid) }
                    return _G.VRILZ_LastJobId
                end
            end
        end
    end
    return nil
end

local function joinDoJoin(server)
    if not server or not server.id then
        JoinState.status = "❌ Server invalid"
        return false
    end
    if JoinState.joining then return false end
    JoinState.joining = true
    JoinState.status = string.format("🚀 Join '%s' (%d/%d)...",
        tostring(server.name or "?"), tonumber(server.playing) or 0, tonumber(server.maxPlayers) or 0)
    local placeId = JoinState.placeId or game.PlaceId
    saveLastJobId(server.id, placeId)
    task.spawn(function()
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
        end)
        if not ok then
            JoinState.status = "❌ Teleport gagal: " .. tostring(err)
            JoinState.joining = false
        end
    end)
    return true
end

local function joinRejoinNow()
    local last = loadLastJobId()
    if not last then
        JoinState.status = "❌ Belum ada JobId tersimpan"
        return false, "no saved jobid"
    end
    JoinState.status = "🔄 Rejoin ke server terakhir..."
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(last.placeId, last.jobId, LocalPlayer)
    end)
    if not ok then
        JoinState.status = "❌ Rejoin gagal: " .. tostring(err)
        return false, tostring(err)
    end
    return true
end

local function joinStartLoop()
    task.spawn(function()
        while true do
            task.wait(1)
            if not JoinState.enabled then JoinState.retryCount = 0; continue end
            if JoinState.joining then continue end
            if JoinState.mode == "player" and JoinState.keyword == "" then
                JoinState.status = "⚠ Username kosong"
                continue
            end
            if JoinState.mode == "jobid" and JoinState.keyword == "" then
                JoinState.status = "⚠ Job ID kosong"
                continue
            end
            if JoinState.retryCount >= JoinState.maxRetry then
                JoinState.status = "❌ Gagal setelah " .. JoinState.maxRetry .. "x"
                JoinState.enabled = false
                if Shared then Shared.AutoJoin_Enabled = false end
                continue
            end
            JoinState.retryCount = JoinState.retryCount + 1
            JoinState.status = string.format("🔍 Scan #%d (%s)...", JoinState.retryCount, JoinState.mode)
            local placeId = JoinState.placeId or game.PlaceId
            local server, err = joinFindServer(placeId, JoinState.mode, JoinState.keyword, JoinState.maxServers)
            if server then
                JoinState.status = "✅ Ketemu! Join..."
                joinDoJoin(server)
                return
            else
                JoinState.status = string.format("⏳ %s — retry %ds", err or "not found", JoinState.retryDelay)
                task.wait(JoinState.retryDelay)
            end
        end
    end)
end

local function joinNow(mode, keyword, placeId)
    JoinState.mode = mode or JoinState.mode
    JoinState.keyword = keyword or JoinState.keyword or ""
    JoinState.placeId = placeId or JoinState.placeId
    JoinState.retryCount = 0
    JoinState.joining = false
    if JoinState.mode == "player" then
        if JoinState.keyword == "" then
            JoinState.status = "⚠ Username kosong"
            return false, "empty"
        end
        local uid = joinResolveUserId(JoinState.keyword)
        if not uid then
            JoinState.status = "❌ Username tidak ditemukan"
            return false, "username not found"
        end
    end
    if JoinState.mode == "jobid" then
        if JoinState.keyword == "" then
            JoinState.status = "⚠ Server ID empty"
            return false, "empty"
        end
        local raw = JoinState.keyword:gsub("%s+", "")
        local isValid = raw:match(
            "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
        )
        if not isValid then
            JoinState.status = "❌ Invalid Server ID (UUID required)"
            return false, "invalid uuid"
        end
        JoinState.keyword = raw
    end
    JoinState.status = "🔍 Manual scan (" .. JoinState.mode .. ")..."
    local server, err = joinFindServer(JoinState.placeId or game.PlaceId, JoinState.mode, JoinState.keyword, JoinState.maxServers)
    if server then
        joinDoJoin(server)
        return true
    else
        JoinState.status = "❌ " .. (err or "not found")
        return false, err
    end
end

local function initAutoJoin()
    loadLastJobId()
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not Shared then continue end
            local wantOn = Shared.AutoJoin_Enabled == true
            if wantOn ~= JoinState.enabled then
                if wantOn then
                    JoinState.mode = Shared.AutoJoin_Mode or "server"
                    JoinState.keyword = Shared.AutoJoin_Keyword or ""
                    JoinState.placeId = Shared.AutoJoin_PlaceId
                    JoinState.maxServers = tonumber(Shared.AutoJoin_MaxScan) or 150
                    JoinState.retryDelay = tonumber(Shared.AutoJoin_RetryDelay) or 5
                    JoinState.maxRetry = tonumber(Shared.AutoJoin_MaxRetry) or 60
                    JoinState.retryCount = 0
                    JoinState.joining = false
                    JoinState.enabled = true
                    joinStartLoop()
                else
                    JoinState.enabled = false
                    JoinState.status = "⏹ Stopped"
                end
            end
        end
    end)

    _G.VRILZ_AutoJoin = {
        JoinNow = joinNow,
        RejoinNow = joinRejoinNow,
        GetState = function() return JoinState end,
        SetMode = function(m) JoinState.mode = m end,
        SetKeyword = function(k) JoinState.keyword = k end,
        SetPlaceId = function(p) JoinState.placeId = tonumber(p) end,
        ResolveUser = joinResolveUserId,
        GetLastJobId = loadLastJobId,
    }
end

-- ============================================================
-- 🏔 SOLO SUMMIT MODE
-- ============================================================
local SoloState = {
    enabled = false,
    clone = nil,
    savedTransp = {},
    savedDisplay = nil,
    status = "⏸️ Idle",
    loopCount = 0,
    summitCount = 0,
}

local function soloRoot()
    local ch = LocalPlayer.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

-- ═══ HIDE real char (transparency=1, TANPA lock speed/anchor) ═══
local function soloHideRealChar()
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if SoloState.savedTransp[d] == nil then
                SoloState.savedTransp[d] = d.Transparency
            end
            d.Transparency = 1
            d.LocalTransparencyModifier = 1
        elseif d:IsA("Decal") then
            if SoloState.savedTransp[d] == nil then
                SoloState.savedTransp[d] = d.Transparency
            end
            d.Transparency = 1
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if SoloState.savedDisplay == nil then
            SoloState.savedDisplay = hum.DisplayDistanceType
        end
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

local function soloRestoreRealChar()
    local char = LocalPlayer.Character
    if not char then return end
    for d, t in pairs(SoloState.savedTransp) do
        if d and d.Parent then
            d.Transparency = t
            d.LocalTransparencyModifier = 0
        end
    end
    SoloState.savedTransp = {}
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and SoloState.savedDisplay then
        hum.DisplayDistanceType = SoloState.savedDisplay
        SoloState.savedDisplay = nil
    end
end

-- ═══ SPAWN CLONE di CP1 + camera nempel clone ═══
local function soloSpawnClone()
    if SoloState.clone then
        SoloState.clone:Destroy()
        SoloState.clone = nil
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

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
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.PlatformStand = true
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

    -- Pivot ke CP1
    local cp1 = SummitCheckpoints[1].position
    local offset = Vector3.new(0, SummitCfg.TPHeight, 0)
    clone:PivotTo(CFrame.new(cp1 + offset))

    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.Massless = true
        end
    end

    clone.Name = char.Name
    clone.Parent = workspace
    SoloState.clone = clone

    -- camera nempel clone HRP
    local cam = workspace.CurrentCamera
    local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
    if cam and cloneHRP then
        cam.CameraSubject = cloneHRP
    end
end

local function soloDestroyClone()
    if SoloState.clone then
        SoloState.clone:Destroy()
        SoloState.clone = nil
    end
end

-- ═══ TP STEP-BY-STEP TANPA ANCHOR ═══
local function soloTpStepByStep(targetPos, label)
    local root = soloRoot()
    if not root then return false end

    local target = targetPos + Vector3.new(0, SummitCfg.TPHeight, 0)
    local startPos = root.Position
    local totalDist = (target - startPos).Magnitude
    local steps = math.ceil(totalDist / SummitCfg.StepDistance)
    if steps < 1 then steps = 1 end

    local dir = target - startPos
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 1 then
        dir = Vector3.new(0, 0, -1)
    else
        dir = dir.Unit
    end

    -- ⭐ CFrame langsung TANPA Anchored
    for i = 1, steps do
        if not SoloState.enabled then return false end
        local r = soloRoot()
        if not r then return false end
        local dist = math.min(SummitCfg.StepDistance * i, totalDist)
        local pos = startPos + dir * dist + Vector3.new(0, SummitCfg.TPHeight, 0)
        pos = Vector3.new(pos.X, target.Y, pos.Z)
        r.CFrame = CFrame.new(pos)
        r.Velocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero
        SoloState.status = string.format("%s [%d/%d] (no-anchor)", label or "TP", i, steps)
        task.wait(SummitCfg.WaitBetweenStep)
    end

    local r = soloRoot()
    if r then
        r.CFrame = CFrame.new(target)
        r.Velocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end

-- ═══ ANCHOR PAS NYAMPE CP (0.3s → unanchor) ═══
local function soloAnchorAtCP()
    local root = soloRoot()
    if not root then return end
    root.Anchored = true
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.3)
    root.Anchored = false
end

-- ═══ MAIN LOOP ═══
local function soloMainLoop()
    for i = math.floor(SummitCfg.StartRenderDelay), 1, -1 do
        if not SoloState.enabled then return end
        SoloState.status = "⏳ Render... (" .. i .. "s)"
        task.wait(1)
    end

    local startNum = tonumber(Shared.AutoSummit_StartCP) or 1
    if startNum < 1 then startNum = 1 end
    if startNum > #SummitCheckpoints then startNum = #SummitCheckpoints end

    while SoloState.enabled do
        SoloState.loopCount += 1
        local n = SoloState.loopCount

        for i = startNum, #SummitCheckpoints do
            if not SoloState.enabled then return end
            local cp = SummitCheckpoints[i]
            SoloState.status = "🏔️ Solo Loop #" .. n .. " — CP " .. cp.number

            soloTpStepByStep(cp.position, "CP " .. cp.number)
            task.wait(0.15)
            soloAnchorAtCP()

            SoloState.status = "✅ CP " .. cp.number .. " done"
            task.wait(SummitCfg.WaitBetweenCP)
        end

        if not SoloState.enabled then return end

        SoloState.status = "⭐ Loop #" .. n .. " — SUMMIT"
        soloTpStepByStep(SummitTopPos, "SUMMIT")
        task.wait(0.15)
        soloAnchorAtCP()
        SoloState.summitCount += 1

        task.wait(SummitCfg.SummitWaitBeforeReturn)
        if not SoloState.enabled then return end

        SoloState.status = "🏠 Balik ke BackBC..."
        soloTpStepByStep(SummitBackBCPos, "🏠 BackBC")
        task.wait(0.15)
        soloAnchorAtCP()
        task.wait(SummitCfg.WaitAtBackBC)

        startNum = 1
        task.wait(0.5)
    end
end

local function initSoloSummit()
    task.spawn(function()
        while true do
            task.wait(0.3)
            if not Shared then continue end
            local wantOn = Shared.SoloSummit_Enabled == true

            if wantOn and not SoloState.enabled then
                if Shared.AutoSummit_Enabled == true then
                    Shared.AutoSummit_Enabled = false
                    task.wait(0.8)
                end
                if Shared.GhostMode_Enabled == true then
                    Shared.GhostMode_Enabled = false
                    task.wait(0.5)
                end
                SoloState.enabled = true
                SoloState.status = "🚀 Starting Solo Mode..."
                soloSpawnClone()
                task.wait(0.3)
                soloHideRealChar()
                task.spawn(soloMainLoop)
            elseif not wantOn and SoloState.enabled then
                SoloState.enabled = false
                SoloState.status = "⏹ Stopping..."
                soloDestroyClone()
                soloRestoreRealChar()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local cam = workspace.CurrentCamera
                if cam and hum then cam.CameraSubject = hum end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        SoloState.savedTransp = {}
        SoloState.savedDisplay = nil
        if SoloState.enabled then
            task.wait(2)
            soloSpawnClone()
            soloHideRealChar()
        end
    end)

    _G.VRILZ_SoloState = SoloState
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
        -- ⭐ AUTO JOIN
    if not Features._autoJoinStarted then
        Features._autoJoinStarted = true
        pcall(initAutoJoin)
    end
    -- ⭐ SOLO SUMMIT MODE
    if not Features._soloSummitStarted then
        Features._soloSummitStarted = true
        pcall(initSoloSummit)
    end
end

    _G.VRILZ_Features = Features

return Features
