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

    _G.VRILZ_Features = Features
_G.VRILZ_Shared = Shared
_G.VRILZ_UI_Shared = Shared

return Features
