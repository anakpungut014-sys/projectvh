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
-- 🥚 EGG FEATURE — Teleport → Pickup → Safe → Ulangi
-- ============================================================

-- ⭐ SAFE ZONE (posisi lo di safe zone)
local SAFE_POSITION = Vector3.new(537.88, 70.66, -355.15)

Features.EggState = {
    AllEggs        = {},
    Zones          = {},
    FilterZones    = {},
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

-- ⭐ INIT
function Features.InitEgg()
    local st = Features.EggState
    if st.Initialized then return end
    st.Initialized = true
    for _, z in ipairs(loadZoneList()) do st.Zones[z] = true end
    st.FilterZones = {}
end

-- ⭐ Refresh egg list
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

-- ⭐ Cari egg target (terdekat di zone pilihan)
function Features.FindTargetEgg()
    local st = Features.EggState
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestEgg, bestDist = nil, math.huge
    for _, egg in ipairs(st.AllEggs) do
        if egg.part.Parent and st.FilterZones[egg.zone] then
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
-- ⭐ AUTO STEAL LOOP — Teleport → Pickup → Safe → Ulangi
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
                        task.wait(1.5)
                    end

                    -- 3. Balik safe zone
                    pcall(function()
                        hrp.CFrame = CFrame.new(st.SafePosition + Vector3.new(0, 5, 0))
                    end)
                    task.wait(0.5)
                end
            else
                -- ⭐ Gak ada egg → diem 2 detik
                task.wait(2)
            end

            task.wait(0.3)
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
