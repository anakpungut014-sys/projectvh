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
                    -- ⭐ AUTO FISH ON → GHOST IKUT ON
                    Shared.GhostMode_Enabled = true
                else
                    FishState.enabled   = false
                    FishState.reelAbort = true
                    -- ⭐ AUTO FISH OFF → GHOST IKUT OFF (char balik normal)
                    Shared.GhostMode_Enabled = false
                end
            end
        end
    end)
end

-- ============================================================
-- 🏔 AUTO SUMMIT — LOGIC TP LANGSUNG + CEPAT (standalone)
-- Gak perlu soreyacp.txt lagi. Cukup Shared.AutoSummit_Enabled = true
-- ============================================================
local SummitCfg = {
    StepDistance = 40,        -- ⚡ lebih gede = lebih cepat (default 25)
    TPHeight = 5,
    WaitBetweenStep = 0.03,   -- ⚡ lebih cepet (default 0.06)
    WaitBetweenCP = 0.15,     -- ⚡ lebih cepet (default 0.4)
    WaitAtBackBC = 0.8,       -- ⚡ lebih cepet (default 1.5)
    SummitWaitBeforeReturn = 1.0,  -- ⚡ lebih cepet (default 2.0)
    StartRenderDelay = 2.0,   -- ⚡ lebih cepet (default 5.0)
    DetectRange = 100,
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

local function summitDetectStart()
    local root = summitRoot()
    if not root then return 1 end
    local pos = root.Position
    local bestCP, bestDist = nil, math.huge
    for _, cp in ipairs(SummitCheckpoints) do
        local d = (pos - cp.position).Magnitude
        if d < bestDist then bestDist = d; bestCP = cp.number end
    end
    if bestDist > SummitCfg.DetectRange then return 1 end
    return bestCP or 1
end

-- ⚡ TP CEPAT: langsung set CFrame per step, tanpa tween
local function summitTpFast(targetPos, label)
    local root = summitRoot()
    if not root then return false end

    -- ⭐ SAFETY: unanchor kalau ghost/dll anchor HRP
    if root.Anchored then root.Anchored = false end

    local startPos = root.Position
    local target = targetPos + Vector3.new(0, SummitCfg.TPHeight, 0)
    local totalDist = (target - startPos).Magnitude

    if totalDist <= SummitCfg.StepDistance then
        root.CFrame = CFrame.new(target)
        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        return true
    end

    local steps = math.ceil(totalDist / SummitCfg.StepDistance)
    local dir = (target - startPos)
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 1 then dir = Vector3.new(0, 0, -1) else dir = dir.Unit end

    -- ⚡ STEP TP — pakai loop minimal wait
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

    local r = summitRoot()
    if r then
        r.CFrame = CFrame.new(target)
        r.Velocity = Vector3.zero
        r.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end

local function summitBackBC()
    local part = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find("back to bc") or n:find("backtobc") or n:find("back bc") then
            if obj:IsA("BasePart") then part = obj; break
            elseif obj:IsA("Model") then
                local p = obj:FindFirstChildWhichIsA("BasePart", true)
                if p then part = p; break end
            end
        end
    end
    if part then SummitBackBCPos = part.Position end
    summitTpFast(SummitBackBCPos, "🏠 BackBC")
    task.wait(SummitCfg.WaitAtBackBC)
end

local function summitMainLoop()
    -- ⚡ Render delay lebih pendek
    for i = math.floor(SummitCfg.StartRenderDelay), 1, -1 do
        if not SummitRun.enabled then return end
        SummitRun.status = "⏳ Render... (" .. i .. "s)"
        task.wait(1)
    end

    local startNum = summitDetectStart()
    SummitRun.status = "🚀 Mulai dari CP " .. startNum

    while SummitRun.enabled do
        SummitRun.loopCount += 1
        local n = SummitRun.loopCount

        -- ⚡ Naik CP — pakai TP cepat
        for i = startNum, #SummitCheckpoints do
            if not SummitRun.enabled then return end
            local cp = SummitCheckpoints[i]
            SummitRun.status = "🏔️ Loop #" .. n .. " — CP " .. cp.number
            summitTpFast(cp.position, "CP " .. cp.number)
            task.wait(SummitCfg.WaitBetweenCP)
        end

        if not SummitRun.enabled then return end

        -- ⚡ Summit
        SummitRun.status = "⭐ Loop #" .. n .. " — SUMMIT"
        summitTpFast(SummitTopPos, "SUMMIT")
        task.wait(SummitCfg.SummitWaitBeforeReturn)
        SummitRun.summitCount += 1
        print("[AUTO SUMMIT] ✅ Summit! Total:", SummitRun.summitCount)

        if not SummitRun.enabled then return end

        -- ⚡ Balik BC
        SummitRun.status = "🏠 Balik ke BackBC..."
        summitBackBC()

        if not SummitRun.enabled then return end

        startNum = 1
        task.wait(0.5)  -- ⚡ jeda antar loop lebih cepet
    end
end

-- ⭐ BRIDGE: baca Shared.AutoSummit_Enabled → jalanin logic TP
local function initAutoSummit()
    task.spawn(function()
        while true do
            task.wait(0.3)
            if not Shared then continue end
            local wantOn = Shared.AutoSummit_Enabled == true

            if wantOn and not SummitRun.enabled then
                -- ⚠️ SAFETY: Ghost Mode anchor HRP → TP gak jalan
                if Shared.GhostMode_Enabled == true then
                    Shared.GhostMode_Enabled = false
                    print("[AUTO SUMMIT] 🔓 Ghost OFF dulu biar TP jalan")
                    task.wait(0.8)
                end
                SummitRun.enabled = true
                SummitRun.status = "🚀 Starting..."
                task.spawn(summitMainLoop)
            elseif not wantOn and SummitRun.enabled then
                SummitRun.enabled = false
                SummitRun.status = "⏹ Stopping..."
            end
        end
    end)

    -- ⭐ Update status ke _G biar UI bisa baca
    _G.VRILZ_SummitState = SummitRun
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
