-- ============================================================
-- VRILZHUB FEATURES — NAME GAME v1.0
-- ============================================================

local Features = {}
local Shared = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and not hum.SeatPart and not hum.PlatformStand then
            pcall(function() hum.Jump = true end)
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
-- 🥚 EGG FEATURE — Filter Rarity + Zone + Auto Steal
-- ============================================================

-- ⭐ SAFE ZONE (posisi lo di safe zone)
local SAFE_POSITION = Vector3.new(537.88, 70.66, -355.15)

-- ⭐ RARITY LIST (dari lo)
local RARITY_LIST = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary",
    "Mythic", "Secret", "Eternal", "Divine"
}

Features.EggState = {
    AllEggs        = {},
    Zones          = {},
    Rarities       = {},
    FilterZones    = {},
    FilterRarities = {},
    AutoSteal      = false,
    SafePosition   = SAFE_POSITION,
    Initialized    = false,
}

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

-- ⭐ Baca rarity dari egg (coba SEMUA sumber)
local function readEggRarity(part)
    if not part then return nil end

    -- 1. Attribute di part
    for _, attrName in ipairs({"Rarity", "rarity", "Tier", "RarityName", "EggRarity"}) do
        local v = part:GetAttribute(attrName)
        if v and tostring(v) ~= "" then return tostring(v) end
    end

    -- 2. Descendants (StringValue, dst)
    for _, c in ipairs(part:GetDescendants()) do
        if c:IsA("StringValue") or c:IsA("IntValue") then
            local n = c.Name:lower()
            if n:find("rarity") or n:find("tier") then
                return tostring(c.Value)
            end
        end
    end

    -- 3. Tag
    for _, tag in ipairs(part:GetTags()) do
        for _, r in ipairs(RARITY_LIST) do
            if tag:lower() == r:lower() then return tag end
        end
    end

    -- 4. Nama object
    local name = part.Name
    for _, r in ipairs(RARITY_LIST) do
        if name:find(r, 1, true) then return r end
    end

    return nil
end

-- ⭐ INIT
function Features.InitEgg()
    local st = Features.EggState
    if st.Initialized then return end
    st.Initialized = true

    -- Load zone
    for _, z in ipairs(loadZoneList()) do st.Zones[z] = true end

    -- Load rarity dari RARITY_LIST
    for _, r in ipairs(RARITY_LIST) do st.Rarities[r] = true end

    st.FilterZones = {}
    st.FilterRarities = {}
end

-- ⭐ Refresh egg list
function Features.RefreshEggs()
    local st = Features.EggState
    st.AllEggs = {}
    local centers = getZoneCenters()
    for _, part in ipairs(workspace:GetChildren()) do
        if isEggPart(part) then
            local zone = getNearestZone(part.Position, centers)
            local rarity = readEggRarity(part)
            table.insert(st.AllEggs, {
                part = part,
                zone = zone,
                rarity = rarity,
                position = part.Position,
                prompt = part:FindFirstChild("CarryAreaEgg"),
            })
        end
    end
end

-- ⭐ Cek apakah egg cocok filter
function Features.EggMatchesFilter(egg)
    local st = Features.EggState
    if not egg.part.Parent then return false end

    -- Cek zone filter
    if not st.FilterZones[egg.zone] then return false end

    -- Cek rarity filter
    local hasRarityFilter = next(st.FilterRarities) ~= nil
    if hasRarityFilter then
        if not egg.rarity then return false end
        if not st.FilterRarities[egg.rarity] then return false end
    end

    return true
end

-- ⭐ Cari egg target (terdekat yang COCOK filter)
function Features.FindTargetEgg()
    local st = Features.EggState
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestEgg, bestDist = nil, math.huge
    for _, egg in ipairs(st.AllEggs) do
        if Features.EggMatchesFilter(egg) then
            local dist = (egg.position - hrp.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestEgg = egg
            end
        end
    end
    return bestEgg
end

Features._eggLoopThread = nil

-- ============================================================
-- ⭐ AUTO STEAL LOOP — Teleport → Steal → Tunggu egg hilang → Safe
-- ============================================================
function Features.StartEggAutoSteal()
    if Features._eggLoopThread then return end
    local st = Features.EggState
    Features.InitEgg()

    Features._eggLoopThread = task.spawn(function()
        while st.AutoSteal do
            Features.RefreshEggs()

            local target = Features.FindTargetEgg()

            if target then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    -- 1. Teleport ke egg
                    pcall(function()
                        hrp.CFrame = CFrame.new(target.position + Vector3.new(0, 3, 0))
                    end)
                    task.wait(0.15)

                    -- 2. Fire prompt pickup
                    if target.prompt and target.prompt.Parent then
                        pcall(fireproximityprompt, target.prompt)
                    end

                    -- ⭐ 3. TUNGGU sampai egg beneran hilang dari Workspace
                    --    (artinya berhasil di-steal, egg di tangan)
                    local stole = false
                    for i = 1, 30 do  -- max 3 detik
                        task.wait(0.1)
                        if not target.part.Parent then
                            stole = true
                            break
                        end
                    end

                    if stole then
                        -- ✅ Egg berhasil di-tangan → balik safe zone
                        pcall(function()
                            hrp.CFrame = CFrame.new(st.SafePosition + Vector3.new(0, 3, 0))
                        end)
                        task.wait(0.3)
                    else
                        -- ⚠️ Egg gagal hilang → ulangi egg yang SAMA
                        task.wait(0.5)
                    end
                end
            else
                -- ⭐ Gak ada egg yang cocok filter → diem 2 detik
                task.wait(2)
            end

            task.wait(0.1)
        end
        Features._eggLoopThread = nil
    end)
end

function Features.StopEggAutoSteal()
    Features.EggState.AutoSteal = false
end

-- ============================================================
-- FEATURES.INIT
-- ============================================================
function Features.Init(sharedState)
    Shared = sharedState
    if not Features._antiAFKStarted then
        Features._antiAFKStarted = true
        Features.startAntiAFK()
    end
end

_G.VRILZ_Features = Features
_G.VRILZ_Shared = Shared
_G.VRILZ_UI_Shared = Shared

return Features
