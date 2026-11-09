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
-- FEATURES.INIT
-- ============================================================
function Features.Init(sharedState)
    Shared = sharedState

    -- ⭐ Guard: cegah double-start anti-AFK
    if not Features._antiAFKStarted then
        Features._antiAFKStarted = true
        Features.startAntiAFK()
    end
end   -- ⭐⭐⭐ TUTUP Features.Init DI SINI ⭐⭐⭐

-- ============================================================
-- 🥚 EGG FEATURE v7 FINAL — Steal + Rarity Filter + Drop
-- Safe zone: 537.88, 70.66, -355.15
-- Rarity: Common, Uncommon, Rare, Epic, Legendary, Mythic, Secret, Eternal, Divine
-- ============================================================

-- ⭐ SAFE ZONE (posisi lo)
local SAFE_POSITION = Vector3.new(537.88, 70.66, -355.15)

-- ⭐ RARITY LIST (dari lo)
local RARITY_LIST = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary",
    "Mythic", "Secret", "Eternal", "Divine"
}

-- ⭐ RARITY RANK (buat priority — tinggi = lebih baik)
local RARITY_RANK = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
    Mythic = 6, Secret = 7, Eternal = 8, Divine = 9,
}

Features.EggState = {
    AllEggs        = {},
    Zones          = {},
    FilterZones    = {},
    FilterRarities = {},
    AutoSteal      = false,
    SafePosition   = SAFE_POSITION,
    Status         = "Idle",
    Initialized    = false,
}

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")

-- ⭐ Load zone list dari GuardAreas
local function loadZoneList()
    local list = {}
    pcall(function()
        local obj = workspace:FindFirstChild("__OBJECTS")
        local areas = obj and obj:FindFirstChild("Areas")
        local guards = areas and areas:FindFirstChild("GuardAreas")
        if guards then
            for _, zone in ipairs(guards:GetChildren()) do
                table.insert(list, zone.Name)
            end
        end
    end)
    if #list == 0 then
        list = {"Abyss Ocean", "Jungle", "Volcano", "Cosmic", "Forest",
                "Desert", "Snow", "Lake", "Prehistoric", "Royal Kingdom"}
    end
    table.sort(list)
    return list
end

-- ⭐ Zone centers
local function getZoneCenters()
    local centers = {}
    pcall(function()
        local obj = workspace:FindFirstChild("__OBJECTS")
        local areas = obj and obj:FindFirstChild("Areas")
        local guards = areas and areas:FindFirstChild("GuardAreas")
        if guards then
            for _, zone in ipairs(guards:GetChildren()) do
                local guard = zone:FindFirstChild("Guard")
                if guard then
                    local bp = guard:IsA("BasePart") and guard or guard:FindFirstChildWhichIsA("BasePart", true)
                    if bp then centers[zone.Name] = bp.Position end
                end
            end
        end
    end)
    return centers
end

local function getNearestZone(pos, centers)
    local bestZone, bestDist = "Unknown", math.huge
    for z, zp in pairs(centers) do
        local d = (pos - zp).Magnitude
        if d < bestDist then bestDist = d; bestZone = z end
    end
    return bestZone
end

-- ⭐ Cek egg valid
local function isEggPart(part)
    if not part or not part:IsA("BasePart") then return false end
    if part.Name ~= "SmartPromptPart" then return false end
    if part.Parent ~= workspace then return false end
    local prompt = part:FindFirstChild("CarryAreaEgg")
    return prompt and prompt:IsA("ProximityPrompt") and prompt.ActionText:lower() == "steal"
end

-- ⭐ Baca rarity dari tool hasil steal
-- Coba semua sumber: attribute, EggVisualRecord, name, dll
local function readToolRarity(tool)
    if not tool then return nil end

    -- 1. Attribute langsung
    for _, attrName in ipairs({"Rarity", "rarity", "Tier", "RarityName", "EggRarity", "AssetRarity"}) do
        local v = tool:GetAttribute(attrName)
        if v and tostring(v) ~= "" then
            local sv = tostring(v)
            for _, r in ipairs(RARITY_LIST) do
                if sv:lower():find(r:lower(), 1, true) then return r end
            end
            return sv
        end
    end

    -- 2. EggVisualRecord JSON
    local evr = tool:GetAttribute("EggVisualRecord")
    if evr then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(tostring(evr))
        end)
        if ok and type(data) == "table" then
            for _, key in ipairs({"Rarity", "rarity", "Tier", "RarityName", "AssetRarity", "Category"}) do
                local v = data[key]
                if v then
                    local sv = tostring(v)
                    for _, r in ipairs(RARITY_LIST) do
                        if sv:lower():find(r:lower(), 1, true) then return r end
                    end
                end
            end
        end
    end

    -- 3. Cek semua attribute yang value-nya cocok rarity list
    for k, v in pairs(tool:GetAttributes()) do
        local sv = tostring(v)
        for _, r in ipairs(RARITY_LIST) do
            if sv == r then return r end
        end
    end

    -- 4. Cek nama tool — kadang nama mengandung rarity
    local name = tool.Name
    for _, r in ipairs(RARITY_LIST) do
        if name:find(r, 1, true) then return r end
    end

    return nil
end

function Features.InitEgg()
    local st = Features.EggState
    if st.Initialized then return end
    st.Initialized = true

    for _, z in ipairs(loadZoneList()) do st.Zones[z] = true end
    st.FilterZones = {}
    st.FilterRarities = {}
end

function Features.RefreshEggs()
    local st = Features.EggState
    st.AllEggs = {}
    local centers = getZoneCenters()

    for _, part in ipairs(workspace:GetChildren()) do
        if isEggPart(part) then
            local zone = getNearestZone(part.Position, centers)
            table.insert(st.AllEggs, {
                part = part,
                zone = zone,
                position = part.Position,
                prompt = part:FindFirstChild("CarryAreaEgg"),
            })
        end
    end
end

function Features.FindTargetEgg()
    local st = Features.EggState
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestEgg, bestDist = nil, math.huge

    for _, egg in ipairs(st.AllEggs) do
        if not egg.part.Parent then goto skip end
        if not st.FilterZones[egg.zone] then goto skip end

        local dist = (egg.position - hrp.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestEgg = egg
        end
        ::skip::
    end
    return bestEgg
end

-- ⭐ Cari tool baru yang masuk ke backpack
local function findNewTool(beforeSet)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and not beforeSet[t] then
            return t
        end
    end
    return nil
end

-- ⭐ Snapshot tool yang ada di backpack
local function snapshotTools()
    local set = {}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then set[t] = true end
        end
    end
    return set
end

-- ⭐ DROP tool (buang dari backpack)
local function dropTool(tool)
    if not tool or not tool.Parent then return end
    pcall(function()
        -- Coba destroy
        tool:Destroy()
    end)
end

-- ⭐ Cek apakah rarity tool cocok filter
local function rarityMatches(tool)
    local st = Features.EggState
    local hasRarityFilter = next(st.FilterRarities) ~= nil
    if not hasRarityFilter then
        return true, "no filter"
    end

    local rarity = readToolRarity(tool)
    if not rarity then
        return false, "unknown rarity"
    end

    if st.FilterRarities[rarity] then
        return true, rarity
    end
    return false, rarity
end

Features._eggLoopThread = nil

function Features.StartEggAutoSteal()
    if Features._eggLoopThread then return end
    local st = Features.EggState
    Features.InitEgg()

    Features._eggLoopThread = task.spawn(function()
        while st.AutoSteal do
            st.Status = "🔍 Scanning eggs..."
            Features.RefreshEggs()

            local target = Features.FindTargetEgg()

            if not target then
                st.Status = "⏸️ Gak ada target — nunggu respawn..."
                task.wait(2)
            else
                st.Status = "🎯 Steal @ " .. target.zone
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    -- Snapshot sebelum steal
                    local beforeSet = snapshotTools()

                    -- Teleport & steal
                    pcall(function()
                        hrp.CFrame = CFrame.new(target.position + Vector3.new(0, 3, 0))
                    end)
                    task.wait(0.15)

                    if target.prompt and target.prompt.Parent then
                        pcall(fireproximityprompt, target.prompt)
                    end

                    -- Tunggu tool masuk (max 3 detik)
                    local newTool = nil
                    for i = 1, 30 do
                        task.wait(0.1)
                        newTool = findNewTool(beforeSet)
                        if newTool then break end
                    end

                    -- Cek rarity
                    if newTool then
                        local matched, rarityOrReason = rarityMatches(newTool)
                        if matched then
                            st.Status = "✅ Got " .. tostring(rarityOrReason) ..
                                " — balik safe zone"
                            -- Balik ke safe zone
                            pcall(function()
                                hrp.CFrame = CFrame.new(st.SafePosition + Vector3.new(0, 5, 0))
                            end)
                            task.wait(0.5)
                        else
                            st.Status = "❌ " .. tostring(rarityOrReason) ..
                                " — drop & lanjut"
                            dropTool(newTool)
                            task.wait(0.2)
                            -- Gak balik safe zone, langsung lanjut
                        end
                    else
                        st.Status = "⚠️ Tool gak masuk — lanjut"
                        task.wait(0.3)
                    end
                end
                task.wait(0.2)
            end
        end
        st.Status = "Idle"
        Features._eggLoopThread = nil
    end)
end

function Features.StopEggAutoSteal()
    Features.EggState.AutoSteal = false
end

    _G.VRILZ_Features = Features
_G.VRILZ_Shared = Shared
_G.VRILZ_UI_Shared = Shared

return Features
