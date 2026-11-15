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
-- 👻 GHOST MODE — Real char invisible + fake clone diem
-- ============================================================

local GhostState = {
    enabled      = false,
    clone        = nil,
    saved        = {},
    savedDisplay = nil,
}

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
    -- hilangkan nama di atas kepala
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

    -- ⭐ WAJIB: character default-nya Archivable=false → Clone() return NIL
    local oldArch = char.Archivable
    char.Archivable = true
    local ok, clone = pcall(function() return char:Clone() end)
    char.Archivable = oldArch
    if not ok or not clone then return end

    -- bersihkan clone: scripts, humanoid, animate, tool
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
            d:Destroy()
        end
    end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then hum:Destroy() end
    local anim = clone:FindFirstChild("Animate")
    if anim then anim:Destroy() end
    for _, d in ipairs(clone:GetChildren()) do
        if d:IsA("Tool") then d:Destroy() end
    end
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
end

local function ghostEnable()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    ghostCreateClone(char)  -- clone DULU (masih keliatan normal)
    task.wait(0.1)
    ghostHide(char)         -- baru real char di-invisible
    GhostState.enabled = true
end

local function ghostDisable()
    local char = LocalPlayer.Character
    if char then ghostRestore(char) end
    if GhostState.clone then
        GhostState.clone:Destroy()
        GhostState.clone = nil
    end
    GhostState.enabled = false
end

local function initGhostMode()
    -- respawn → re-apply ghost
    LocalPlayer.CharacterAdded:Connect(function()
        if GhostState.enabled then
            task.wait(2)
            pcall(ghostEnable)
        end
    end)

    -- polling loop: ikutin toggle + safety
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
                    -- clone kehapus server → recreate
                    if GhostState.clone and not GhostState.clone.Parent then
                        pcall(ghostCreateClone, char)
                    end
                    -- server force-restore transparency → re-hide
                    if GhostState.clone and GhostState.clone.Parent
                        and hrp.Transparency < 1 then
                        pcall(ghostHide, char)
                    end
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
