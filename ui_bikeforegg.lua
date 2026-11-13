-- ============================================================
-- VRILZHUB UI — Tfa v1.0 (AUTO-DETECT PC & MOBILE)
-- PC: 800x580 | Mobile: 88% x 78% viewport
-- ============================================================

local UI = {}
local Shared = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ====== AUTO-DETECT MOBILE ======
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ====== UI CONFIG ======
local UI_CONFIG = {
    MOBILE = {
    WIN_W = 340,
    WIN_H = 560,
    -- Note: di HP viewport < 452px, ini otomatis di-clamp jadi viewport.X - 32

    SIDEBAR_W = 64,     -- dari 58 → 64 (biar icon tab gak kejepit)
    TAB_H = 42,         -- dari 38 → 42
    TAB_ICON = 18,      -- dari 16 → 18
    TAB_SHOW_LABEL = false,
    CARD_HEADER = 32,   -- dari 30 → 32
    CARD_PAD_TOP = 10,
    CARD_PAD_BOT = 12,
    CARD_PAD_SIDE = 12,
    CARD_GAP = 8,
    TOGGLE_H = 36,      -- dari 34 → 36
    TOGGLE_W = 48,      -- dari 46 → 48
    TOGGLE_KNOB = 19,
    DROPDOWN_H = 40,    -- dari 38 → 40
    DROPDOWN_ITEM = 32,
    DROPDOWN_POPUP_W = 160,   -- dari 140 → 160 (biar teks gak kepotong)
    ACTION_H = 34,
    FONT_TITLE = 12,
    FONT_LABEL = 12,    -- dari 11 → 12
    FONT_MUTED = 10,    -- dari 9 → 10
    FONT_SMALL = 10,
    FONT_MED = 12,
    FONT_LARGE = 14,
    HEADER_H = 40,      -- dari 36 → 40
    SEARCH_H = 30,
    NOTIF_W = 280,      -- dari 260 → 280
    NOTIF_H = 48,
    OPEN_BTN = 52,
    CHAT_MSG_H = 46,
    CHAT_AVATAR = 22,
    CHAT_FONT = 11,
    CHAT_NAME_FONT = 10,
    CHAT_INPUT_H = 34,
    CHAT_SEND_W = 48,
    CHAT_BUBBLE_PAD = 8,
    CHAT_MAX_MSG = 100,
    CHAT_SHOW_AVATAR = false,
    CHAT_PANEL_H = 340,
},
    PC = {
        WIN_W = 720, WIN_H = 480,
        SIDEBAR_W = 152, TAB_H = 46, TAB_ICON = 17, TAB_SHOW_LABEL = true,
        CARD_HEADER = 36, CARD_PAD_TOP = 12, CARD_PAD_BOT = 14, CARD_PAD_SIDE = 16,
        CARD_GAP = 9, TOGGLE_H = 34, TOGGLE_W = 48, TOGGLE_KNOB = 18,
        DROPDOWN_H = 38, DROPDOWN_ITEM = 30, DROPDOWN_POPUP_W = 180, ACTION_H = 34,
        FONT_TITLE = 12, FONT_LABEL = 12, FONT_MUTED = 10, FONT_SMALL = 10,
        FONT_MED = 12, FONT_LARGE = 15,
        HEADER_H = 52, SEARCH_H = 34, NOTIF_W = 380, NOTIF_H = 52, OPEN_BTN = 56,
        -- LIVE CHAT
        CHAT_MSG_H = 54, CHAT_AVATAR = 30, CHAT_FONT = 12, CHAT_NAME_FONT = 11,
        CHAT_INPUT_H = 40, CHAT_SEND_W = 76, CHAT_BUBBLE_PAD = 12,
        CHAT_MAX_MSG = 200, CHAT_SHOW_AVATAR = true, CHAT_PANEL_H = 420,
    },
}

-- ====== KEY SYSTEM URL (dipindah ke atas biar ChatClient bisa akses) ======
local KEY_SYSTEM_URL = "https://key-system.vrilzwops.workers.dev"

-- ============================================================
-- 🌐 PRESENCE CONFIG — jsonbin.io
-- ============================================================
local JSONBIN_ID  = "6ae883c0ac6210605a65b777"
local JSONBIN_KEY = "$2a$10$91ForV6oQEOZDxOiokdjRu/lrrb26tyJns1XdLwDXEUFc/Mhkyj6C"

local CFG = IS_MOBILE and UI_CONFIG.MOBILE or UI_CONFIG.PC

-- ====== THEME ======
local Themes = {
    Brutal = {
        BG = Color3.fromRGB(7, 8, 11), Surface = Color3.fromRGB(13, 14, 18),
        Surface2 = Color3.fromRGB(20, 20, 24), Surface3 = Color3.fromRGB(28, 28, 33),
        Stroke = Color3.fromRGB(255, 126, 20), Text = Color3.fromRGB(248, 249, 252),
        Muted = Color3.fromRGB(158, 162, 172), Accent = Color3.fromRGB(255, 126, 20),
        Accent2 = Color3.fromRGB(255, 170, 55), Accent3 = Color3.fromRGB(255, 210, 120),
        Success = Color3.fromRGB(70, 230, 140), Error = Color3.fromRGB(255, 75, 85),
    },
    Ice = {
        BG = Color3.fromRGB(5, 10, 20), Surface = Color3.fromRGB(10, 20, 35),
        Surface2 = Color3.fromRGB(15, 30, 50), Surface3 = Color3.fromRGB(20, 40, 65),
        Stroke = Color3.fromRGB(150, 220, 255), Text = Color3.fromRGB(240, 250, 255),
        Muted = Color3.fromRGB(150, 200, 240), Accent = Color3.fromRGB(50, 150, 255),
        Accent2 = Color3.fromRGB(150, 220, 255), Accent3 = Color3.fromRGB(255, 50, 80),
        Success = Color3.fromRGB(50, 255, 150), Error = Color3.fromRGB(255, 50, 80),
    },
    Fire = {
        BG = Color3.fromRGB(20, 5, 0), Surface = Color3.fromRGB(35, 10, 5),
        Surface2 = Color3.fromRGB(50, 15, 5), Surface3 = Color3.fromRGB(65, 20, 10),
        Stroke = Color3.fromRGB(255, 100, 50), Text = Color3.fromRGB(255, 240, 230),
        Muted = Color3.fromRGB(220, 170, 150), Accent = Color3.fromRGB(255, 100, 50),
        Accent2 = Color3.fromRGB(255, 200, 50), Accent3 = Color3.fromRGB(255, 50, 80),
        Success = Color3.fromRGB(50, 255, 150), Error = Color3.fromRGB(255, 50, 80),
    },
    Pink = {
        BG = Color3.fromRGB(20, 5, 15), Surface = Color3.fromRGB(35, 10, 25),
        Surface2 = Color3.fromRGB(50, 15, 35), Surface3 = Color3.fromRGB(65, 20, 45),
        Stroke = Color3.fromRGB(255, 105, 180), Text = Color3.fromRGB(255, 240, 250),
        Muted = Color3.fromRGB(230, 170, 210), Accent = Color3.fromRGB(255, 105, 180),
        Accent2 = Color3.fromRGB(255, 182, 220), Accent3 = Color3.fromRGB(255, 220, 245),
        Success = Color3.fromRGB(50, 255, 150), Error = Color3.fromRGB(255, 50, 80),
    },
    Green = {
        BG = Color3.fromRGB(5, 20, 10), Surface = Color3.fromRGB(10, 35, 20),
        Surface2 = Color3.fromRGB(15, 50, 30), Surface3 = Color3.fromRGB(20, 65, 40),
        Stroke = Color3.fromRGB(50, 255, 120), Text = Color3.fromRGB(240, 255, 245),
        Muted = Color3.fromRGB(170, 230, 190), Accent = Color3.fromRGB(50, 255, 120),
        Accent2 = Color3.fromRGB(150, 255, 180), Accent3 = Color3.fromRGB(200, 255, 220),
        Success = Color3.fromRGB(50, 255, 150), Error = Color3.fromRGB(255, 50, 80),
    },
    Blue = {
        BG = Color3.fromRGB(5, 10, 25), Surface = Color3.fromRGB(10, 20, 45),
        Surface2 = Color3.fromRGB(15, 30, 65), Surface3 = Color3.fromRGB(20, 40, 85),
        Stroke = Color3.fromRGB(50, 150, 255), Text = Color3.fromRGB(240, 245, 255),
        Muted = Color3.fromRGB(170, 200, 240), Accent = Color3.fromRGB(50, 150, 255),
        Accent2 = Color3.fromRGB(150, 200, 255), Accent3 = Color3.fromRGB(220, 235, 255),
        Success = Color3.fromRGB(50, 255, 150), Error = Color3.fromRGB(255, 50, 80),
    },
        Mustard = {
        BG = Color3.fromRGB(30, 25, 5), Surface = Color3.fromRGB(45, 38, 10),
        Surface2 = Color3.fromRGB(60, 50, 15), Surface3 = Color3.fromRGB(75, 62, 20),
        Stroke = Color3.fromRGB(230, 190, 50), Text = Color3.fromRGB(255, 250, 230),
        Muted = Color3.fromRGB(200, 180, 130), Accent = Color3.fromRGB(230, 190, 50),
        Accent2 = Color3.fromRGB(255, 220, 90), Accent3 = Color3.fromRGB(255, 240, 150),
        Success = Color3.fromRGB(150, 230, 100), Error = Color3.fromRGB(255, 80, 80),
    },
    Olive = {
        BG = Color3.fromRGB(20, 25, 10), Surface = Color3.fromRGB(35, 45, 20),
        Surface2 = Color3.fromRGB(50, 65, 30), Surface3 = Color3.fromRGB(65, 80, 40),
        Stroke = Color3.fromRGB(140, 170, 60), Text = Color3.fromRGB(245, 250, 235),
        Muted = Color3.fromRGB(180, 200, 140), Accent = Color3.fromRGB(140, 170, 60),
        Accent2 = Color3.fromRGB(180, 210, 90), Accent3 = Color3.fromRGB(210, 235, 140),
        Success = Color3.fromRGB(100, 220, 120), Error = Color3.fromRGB(255, 80, 80),
    },
}

local CurrentTheme = "Brutal"
local C = Themes[CurrentTheme]

local ThemeWidgets = {}
local function registerTheme(widget, key, property)
    table.insert(ThemeWidgets, {widget = widget, key = key, property = property})
end

local function applyTheme(themeName)
    CurrentTheme = themeName
    C = Themes[themeName]
    for _, item in ipairs(ThemeWidgets) do
        pcall(function()
            item.widget[item.property] = C[item.key]
        end)
    end
end

-- ============================================================
-- TITLE SYSTEM v2 — OWNER + PREMIUM CUSTOM TITLE + SAVE
-- ============================================================
local OWNER_USERID = 5126297278
local TITLE_GUI_NAME = "VRILZ_TitleTag"
local titleGuiRef = nil
local titleLoopRunning = false

-- ═══════════════════════════════════════════
-- SAVE/LOAD TITLE (pake writefile/readfile)
-- ═══════════════════════════════════════════
local TITLE_SAVE_FILE = "vrilz_title.txt"

local function saveCustomTitle(title)
    if writefile then
        pcall(function()
            writefile(TITLE_SAVE_FILE, title or "")
        end)
    end
    -- Simpen juga ke _G biar cepet akses
    _G.VRILZ_CustomTitle = title
end

local function loadCustomTitle()
    -- Cek _G dulu
    if _G.VRILZ_CustomTitle then
        return _G.VRILZ_CustomTitle
    end
    
    -- Cek file
    if readfile and isfile then
        local ok, exists = pcall(isfile, TITLE_SAVE_FILE)
        if ok and exists then
            local okRead, content = pcall(readfile, TITLE_SAVE_FILE)
            if okRead and content then
                content = content:gsub("^%s+", ""):gsub("%s+$", "")
                if content ~= "" then
                    _G.VRILZ_CustomTitle = content
                    return content
                end
            end
        end
    end
    
    return nil
end

local function clearCustomTitle()
    _G.VRILZ_CustomTitle = nil
    if delfile and isfile then
        local ok, exists = pcall(isfile, TITLE_SAVE_FILE)
        if ok and exists then
            pcall(delfile, TITLE_SAVE_FILE)
        end
    end
end

-- ═══════════════════════════════════════════
-- CEK APAKAH USER BISA CUSTOM TITLE
-- ═══════════════════════════════════════════
local function canCustomTitle()
    -- Owner = selalu bisa
    if LocalPlayer.UserId == OWNER_USERID then
        return true
    end
    
    -- Cek key type = PREMIUM
    if Shared and Shared.KeyType then
        local kt = tostring(Shared.KeyType):upper()
        if kt == "PREMIUM" or kt == "OWNER" or kt == "VIP" then
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════════
-- GET TITLE TEXT
-- ═══════════════════════════════════════════
local function getTitleText()
    -- Owner
    if LocalPlayer.UserId == OWNER_USERID then
        local custom = _G.VRILZ_CustomTitle
        if custom and custom ~= "" then
            return "[👑 " .. custom .. "]"
        end
        return "[👑 OWNER]"
    end
    
    -- Premium user — cek custom title
    if canCustomTitle() then
        local custom = _G.VRILZ_CustomTitle
        if custom and custom ~= "" then
            return "[👑 " .. custom .. "]"
        end
    end
    
    -- Default
    return "[VH COMMUNITY]"
end

local function getTitleColors()
    -- Owner ATAU Premium = rainbow
    if LocalPlayer.UserId == OWNER_USERID or canCustomTitle() then
        return {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 127, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(139, 0, 255),
            Color3.fromRGB(255, 0, 255),
        }
    else
        return {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 255, 255),
        }
    end
end

local function removeTitle()
    if titleGuiRef then
        pcall(function() titleGuiRef:Destroy() end)
        titleGuiRef = nil
    end
end

local function buildTitle()
    removeTitle()

    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = TITLE_GUI_NAME
    bb.Size = UDim2.fromOffset(220, 32)
    bb.StudsOffset = Vector3.new(0, 2.8, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 500
    bb.Adornee = head
    bb.Parent = head
    titleGuiRef = bb

    local lbl = Instance.new("TextLabel")
    lbl.Name = "TitleLabel"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = getTitleText()
    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.2
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 15
    lbl.TextScaled = false
    lbl.TextWrapped = false
    lbl.Parent = bb

    -- Animasi rainbow
    if not titleLoopRunning then
        titleLoopRunning = true
        task.spawn(function()
            local idx = 1
            while titleLoopRunning do
                task.wait(0.12)
                if not Shared.ShowTitle then
                    idx = 1
                    continue
                end
                local colors = getTitleColors()
                if titleGuiRef and titleGuiRef.Parent then
                    local label = titleGuiRef:FindFirstChild("TitleLabel")
                    if label then
                        label.TextColor3 = colors[idx]
                    end
                end
                idx = idx + 1
                if idx > #colors then idx = 1 end
            end
        end)
    end
end

local function refreshTitle()
    if Shared.ShowTitle then
        buildTitle()
    else
        removeTitle()
    end
end

-- Auto refresh pas karakter respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    refreshTitle()
end)

-- Expose function biar UI bisa panggil
_G.VRILZ_RefreshTitle = refreshTitle

-- ====== NOTIFICATION ======
local NotifHolder = nil

local function setupNotifHolder(parent)
    NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotifHolder"
    NotifHolder.AnchorPoint = Vector2.new(0.5, 0)
    NotifHolder.Position = UDim2.new(0.5, 0, 0, 20)
    NotifHolder.Size = UDim2.fromOffset(420, 320)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.ZIndex = 500
    NotifHolder.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotifHolder
end

-- ============================================================
-- 🌠 PREMIUM METEOR GLOW NOTIFICATION v3
-- Meteor jatuh dari atas + text auto-fit (gak pernah keluar)
-- ============================================================
local function notify(text, type)
    if not NotifHolder then return end
    type = type or "info"

    -- ═══ WARNA PER TYPE (NO GREEN) ═══
    local color, glowColor, icon, gradientTop, gradientBot
    if type == "success" then
        color = Color3.fromRGB(80, 180, 255)          -- biru cyan (bukan ijo)
        glowColor = Color3.fromRGB(120, 220, 255)
        icon = "✓"
        gradientTop = Color3.fromRGB(18, 40, 65)
        gradientBot = Color3.fromRGB(8, 16, 28)
    elseif type == "error" then
        color = Color3.fromRGB(255, 90, 100)
        glowColor = Color3.fromRGB(255, 40, 70)
        icon = "✕"
        gradientTop = Color3.fromRGB(62, 24, 28)
        gradientBot = Color3.fromRGB(22, 8, 10)
    elseif type == "warning" then
        color = Color3.fromRGB(255, 200, 80)
        glowColor = Color3.fromRGB(255, 160, 30)
        icon = "!"
        gradientTop = Color3.fromRGB(60, 46, 16)
        gradientBot = Color3.fromRGB(22, 18, 8)
    else
        color = Color3.fromRGB(170, 130, 255)         -- ungu buat info
        glowColor = Color3.fromRGB(200, 160, 255)
        icon = "✦"
        gradientTop = Color3.fromRGB(35, 22, 60)
        gradientBot = Color3.fromRGB(14, 10, 26)
    end

    -- ═══ UKURAN KECIL ═══
    local isMob = IS_MOBILE
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local maxW = isMob and math.min(vp.X - 40, 230) or 270
    local notifW = math.clamp(maxW, 190, 290)
    local notifH = isMob and 46 or 52

    -- ═══ MAIN CONTAINER ═══
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(notifW, notifH)
    notif.BackgroundColor3 = gradientBot
    notif.BorderSizePixel = 0
    notif.ZIndex = 501
    notif.ClipsDescendants = true        -- ⭐ meteor kepotong di dalam card
    notif.Parent = NotifHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif

    -- ═══ GRADIENT BODY ═══
    local bodyGradient = Instance.new("UIGradient")
    bodyGradient.Rotation = 115
    bodyGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, gradientTop),
        ColorSequenceKeypoint.new(0.5, gradientBot),
        ColorSequenceKeypoint.new(1, gradientBot),
    })
    bodyGradient.Parent = notif

    -- ═══ NEON STROKE ═══
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.Transparency = 0.12
    stroke.Parent = notif

    -- ═══ TOP GLOSS ═══
    local gloss = Instance.new("Frame")
    gloss.Size = UDim2.new(1, -16, 0, 1)
    gloss.Position = UDim2.fromOffset(8, 1)
    gloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gloss.BackgroundTransparency = 0.75
    gloss.BorderSizePixel = 0
    gloss.ZIndex = 503
    gloss.Parent = notif
    local glc = Instance.new("UICorner")
    glc.CornerRadius = UDim.new(1, 0)
    glc.Parent = gloss

    -- ═══ METEOR LAYER (di dalam card, di belakang konten) ═══
    local meteorLayer = Instance.new("Frame")
    meteorLayer.Name = "MeteorLayer"
    meteorLayer.Size = UDim2.fromScale(1, 1)
    meteorLayer.BackgroundTransparency = 1
    meteorLayer.ZIndex = 502
    meteorLayer.ClipsDescendants = true
    meteorLayer.Parent = notif

    -- ═══ ICON ═══
    local iconSize = isMob and 26 or 30
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.fromOffset(iconSize, iconSize)
    iconBg.Position = UDim2.new(0, isMob and 8 or 10, 0.5, 0)
    iconBg.AnchorPoint = Vector2.new(0, 0.5)
    iconBg.BackgroundColor3 = color
    iconBg.BorderSizePixel = 0
    iconBg.ZIndex = 505
    iconBg.Parent = notif
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0)
    ic.Parent = iconBg

    local iconGrad = Instance.new("UIGradient")
    iconGrad.Rotation = 135
    iconGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, glowColor),
    })
    iconGrad.Parent = iconBg

    local iconGlow = Instance.new("Frame")
    iconGlow.Size = UDim2.new(1, 6, 1, 6)
    iconGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    iconGlow.BackgroundColor3 = glowColor
    iconGlow.BackgroundTransparency = 0.7
    iconGlow.BorderSizePixel = 0
    iconGlow.ZIndex = 504
    iconGlow.Parent = iconBg
    local igc = Instance.new("UICorner")
    igc.CornerRadius = UDim.new(1, 0)
    igc.Parent = iconGlow

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.fromScale(1, 1)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLbl.Font = Enum.Font.GothamBlack
    iconLbl.TextSize = isMob and 14 or 16
    iconLbl.ZIndex = 506
    iconLbl.Parent = iconBg

    -- ═══ TEXT LABEL (AUTO-FIT) ═══
    local textX = (isMob and 8 or 10) + iconSize + (isMob and 7 or 9)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -(textX + (isMob and 7 or 10)), 1, -4)
    label.Position = UDim2.fromOffset(textX, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(248, 250, 255)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.TextTruncate = Enum.TextTruncate.None
    label.ZIndex = 505
    label.Parent = notif

    local baseSize = isMob and 11 or 12
    local minSize = isMob and 8 or 9
    label.TextSize = baseSize

    local function autoFit()
        local fitSize = baseSize
        label.TextSize = fitSize
        local safety = 20
        while not label.TextFits and fitSize > minSize and safety > 0 do
            fitSize = fitSize - 1
            label.TextSize = fitSize
            safety = safety - 1
            task.wait()
        end
        if not label.TextFits and fitSize <= minSize then
            label.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end
    task.defer(autoFit)

    -- ═══ METEOR DI DALAM CARD (horizontal streak) ═══
    local function spawnInnerMeteor()
        if not notif.Parent or not meteorLayer.Parent then return end

        local meteor = Instance.new("Frame")
        meteor.Name = "InnerMeteor"
        meteor.AnchorPoint = Vector2.new(0.5, 0.5)
        meteor.BackgroundColor3 = glowColor
        meteor.BorderSizePixel = 0
        meteor.ZIndex = 502

        -- Ukuran meteor kecil (di dalam card)
        local headSize = math.random(4, 6)
        meteor.Size = UDim2.fromOffset(headSize, headSize)
        local yPos = math.random(15, 85) / 100
        meteor.Position = UDim2.fromScale(-0.1, yPos)
        meteor.Parent = meteorLayer

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(1, 0)
        mc.Parent = meteor

        -- Head glow (halo kecil)
        local headGlow = Instance.new("Frame")
        headGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        headGlow.Position = UDim2.fromScale(0.5, 0.5)
        headGlow.Size = UDim2.fromOffset(headSize * 2.5, headSize * 2.5)
        headGlow.BackgroundColor3 = glowColor
        headGlow.BackgroundTransparency = 0.6
        headGlow.BorderSizePixel = 0
        headGlow.ZIndex = 501
        headGlow.Parent = meteor
        local hgc = Instance.new("UICorner")
        hgc.CornerRadius = UDim.new(1, 0)
        hgc.Parent = headGlow

        -- TRAIL memanjang (ke kiri, karena meteor gerak ke kanan)
        local trail = Instance.new("Frame")
        trail.AnchorPoint = Vector2.new(1, 0.5)
        trail.Position = UDim2.fromScale(0.5, 0.5)
        trail.Size = UDim2.fromOffset(math.random(35, 60), 2)
        trail.BackgroundColor3 = color
        trail.BackgroundTransparency = 0.25
        trail.BorderSizePixel = 0
        trail.ZIndex = 501
        trail.Parent = meteor

        local trailGrad = Instance.new("UIGradient")
        trailGrad.Rotation = 0
        trailGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.4, 0.15),
            NumberSequenceKeypoint.new(1, 0),
        })
        trailGrad.Parent = trail

        -- Spark kecil di trail
        for i = 1, math.random(2, 4) do
            local spark = Instance.new("Frame")
            spark.AnchorPoint = Vector2.new(0.5, 0.5)
            spark.Position = UDim2.new(1, math.random(-30, -8), 0.5, math.random(-2, 2))
            spark.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
            spark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            spark.BackgroundTransparency = 0.4
            spark.BorderSizePixel = 0
            spark.ZIndex = 501
            spark.Parent = meteor
            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(1, 0)
            sc.Parent = spark
        end

        -- Animasi: geser dari kiri ke kanan (di dalam card)
        local duration = math.random(90, 140) / 100
        TweenService:Create(meteor, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.fromScale(1.1, yPos),
        }):Play()

        -- Fade out di ujung kanan
        task.delay(duration * 0.85, function()
            if meteor.Parent then
                TweenService:Create(meteor, TweenInfo.new(duration * 0.15), {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(trail, TweenInfo.new(duration * 0.15), {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(headGlow, TweenInfo.new(duration * 0.15), {
                    BackgroundTransparency = 1,
                }):Play()
            end
        end)

        task.delay(duration + 0.1, function()
            if meteor then meteor:Destroy() end
        end)
    end

    -- Spawn meteor berkala (di dalam card)
    task.spawn(function()
        task.wait(0.2)
        spawnInnerMeteor()
        while notif.Parent do
            task.wait(math.random(8, 16) / 10)
            if not notif.Parent then break end
            spawnInnerMeteor()
        end
    end)

    -- ═══ ANIMASI MASUK: SLIDE DARI KANAN (halus) ═══
    notif.Position = UDim2.new(0.5, notifW + 10, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    -- Icon pulse
    task.spawn(function()
        while notif.Parent do
            task.wait(1.4)
            if not notif.Parent then break end
            TweenService:Create(iconGlow, TweenInfo.new(0.5), {BackgroundTransparency = 0.85}):Play()
            task.wait(0.5)
            TweenService:Create(iconGlow, TweenInfo.new(0.5), {BackgroundTransparency = 0.65}):Play()
        end
    end)

    -- ═══ ANIMASI HILANG: FADE + SLIDE KECIL KE KANAN (no flying out) ═══
    task.delay(3.5, function()
        if not notif.Parent then return end

        TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.fromOffset(30, 0),          -- geser dikit aja
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(notifW * 0.9, notifH),  -- mengecil dikit
        }):Play()

        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TweenService:Create(iconLbl, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TweenService:Create(iconBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(iconGlow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(gloss, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()

        task.wait(0.4)
        if notif then notif:Destroy() end
    end)
end

-- ====== CARD (RIPPLE SAJA) ======
local function makeCard(parent, title, layoutOrder)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C.Surface
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = layoutOrder or 1
    card.ZIndex = 1
    card.Parent = parent
    registerTheme(card, "Surface", "BackgroundColor3")
    card.BackgroundTransparency = 0.55

    -- Layered card depth: soft shadow + glossy surface.
    local cardShadow = Instance.new("Frame")
    cardShadow.Name = "CardShadow"
    cardShadow.Size = UDim2.new(1, 8, 1, 10)
    cardShadow.Position = UDim2.fromOffset(0, 5)
    cardShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    cardShadow.BackgroundTransparency = 0.48
    cardShadow.BorderSizePixel = 0
    cardShadow.ZIndex = 0
    cardShadow.Parent = card
    local cardShadowCorner = Instance.new("UICorner")
    cardShadowCorner.CornerRadius = UDim.new(0, 14)
    cardShadowCorner.Parent = cardShadow

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = card

    local cardGradient = Instance.new("UIGradient")
    cardGradient.Rotation = 90
    cardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 25, 29)),
        ColorSequenceKeypoint.new(0.55, C.Surface),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 14)),
    })

    local gloss = Instance.new("Frame")
    gloss.Name = "Gloss"
    gloss.Size = UDim2.new(1, -18, 0, 1)
    gloss.Position = UDim2.fromOffset(9, 1)
    gloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gloss.BackgroundTransparency = 0.86
    gloss.BorderSizePixel = 0
    gloss.ZIndex = 2
    gloss.Parent = card
    local glossCorner = Instance.new("UICorner")
    glossCorner.CornerRadius = UDim.new(1, 0)
    glossCorner.Parent = gloss

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Accent
    stroke.Thickness = 1.6
    stroke.Transparency = 0.22
    stroke.Parent = card
    registerTheme(stroke, "Accent", "Color")
  
    -- Header
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, CFG.CARD_HEADER)
    headerFrame.BackgroundColor3 = C.Surface2
    headerFrame.BorderSizePixel = 0
    headerFrame.ZIndex = 2
    headerFrame.Parent = card
    registerTheme(headerFrame, "Surface2", "BackgroundColor3")
    headerFrame.BackgroundTransparency = 0.45

    local headerGradient = Instance.new("UIGradient")
    headerGradient.Rotation = 0
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 39)),
        ColorSequenceKeypoint.new(0.55, C.Surface2),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22)),
    })

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 13)
    headerCorner.Parent = headerFrame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.new(0, 12, 0.5, -4)
    dot.BackgroundColor3 = C.Accent
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = headerFrame

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    registerTheme(dot, "Accent", "BackgroundColor3")

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.fromOffset(26, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = C.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = CFG.FONT_TITLE
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 3
    titleLabel.Parent = headerFrame
    registerTheme(titleLabel, "Text", "TextColor3")

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, CFG.CARD_HEADER)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = card

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop = UDim.new(0, CFG.CARD_PAD_TOP)
    contentPad.PaddingBottom = UDim.new(0, CFG.CARD_PAD_BOT)
    contentPad.PaddingLeft = UDim.new(0, CFG.CARD_PAD_SIDE)
    contentPad.PaddingRight = UDim.new(0, CFG.CARD_PAD_SIDE)
    contentPad.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, CFG.CARD_GAP)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    return card, content
end

-- ====== TOGGLE ======
local function makeToggle(parent, text, default, callback, sharedKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, CFG.TOGGLE_H)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -(CFG.TOGGLE_W + 12), 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.Text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = CFG.FONT_LABEL
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame
    registerTheme(label, "Text", "TextColor3")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(CFG.TOGGLE_W + 6, IS_MOBILE and 28 or 26)
    btn.Position = UDim2.new(1, -CFG.TOGGLE_W, 0.5, -(IS_MOBILE and 13 or 12))
    btn.BackgroundColor3 = default and C.Accent or C.Surface3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = frame
    registerTheme(btn, default and "Accent" or "Surface3", "BackgroundColor3")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = default and C.Accent or Color3.fromRGB(80, 82, 90)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.15
    btnStroke.Parent = btn
    if default then registerTheme(btnStroke, "Accent", "Color") end

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(CFG.TOGGLE_KNOB, CFG.TOGGLE_KNOB)
    knob.Position = default and UDim2.new(1, -(CFG.TOGGLE_KNOB + 3), 0.5, -CFG.TOGGLE_KNOB/2) or UDim2.new(0, 3, 0.5, -CFG.TOGGLE_KNOB/2)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = btn

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- ⭐ STATE: kalau sharedKey dikasih, baca dari Shared. Kalau ngga, pakai local
    local state = default
    if sharedKey and Shared and Shared[sharedKey] ~= nil then
        state = Shared[sharedKey]
    end

    -- ⭐ FUNGSI VISUAL: dipisah biar bisa dipanggil dari refresh
    local function updateVisual(v, animate)
        state = v
        local bgTarget = v and C.Accent or C.Surface3
        local knobTarget = v 
            and UDim2.new(1, -(CFG.TOGGLE_KNOB + 3), 0.5, -CFG.TOGGLE_KNOB/2)
            or UDim2.new(0, 3, 0.5, -CFG.TOGGLE_KNOB/2)
        
        if animate then
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = bgTarget }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), { Position = knobTarget }):Play()
        else
            btn.BackgroundColor3 = bgTarget
            knob.Position = knobTarget
        end
    end

    -- Apply state awal
    updateVisual(state, false)

    btn.MouseButton1Click:Connect(function()
        local newState = not state
        updateVisual(newState, true)
        if sharedKey and Shared then
            Shared[sharedKey] = newState
        end
        if callback then callback(newState) end
    end)

    -- ⭐ REGISTER KE REFRESH SYSTEM
    if sharedKey and _G.VRILZ_RegisterWidget then
        _G.VRILZ_RegisterWidget(function()
            if not btn.Parent then return end
            local fresh = Shared and Shared[sharedKey]
            if fresh ~= nil and fresh ~= state then
                updateVisual(fresh, false)
            end
        end)
    end
end

-- ====== DROPDOWN GLOBAL ======
_G.VRILZ_DropdownLayer = nil
_G.VRILZ_DropdownCloseOverlay = nil
_G.VRILZ_DropdownActive = nil

local function setupDropdownLayer(parent)
    _G.VRILZ_DropdownLayer = Instance.new("Frame")
    _G.VRILZ_DropdownLayer.Name = "DropdownLayer"
    _G.VRILZ_DropdownLayer.Size = UDim2.fromScale(1, 1)
    _G.VRILZ_DropdownLayer.BackgroundTransparency = 1
    _G.VRILZ_DropdownLayer.ZIndex = 2000
    _G.VRILZ_DropdownLayer.Parent = parent

    _G.VRILZ_DropdownCloseOverlay = Instance.new("TextButton")
    _G.VRILZ_DropdownCloseOverlay.Size = UDim2.fromScale(1, 1)
    _G.VRILZ_DropdownCloseOverlay.BackgroundTransparency = 1
    _G.VRILZ_DropdownCloseOverlay.Text = ""
    _G.VRILZ_DropdownCloseOverlay.ZIndex = 1999
    _G.VRILZ_DropdownCloseOverlay.Visible = false
    _G.VRILZ_DropdownCloseOverlay.Parent = _G.VRILZ_DropdownLayer

    _G.VRILZ_DropdownCloseOverlay.MouseButton1Click:Connect(function()
        if _G.VRILZ_DropdownActive and _G.VRILZ_DropdownActive.close then
            _G.VRILZ_DropdownActive.close()
        end
        _G.VRILZ_DropdownActive = nil
        _G.VRILZ_DropdownCloseOverlay.Visible = false
    end)
end

-- ============================================================
-- ⭐ STARFIELD HELPER — Bintang kelap-kelip untuk background opsi
-- ============================================================
local function attachStarfield(parentFrame, starCount, color)
    starCount = starCount or 5
    color = color or Color3.fromRGB(255, 255, 255)

    local starLayer = Instance.new("Frame")
    starLayer.Name = "StarfieldLayer"
    starLayer.Size = UDim2.fromScale(1, 1)
    starLayer.BackgroundTransparency = 1
    starLayer.ClipsDescendants = true
    starLayer.ZIndex = parentFrame.ZIndex - 1
    starLayer.Parent = parentFrame

    for i = 1, starCount do
        local star = Instance.new("Frame")
        local sz = math.random(1, 2)
        star.Name = "Star_" .. i
        star.Size = UDim2.fromOffset(sz, sz)
        star.Position = UDim2.fromScale(math.random(5, 95) / 100, math.random(5, 95) / 100)
        star.BackgroundColor3 = color
        star.BackgroundTransparency = math.random(40, 80) / 100
        star.BorderSizePixel = 0
        star.ZIndex = parentFrame.ZIndex - 1
        star.Parent = starLayer

        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = star

        -- Animasi kelap-kelip (twinkle)
        task.spawn(function()
            local baseTrans = star.BackgroundTransparency
            task.wait(math.random(0, 200) / 100)
            while star.Parent and starLayer.Parent do
                TweenService:Create(star, TweenInfo.new(math.random(30, 80) / 100, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = math.max(0, baseTrans - 0.6)
                }):Play()
                task.wait(math.random(40, 100) / 100)
                if not star.Parent then break end
                TweenService:Create(star, TweenInfo.new(math.random(50, 120) / 100, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = baseTrans
                }):Play()
                task.wait(math.random(60, 180) / 100)
            end
        end)
    end

    return starLayer
end

local function makeDropdownGlobal(anchorFrame, items, default, onSelect)
    local isOpen = false
    local selectedValue = default or items[1] or "Choose..."

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, CFG.DROPDOWN_H)
    container.BackgroundColor3 = C.Surface3
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.Parent = anchorFrame
    registerTheme(container, "Surface3", "BackgroundColor3")
    container.BackgroundTransparency = 0.55

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    registerTheme(stroke, "Accent", "Color")

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(1, -44, 1, 0)
    selectedLbl.Position = UDim2.fromOffset(12, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = selectedValue
    selectedLbl.TextColor3 = C.Text
    selectedLbl.Font = Enum.Font.GothamSemibold
    selectedLbl.TextSize = CFG.FONT_LABEL
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectedLbl.ZIndex = 4
    selectedLbl.Parent = container
    registerTheme(selectedLbl, "Text", "TextColor3")

    -- Real chevron: draw the two strokes instead of using a glyph.
    -- This guarantees the icon can never render as a square/tofu character.
    local arrow = Instance.new("Frame")
    arrow.Name = "DropdownChevron"
    arrow.Size = UDim2.fromOffset(IS_MOBILE and 20 or 22, IS_MOBILE and 16 or 18)
    arrow.Position = UDim2.new(1, -(IS_MOBILE and 27 or 29), 0.5, -(IS_MOBILE and 8 or 9))
    arrow.BackgroundTransparency = 1
    arrow.BorderSizePixel = 0
    arrow.ZIndex = 4
    arrow.Parent = container

    local chevronL = Instance.new("Frame")
    chevronL.Name = "Left"
    chevronL.Size = UDim2.fromOffset(IS_MOBILE and 8 or 9, 2)
    chevronL.Position = UDim2.new(0.5, -(IS_MOBILE and 7 or 8), 0.5, -1)
    chevronL.BackgroundColor3 = C.Accent2
    chevronL.BorderSizePixel = 0
    chevronL.Rotation = 45
    chevronL.ZIndex = 5
    chevronL.Parent = arrow
    registerTheme(chevronL, "Accent2", "BackgroundColor3")

    local chevronR = Instance.new("Frame")
    chevronR.Name = "Right"
    chevronR.Size = UDim2.fromOffset(IS_MOBILE and 8 or 9, 2)
    chevronR.Position = UDim2.new(0.5, 1, 0.5, -1)
    chevronR.BackgroundColor3 = C.Accent2
    chevronR.BorderSizePixel = 0
    chevronR.Rotation = -45
    chevronR.ZIndex = 5
    chevronR.Parent = arrow
    registerTheme(chevronR, "Accent2", "BackgroundColor3")

    local listFrame = Instance.new("ScrollingFrame")
    local popupWidth = CFG.DROPDOWN_POPUP_W
    listFrame.Size = UDim2.fromOffset(popupWidth, 0)
    listFrame.BackgroundColor3 = C.Surface2
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = C.Accent
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.Visible = false
    listFrame.ZIndex = 2001
    listFrame.Parent = _G.VRILZ_DropdownLayer
    registerTheme(listFrame, "Surface2", "BackgroundColor3")

    local listShadow = Instance.new("Frame")
    listShadow.Name = "DropdownShadow"
    listShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    listShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    listShadow.Size = UDim2.new(1, 10, 1, 10)
    listShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listShadow.BackgroundTransparency = 0.35
    listShadow.BorderSizePixel = 0
    listShadow.ZIndex = 2000
    listShadow.Visible = false
    listShadow.Parent = listFrame
    local listShadowCorner = Instance.new("UICorner")
    listShadowCorner.CornerRadius = UDim.new(0, 12)
    listShadowCorner.Parent = listShadow

    local listGradient = Instance.new("UIGradient")
    listGradient.Rotation = 90
    listGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 31, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 13, 16)),
    })
    listGradient.Parent = listFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = listFrame

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = C.Accent
    listStroke.Transparency = 0.2
    listStroke.Thickness = 2
    listStroke.Parent = listFrame
    registerTheme(listStroke, "Accent", "Color")

    local listTopGlow = Instance.new("Frame")
    listTopGlow.Size = UDim2.new(1, -18, 0, 2)
    listTopGlow.Position = UDim2.fromOffset(9, 1)
    listTopGlow.BackgroundColor3 = C.Accent2
    listTopGlow.BackgroundTransparency = 0.08
    listTopGlow.BorderSizePixel = 0
    listTopGlow.ZIndex = 2003
    listTopGlow.Parent = listFrame
    local listTopCorner = Instance.new("UICorner")
    listTopCorner.CornerRadius = UDim.new(1, 0)
    listTopCorner.Parent = listTopGlow
    registerTheme(listTopGlow, "Accent2", "BackgroundColor3")

    local popupHighlight = Instance.new("Frame")
    popupHighlight.Size = UDim2.new(1, -16, 0, 1)
    popupHighlight.Position = UDim2.fromOffset(8, 4)
    popupHighlight.BackgroundColor3 = Color3.new(1, 1, 1)
    popupHighlight.BackgroundTransparency = 0.88
    popupHighlight.BorderSizePixel = 0
    popupHighlight.ZIndex = 2003
    popupHighlight.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = listFrame

    local itemHeight = CFG.DROPDOWN_ITEM
    local maxH = math.min(#items * (itemHeight + 2) + 10, IS_MOBILE and 126 or 148)

    local function closeList()
        isOpen = false
        chevronL.Rotation = 45
        chevronR.Rotation = -45
        local w = listFrame.Size.X.Offset
        TweenService:Create(listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.fromOffset(w, 0)}):Play()
        task.delay(0.2, function()
            if not isOpen then listFrame.Visible = false end
        end)
        if _G.VRILZ_DropdownCloseOverlay then
            _G.VRILZ_DropdownCloseOverlay.Visible = false
        end
        _G.VRILZ_DropdownActive = nil
    end

    local function openList()
        if _G.VRILZ_DropdownActive and _G.VRILZ_DropdownActive.close then
            _G.VRILZ_DropdownActive.close()
        end

        isOpen = true
        listFrame.Visible = true
        chevronL.Rotation = -45
        chevronR.Rotation = 45

        -- Compact popover: jangan selebar field/window.
        local width = math.min(CFG.DROPDOWN_POPUP_W, math.max(140, container.AbsoluteSize.X - 12))
        listFrame.Size = UDim2.fromOffset(width, 0)

        local containerAbsX = container.AbsolutePosition.X
        local containerAbsY = container.AbsolutePosition.Y
        local containerAbsW = container.AbsoluteSize.X
        local containerAbsH = container.AbsoluteSize.Y
        local viewport = workspace.CurrentCamera.ViewportSize
        local screenW = viewport.X
        local screenH = viewport.Y
        local spaceBelow = screenH - (containerAbsY + containerAbsH + 8)
        local realMaxH = math.min(maxH, math.max(spaceBelow, 90))

        -- Tetap tepat di bawah dropdown, rata kanan dengan tombol <>.
        local popupRight = math.min(screenW - 8, containerAbsX + containerAbsW)
        local popupLeft = math.max(8, popupRight - width)
        listFrame.Position = UDim2.fromOffset(popupLeft, containerAbsY + containerAbsH + 6)

        TweenService:Create(listFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(width, realMaxH)
        }):Play()

        if _G.VRILZ_DropdownCloseOverlay then
            _G.VRILZ_DropdownCloseOverlay.Visible = true
        end

        _G.VRILZ_DropdownActive = {
            close = closeList,
            listFrame = listFrame,
            container = container
        }
    end

    container.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if isOpen then closeList() else openList() end
        end
    end)

        for i, item in ipairs(items) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, -8, 0, itemHeight)
        opt.Position = UDim2.fromOffset(4, 0)
        opt.BackgroundColor3 = C.Surface3
        opt.Text = ""
        opt.AutoButtonColor = false
        opt.ZIndex = 2002
        opt.LayoutOrder = i
        opt.ClipsDescendants = true
        opt.Parent = listFrame
        registerTheme(opt, "Surface3", "BackgroundColor3")

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 8)
        optCorner.Parent = opt

        -- ⭐ BACKGROUND GRADIENT
        local optGradient = Instance.new("UIGradient")
        optGradient.Rotation = 90
        optGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Surface3),
            ColorSequenceKeypoint.new(0.5, C.Surface2),
            ColorSequenceKeypoint.new(1, C.Surface3),
        })
        optGradient.Parent = opt

        -- ⭐ BINTANG KELAP-KELIP DI BACKGROUND
        attachStarfield(opt, 5, C.Accent2)

        local optStroke = Instance.new("UIStroke")
        optStroke.Color = C.Accent
        optStroke.Thickness = 1
        optStroke.Transparency = 1
        optStroke.Parent = opt

        -- ⭐ LABEL NAMA dengan gradient shimmer
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "OptionName"
        nameLbl.Size = UDim2.new(1, -12, 1, 0)
        nameLbl.Position = UDim2.fromOffset(8, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = item
        nameLbl.TextColor3 = C.Text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = CFG.FONT_LABEL
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex = 2003
        nameLbl.Parent = opt
        registerTheme(nameLbl, "Text", "TextColor3")

        -- ⭐ EFEK GRADIENT DI NAMA
        local nameGradient = Instance.new("UIGradient")
        nameGradient.Rotation = 0
        nameGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Text),
            ColorSequenceKeypoint.new(0.5, C.Accent2),
            ColorSequenceKeypoint.new(1, C.Text),
        })
        nameGradient.Parent = nameLbl

        -- ⭐ SHIMMER (cahaya bergerak di nama)
        task.spawn(function()
            local offset = 0
            while nameLbl.Parent and opt.Parent do
                offset = offset + 0.04
                if offset > 1 then offset = 0 end
                nameGradient.Offset = Vector2.new(offset, 0)
                task.wait(0.05)
            end
        end)

        if item == selectedValue then
            opt.BackgroundColor3 = C.Accent
            nameLbl.TextColor3 = Color3.new(1, 1, 1)
            nameLbl.TextStrokeColor3 = C.Accent2
            nameLbl.TextStrokeTransparency = 0.3
            optStroke.Transparency = 0.15
            nameGradient.Enabled = false
        end

        opt.MouseEnter:Connect(function()
            if item ~= selectedValue then
                TweenService:Create(opt, TweenInfo.new(0.15), {BackgroundColor3 = C.Surface2}):Play()
                nameLbl.TextColor3 = C.Accent2
                nameLbl.TextStrokeColor3 = C.Accent
                nameLbl.TextStrokeTransparency = 0.4
            end
            TweenService:Create(optStroke, TweenInfo.new(0.15), {Transparency = item == selectedValue and 0.15 or 0.45}):Play()
        end)
        opt.MouseLeave:Connect(function()
            if item ~= selectedValue then
                TweenService:Create(opt, TweenInfo.new(0.15), {BackgroundColor3 = C.Surface3}):Play()
                nameLbl.TextColor3 = C.Text
                nameLbl.TextStrokeTransparency = 1
            end
            TweenService:Create(optStroke, TweenInfo.new(0.15), {Transparency = item == selectedValue and 0.15 or 1}):Play()
        end)

        opt.MouseButton1Click:Connect(function()
            selectedValue = item
            selectedLbl.Text = item
            closeList()
            if onSelect then onSelect(item) end
        end)
    end
    
    return container
end

-- ====== DROPDOWN MULTI-SELECT (NONE LOGIC) ======
local function makeDropdownMulti(anchorFrame, items, sharedTable, itemColors, onChanged)
    local isOpen = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, CFG.DROPDOWN_H)
    container.BackgroundColor3 = C.Surface3
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.Parent = anchorFrame
    registerTheme(container, "Surface3", "BackgroundColor3")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    registerTheme(stroke, "Accent", "Color")

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(1, -44, 1, 0)
    selectedLbl.Position = UDim2.fromOffset(12, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = "..."
    selectedLbl.TextColor3 = C.Text
    selectedLbl.Font = Enum.Font.GothamSemibold
    selectedLbl.TextSize = CFG.FONT_LABEL
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectedLbl.ZIndex = 4
    selectedLbl.Parent = container
    registerTheme(selectedLbl, "Text", "TextColor3")

    -- Draw the rarity chevron from two small strokes so it never becomes a square/tofu glyph.
    local arrow = Instance.new("Frame")
    arrow.Name = "RarityChevron"
    arrow.Size = UDim2.fromOffset(IS_MOBILE and 20 or 22, IS_MOBILE and 16 or 18)
    arrow.Position = UDim2.new(1, -(IS_MOBILE and 27 or 29), 0.5, -(IS_MOBILE and 8 or 9))
    arrow.BackgroundTransparency = 1
    arrow.BorderSizePixel = 0
    arrow.ZIndex = 4
    arrow.Parent = container

    local arrowL = Instance.new("Frame")
    arrowL.Size = UDim2.fromOffset(IS_MOBILE and 8 or 9, 2)
    arrowL.Position = UDim2.new(0.5, -(IS_MOBILE and 7 or 8), 0.5, -1)
    arrowL.BackgroundColor3 = C.Accent
    arrowL.BorderSizePixel = 0
    arrowL.Rotation = 45
    arrowL.ZIndex = 5
    arrowL.Parent = arrow
    registerTheme(arrowL, "Accent", "BackgroundColor3")

    local arrowR = Instance.new("Frame")
    arrowR.Size = UDim2.fromOffset(IS_MOBILE and 8 or 9, 2)
    arrowR.Position = UDim2.new(0.5, 1, 0.5, -1)
    arrowR.BackgroundColor3 = C.Accent
    arrowR.BorderSizePixel = 0
    arrowR.Rotation = -45
    arrowR.ZIndex = 5
    arrowR.Parent = arrow
    registerTheme(arrowR, "Accent", "BackgroundColor3")

    local listFrame = Instance.new("ScrollingFrame")
    local popupWidth = CFG.DROPDOWN_POPUP_W
    listFrame.Size = UDim2.fromOffset(popupWidth, 0)
    listFrame.BackgroundColor3 = C.Surface2
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = C.Accent
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.Visible = false
    listFrame.ZIndex = 2001
    listFrame.Parent = _G.VRILZ_DropdownLayer
    registerTheme(listFrame, "Surface2", "BackgroundColor3")

    local listGradient = Instance.new("UIGradient")
    listGradient.Rotation = 90
    listGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 31, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 13, 16)),
    })
    listGradient.Parent = listFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = listFrame

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = C.Accent
    listStroke.Transparency = 0.2
    listStroke.Thickness = 2
    listStroke.Parent = listFrame
    registerTheme(listStroke, "Accent", "Color")

    local listShadow = Instance.new("Frame")
    listShadow.Name = "DropdownShadow"
    listShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    listShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    listShadow.Size = UDim2.new(1, 10, 1, 10)
    listShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listShadow.BackgroundTransparency = 0.35
    listShadow.BorderSizePixel = 0
    listShadow.ZIndex = 2000
    listShadow.Visible = false
    listShadow.Parent = listFrame
    local listShadowCorner = Instance.new("UICorner")
    listShadowCorner.CornerRadius = UDim.new(0, 12)
    listShadowCorner.Parent = listShadow

    local popupHighlight = Instance.new("Frame")
    popupHighlight.Size = UDim2.new(1, -16, 0, 1)
    popupHighlight.Position = UDim2.fromOffset(8, 4)
    popupHighlight.BackgroundColor3 = Color3.new(1, 1, 1)
    popupHighlight.BackgroundTransparency = 0.88
    popupHighlight.BorderSizePixel = 0
    popupHighlight.ZIndex = 2003
    popupHighlight.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = listFrame

    local itemHeight = CFG.DROPDOWN_ITEM
    local maxH = math.min(#items * (itemHeight + 2) + 10, IS_MOBILE and 126 or 148)

    local optionButtons = {}

    local function updateLabel()
        local selected = {}
        for _, r in ipairs(items) do
            if sharedTable[r] then table.insert(selected, r) end
        end
        if #selected == 0 then
            selectedLbl.Text = "Select Rarity..."
        elseif #selected == 1 and selected[1] == "None" then
            selectedLbl.Text = "None"
        elseif #selected <= 2 then
            selectedLbl.Text = table.concat(selected, ", ")
        else
            selectedLbl.Text = #selected .. " rarity is selected"
        end
    end

    local function updateButtonVisual(item)
        local opt = optionButtons[item]
        if not opt then return end
        local on = sharedTable[item] == true
        opt.chk.Text = on and "✓" or "○"
        opt.bg.BackgroundColor3 = on and C.Surface2 or C.Surface3

        -- ⭐ JANGAN override TextColor3 — biarkan gradient shimmer yang urus
        -- Cuma update stroke buat highlight selected
        if on then
            opt.txt.TextStrokeColor3 = C.Accent
            opt.txt.TextStrokeTransparency = 0.4
        else
            opt.txt.TextStrokeTransparency = 1
        end
    end

    local function closeList()
        isOpen = false
        arrowL.Rotation = 45
        arrowR.Rotation = -45
        local w = listFrame.Size.X.Offset
        TweenService:Create(listFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.fromOffset(w, 0)}):Play()
        task.delay(0.2, function()
            if not isOpen then listFrame.Visible = false end
        end)
        if _G.VRILZ_DropdownCloseOverlay then
            _G.VRILZ_DropdownCloseOverlay.Visible = false
        end
        _G.VRILZ_DropdownActive = nil
    end

    local function openList()
        if _G.VRILZ_DropdownActive and _G.VRILZ_DropdownActive.close then
            _G.VRILZ_DropdownActive.close()
        end

        isOpen = true
        listFrame.Visible = true
        arrowL.Rotation = -45
        arrowR.Rotation = 45

        -- Compact popover: jangan selebar field/window.
        local width = math.min(CFG.DROPDOWN_POPUP_W, math.max(140, container.AbsoluteSize.X - 12))
        listFrame.Size = UDim2.fromOffset(width, 0)

        local containerAbsX = container.AbsolutePosition.X
        local containerAbsY = container.AbsolutePosition.Y
        local containerAbsW = container.AbsoluteSize.X
        local containerAbsH = container.AbsoluteSize.Y
        local viewport = workspace.CurrentCamera.ViewportSize
        local screenW = viewport.X
        local screenH = viewport.Y
        local spaceBelow = screenH - (containerAbsY + containerAbsH + 8)
        local realMaxH = math.min(maxH, math.max(spaceBelow, 90))

        -- Tetap tepat di bawah dropdown, rata kanan dengan tombol <>.
        local popupRight = math.min(screenW - 8, containerAbsX + containerAbsW)
        local popupLeft = math.max(8, popupRight - width)
        listFrame.Position = UDim2.fromOffset(popupLeft, containerAbsY + containerAbsH + 6)

        TweenService:Create(listFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(width, realMaxH)
        }):Play()

        if _G.VRILZ_DropdownCloseOverlay then
            _G.VRILZ_DropdownCloseOverlay.Visible = true
        end

        _G.VRILZ_DropdownActive = {
            close = closeList,
            listFrame = listFrame,
            container = container
        }
    end

    container.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if isOpen then closeList() else openList() end
        end
    end)

        for i, item in ipairs(items) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, -8, 0, itemHeight)
        opt.Position = UDim2.fromOffset(4, 0)
        opt.BackgroundColor3 = C.Surface3
        opt.Text = ""
        opt.AutoButtonColor = false
        opt.ZIndex = 2002
        opt.LayoutOrder = i
        opt.ClipsDescendants = true
        opt.Parent = listFrame
        registerTheme(opt, "Surface3", "BackgroundColor3")

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 5)
        optCorner.Parent = opt

        -- ⭐ BACKGROUND GRADIENT
        local optGradient = Instance.new("UIGradient")
        optGradient.Rotation = 90
        optGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Surface3),
            ColorSequenceKeypoint.new(0.5, C.Surface2),
            ColorSequenceKeypoint.new(1, C.Surface3),
        })
        optGradient.Parent = opt

        -- ⭐ BINTANG KELAP-KELIP
        attachStarfield(opt, 5, C.Accent2)

        local chk = Instance.new("TextLabel")
        chk.Size = UDim2.fromOffset(24, itemHeight)
        chk.Position = UDim2.fromOffset(8, 0)
        chk.BackgroundTransparency = 1
        chk.Text = sharedTable[item] and "✓" or "○"
        chk.TextColor3 = C.Accent
        chk.Font = Enum.Font.GothamBold
        chk.TextSize = 14
        chk.ZIndex = 2003
        chk.Parent = opt

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -40, 1, 0)
        txt.Position = UDim2.fromOffset(36, 0)
        txt.BackgroundTransparency = 1
        txt.Text = item
        txt.TextColor3 = C.Text
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = CFG.FONT_LABEL
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextTruncate = Enum.TextTruncate.AtEnd
        txt.ZIndex = 2003
        txt.Parent = opt

        -- ⭐ EFEK GRADIENT DI NAMA
        local txtGradient = Instance.new("UIGradient")
        txtGradient.Rotation = 0
        txtGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.Text),
            ColorSequenceKeypoint.new(0.5, C.Accent2),
            ColorSequenceKeypoint.new(1, C.Text),
        })
        txtGradient.Parent = txt

        -- ⭐ SHIMMER
        task.spawn(function()
            local offset = 0
            while txt.Parent and opt.Parent do
                offset = offset + 0.04
                if offset > 1 then offset = 0 end
                txtGradient.Offset = Vector2.new(offset, 0)
                task.wait(0.05)
            end
        end)

        if sharedTable[item] then
            opt.BackgroundColor3 = C.Surface2
            txt.TextColor3 = C.Accent2
            txt.TextStrokeColor3 = C.Accent
            txt.TextStrokeTransparency = 0.4
        end

        optionButtons[item] = {bg = opt, chk = chk, txt = txt}

        -- ⭐ HOVER EFFECT (glow + nama nyala) — TAMBAH INI
        opt.MouseEnter:Connect(function()
            if not sharedTable[item] then
                TweenService:Create(opt, TweenInfo.new(0.15), {BackgroundColor3 = C.Surface2}):Play()
                txt.TextStrokeColor3 = C.Accent
                txt.TextStrokeTransparency = 0.4
            end
        end)

        opt.MouseLeave:Connect(function()
            if not sharedTable[item] then
                TweenService:Create(opt, TweenInfo.new(0.15), {BackgroundColor3 = C.Surface3}):Play()
                txt.TextStrokeTransparency = 1
            end
        end)

        opt.MouseButton1Click:Connect(function()
            local isNone = (item == "None")

            if isNone then
                if sharedTable["None"] then
                    local anyOther = false
                    for _, r in ipairs(items) do
                        if r ~= "None" and sharedTable[r] then anyOther = true break end
                    end
                    if not anyOther then return end
                    sharedTable["None"] = false
                    updateButtonVisual("None")
                else
                    for _, r in ipairs(items) do
                        if r ~= "None" then sharedTable[r] = false end
                    end
                    sharedTable["None"] = true
                    for _, r in ipairs(items) do updateButtonVisual(r) end
                end
            else
                sharedTable[item] = not sharedTable[item]
                if sharedTable[item] then
                    if sharedTable["None"] then
                        sharedTable["None"] = false
                        updateButtonVisual("None")
                    end
                else
                    local anyOn = false
                    for _, r in ipairs(items) do
                        if r ~= "None" and sharedTable[r] then anyOn = true break end
                    end
                    if not anyOn then
                        sharedTable["None"] = true
                        updateButtonVisual("None")
                    end
                end
                updateButtonVisual(item)
            end

            updateLabel()
            if onChanged then onChanged(sharedTable) end
        end)
    end

    updateLabel()
    return container
end

-- ============================================================
-- 🌌 LIGHTS EFFECT LAYER v3 — REALISTIC METEOR SHOWER
-- ============================================================
local function buildLightsEffectLayer(mainFrame)
    local layer = Instance.new("Frame")
    layer.Name = "LightsEffectLayer"
    layer.Size = UDim2.fromScale(1, 1)
    layer.Position = UDim2.fromScale(0, 0)
    layer.BackgroundTransparency = 1
    layer.ClipsDescendants = true
    layer.ZIndex = 4
    layer.Active = false
    layer.Parent = mainFrame

    local layerCorner = Instance.new("UICorner")
    layerCorner.CornerRadius = UDim.new(0, 18)
    layerCorner.Parent = layer

    local active = true
    layer.Destroying:Connect(function()
        active = false
    end)

    -- ══════════════════════════════════════════
    -- STARFIELD — bintang kedap-kedip (twinkle)
    -- ══════════════════════════════════════════
    local starfield = Instance.new("Frame")
    starfield.Name = "Starfield"
    starfield.Size = UDim2.fromScale(1, 1)
    starfield.BackgroundTransparency = 1
    starfield.ClipsDescendants = true
    starfield.ZIndex = 5
    starfield.Parent = layer

    local starColors = {
        Color3.fromRGB(255, 255, 255),   -- putih
        Color3.fromRGB(180, 220, 255),   -- biru muda
        Color3.fromRGB(255, 220, 180),   -- kuning lembut
        Color3.fromRGB(200, 180, 255),   -- ungu
        Color3.fromRGB(255, 180, 220),   -- pink lembut
    }
    local starCount = IS_MOBILE and 45 or 70

    for i = 1, starCount do
        local star = Instance.new("Frame")
        local sz = math.random(1, 3)
        star.Name = "Star_" .. i
        star.Size = UDim2.fromOffset(sz, sz)
        star.Position = UDim2.fromScale(math.random(0, 1000) / 1000, math.random(0, 1000) / 1000)
        star.BackgroundColor3 = starColors[math.random(1, #starColors)]
        star.BackgroundTransparency = math.random(40, 85) / 100
        star.BorderSizePixel = 0
        star.ZIndex = 6
        star.Parent = starfield

        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = star

        -- Glow halo tipis di sekitar bintang
        local starGlow = Instance.new("Frame")
        starGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        starGlow.Position = UDim2.fromScale(0.5, 0.5)
        starGlow.Size = UDim2.new(3, 0, 3, 0)
        starGlow.BackgroundColor3 = star.BackgroundColor3
        starGlow.BackgroundTransparency = 0.92
        starGlow.BorderSizePixel = 0
        starGlow.ZIndex = 5
        starGlow.Parent = star
        local sgc = Instance.new("UICorner")
        sgc.CornerRadius = UDim.new(1, 0)
        sgc.Parent = starGlow

        -- Twinkle animation
        local baseTrans = star.BackgroundTransparency
        local baseGlowTrans = starGlow.BackgroundTransparency
        local minTrans = math.max(0, baseTrans - 0.55)
        local minGlowTrans = math.max(0, baseGlowTrans - 0.10)

        task.spawn(function()
            task.wait(math.random(0, 400) / 100)  -- delay random awal
            while star.Parent and active do
                local upDur = math.random(50, 120) / 100
                local downDur = math.random(60, 140) / 100

                TweenService:Create(star, TweenInfo.new(upDur, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = minTrans
                }):Play()
                TweenService:Create(starGlow, TweenInfo.new(upDur, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = minGlowTrans
                }):Play()

                task.wait(upDur + math.random(0, 80) / 100)

                TweenService:Create(star, TweenInfo.new(downDur, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = baseTrans
                }):Play()
                TweenService:Create(starGlow, TweenInfo.new(downDur, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = baseGlowTrans
                }):Play()

                task.wait(downDur + math.random(0, 200) / 100)
            end
        end)
    end

    -- ══════════════════════════════════════════
    -- SATELIT muter di orbit (2 satelit)
    -- ══════════════════════════════════════════
    local function createSatellite(radiusPct, speed, startAngle, color)
        local orbitCenter = Instance.new("Frame")
        orbitCenter.Name = "SatelliteOrbit"
        orbitCenter.AnchorPoint = Vector2.new(0.5, 0.5)
        orbitCenter.Position = UDim2.fromScale(0.5, 0.5)
        orbitCenter.Size = UDim2.fromScale(1, 1)
        orbitCenter.BackgroundTransparency = 1
        orbitCenter.ZIndex = 6
        orbitCenter.Parent = layer

        -- Satelit body
        local sat = Instance.new("Frame")
        sat.Name = "Satellite"
        sat.AnchorPoint = Vector2.new(0.5, 0.5)
        sat.Size = UDim2.fromOffset(IS_MOBILE and 6 or 8, IS_MOBILE and 6 or 8)
        sat.BackgroundColor3 = color
        sat.BorderSizePixel = 0
        sat.ZIndex = 7
        sat.Parent = orbitCenter

        local satCorner = Instance.new("UICorner")
        satCorner.CornerRadius = UDim.new(1, 0)
        satCorner.Parent = sat

        -- Glow
        local satGlow = Instance.new("Frame")
        satGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        satGlow.Position = UDim2.fromScale(0.5, 0.5)
        satGlow.Size = UDim2.new(2.5, 0, 2.5, 0)
        satGlow.BackgroundColor3 = color
        satGlow.BackgroundTransparency = 0.75
        satGlow.BorderSizePixel = 0
        satGlow.ZIndex = 6
        satGlow.Parent = sat
        local sgc2 = Instance.new("UICorner")
        sgc2.CornerRadius = UDim.new(1, 0)
        sgc2.Parent = satGlow

        -- Panel satelit (2 strip tipis)
        local panelL = Instance.new("Frame")
        panelL.AnchorPoint = Vector2.new(1, 0.5)
        panelL.Position = UDim2.new(0.5, -3, 0.5, 0)
        panelL.Size = UDim2.fromOffset(6, 2)
        panelL.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
        panelL.BackgroundTransparency = 0.3
        panelL.BorderSizePixel = 0
        panelL.ZIndex = 7
        panelL.Parent = sat

        local panelR = Instance.new("Frame")
        panelR.AnchorPoint = Vector2.new(0, 0.5)
        panelR.Position = UDim2.new(0.5, 3, 0.5, 0)
        panelR.Size = UDim2.fromOffset(6, 2)
        panelR.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
        panelR.BackgroundTransparency = 0.3
        panelR.BorderSizePixel = 0
        panelR.ZIndex = 7
        panelR.Parent = sat

        -- Animasi orbit
        task.spawn(function()
            local angle = startAngle or 0
            while sat.Parent and active do
                task.wait(0.03)
                angle = angle + speed
                if angle > math.pi * 2 then angle = angle - math.pi * 2 end

                -- Orbit ellipse
                local rx = radiusPct * 0.5
                local ry = radiusPct * 0.25
                local x = 0.5 + math.cos(angle) * rx
                local y = 0.5 + math.sin(angle) * ry
                sat.Position = UDim2.fromScale(x, y)

                -- Skala satelit
                local depth = math.sin(angle)
                local scale = 0.7 + (depth + 1) * 0.25
                local baseSize = IS_MOBILE and 6 or 8
                sat.Size = UDim2.fromOffset(baseSize * scale, baseSize * scale)
                sat.BackgroundTransparency = 0.3 - depth * 0.3
            end
        end)
    end

    -- 2 satelit muter
    createSatellite(0.85, 0.012, 0, Color3.fromRGB(180, 220, 255))
    createSatellite(0.70, -0.018, math.pi, Color3.fromRGB(255, 180, 200))

    -- ══════════════════════════════════════════
    -- METEOR JATUH (REALISTIS)
    -- ══════════════════════════════════════════
    local meteorColors = {
        Color3.fromRGB(255, 200, 120),  -- oranye api
        Color3.fromRGB(150, 220, 255),  -- biru ice
        Color3.fromRGB(255, 160, 200),  -- pink
        Color3.fromRGB(200, 180, 255),  -- ungu
    }

    local function spawnMeteor()
        if not active or not layer.Parent then return end

        local pickColor = meteorColors[math.random(1, #meteorColors)]
        
        -- Tentukan arah diagonal (Miring melintasi layar)
        local goRight = math.random() > 0.5
        local startX, endX
        
        if goRight then
            startX = math.random(-20, 10) / 100
            endX = startX + math.random(80, 120) / 100
        else
            startX = math.random(90, 120) / 100
            endX = startX - math.random(80, 120) / 100
        end

        local startY = -0.2
        local endY = 1.2

        -- Hitung sudut miring secara presisi buat ekornya
        local angleDeg = math.deg(math.atan2(endY - startY, endX - startX)) - 90

        -- ══════════════════════════════════════════
        -- 1. KEPALA METEOR (BOLA SEMPURNA)
        -- ══════════════════════════════════════════
        local meteor = Instance.new("Frame")
        meteor.Name = "MeteorHead"
        meteor.AnchorPoint = Vector2.new(0.5, 0.5)
        meteor.Size = UDim2.fromOffset(8, 8) -- Ukuran fix, dijamin bulat
        meteor.Position = UDim2.fromScale(startX, startY)
        meteor.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Inti putih panas
        meteor.BorderSizePixel = 0
        meteor.ZIndex = 15
        meteor.Parent = layer

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(1, 0) -- 1,0 = Lingkaran sempurna
        mc.Parent = meteor

        -- Glow luar (halo cahaya)
        local headGlow = Instance.new("Frame")
        headGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        headGlow.Position = UDim2.fromScale(0.5, 0.5)
        headGlow.Size = UDim2.fromOffset(24, 24)
        headGlow.BackgroundColor3 = pickColor
        headGlow.BackgroundTransparency = 0.3
        headGlow.BorderSizePixel = 0
        headGlow.ZIndex = 14
        headGlow.Parent = meteor
        local hgc = Instance.new("UICorner")
        hgc.CornerRadius = UDim.new(1, 0)
        hgc.Parent = headGlow

        -- ══════════════════════════════════════════
        -- 2. EKOR KOMET MULTI-LAYER (REALISTIS)
        -- ══════════════════════════════════════════
        local trailHolder = Instance.new("Frame")
        trailHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        trailHolder.Position = UDim2.fromScale(0.5, 0.5)
        trailHolder.Size = UDim2.fromOffset(1, 1)
        trailHolder.BackgroundTransparency = 1
        trailHolder.Rotation = angleDeg -- Ekor miring sesuai arah
        trailHolder.ZIndex = 10
        trailHolder.Parent = meteor

        local trailLength = math.random(100, 150)

        -- Layer 1: Ekor Luar (Besar & Transparan / Efek Gas)
        local outerTrail = Instance.new("Frame")
        outerTrail.AnchorPoint = Vector2.new(0.5, 1)
        outerTrail.Position = UDim2.new(0.5, 0, 0.5, 0)
        outerTrail.Size = UDim2.fromOffset(12, trailLength)
        outerTrail.BackgroundColor3 = pickColor
        outerTrail.BorderSizePixel = 0
        outerTrail.ZIndex = 11
        outerTrail.Parent = trailHolder
        
        local outerGrad = Instance.new("UIGradient")
        outerGrad.Rotation = 90
        outerGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),      -- Ujung ekor hilang total
            NumberSequenceKeypoint.new(0.5, 0.85), -- Tengah samar
            NumberSequenceKeypoint.new(1, 0.4),    -- Deket kepala terang
        })
        outerGrad.Parent = outerTrail

        -- Layer 2: Ekor Tengah (Warna Meteor / Inti Ekor)
        local midTrail = Instance.new("Frame")
        midTrail.AnchorPoint = Vector2.new(0.5, 1)
        midTrail.Position = UDim2.new(0.5, 0, 0.5, 0)
        midTrail.Size = UDim2.fromOffset(6, trailLength * 0.9)
        midTrail.BackgroundColor3 = pickColor
        midTrail.BorderSizePixel = 0
        midTrail.ZIndex = 12
        midTrail.Parent = trailHolder
        
        local midGrad = Instance.new("UIGradient")
        midGrad.Rotation = 90
        midGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.4, 0.6),
            NumberSequenceKeypoint.new(1, 0.1),
        })
        midGrad.Parent = midTrail

        -- Layer 3: Ekor Dalam (Putih Panas / Laser Core)
        local coreTrail = Instance.new("Frame")
        coreTrail.AnchorPoint = Vector2.new(0.5, 1)
        coreTrail.Position = UDim2.new(0.5, 0, 0.5, 0)
        coreTrail.Size = UDim2.fromOffset(2, trailLength * 0.7)
        coreTrail.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        coreTrail.BorderSizePixel = 0
        coreTrail.ZIndex = 13
        coreTrail.Parent = trailHolder
        
        local coreGrad = Instance.new("UIGradient")
        coreGrad.Rotation = 90
        coreGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.7, 0.3),
            NumberSequenceKeypoint.new(1, 0),
        })
        coreGrad.Parent = coreTrail

        -- Percikan Api (Sparks) yang berjatuhan
        for s = 1, math.random(4, 7) do
            local spark = Instance.new("Frame")
            spark.AnchorPoint = Vector2.new(0.5, 0.5)
            spark.Position = UDim2.new(0.5, math.random(-6, 6), 0.5, -math.random(10, trailLength - 10))
            spark.Size = UDim2.fromOffset(math.random(1, 3), math.random(1, 3))
            spark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            spark.BackgroundTransparency = math.random(10, 50) / 100
            spark.BorderSizePixel = 0
            spark.ZIndex = 12
            spark.Parent = trailHolder
            local spc = Instance.new("UICorner")
            spc.CornerRadius = UDim.new(1, 0)
            spc.Parent = spark
        end

        -- ══════════════════════════════════════════
        -- 3. ANIMASI JATUH
        -- ══════════════════════════════════════════
        local duration = math.random(150, 250) / 100 -- 1.5 - 2.5 detik
        
        -- Gerak mulus ke titik ujung
        TweenService:Create(meteor, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.fromScale(endX, endY),
        }):Play()

        -- Fade Out pas mendekati ujung layar
        task.delay(duration * 0.8, function()
            if meteor.Parent then
                TweenService:Create(meteor, TweenInfo.new(duration * 0.2, Enum.EasingStyle.Quad), {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(headGlow, TweenInfo.new(duration * 0.2, Enum.EasingStyle.Quad), {
                    BackgroundTransparency = 1,
                }):Play()
                -- Fade out semua layer ekor secara barengan
                for _, child in ipairs(trailHolder:GetChildren()) do
                    if child:IsA("Frame") and child.Name ~= "Spark" then -- Spark udah transparan natural
                        local targetTrans = child.BackgroundTransparency + 0.3
                        TweenService:Create(child, TweenInfo.new(duration * 0.2), {
                            BackgroundTransparency = targetTrans
                        }):Play()
                    end
                end
            end
        end)

        -- Hapus objek
        task.delay(duration + 0.2, function()
            if meteor then meteor:Destroy() end
        end)
    end

    -- Loop spawn meteor
    task.spawn(function()
        task.wait(1.5)
        while active do
            spawnMeteor()
            if math.random() < 0.3 then
                task.wait(math.random(10, 30) / 100)
                spawnMeteor()
            end
            task.wait(math.random(150, 350) / 100)  -- 1.5-3.5 detik
        end
    end)
    return layer
end

-- ============================================================
-- ⚡ LIGHTNING EFFECT LAYER v4 — Rapi, gak numpuk, tetap bagus
-- ============================================================
local function buildLightningEffectLayer(mainFrame)
    local layer = Instance.new("Frame")
    layer.Name = "LightningEffectLayer"
    layer.Size = UDim2.fromScale(1, 1)
    layer.Position = UDim2.fromScale(0, 0)
    layer.BackgroundTransparency = 1
    layer.ClipsDescendants = true
    layer.ZIndex = 7
    layer.Active = false
    layer.Parent = mainFrame

    local layerCorner = Instance.new("UICorner")
    layerCorner.CornerRadius = UDim.new(0, 18)
    layerCorner.Parent = layer

    local lightningActive = true
    layer.Destroying:Connect(function()
        lightningActive = false
    end)

    -- ══════════════════════════════════════════
    -- LOCK: cegah petir numpuk. Cuma 1 sambaran pada satu waktu.
    -- ══════════════════════════════════════════
    local currentBoltHolder = nil

    -- ══════════════════════════════════════════
    -- HELPER: 1 segmen garis petir miring
    -- ══════════════════════════════════════════
    local function makeSegment(parent, p1, p2, thickness, color, transparency, zIndex)
        local dx = (p2.x - p1.x) * 1000
        local dy = (p2.y - p1.y) * 1000
        local length = math.sqrt(dx * dx + dy * dy)
        local angle = math.deg(math.atan2(dy, dx))
        local midX = (p1.x + p2.x) / 2
        local midY = (p1.y + p2.y) / 2

        local seg = Instance.new("Frame")
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        seg.Position = UDim2.fromScale(midX, midY)
        seg.Size = UDim2.fromOffset(length, thickness)
        seg.Rotation = angle
        seg.BackgroundColor3 = color
        seg.BackgroundTransparency = transparency
        seg.BorderSizePixel = 0
        seg.ZIndex = zIndex
        seg.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = seg

        return seg
    end

    -- ══════════════════════════════════════════
    -- HELPER: generate zig-zag path
    -- ══════════════════════════════════════════
    local function generateBoltPath(startX, startY, endY, segments, jitter)
        local path = { {x = startX, y = startY} }
        for i = 1, segments do
            local t = i / segments
            local py = startY + (endY - startY) * t
            local px = startX + math.random(-jitter, jitter) / 100
            px = math.clamp(px, 0.03, 0.97)
            py = math.clamp(py, 0.03, 0.97)
            table.insert(path, {x = px, y = py})
        end
        return path
    end

    -- ══════════════════════════════════════════
    -- SPAWN 1 PETIR (dijamin cuma 1 aktif)
    -- ══════════════════════════════════════════
    local function spawnLightningBolt()
        if not lightningActive or not layer.Parent then return end

        -- ⭐ Kalau masih ada petir aktif → hapus dulu (anti numpuk)
        if currentBoltHolder and currentBoltHolder.Parent then
            currentBoltHolder:Destroy()
            currentBoltHolder = nil
        end

        -- ═══ Posisi petir ═══
        local startX = math.random(20, 80) / 100
        local startY = 0.03
        local endY = math.random(55, 85) / 100
        local endX = math.clamp(startX + math.random(-15, 15) / 100, 0.05, 0.95)

        local boltHolder = Instance.new("Frame")
        boltHolder.Name = "LightningBolt"
        boltHolder.Size = UDim2.fromScale(1, 1)
        boltHolder.BackgroundTransparency = 1
        boltHolder.ClipsDescendants = true
        boltHolder.ZIndex = 8
        boltHolder.Parent = layer
        currentBoltHolder = boltHolder

        local allFrames = {}
        local RED_CORE  = Color3.fromRGB(255, 30, 30)
        local RED_GLOW  = Color3.fromRGB(255, 80, 80)
        local WHITE_HOT = Color3.fromRGB(255, 230, 230)
        local DARK_RED  = Color3.fromRGB(180, 0, 0)

        -- Jalur utama
        local mainSegments = math.random(6, 8)
        local mainPath = generateBoltPath(startX, startY, endY, mainSegments, 5)

        for i = 1, #mainPath - 1 do
            local p1 = mainPath[i]
            local p2 = mainPath[i + 1]

            table.insert(allFrames, makeSegment(boltHolder, p1, p2, math.random(10, 13), RED_GLOW, 0.5, 8))
            table.insert(allFrames, makeSegment(boltHolder, p1, p2, math.random(5, 7), RED_CORE, 0.15, 9))
            table.insert(allFrames, makeSegment(boltHolder, p1, p2, 3, RED_CORE, 0, 10))
            table.insert(allFrames, makeSegment(boltHolder, p1, p2, 1.2, WHITE_HOT, 0, 11))

            -- Cabang (cuma 40% chance, biar gak terlalu banyak)
            if math.random() < 0.4 then
                local branchStart = p1
                local branchLenY = math.random(10, 20) / 100
                local branchLenX = math.random(-15, 15) / 100
                local branchEnd = {
                    x = math.clamp(branchStart.x + branchLenX, 0.03, 0.97),
                    y = math.clamp(branchStart.y + branchLenY, 0.03, 0.98)
                }

                local subSegs = math.random(2, 3)
                local branchPath = { branchStart }
                for s = 1, subSegs do
                    local st = s / subSegs
                    local sx = branchStart.x + (branchEnd.x - branchStart.x) * st + math.random(-4, 4) / 100
                    local sy = branchStart.y + (branchEnd.y - branchStart.y) * st + math.random(-2, 2) / 100
                    sx = math.clamp(sx, 0.03, 0.97)
                    sy = math.clamp(sy, 0.03, 0.98)
                    table.insert(branchPath, {x = sx, y = sy})
                end

                for bs = 1, #branchPath - 1 do
                    local bp1 = branchPath[bs]
                    local bp2 = branchPath[bs + 1]
                    table.insert(allFrames, makeSegment(boltHolder, bp1, bp2, math.random(4, 5), RED_GLOW, 0.65, 8))
                    table.insert(allFrames, makeSegment(boltHolder, bp1, bp2, 1.5, RED_CORE, 0.1, 9))
                end
            end
        end

        -- Impact glow di titik bawah
        local impactX = mainPath[#mainPath].x
        local impactY = mainPath[#mainPath].y

        local impact = Instance.new("Frame")
        impact.AnchorPoint = Vector2.new(0.5, 0.5)
        impact.Position = UDim2.fromScale(impactX, impactY)
        impact.Size = UDim2.fromOffset(28, 28)
        impact.BackgroundColor3 = RED_GLOW
        impact.BackgroundTransparency = 0.4
        impact.BorderSizePixel = 0
        impact.ZIndex = 9
        impact.Parent = boltHolder
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(1, 0)
        ic.Parent = impact
        table.insert(allFrames, impact)

        local impactCore = Instance.new("Frame")
        impactCore.AnchorPoint = Vector2.new(0.5, 0.5)
        impactCore.Position = UDim2.fromScale(impactX, impactY)
        impactCore.Size = UDim2.fromOffset(10, 10)
        impactCore.BackgroundColor3 = WHITE_HOT
        impactCore.BorderSizePixel = 0
        impactCore.ZIndex = 11
        impactCore.Parent = boltHolder
        local icc = Instance.new("UICorner")
        icc.CornerRadius = UDim.new(1, 0)
        icc.Parent = impactCore
        table.insert(allFrames, impactCore)

        -- ═══ Animasi flicker (4 tahap) ═══
        for _, f in ipairs(allFrames) do
            local origTrans = f.BackgroundTransparency
            f.BackgroundTransparency = 1
            task.delay(0.01, function()
                if f.Parent then
                    TweenService:Create(f, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {
                        BackgroundTransparency = origTrans
                    }):Play()
                end
            end)
        end

        task.delay(0.08, function()
            if not boltHolder.Parent then return end
            for _, f in ipairs(allFrames) do
                if f.Parent then
                    f.BackgroundTransparency = math.min(0.85, f.BackgroundTransparency + 0.5)
                end
            end
        end)

        task.delay(0.16, function()
            if not boltHolder.Parent then return end
            for _, f in ipairs(allFrames) do
                if f.Parent then
                    f.BackgroundTransparency = math.max(0, f.BackgroundTransparency - 0.4)
                end
            end
        end)

        task.delay(0.28, function()
            for _, f in ipairs(allFrames) do
                if f.Parent then
                    TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
        end)

        -- Cleanup (dan reset currentBoltHolder)
        task.delay(0.85, function()
            if boltHolder and boltHolder.Parent then
                boltHolder:Destroy()
            end
            if currentBoltHolder == boltHolder then
                currentBoltHolder = nil
            end
        end)
    end

    -- ══════════════════════════════════════════
    -- LOOP SPAWN — 1 sambaran, jeda 3-6 detik
    -- ══════════════════════════════════════════
    task.spawn(function()
        task.wait(2) -- delay awal
        while lightningActive do
            -- ⭐ Cuma spawn kalau gak ada petir aktif (anti numpuk)
            if not currentBoltHolder then
                spawnLightningBolt()
            end

            -- ⭐ Jeda 3-6 detik sebelum cek lagi
            task.wait(math.random(300, 600) / 100)
        end
    end)

    return layer
end

-- ====== FPS WINDOW ======
local function buildFPSWindow(parent)
    local fpsWin = Instance.new("Frame")
    fpsWin.Name = "FPSWindow"
    fpsWin.Size = UDim2.fromOffset(IS_MOBILE and 160 or 180, IS_MOBILE and 64 or 70)
    fpsWin.Position = UDim2.fromOffset(20, 90)
    fpsWin.BackgroundColor3 = C.Surface
    fpsWin.BackgroundTransparency = 0.1
    fpsWin.BorderSizePixel = 0
    fpsWin.Visible = false
    fpsWin.ZIndex = 60
    fpsWin.Parent = parent
    registerTheme(fpsWin, "Surface", "BackgroundColor3")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = fpsWin

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = fpsWin
    registerTheme(stroke, "Accent", "Color")

    local fpsLbl = Instance.new("TextLabel")
    fpsLbl.Size = UDim2.new(1, -20, 0, 24)
    fpsLbl.Position = UDim2.fromOffset(10, 8)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS: --"
    fpsLbl.TextColor3 = C.Text
    fpsLbl.Font = Enum.Font.GothamBold
    fpsLbl.TextSize = IS_MOBILE and 12 or 14
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.ZIndex = 61
    fpsLbl.Parent = fpsWin
    registerTheme(fpsLbl, "Text", "TextColor3")

    local pingLbl = Instance.new("TextLabel")
    pingLbl.Size = UDim2.new(1, -20, 0, 20)
    pingLbl.Position = UDim2.fromOffset(10, IS_MOBILE and 30 or 34)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "PING: --"
    pingLbl.TextColor3 = C.Accent2
    pingLbl.Font = Enum.Font.GothamBold
    pingLbl.TextSize = IS_MOBILE and 11 or 12
    pingLbl.TextXAlignment = Enum.TextXAlignment.Left
    pingLbl.ZIndex = 61
    pingLbl.Parent = fpsWin
    registerTheme(pingLbl, "Accent2", "TextColor3")

    local frames, last = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local elapsed = os.clock() - last
        if elapsed >= 0.5 then
            local fps = math.floor(frames / elapsed)
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            fpsLbl.Text = "FPS: " .. fps
            pingLbl.Text = "PING: " .. ping .. "ms"
            frames = 0
            last = os.clock()
        end
    end)

    return fpsWin
end

-- ============================================================
-- 🏷 TAG SCRIPT PER GAME (untuk Live Chat) — PINDAH KE ATAS
-- ============================================================
local SCRIPT_TAGS = {
    [118517641508250] = "MT SOREYA",  -- Mount Soreya
    [124216119978534] = "RAP",        -- Ride a Pet
    [120219252362013]     = "TFF",        -- Throw Food
}

local function getScriptTag()
    return SCRIPT_TAGS[game.PlaceId]
end

-- ============================================================
-- LIVE CHAT CLIENT (global via Cloudflare Worker + D1)
-- ============================================================
_G.VRILZ_ChatClient = _G.VRILZ_ChatClient or {
    listeners = {},
    lastTs = 0,
    polling = false,
}
local ChatClient = _G.VRILZ_ChatClient

local function getChatHttpRequest()
    return (syn and syn.request)
        or (http and http.request)
        or (http_request)
        or (request)
end

local function chatHttpJSON(url, method, bodyTable)
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function()
        local req = getChatHttpRequest()
        if req then
            local opts = {
                Url = url,
                Method = method,
                Headers = {["Content-Type"] = "application/json"},
            }
            if bodyTable then opts.Body = HttpService:JSONEncode(bodyTable) end
            return req(opts)
        end
        if method == "POST" then
            return {
                StatusCode = 200,
                Body = HttpService:PostAsync(url, HttpService:JSONEncode(bodyTable), Enum.HttpContentType.ApplicationJson)
            }
        else
            return {StatusCode = 200, Body = HttpService:GetAsync(url)}
        end
    end)
    if not ok or not res then return nil end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(res.Body or res.body or "")
    end)
    if not okDecode then return nil end
    return data
end

function ChatClient.onMessage(cb)
    table.insert(ChatClient.listeners, cb)
end

function ChatClient.send(text)
    if type(text) ~= "string" then return false, "invalid" end
    text = text:gsub("[\n\r]", " "):sub(1, 200)
    if text == "" then return false, "empty" end

    local data = chatHttpJSON(
        KEY_SYSTEM_URL:gsub("/$", "") .. "/api/chat/send",
        "POST",
        {
            userId = LocalPlayer.UserId,
            username = LocalPlayer.Name,
            displayName = LocalPlayer.DisplayName,
            text = text,
            scriptTag = getScriptTag() or "",
        }
    )
    if data and data.success then return true end
    return false, (data and data.message) or "network error"
end

function ChatClient.pollOnce()
    local url = KEY_SYSTEM_URL:gsub("/$", "") .. "/api/chat/poll?since=" .. tostring(ChatClient.lastTs)
    local data = chatHttpJSON(url, "GET", nil)
    if not data or not data.success or type(data.messages) ~= "table" then return end

    for _, m in ipairs(data.messages) do
        local ts = tonumber(m.ts or 0)
        if ts > ChatClient.lastTs then ChatClient.lastTs = ts end
        local msg = {
            userId = tonumber(m.i or 0),
            username = tostring(m.u or "?"),
            displayName = tostring(m.d or m.u or "?"),
            text = tostring(m.t or ""),
            time = os.date("%H:%M", math.floor(ts / 1000)),
            ts = ts,
            scriptTag = tostring(m.g or ""),
        }
        table.insert(Shared.LiveChat_Messages, msg)
        while #Shared.LiveChat_Messages > Shared.LiveChat_MaxMessages do
            table.remove(Shared.LiveChat_Messages, 1)
        end
        for _, cb in ipairs(ChatClient.listeners) do
            task.spawn(cb, msg)
        end
    end
end

function ChatClient.start()
    if ChatClient.polling then return end
    ChatClient.polling = true
    task.spawn(function()
        while ChatClient.polling do
            pcall(ChatClient.pollOnce)
            task.wait(Shared.LiveChat_PollInterval or 1.5)
        end
    end)
end

-- ============================================================
-- 🎮 GRAPHICS ENGINE — FPS BOOST + 4K HD MODE
-- ============================================================
local GFX = {
    FPSEnabled = false,
    HDEnabled = false,
    Original = {},
    Created = {},
    LoopThread = nil,
    TextureBackup = {},
    HiddenParts = {},
    Connections = {},
}

local function gfx_save(obj, prop)
    local ok, val = pcall(function() return obj[prop] end)
    if ok then table.insert(GFX.Original, {obj = obj, prop = prop, value = val}) end
end

local function gfx_restore()
    for _, item in ipairs(GFX.Original) do
        pcall(function() item.obj[item.prop] = item.value end)
    end
    GFX.Original = {}
end

local function gfx_add(inst)
    table.insert(GFX.Created, inst)
    return inst
end

local function gfx_cleanup()
    for _, inst in ipairs(GFX.Created) do
        pcall(function() if inst and inst.Parent then inst:Destroy() end end)
    end
    GFX.Created = {}
end

-- ===== FPS BOOST v5 — HIDE ALL VISUAL EFFECTS + HD REALISTIC (NO PATAH-PATAH) =====
-- ⭐ SEMUA VISUAL EFFECT DI-HIDE, LIGHTING NATURAL HD, 100% NO LAG
local function gfx_enableFPS()
    if GFX.FPSEnabled then return end
    GFX.FPSEnabled = true

    -- Reset tracking dulu (biar gak numpuk kalau enable berkali-kali)
    GFX.HiddenParts = {}
    GFX.Connections = {}

    -- ═══════════════════════════════════════════════════════════
    -- 1. SAVE LIGHTING STATE (buat restore nanti)
    -- ═══════════════════════════════════════════════════════════
    gfx_save(Lighting, "GlobalShadows")
    gfx_save(Lighting, "ShadowSoftness")
    gfx_save(Lighting, "Ambient")
    gfx_save(Lighting, "OutdoorAmbient")
    gfx_save(Lighting, "Brightness")
    gfx_save(Lighting, "ExposureCompensation")
    gfx_save(Lighting, "EnvironmentDiffuseScale")
    gfx_save(Lighting, "EnvironmentSpecularScale")
    gfx_save(Lighting, "ColorShift_Top")
    gfx_save(Lighting, "ColorShift_Bottom")
    gfx_save(Lighting, "ClockTime")
    gfx_save(Lighting, "GeographicLatitude")
    gfx_save(Lighting, "FogEnd")
    gfx_save(Lighting, "FogStart")

    -- ═══════════════════════════════════════════════════════════
    -- 2. APPLY HD REALISTIC LIGHTING (natural, gak overbright)
    -- ═══════════════════════════════════════════════════════════
    pcall(function()
        Lighting.GlobalShadows = false         -- shadows off = FPS naik drastis
        Lighting.ShadowSoftness = 0
        Lighting.Ambient = Color3.fromRGB(80, 82, 90)      -- natural gray
        Lighting.OutdoorAmbient = Color3.fromRGB(105, 110, 120) -- outdoor natural
        Lighting.Brightness = 1.4              -- natural (bukan 2.5)
        Lighting.ExposureCompensation = 0
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.5
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ClockTime = 14.5              -- siang natural
        Lighting.GeographicLatitude = 0
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end)

    -- Set graphics quality rendah (FPS boost utama)
    pcall(function()
        local userGameSettings = UserSettings and UserSettings():GetService("UserGameSettings")
        if userGameSettings then
            -- Save dulu
            GFX._origQuality = userGameSettings.SavedQualityLevel
            userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel3
        end
    end)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
    end)

    -- ═══════════════════════════════════════════════════════════
    -- 3. HIDE SEMUA VISUAL EFFECT (PARTICLE, BEAM, TRAIL, DLL)
    -- ═══════════════════════════════════════════════════════════
    local function hideEffect(obj)
        if not obj or not obj.Parent then return end
        if GFX.HiddenParts[obj] then return end  -- ⭐ biar gak double save

        -- Simpan original state
        local backup = { obj = obj }
        pcall(function() backup.enabled = obj.Enabled end)
        pcall(function() backup.rate = obj.Rate end)
        pcall(function() backup.transparency = obj.Transparency end)
        pcall(function() backup.visible = obj.Visible end)
        pcall(function() backup.brightness = obj.Brightness end)
        pcall(function() backup.density = obj.Density end)
        pcall(function() backup.haze = obj.Haze end)
        GFX.HiddenParts[obj] = backup

        -- Hide semua property
        pcall(function() obj.Enabled = false end)
        pcall(function() obj.Transparency = 1 end)
        pcall(function() obj.Visible = false end)
        pcall(function() obj.Rate = 0 end)
        pcall(function() obj.Brightness = 0 end)
        pcall(function() obj.LightEmission = 0 end)
        pcall(function() obj.Density = 0 end)
        pcall(function() obj.Haze = 0 end)
        pcall(function() obj.Glare = 0 end)
    end

    -- ═══ KATEGORI EFFECT YANG DI-HIDE ═══
    local EFFECT_CLASSES = {
        "ParticleEmitter",
        "Beam",
        "Trail",
        "Smoke",
        "Fire",
        "Sparkles",
        "PointLight",
        "SpotLight",
        "SurfaceLight",
        "Explosion",
    }

    -- Skip VRILZ objects (ESP/Highlight jangan di-hide)
    local function isVrilzObject(obj)
        local p = obj
        local depth = 0
        while p and depth < 5 do
            if p.Name and tostring(p.Name):find("VRILZ_", 1, true) then
                return true
            end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end

        -- ═══════════════════════════════════════════════════════════
    -- 3.5 HIDE POHON & WALL (exact match — aman, gak kena jalan)
    -- ═══════════════════════════════════════════════════════════
    local HIDE_NAMES = {
        -- ═══ POHON ═══
        ["ForestTree1"] = true,
        ["ForestTree2"] = true,
        ["ForestBush1"] = true,
        ["ForestFern1"] = true,
        ["ForestGrassPatch1"] = true,
        ["Trunk"] = true,
        ["TrunkDark"] = true,
        ["Leaves"] = true,
        ["LeavesSecondary"] = true,
        ["Leaf"] = true,
        ["Fern"] = true,
        ["FernLight"] = true,

        -- ═══ WALL / PAGAR ═══
        ["Wood"] = true,
        ["DarkWood"] = true,
        ["LightWood"] = true,
        ["WoodLight"] = true,
        ["WoodDark"] = true,
        ["WoodInner"] = true,
        ["Fence"] = true,
        ["Wall"] = true,
        ["WallWood"] = true,
    }

    local function isHideTarget(obj)
        if not obj or not obj.Parent then return false end
        return HIDE_NAMES[obj.Name] == true
    end

    local function hideTree(obj)
        if not obj or not obj.Parent then return end
        if GFX.HiddenParts[obj] then return end

        local backup = { obj = obj, isTree = true }
        GFX.HiddenParts[obj] = backup

        if obj:IsA("BasePart") then
            pcall(function() backup.transparency = obj.Transparency end)
            pcall(function() backup.collide = obj.CanCollide end)
            pcall(function() obj.Transparency = 1 end)
            pcall(function() obj.CanCollide = false end)
            pcall(function() obj.CanQuery = false end)
            pcall(function() obj.CanTouch = false end)
        elseif obj:IsA("Model") then
            local partsBackup = {}
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    partsBackup[d] = {
                        transparency = d.Transparency,
                        collide = d.CanCollide,
                    }
                    pcall(function() d.Transparency = 1 end)
                    pcall(function() d.CanCollide = false end)
                    pcall(function() d.CanQuery = false end)
                    pcall(function() d.CanTouch = false end)
                end
            end
            backup.parts = partsBackup
        end
    end

    task.spawn(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not GFX.FPSEnabled then break end
            if isHideTarget(obj) and not isVrilzObject(obj) then
                hideTree(obj)
            end
        end

        local hideConn = Workspace.DescendantAdded:Connect(function(obj)
            if not GFX.FPSEnabled then return end
            task.defer(function()
                if obj and obj.Parent and isHideTarget(obj) and not isVrilzObject(obj) then
                    hideTree(obj)
                end
            end)
        end)
        table.insert(GFX.Connections, hideConn)
    end)

    -- ═══ SCAN SEMUA EFFECT DI WORKSPACE ═══
    task.spawn(function()
        local function scanEffects()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if not GFX.FPSEnabled then break end

                local isEffect = false
                for _, class in ipairs(EFFECT_CLASSES) do
                    if obj:IsA(class) then
                        isEffect = true
                        break
                    end
                end

                if isEffect and not isVrilzObject(obj) then
                    hideEffect(obj)
                end
            end
        end

        scanEffects()

        -- ═══ WATCH EFFECT BARU (muncul belakangan) ═══
        local conn = Workspace.DescendantAdded:Connect(function(obj)
            if not GFX.FPSEnabled then return end
            task.defer(function()
                if not obj or not obj.Parent then return end

                local isEffect = false
                for _, class in ipairs(EFFECT_CLASSES) do
                    if obj:IsA(class) then
                        isEffect = true
                        break
                    end
                end

                if isEffect and not isVrilzObject(obj) then
                    hideEffect(obj)
                end

                -- ⭐ Cek descendants juga (misal Model baru yang ada particle di dalamnya)
                pcall(function()
                    for _, d in ipairs(obj:GetDescendants()) do
                        if not GFX.FPSEnabled then break end
                        for _, class in ipairs(EFFECT_CLASSES) do
                            if d:IsA(class) and not isVrilzObject(d) then
                                hideEffect(d)
                                break
                            end
                        end
                    end
                end)
            end)
        end)
        table.insert(GFX.Connections, conn)

        -- ═══ HIDE EFFECT DI LIGHTING JUGA ═══
        for _, obj in ipairs(Lighting:GetDescendants()) do
            for _, class in ipairs(EFFECT_CLASSES) do
                if obj:IsA(class) then
                    hideEffect(obj)
                    break
                end
            end
        end

        notify("✨ FPS Boost ON — " .. tostring(#Workspace:GetDescendants()) .. " objects scanned", "success")
    end)
    
    -- ═══════════════════════════════════════════════════════════
    -- 4. HIDE POST-PROCESSING EFFECT BERAT (Atmosphere, DOF, SunRays, Bloom)
    -- ═══════════════════════════════════════════════════════════
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            gfx_save(obj, "Density")
            gfx_save(obj, "Haze")
            pcall(function()
                obj.Density = 0
                obj.Haze = 0
            end)
        elseif obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") then
            gfx_save(obj, "Enabled")
            gfx_save(obj, "Intensity")
            pcall(function()
                obj.Enabled = false
                obj.Intensity = 0
            end)
        elseif obj:IsA("ColorCorrectionEffect") then
            gfx_save(obj, "Brightness")
            gfx_save(obj, "Contrast")
            gfx_save(obj, "Saturation")
            pcall(function()
                obj.Brightness = 0
                obj.Contrast = 0
                obj.Saturation = 0
            end)
        end
    end

    -- ═══════════════════════════════════════════════════════════
    -- 5. COLOR CORRECTION RINGAN (HD realistic, gak flat)
    -- ═══════════════════════════════════════════════════════════
    local oldCC = Lighting:FindFirstChild("VRILZ_FPS_CC")
    if oldCC then oldCC:Destroy() end

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "VRILZ_FPS_CC"
    cc.Brightness = 0.02       -- tipis, biar gak gelap
    cc.Contrast = 0.05         -- sedikit kontras
    cc.Saturation = 0.06       -- warna tetap hidup
    cc.TintColor = Color3.fromRGB(255, 255, 255)
    cc.Parent = Lighting
    gfx_add(cc)

    -- ═══════════════════════════════════════════════════════════
    -- 6. RE-APPLY LOOP (effect baru kadang muncul lagi / respawn)
    -- ═══════════════════════════════════════════════════════════
    if not GFX.LoopThread then
        GFX.LoopThread = task.spawn(function()
            while GFX.FPSEnabled do
                task.wait(2)  -- ⭐ 2s, hemat CPU
                if not GFX.FPSEnabled then break end

                -- Re-apply graphics quality
                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
                end)

                -- Re-hide effect yang muncul lagi (batched)
                local count = 0
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if count >= 100 then break end  -- ⭐ batasi per pass
                    if not GFX.FPSEnabled then break end

                    local isEffect = false
                    for _, class in ipairs(EFFECT_CLASSES) do
                        if obj:IsA(class) then
                            isEffect = true
                            break
                        end
                    end

                    if isEffect and not isVrilzObject(obj) then
                        if not GFX.HiddenParts[obj] then
                            hideEffect(obj)
                            count = count + 1
                        elseif obj.Enabled ~= false then
                            pcall(function() obj.Enabled = false end)
                            count = count + 1
                        end
                    end
                end
            end
        end)
    end

    notify("FPS Boost ON ✅", "success")
end

local function gfx_disableFPS()
    if not GFX.FPSEnabled then return end
    GFX.FPSEnabled = false
    GFX.LoopThread = nil

    -- ═══ DISCONNECT WATCHER ═══
    for _, conn in ipairs(GFX.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    GFX.Connections = {}

    -- ═══ RESTORE SEMUA EFFECT YANG DISEMBUNYIKAN ═══
        for obj, backup in pairs(GFX.HiddenParts) do
        if obj and obj.Parent then
            pcall(function()
                if backup.enabled ~= nil then obj.Enabled = backup.enabled end
                if backup.rate ~= nil then obj.Rate = backup.rate end
                if backup.transparency ~= nil then obj.Transparency = backup.transparency end
                if backup.visible ~= nil then obj.Visible = backup.visible end
                if backup.brightness ~= nil then obj.Brightness = backup.brightness end
                if backup.density ~= nil then obj.Density = backup.density end
                if backup.haze ~= nil then obj.Haze = backup.haze end

                -- ⭐ Restore pohon / wall
                if backup.isTree then
                    if backup.parts then
                        for part, partData in pairs(backup.parts) do
                            if part and part.Parent then
                                pcall(function() part.Transparency = partData.transparency end)
                                pcall(function() part.CanCollide = partData.collide end)
                                pcall(function() part.CanQuery = true end)
                                pcall(function() part.CanTouch = true end)
                            end
                        end
                    elseif obj:IsA("BasePart") then
                        if backup.transparency ~= nil then
                            pcall(function() obj.Transparency = backup.transparency end)
                        end
                        if backup.collide ~= nil then
                            pcall(function() obj.CanCollide = backup.collide end)
                        end
                        pcall(function() obj.CanQuery = true end)
                        pcall(function() obj.CanTouch = true end)
                    end
                end
            end)
        end
    end
    GFX.HiddenParts = {}

    -- ═══ RESTORE GRAPHICS QUALITY ═══
    if GFX._origQuality then
        pcall(function()
            local userGameSettings = UserSettings and UserSettings():GetService("UserGameSettings")
            if userGameSettings then
                userGameSettings.SavedQualityLevel = GFX._origQuality
            end
        end)
        GFX._origQuality = nil
    end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
    end)

    -- ═══ RESTORE LIGHTING STATE ═══
    gfx_restore()

    -- ═══ HAPUS COLOR CORRECTION TAMBAHAN ═══
    local cc = Lighting:FindFirstChild("VRILZ_FPS_CC")
    if cc then cc:Destroy() end

    notify("FPS Boost disabled", "info")
end

-- ===== 4K HD MODE =====
local function gfx_enableHD()
    if GFX.HDEnabled then return end
    GFX.HDEnabled = true

    -- Auto-disable FPS Boost
    if GFX.FPSEnabled then
        gfx_disableFPS()
        notify("⚠️ FPS Boost dimatiin (bentrok sama 4K HD)", "warning")
    end

    -- Render
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level10 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
    pcall(function() settings().Rendering.AntiAliasing = Enum.AntiAliasingMode.MSAA_4x end)
    pcall(function() settings().Rendering.EagerBulkExecution = false end)
    pcall(function() workspace.StreamingTargetRadius = 1024 end)
    pcall(function() workspace.StreamingMinRadius = 256 end)

    -- Lighting
    gfx_save(Lighting, "GlobalShadows")
    gfx_save(Lighting, "EnvironmentDiffuseScale")
    gfx_save(Lighting, "EnvironmentSpecularScale")
    gfx_save(Lighting, "Ambient")
    gfx_save(Lighting, "OutdoorAmbient")
    gfx_save(Lighting, "Brightness")
    gfx_save(Lighting, "ClockTime")
    gfx_save(Lighting, "ExposureCompensation")
    gfx_save(Lighting, "FogEnd")
    gfx_save(Lighting, "FogStart")
    gfx_save(Lighting, "ShadowSoftness")
    pcall(function()
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = 0.35
    Lighting.EnvironmentDiffuseScale = 0.6
    Lighting.EnvironmentSpecularScale = 0.6
    Lighting.Brightness = 1.4          -- natural, bukan 2.5
    Lighting.ExposureCompensation = 0  -- netral, gak overbright
    Lighting.ClockTime = 14.5
    Lighting.GeographicLatitude = 0
    Lighting.Ambient = Color3.fromRGB(70, 72, 82)
    Lighting.OutdoorAmbient = Color3.fromRGB(95, 100, 110)
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end)
    pcall(function()
        gfx_save(Lighting, "Technology")
        Lighting.Technology = Enum.Technology.Future
    end)

    -- Post FX
    for _, name in ipairs({"VRILZ_HD_Bloom","VRILZ_HD_SunRays","VRILZ_HD_DOF",
                            "VRILZ_HD_ColorCorrection","VRILZ_HD_Atmosphere","VRILZ_HD_Sky"}) do
        local old = Lighting:FindFirstChild(name)
        if old then old:Destroy() end
    end

    local bloom = Instance.new("BloomEffect")
bloom.Name = "VRILZ_HD_Bloom"
bloom.Intensity = 0.5          -- dari 1.4 → 0.5 (halus)
bloom.Size = 20
bloom.Threshold = 1.1          -- cuma highlight yg glow, bukan semua
bloom.Parent = Lighting
gfx_add(bloom)

local sunRays = Instance.new("SunRaysEffect")
sunRays.Name = "VRILZ_HD_SunRays"
sunRays.Intensity = 0.08       -- dari 0.18 → 0.08 (tipis)
sunRays.Spread = 0.6
sunRays.Parent = Lighting
gfx_add(sunRays)

local dof = Instance.new("DepthOfFieldEffect")
dof.Name = "VRILZ_HD_DOF"
dof.FarIntensity = 0.12
dof.FocusDistance = 45
dof.InFocusRadius = 32
dof.NearIntensity = 0.04
dof.Parent = Lighting
gfx_add(dof)

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "VRILZ_HD_ColorCorrection"
cc.Brightness = 0              -- dari 0.03 → 0
cc.Contrast = 0.08             -- dari 0.18 → 0.08 (gak terlalu kontras)
cc.Saturation = 0.06           -- dari 0.15 → 0.06 (natural)
cc.TintColor = Color3.fromRGB(255, 255, 255)  -- netral, gak ada tint
cc.Parent = Lighting
gfx_add(cc)

local atmo = Instance.new("Atmosphere")
atmo.Name = "VRILZ_HD_Atmosphere"
atmo.Density = 0.12            -- dari 0.32 → 0.12 (tipis)
atmo.Offset = 0.1
atmo.Color = Color3.fromRGB(200, 202, 208)
atmo.Decay = Color3.fromRGB(108, 115, 128)
atmo.Glare = 0.05              -- dari 0.18 → 0.05 (gak silau)
atmo.Haze = 0.3                -- dari 1.3 → 0.3 (penting!)
atmo.Parent = Lighting
gfx_add(atmo)
    
    if not Lighting:FindFirstChildOfClass("Sky") then
        local sky = Instance.new("Sky")
        sky.Name = "VRILZ_HD_Sky"
        sky.SkyboxBk = "rbxassetid://159454299"
        sky.SkyboxDn = "rbxassetid://159454296"
        sky.SkyboxFt = "rbxassetid://159454293"
        sky.SkyboxLf = "rbxassetid://159454286"
        sky.SkyboxRt = "rbxassetid://159454300"
        sky.SkyboxUp = "rbxassetid://159454288"
        sky.SunAngularSize = 22
        sky.MoonAngularSize = 12
        sky.StarCount = 3500
        sky.Parent = Lighting
        gfx_add(sky)
    end

    -- Terrain
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            gfx_save(terrain, "WaterWaveSize")
            gfx_save(terrain, "WaterWaveSpeed")
            gfx_save(terrain, "WaterReflectance")
            gfx_save(terrain, "WaterTransparency")
            terrain.WaterWaveSize = 0.18
            terrain.WaterWaveSpeed = 12
            terrain.WaterReflectance = 0.18
            terrain.WaterTransparency = 0.08
        end
    end)

    -- Materials
    pcall(function()
        local ms = game:GetService("MaterialService")
        if ms then
            gfx_save(ms, "Use2022Materials")
            ms.Use2022Materials = true
        end
    end)

    -- Texture sharpen
    task.spawn(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if count >= 800 then break end
            if obj:IsA("Texture") then
                pcall(function()
                    table.insert(GFX.TextureBackup, {obj = obj, u = obj.StudsPerTileU, v = obj.StudsPerTileV})
                    obj.StudsPerTileU = obj.StudsPerTileU * 0.6
                    obj.StudsPerTileV = obj.StudsPerTileV * 0.6
                end)
                count = count + 1
            elseif obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
                count = count + 1
            end
        end
    end)

    -- Continuous re-apply
    if not GFX.LoopThread then
GFX.LoopThread = task.spawn(function()
    while GFX.HDEnabled do
        task.wait(2)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level10 end)
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.6
            Lighting.EnvironmentSpecularScale = 0.6
            Lighting.Brightness = 1.4
            Lighting.ExposureCompensation = 0
        end)
        pcall(function() workspace.StreamingTargetRadius = 1024 end)
    end
end)
    end

    notify("🎮 4K HD Mode: ON", "success")
end

local function gfx_disableHD()
    if not GFX.HDEnabled then return end
    GFX.HDEnabled = false
    GFX.LoopThread = nil

    gfx_cleanup()

    for _, item in ipairs(GFX.TextureBackup) do
        pcall(function()
            if item.obj and item.obj.Parent then
                item.obj.StudsPerTileU = item.u
                item.obj.StudsPerTileV = item.v
            end
        end)
    end
    GFX.TextureBackup = {}

    gfx_restore()

    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level06 end)

    notify("🎮 4K HD Mode: OFF", "info")
end

-- ============================================================
-- 🌐 PLAYER ONLINE PRESENCE — via jsonbin.io
-- ============================================================
_G.VRILZ_Presence = _G.VRILZ_Presence or {
    OnlineCount = 0,
    Started = false,
}

local function presenceReq(method, body)
    local HttpService = game:GetService("HttpService")
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end

    local url = "https://api.jsonbin.io/v3/b/" .. JSONBIN_ID
    local opts = {
        Url = url,
        Method = method,
        Headers = {
            ["Content-Type"] = "application/json",
            ["X-Master-Key"] = JSONBIN_KEY,
            ["X-Bin-Meta"] = "false",
        },
    }
    if body then opts.Body = HttpService:JSONEncode(body) end

    local ok, res = pcall(req, opts)
    if not ok or not res then return nil end
    local bodyStr = res.Body or res.body or ""
    local okDec, data = pcall(function() return HttpService:JSONDecode(bodyStr) end)
    if not okDec then return nil end
    return data
end

function _G.VRILZ_Presence.Start()
    if _G.VRILZ_Presence.Started then return end
    _G.VRILZ_Presence.Started = true

    local myId = tostring(LocalPlayer.UserId)
    local TIMEOUT = 60 -- detik

    -- Heartbeat tiap 25 detik
    task.spawn(function()
        while true do
            pcall(function()
                local data = presenceReq("GET") or {}
                if type(data) ~= "table" then data = {} end
                
                -- Hapus yang expired
                local now = os.time()
                for uid, ts in pairs(data) do
                    if type(ts) ~= "number" or (now - ts) > TIMEOUT then
                        data[uid] = nil
                    end
                end
                data[myId] = now

                presenceReq("PUT", data)
            end)
            task.wait(25)
        end
    end)

    -- Poll count tiap 10 detik
    task.spawn(function()
        while true do
            local data = presenceReq("GET")
            if type(data) == "table" then
                local now = os.time()
                local n = 0
                for uid, ts in pairs(data) do
                    if type(ts) == "number" and (now - ts) <= TIMEOUT then
                        n = n + 1
                    end
                end
                _G.VRILZ_Presence.OnlineCount = n
            end
            task.wait(10)
        end
    end)
end

-- ============================================================
-- ⚠️ CLOSE CONFIRMATION POPUP
-- ============================================================
local function showCloseConfirmation(parent, onConfirm, onCancel)
    -- Dim background blocker
    local blocker = Instance.new("TextButton")
    blocker.Name = "CloseConfirmBlocker"
    blocker.Size = UDim2.fromScale(1, 1)
    blocker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blocker.BackgroundTransparency = 0.4
    blocker.Text = ""
    blocker.AutoButtonColor = false
    blocker.ZIndex = 900
    blocker.Parent = parent

    -- Popup card
    local popup = Instance.new("Frame")
    popup.Name = "CloseConfirmPopup"
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.Position = UDim2.fromScale(0.5, 0.5)
    popup.Size = UDim2.fromOffset(0, 0)
    popup.BackgroundColor3 = C.Surface
    popup.BorderSizePixel = 0
    popup.ZIndex = 901
    popup.ClipsDescendants = true
    popup.Parent = blocker

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 16)
    pc.Parent = popup

    local pgrad = Instance.new("UIGradient")
    pgrad.Rotation = 135
    pgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 20, 22)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 12, 14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 5, 6)),
    })
    pgrad.Parent = popup

    local pstroke = Instance.new("UIStroke")
    pstroke.Color = C.Error
    pstroke.Thickness = 2
    pstroke.Transparency = 0.2
    pstroke.Parent = popup

    -- Warning icon
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.fromOffset(48, 48)
    iconFrame.Position = UDim2.new(0.5, 0, 0, 18)
    iconFrame.AnchorPoint = Vector2.new(0.5, 0)
    iconFrame.BackgroundColor3 = C.Error
    iconFrame.BackgroundTransparency = 0.85
    iconFrame.BorderSizePixel = 0
    iconFrame.ZIndex = 903
    iconFrame.Parent = popup
    local ifc = Instance.new("UICorner")
    ifc.CornerRadius = UDim.new(1, 0)
    ifc.Parent = iconFrame

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.fromScale(1, 1)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = "⚠"
    iconLbl.TextColor3 = C.Error
    iconLbl.Font = Enum.Font.GothamBlack
    iconLbl.TextSize = 26
    iconLbl.ZIndex = 904
    iconLbl.Parent = iconFrame

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -32, 0, 24)
    titleLbl.Position = UDim2.new(0, 16, 0, 76)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Are you sure you want to close?"
    titleLbl.TextColor3 = C.Text
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 15
    titleLbl.ZIndex = 903
    titleLbl.Parent = popup
    registerTheme(titleLbl, "Text", "TextColor3")

    -- Description
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -32, 0, 40)
    descLbl.Position = UDim2.new(0, 16, 0, 102)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = "All features will stop working and\nthe script will be fully unloaded."
    descLbl.TextColor3 = C.Muted
    descLbl.Font = Enum.Font.GothamSemibold
    descLbl.TextSize = 11
    descLbl.TextWrapped = true
    descLbl.ZIndex = 903
    descLbl.Parent = popup
    registerTheme(descLbl, "Muted", "TextColor3")

    -- Button row
    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -32, 0, 38)
    btnRow.Position = UDim2.new(0, 16, 0, 152)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 903
    btnRow.Parent = popup

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 10)
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.Parent = btnRow

    -- Go Back (safe)
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0.5, -5, 1, 0)
    backBtn.BackgroundColor3 = C.Surface3
    backBtn.Text = "← Go Back"
    backBtn.TextColor3 = C.Text
    backBtn.Font = Enum.Font.GothamBold
    backBtn.TextSize = 12
    backBtn.BorderSizePixel = 0
    backBtn.AutoButtonColor = false
    backBtn.LayoutOrder = 1
    backBtn.ZIndex = 904
    backBtn.Parent = btnRow
    registerTheme(backBtn, "Surface3", "BackgroundColor3")

    local bbCorner = Instance.new("UICorner")
    bbCorner.CornerRadius = UDim.new(0, 10)
    bbCorner.Parent = backBtn

    local bbStroke = Instance.new("UIStroke")
    bbStroke.Color = C.Text
    bbStroke.Thickness = 1
    bbStroke.Transparency = 0.7
    bbStroke.Parent = backBtn

    -- Close (danger)
    local closeConfirmBtn = Instance.new("TextButton")
    closeConfirmBtn.Size = UDim2.new(0.5, -5, 1, 0)
    closeConfirmBtn.BackgroundColor3 = C.Error
    closeConfirmBtn.Text = "✕ Close Script"
    closeConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
    closeConfirmBtn.Font = Enum.Font.GothamBlack
    closeConfirmBtn.TextSize = 12
    closeConfirmBtn.BorderSizePixel = 0
    closeConfirmBtn.AutoButtonColor = false
    closeConfirmBtn.LayoutOrder = 2
    closeConfirmBtn.ZIndex = 904
    closeConfirmBtn.Parent = btnRow

    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(0, 10)
    cbc.Parent = closeConfirmBtn

    local cbStroke = Instance.new("UIStroke")
    cbStroke.Color = Color3.fromRGB(255, 180, 180)
    cbStroke.Thickness = 1
    cbStroke.Transparency = 0.5
    cbStroke.Parent = closeConfirmBtn

    -- Hover
    backBtn.MouseEnter:Connect(function()
        TweenService:Create(backBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.Surface2 }):Play()
    end)
    backBtn.MouseLeave:Connect(function()
        TweenService:Create(backBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.Surface3 }):Play()
    end)

    closeConfirmBtn.MouseEnter:Connect(function()
        TweenService:Create(closeConfirmBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(255, 90, 100)
        }):Play()
    end)
    closeConfirmBtn.MouseLeave:Connect(function()
        TweenService:Create(closeConfirmBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.Error
        }):Play()
    end)

    -- Animate in
    local targetW = IS_MOBILE and math.min(320, (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 400) - 40) or 340
    local targetH = 210
    popup.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(targetW, targetH)
    }):Play()

    local function destroyPopup(cb)
        TweenService:Create(popup, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        TweenService:Create(blocker, TweenInfo.new(0.25), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.28)
        blocker:Destroy()
        if cb then cb() end
    end

    backBtn.MouseButton1Click:Connect(function()
        destroyPopup(function()
            if onCancel then onCancel() end
        end)
    end)

    closeConfirmBtn.MouseButton1Click:Connect(function()
        destroyPopup(function()
            if onConfirm then onConfirm() end
        end)
    end)

        -- Click outside = cancel (safe default)
    blocker.MouseButton1Click:Connect(function(input)
        if not input then return end -- ⭐ FIX ERROR: cegah index nil
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local pPos = popup.AbsolutePosition
            local pSize = popup.AbsoluteSize
            if pos.X < pPos.X or pos.X > pPos.X + pSize.X
                or pos.Y < pPos.Y or pos.Y > pPos.Y + pSize.Y then
                destroyPopup(function()
                    if onCancel then onCancel() end
                end)
            end
        end
    end)
end

-- ============================================================
-- BUILD MAIN WINDOW
-- ============================================================
local function buildMainWindow(parent)
    local screenGui = parent
    local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)

local winW, winH
if IS_MOBILE then
    -- Mobile: target 400 x 520 (pakai math biar aman di layar kecil)
    winW = math.min(400, math.floor(viewport.X * 0.88))
    winH = math.min(520, math.floor(viewport.Y * 0.78))
else
    -- Samakan dengan SenaHub: 720 x 480
    winW = math.min(720, math.floor(viewport.X * 0.90))
    winH = math.min(480, math.floor(viewport.Y * 0.88))
end

    local main = Instance.new("Frame")
main.Name = "MainWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(winW, winH)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.ZIndex = 1
main.Parent = screenGui
registerTheme(main, "BG", "BackgroundColor3")

-- ⭐⭐⭐ FOTO ANIME BACKGROUND ⭐⭐⭐
local animeBg = Instance.new("ImageLabel")
animeBg.Name = "AnimeBackground"
animeBg.Size = UDim2.fromScale(1, 1)
animeBg.Position = UDim2.fromScale(0, 0)
animeBg.BackgroundTransparency = 1
-- ⭐⭐⭐ GITHUB IMAGE LOADER ⭐⭐⭐
local GITHUB_ANIME_URL = "https://raw.githubusercontent.com/vrilz-vd/anime/refs/heads/main/tokyoanime.jpe"
local GITHUB_ANIME_CACHE = "vrilz_anime_bg_v5.png"

local function loadGithubImage()
    -- Cek apakah executor support getcustomasset
    if not (writefile and isfile and getcustomasset) then
        warn("[BG] Executor gak support getcustomasset")
        return nil
    end
    
    -- Cek cache dulu
    if isfile(GITHUB_ANIME_CACHE) then
        local ok, asset = pcall(getcustomasset, GITHUB_ANIME_CACHE)
        if ok and asset then
            return asset
        end
    end
    
    -- Download dari GitHub
    local ok, content = pcall(function()
        return game:HttpGet(GITHUB_ANIME_URL)
    end)
    
    if not ok or not content then
        warn("[BG] ❌ Gagal download dari GitHub")
        return nil
    end
    
    -- Simpan ke file lokal
    pcall(writefile, GITHUB_ANIME_CACHE, content)
    
    -- Convert ke asset
    local ok2, asset = pcall(getcustomasset, GITHUB_ANIME_CACHE)
    if ok2 and asset then
        return asset
    end
    
    warn("[BG] ❌ Gagal convert ke asset")
    return nil
end

-- Pasang ke ImageLabel
local bgAsset = loadGithubImage()
if bgAsset then
    animeBg.Image = bgAsset
else
    animeBg.Image = ""
    animeBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
end
-- ⭐⭐⭐ END GITHUB IMAGE LOADER ⭐⭐⭐
animeBg.ScaleType = Enum.ScaleType.Crop
animeBg.ZIndex = 1
animeBg.Parent = main

local animeBgCorner = Instance.new("UICorner")
animeBgCorner.CornerRadius = UDim.new(0, 0)
animeBgCorner.Parent = animeBg

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 0)
    shadowCorner.Parent = shadow

    local bevel = Instance.new("Frame")
    bevel.Name = "WindowBevel"
    bevel.Size = UDim2.new(1, -2, 1, -2)
    bevel.Position = UDim2.fromOffset(1, 1)
    bevel.BackgroundTransparency = 1
    bevel.BorderSizePixel = 0
    bevel.ZIndex = 1
    bevel.Parent = main
    local bevelCorner = Instance.new("UICorner")
    bevelCorner.CornerRadius = UDim.new(0, 0)
    bevelCorner.Parent = bevel
    local bevelStroke = Instance.new("UIStroke")
    bevelStroke.Color = Color3.fromRGB(255, 255, 255)
    bevelStroke.Thickness = 1
    bevelStroke.Transparency = 0.88
    bevelStroke.Parent = bevel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 0)
    corner.Parent = main

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(23, 24, 29)),
        ColorSequenceKeypoint.new(0.45, C.BG),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 6, 9)),
    })

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Accent
    stroke.Thickness = 2.6
    stroke.Transparency = 0.08
    stroke.Parent = main
    registerTheme(stroke, "Accent", "Color")

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, CFG.HEADER_H)
    header.BackgroundColor3 = C.Surface
    header.BorderSizePixel = 0
    header.ZIndex = 10
    header.Parent = main
    header.Active = true
    registerTheme(header, "Surface", "BackgroundColor3")
    header.BackgroundTransparency = 0.35

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 0)
    headerCorner.Parent = header

    local headerGlow = Instance.new("Frame")
    headerGlow.Size = UDim2.new(1, -24, 0, 2)
    headerGlow.Position = UDim2.new(0, 12, 1, -2)
    headerGlow.BackgroundColor3 = C.Accent
    headerGlow.BackgroundTransparency = 0.15
    headerGlow.BorderSizePixel = 0
    headerGlow.ZIndex = 12
    headerGlow.Parent = header
    local headerGlowCorner = Instance.new("UICorner")
    headerGlowCorner.CornerRadius = UDim.new(1, 0)
    headerGlowCorner.Parent = headerGlow
    registerTheme(headerGlow, "Accent", "BackgroundColor3")

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 14)
    headerFix.Position = UDim2.new(0, 0, 1, -14)
    headerFix.BackgroundTransparency = 1
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 10
    headerFix.Parent = header

   -- ⭐⭐⭐ VH LOGO 3D + PETIR MERAH ⭐⭐⭐
local logoHolder = Instance.new("Frame")
logoHolder.Name = "HeaderLogo"
logoHolder.Size = UDim2.fromOffset(IS_MOBILE and 32 or 38, IS_MOBILE and 32 or 38)
logoHolder.Position = UDim2.fromOffset(IS_MOBILE and 10 or 12, (CFG.HEADER_H - (IS_MOBILE and 32 or 38)) / 2)
logoHolder.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
logoHolder.BackgroundTransparency = 1
logoHolder.ZIndex = 11
logoHolder.ClipsDescendants = true
logoHolder.Parent = header

local lhCorner = Instance.new("UICorner")
lhCorner.CornerRadius = UDim.new(0, 8)
lhCorner.Parent = logoHolder

-- Garis tepi menyala
local lhStroke = Instance.new("UIStroke")
lhStroke.Color = C.Accent
lhStroke.Thickness = 1.5
lhStroke.Transparency = 0.2
lhStroke.Parent = logoHolder

local textSizeVal = IS_MOBILE and 14 or 18

-- Efek 3D Shadow
local vhShadow = Instance.new("TextLabel")
vhShadow.Size = UDim2.fromScale(1, 1)
vhShadow.Position = UDim2.fromOffset(2, 2)
vhShadow.BackgroundTransparency = 1
vhShadow.Text = "VH"
vhShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
vhShadow.TextTransparency = 0.2
vhShadow.Font = Enum.Font.GothamBlack
vhShadow.TextSize = textSizeVal
vhShadow.ZIndex = 12
vhShadow.Parent = logoHolder

-- Efek 3D Depth (Warna Orange/Accent)
local vhDepth = Instance.new("TextLabel")
vhDepth.Size = UDim2.fromScale(1, 1)
vhDepth.Position = UDim2.fromOffset(1, 1)
vhDepth.BackgroundTransparency = 1
vhDepth.Text = "VH"
vhDepth.TextColor3 = C.Accent
vhDepth.Font = Enum.Font.GothamBlack
vhDepth.TextSize = textSizeVal
vhDepth.ZIndex = 13
vhDepth.Parent = logoHolder

-- Teks Utama Putih
local vhFace = Instance.new("TextLabel")
vhFace.Size = UDim2.fromScale(1, 1)
vhFace.BackgroundTransparency = 1
vhFace.Text = "VH"
vhFace.TextColor3 = Color3.fromRGB(255, 255, 255)
vhFace.Font = Enum.Font.GothamBlack
vhFace.TextSize = textSizeVal
vhFace.TextStrokeColor3 = C.Accent
vhFace.TextStrokeTransparency = 0
vhFace.ZIndex = 14
vhFace.Parent = logoHolder
registerTheme(vhFace, "Accent", "TextStrokeColor3")  -- ⭐ TAMBAH INI

-- ⚡ EFEK PETIR MERAH ⚡
local lightningHolder = Instance.new("Frame")
lightningHolder.Size = UDim2.fromScale(1, 1)
lightningHolder.BackgroundTransparency = 1
lightningHolder.ClipsDescendants = true
lightningHolder.ZIndex = 15
lightningHolder.Parent = logoHolder

task.spawn(function()
    while logoHolder.Parent do
        task.wait(math.random(10, 25) / 10) -- Jeda acak
        if not logoHolder.Parent then break end
        
        -- Bikin garis petir
        local bolt = Instance.new("Frame")
        bolt.AnchorPoint = Vector2.new(0.5, 0.5)
        bolt.Size = UDim2.fromOffset(1.5, math.random(8, 12))
        bolt.Position = UDim2.fromScale(math.random(20, 80)/100, math.random(20, 80)/100)
        bolt.Rotation = math.random(-45, 45)
        bolt.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- MERAH NYALA
        bolt.BorderSizePixel = 0
        bolt.ZIndex = 16
        bolt.Parent = lightningHolder
        
        -- Animasi kilat hilang
        task.wait(0.05)
        bolt.BackgroundTransparency = 1
        task.wait(0.05)
        if bolt then bolt:Destroy() end
    end
end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 0, 20)
    title.Position = UDim2.fromOffset(IS_MOBILE and 48 or 58, IS_MOBILE and 8 or 10)
    title.BackgroundTransparency = 1
    title.Text = "VRILZHUB"
    title.TextColor3 = C.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = IS_MOBILE and 13 or 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = header
    registerTheme(title, "Text", "TextColor3")

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 300, 0, 14)
    subtitle.Position = UDim2.fromOffset(IS_MOBILE and 48 or 58, IS_MOBILE and 26 or 28)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Throw Food A · v1.0"
    subtitle.TextColor3 = C.Muted
    subtitle.Font = Enum.Font.GothamSemibold
    subtitle.TextSize = IS_MOBILE and 9 or 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 11
    subtitle.Parent = header
    registerTheme(subtitle, "Muted", "TextColor3")

    -- PLAYER PROFILE CHIP
    local profile = Instance.new("Frame")
    profile.Name = "PlayerProfile"
    local headerGap = IS_MOBILE and 10 or 14
    local closeW = IS_MOBILE and 28 or 32
    local minW = IS_MOBILE and 28 or 32
    local closeRight = IS_MOBILE and 8 or 10
    local closeLeft = -(closeRight + closeW)
    local minLeft = closeLeft - headerGap - minW
    local profileRight = minLeft - headerGap

    profile.Size = UDim2.fromOffset(IS_MOBILE and 126 or 168, IS_MOBILE and 34 or 38)
    profile.AnchorPoint = Vector2.new(1, 0.5)
    profile.Position = UDim2.new(1, profileRight, 0.5, 0)
    profile.BackgroundColor3 = C.Surface2
    profile.BorderSizePixel = 0
    profile.ZIndex = 12
    profile.Parent = header
    registerTheme(profile, "Surface2", "BackgroundColor3")
    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(1, 0)
    profileCorner.Parent = profile
    local profileStroke = Instance.new("UIStroke")
    profileStroke.Color = C.Accent
    profileStroke.Thickness = 1
    profileStroke.Transparency = 0.45
    profileStroke.Parent = profile
    registerTheme(profileStroke, "Accent", "Color")

    local profileAvatar = Instance.new("ImageLabel")
    profileAvatar.Size = UDim2.fromOffset(IS_MOBILE and 27 or 31, IS_MOBILE and 27 or 31)
    profileAvatar.Position = UDim2.fromOffset(4, IS_MOBILE and 3.5 or 3.5)
    profileAvatar.BackgroundColor3 = C.Surface3
    profileAvatar.BorderSizePixel = 0
    profileAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    profileAvatar.ZIndex = 13
    profileAvatar.Parent = profile
    local profileAvatarCorner = Instance.new("UICorner")
    profileAvatarCorner.CornerRadius = UDim.new(1, 0)
    profileAvatarCorner.Parent = profileAvatar
    local profileAvatarStroke = Instance.new("UIStroke")
    profileAvatarStroke.Color = C.Accent2
    profileAvatarStroke.Thickness = 1
    profileAvatarStroke.Parent = profileAvatar
    registerTheme(profileAvatarStroke, "Accent2", "Color")

    local profileName = Instance.new("TextLabel")
    profileName.Size = UDim2.new(1, -(IS_MOBILE and 60 or 68), 0, 16)
    profileName.Position = UDim2.fromOffset(IS_MOBILE and 37 or 43, 4)
    profileName.BackgroundTransparency = 1
    profileName.Text = LocalPlayer.DisplayName
    profileName.TextColor3 = C.Text
    profileName.Font = Enum.Font.GothamBold
    profileName.TextSize = IS_MOBILE and 10 or 11
    profileName.TextXAlignment = Enum.TextXAlignment.Left
    profileName.TextTruncate = Enum.TextTruncate.AtEnd
    profileName.ZIndex = 13
    profileName.Parent = profile
    registerTheme(profileName, "Text", "TextColor3")

    local profileUser = Instance.new("TextLabel")
    profileUser.Size = UDim2.new(1, -(IS_MOBILE and 60 or 68), 0, 12)
    profileUser.Position = UDim2.fromOffset(IS_MOBILE and 37 or 43, 20)
    profileUser.BackgroundTransparency = 1
    profileUser.Text = "@" .. LocalPlayer.Name
    profileUser.TextColor3 = C.Muted
    profileUser.Font = Enum.Font.GothamSemibold
    profileUser.TextSize = IS_MOBILE and 8 or 9
    profileUser.TextXAlignment = Enum.TextXAlignment.Left
    profileUser.TextTruncate = Enum.TextTruncate.AtEnd
    profileUser.ZIndex = 13
    profileUser.Parent = profile
    registerTheme(profileUser, "Muted", "TextColor3")

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(minW, IS_MOBILE and 28 or 32)
    minBtn.Position = UDim2.new(1, minLeft, 0.5, -(IS_MOBILE and 14 or 16))
    minBtn.BackgroundColor3 = C.Surface3
    minBtn.Text = "−"
    minBtn.TextColor3 = C.Text
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = IS_MOBILE and 18 or 20
    minBtn.BorderSizePixel = 0
    minBtn.ZIndex = 14
    minBtn.Parent = header
    registerTheme(minBtn, "Surface3", "BackgroundColor3")
    registerTheme(minBtn, "Text", "TextColor3")

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(closeW, IS_MOBILE and 28 or 32)
    closeBtn.Position = UDim2.new(1, closeLeft, 0.5, -(IS_MOBILE and 14 or 16))
    closeBtn.BackgroundColor3 = C.Surface3
    closeBtn.Text = "×"
    closeBtn.TextColor3 = C.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = IS_MOBILE and 20 or 22
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 14
    closeBtn.Parent = header
    registerTheme(closeBtn, "Surface3", "BackgroundColor3")
    registerTheme(closeBtn, "Text", "TextColor3")

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    -- BODY
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -20, 1, -(CFG.HEADER_H + 20))
    body.Position = UDim2.new(0, 10, 0, CFG.HEADER_H + 10)
    body.BackgroundTransparency = 1
    body.ZIndex = 2
    body.Parent = main

    local sidebarW = CFG.SIDEBAR_W
    -- SIDEBAR CONTAINER
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, sidebarW, 1, 0)
    sidebar.BackgroundColor3 = C.Surface
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 3
    sidebar.ClipsDescendants = true
    sidebar.Parent = body
    registerTheme(sidebar, "Surface", "BackgroundColor3")
    sidebar.BackgroundTransparency = 0.5

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 14)
    sidebarCorner.Parent = sidebar

    local sidebarStroke = Instance.new("UIStroke")
    sidebarStroke.Color = C.Accent
    sidebarStroke.Thickness = 1
    sidebarStroke.Transparency = 0.7
    sidebarStroke.Parent = sidebar
    registerTheme(sidebarStroke, "Accent", "Color")

    local sidebarGlow = Instance.new("Frame")
    sidebarGlow.Size = UDim2.new(1, -18, 0, 2)
    sidebarGlow.Position = UDim2.fromOffset(9, 1)
    sidebarGlow.BackgroundColor3 = C.Accent2
    sidebarGlow.BackgroundTransparency = 0.1
    sidebarGlow.BorderSizePixel = 0
    sidebarGlow.ZIndex = 5
    sidebarGlow.Parent = sidebar
    local sidebarGlowCorner = Instance.new("UICorner")
    sidebarGlowCorner.CornerRadius = UDim.new(1, 0)
    sidebarGlowCorner.Parent = sidebarGlow
    registerTheme(sidebarGlow, "Accent2", "BackgroundColor3")

    -- SCROLLING FRAME DI DALAM SIDEBAR
    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Size = UDim2.fromScale(1, 1)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel = 0
    sidebarScroll.ScrollBarThickness = 2
    sidebarScroll.ScrollBarImageColor3 = C.Accent
    sidebarScroll.ScrollBarImageTransparency = 0.5
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarScroll.ZIndex = 4
    sidebarScroll.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebarScroll

    local sidebarPad = Instance.new("UIPadding")
    sidebarPad.PaddingTop = UDim.new(0, IS_MOBILE and 6 or 10)
    sidebarPad.PaddingBottom = UDim.new(0, IS_MOBILE and 6 or 10)
    sidebarPad.PaddingLeft = UDim.new(0, 6)
    sidebarPad.PaddingRight = UDim.new(0, 6)
    sidebarPad.Parent = sidebarScroll

    local pageHolder = Instance.new("ScrollingFrame")
    pageHolder.Size = UDim2.new(1, -(sidebarW + 10), 1, 0)
    pageHolder.Position = UDim2.new(0, sidebarW + 10, 0, 0)
    pageHolder.BackgroundTransparency = 1
    pageHolder.BorderSizePixel = 0
    pageHolder.ScrollBarThickness = 4
    pageHolder.ScrollBarImageColor3 = C.Accent
    pageHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    pageHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pageHolder.ZIndex = 3
    pageHolder.Parent = body
    registerTheme(pageHolder, "Accent", "ScrollBarImageColor3")

    local pageHolderPad = Instance.new("UIPadding")
    pageHolderPad.PaddingTop = UDim.new(0, 4)
    pageHolderPad.PaddingBottom = UDim.new(0, 40)
    pageHolderPad.PaddingLeft = UDim.new(0, IS_MOBILE and 6 or 10)
    pageHolderPad.PaddingRight = UDim.new(0, IS_MOBILE and 6 or 10)
    pageHolderPad.Parent = pageHolder

        -- Resize handle (PC + Mobile)
do
        local resizeHandle = Instance.new("TextButton")
    local handleSize = IS_MOBILE and 32 or 22
    resizeHandle.Size = UDim2.fromOffset(handleSize, handleSize)
    resizeHandle.Position = UDim2.new(1, -handleSize, 1, -handleSize) -- ⭐ Mentok di pojok
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = "" -- ⭐ Hapus teksnya
    resizeHandle.TextColor3 = Color3.fromRGB(0, 0, 0) -- ⭐ Jadiin item (transparan)
    resizeHandle.TextSize = IS_MOBILE and 22 or 17
    resizeHandle.Font = Enum.Font.GothamBold
    resizeHandle.AutoButtonColor = false
    resizeHandle.Active = false
    resizeHandle.ZIndex = 100
    resizeHandle.Parent = main
    -- (registerTheme dihapus biar gak ada warna orange)

    -- Hit target lebih gede biar gampang di-tap di HP
    local hitPad = Instance.new("TextButton")
    hitPad.AnchorPoint = Vector2.new(1, 1)
    hitPad.Size = UDim2.fromOffset(handleSize + 14, handleSize + 14)
    hitPad.Position = UDim2.new(1, 0, 1, 0) -- ⭐ Mentok 100% di pojok kanan bawah
    hitPad.BackgroundTransparency = 1
    hitPad.Text = ""
    hitPad.AutoButtonColor = false
    hitPad.Active = true
    hitPad.ZIndex = 200
    hitPad.Parent = main
    
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    local resizeInput = nil

    local function isResizeInput(i)
        return i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch
    end

    hitPad.InputBegan:Connect(function(i)
        if not isResizeInput(i) then return end
        if resizing then return end  -- ⭐ FIX: jangan re-trigger

        resizing = true
        resizeStart = i.Position
        startSize = main.Size
        resizeInput = i
    end)

    -- ⭐ FIX: reset via global InputEnded, gak peduli End state
    UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
        resizing = false
        resizeInput = nil
        resizeStart = nil
        startSize = nil
    end
end)

    UserInputService.InputChanged:Connect(function(i)
    if not resizing then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    if not resizeStart or not startSize then return end

    local deltaX = i.Position.X - resizeStart.X
    local deltaY = i.Position.Y - resizeStart.Y

    local minW = IS_MOBILE and 260 or 600
    local minH = IS_MOBILE and 300 or 400
    local maxW = IS_MOBILE and (viewport.X - 8) or 1200
    local maxH = IS_MOBILE and (viewport.Y - 20) or 800

    local newX = math.clamp(startSize.X.Offset + deltaX, minW, maxW)
    local newY = math.clamp(startSize.Y.Offset + deltaY, minH, maxH)
    main.Size = UDim2.fromOffset(newX, newY)
end)
    end
        
    -- OPEN BUTTON
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.fromOffset(CFG.OPEN_BTN, CFG.OPEN_BTN)
    openBtn.Position = UDim2.fromOffset(20, 20)
    openBtn.BackgroundColor3 = C.Surface
    openBtn.Text = ""
    openBtn.TextColor3 = C.Accent
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = IS_MOBILE and 14 or 16
    openBtn.BorderSizePixel = 0
    openBtn.Visible = false
    openBtn.ZIndex = 400
    openBtn.Parent = screenGui
    registerTheme(openBtn, "Surface", "BackgroundColor3")
    registerTheme(openBtn, "Accent", "TextColor3")

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 16)
    openCorner.Parent = openBtn

    local openGradient = Instance.new("UIGradient")
    openGradient.Rotation = 135
    openGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 14)),
    })
    openGradient.Parent = openBtn

    local openStroke = Instance.new("UIStroke")
    openStroke.Color = C.Accent
    openStroke.Thickness = 2
    openStroke.Transparency = 0.3
    openStroke.Parent = openBtn

    -- MINIMIZE ICON ONLY: clearer VH + lightweight lightning effect
    local vhShadow = Instance.new("TextLabel")
    vhShadow.Name = "VH3DShadow"
    vhShadow.Size = UDim2.fromScale(1, 1)
    vhShadow.Position = UDim2.fromOffset(2, 3)
    vhShadow.BackgroundTransparency = 1
    vhShadow.Text = "VH"
    vhShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    vhShadow.TextTransparency = 0.05
    vhShadow.TextSize = IS_MOBILE and 22 or 26
    vhShadow.Font = Enum.Font.GothamBlack
    vhShadow.ZIndex = 401
    vhShadow.Parent = openBtn

    local vhDepth = Instance.new("TextLabel")
    vhDepth.Name = "VH3DDepth"
    vhDepth.Size = UDim2.fromScale(1, 1)
    vhDepth.Position = UDim2.fromOffset(1, 1)
    vhDepth.BackgroundTransparency = 1
    vhDepth.Text = "VH"
    vhDepth.TextColor3 = C.Accent
    vhDepth.TextTransparency = 0
    vhDepth.TextSize = IS_MOBILE and 22 or 26
    vhDepth.Font = Enum.Font.GothamBlack
    vhDepth.ZIndex = 402
    vhDepth.Parent = openBtn
    registerTheme(vhDepth, "Accent", "TextColor3")

    local vhFace = Instance.new("TextLabel")
    vhFace.Name = "VH3DFace"
    vhFace.Size = UDim2.fromScale(1, 1)
    vhFace.Position = UDim2.fromOffset(0, 0)
    vhFace.BackgroundTransparency = 1
    vhFace.Text = "VH"
    vhFace.TextColor3 = Color3.fromRGB(255, 255, 255)
    vhFace.TextSize = IS_MOBILE and 22 or 26
    vhFace.Font = Enum.Font.GothamBlack
    vhFace.TextStrokeColor3 = C.Accent
    vhFace.TextStrokeTransparency = 0
    vhFace.ZIndex = 403
    vhFace.Parent = openBtn
    registerTheme(vhFace, "Accent", "TextStrokeColor3")

        local lightningLoopThread = nil -- ⚡ Variabel buat nyimpen thread loop

    local function playMinimizeLightning()
        -- Matiin loop sebelumnya kalau ada
        if lightningLoopThread then
            task.cancel(lightningLoopThread)
            lightningLoopThread = nil
        end

        -- Mulai loop petir merah nyambar terus-terusan
        lightningLoopThread = task.spawn(function()
            while openBtn.Visible do
                -- 1. Efek Getar VH
                local origPos = openBtn.Position
                task.spawn(function()
                    for i = 1, 4 do
                        openBtn.Position = origPos + UDim2.fromOffset(math.random(-3, 3), math.random(-3, 3))
                        task.wait(0.03)
                    end
                    openBtn.Position = origPos
                end)

                -- 2. Efek Petir Merah
                local holder = Instance.new("Frame")
                holder.Name = "MinimizeLightning"
                holder.Size = UDim2.fromScale(1, 1)
                holder.BackgroundTransparency = 1
                holder.ClipsDescendants = true
                holder.ZIndex = 410
                holder.Parent = openBtn

                local segments = {
                    {0.46, 0.18, 18, -28},
                    {0.56, 0.39, 15, 24},
                    {0.48, 0.58, 16, -22},
                    {0.57, 0.77, 13, 26},
                }

                for _, seg in ipairs(segments) do
                    local bolt = Instance.new("Frame")
                    bolt.AnchorPoint = Vector2.new(0.5, 0.5)
                    bolt.Size = UDim2.fromOffset(2, seg[3])
                    bolt.Position = UDim2.fromScale(seg[1], seg[2])
                    bolt.Rotation = seg[4]
                    bolt.BackgroundColor3 = Color3.fromRGB(255, 30, 30) -- ⚡ MERAH
                    bolt.BorderSizePixel = 0
                    bolt.ZIndex = 411
                    bolt.Parent = holder
                    local bc = Instance.new("UICorner")
                    bc.CornerRadius = UDim.new(1, 0)
                    bc.Parent = bolt
                end

                -- 3. Kilatan Merah
                local flash = Instance.new("Frame")
                flash.Size = UDim2.fromScale(1, 1)
                flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                flash.BackgroundTransparency = 0.8
                flash.BorderSizePixel = 0
                flash.ZIndex = 410
                flash.Parent = holder
                local fc = Instance.new("UICorner")
                fc.CornerRadius = UDim.new(0, 16)
                fc.Parent = flash

                -- 4. Animasi Hilang
                TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                for _, child in ipairs(holder:GetChildren()) do
                    if child:IsA("Frame") and child ~= flash then
                        TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    end
                end
                
                -- Jeda sebelum nyambar lagi (acak biar natural)
                task.wait(math.random(3, 10) / 10) 
                if holder then holder:Destroy() end

                -- Jeda antar sambaran
                task.wait(math.random(5, 15) / 10)
            end
        end)
    end

    local openDrag, openDS, openSP = false, nil, nil
    openBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            openDrag = true
            openDS = i.Position
            openSP = openBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if openDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - openDS
            openBtn.Position = UDim2.new(openSP.X.Scale, openSP.X.Offset + d.X, openSP.Y.Scale, openSP.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            openDrag = false
        end
    end)

    openBtn.MouseButton1Click:Connect(function()
        openBtn.Visible = false
        main.Visible = true
        main.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(winW, winH)
        }):Play()
    end)

    minBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        task.delay(0.3, function()
            main.Visible = false
            openBtn.Visible = true
            playMinimizeLightning()
        end)
    end)

closeBtn.MouseButton1Click:Connect(function()
    showCloseConfirmation(screenGui, function()
        -- ── CONFIRMED: user really wants to close ──
        -- Turn off all active features so nothing keeps running
        if Shared then
            for k, v in pairs(Shared) do
                if type(k) == "string" and k:match("_Enabled$") and v == true then
                    Shared[k] = false
                end
            end
        end

        -- Stop GPU/Graphics loops
        if GFX then
            if GFX.FPSEnabled then pcall(gfx_disableFPS) end
            if GFX.HDEnabled then pcall(gfx_disableHD) end
        end

        -- Stop chat polling
        if _G.VRILZ_ChatClient then
            _G.VRILZ_ChatClient.polling = false
        end

        -- Stop presence heartbeat
        if _G.VRILZ_Presence then
            _G.VRILZ_Presence.Started = false
        end

        -- Remove title tag above character
        if Shared then Shared.ShowTitle = false end
        if _G.VRILZ_RefreshTitle then pcall(_G.VRILZ_RefreshTitle) end

        -- Shrink & destroy GUI
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        task.delay(0.35, function()
            pcall(function() screenGui:Destroy() end)
        end)
    end, function()
        -- ── CANCELED: user clicked "Go Back" ──
        notify("✓ Cancelled — script still running", "info")
    end)
end)
    -- TAB SYSTEM
    local pages = {}
    local navs = {}

        local function registerTab(id, icon, label, isAsset)
        local tabH = CFG.TAB_H
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, tabH)
        btn.BackgroundColor3 = Color3.fromRGB(255, 126, 20)
        btn.BackgroundTransparency = 0.55
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 5
        btn.Parent = sidebarScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 11)
        corner.Parent = btn

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(255, 126, 20)
        tabStroke.Thickness = 1
        tabStroke.Transparency = 0.82
        tabStroke.Parent = btn
        registerTheme(tabStroke, "Accent", "Color")

                       -- ⭐ LOGIKA BARU: Cek apakah pakai Asset ID (gambar) atau Emoji (text)
if isAsset then
    -- 1. Bikin wadah kotak di belakang icon
    local iconBox = Instance.new("Frame")
    iconBox.Name = "IconBox"
    if CFG.TAB_SHOW_LABEL then
        iconBox.Size = UDim2.fromOffset(26, 26)
        iconBox.Position = UDim2.fromOffset(8, (tabH - 26) / 2)
    else
        iconBox.Size = UDim2.fromOffset(28, 28)
        iconBox.Position = UDim2.new(0.5, -14, 0.5, -14)
    end
    iconBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Warna kotak default (gelap)
    iconBox.BackgroundTransparency = 0.2
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 5
    iconBox.Parent = btn
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = iconBox

    -- 2. Icon di dalam kotak
    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.fromScale(0.8, 0.8)
    ic.Position = UDim2.fromScale(0.1, 0.1)
    ic.BackgroundTransparency = 1
    ic.ZIndex = 6
    ic.Parent = iconBox
    ic.ScaleType = Enum.ScaleType.Fit
    ic.ImageColor3 = Color3.fromRGB(255, 255, 255)

    local rawId = tostring(icon):gsub("%D", "")
    ic.Image = "rbxassetid://" .. rawId
    if CFG.TAB_SHOW_LABEL then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -44, 1, 0)
        lbl.Position = UDim2.fromOffset(42, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.Muted
        lbl.TextSize = CFG.FONT_LABEL
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 6
        lbl.Parent = btn
        registerTheme(lbl, "Muted", "TextColor3")
        navs[id] = {btn = btn, ic = ic, lbl = lbl, isAsset = true, box = iconBox}
    else
        navs[id] = {btn = btn, ic = ic, lbl = nil, isAsset = true, box = iconBox}
    end

-- ⭐ FIX: pakai ID asli langsung (sudah ID Image, bukan Decal)
local rawId = tostring(icon):gsub("%D", "")
ic.Image = "rbxassetid://" .. rawId

            if CFG.TAB_SHOW_LABEL then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -44, 1, 0)
                lbl.Position = UDim2.fromOffset(42, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = label
                lbl.TextColor3 = C.Muted
                lbl.TextSize = CFG.FONT_LABEL
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 6
                lbl.Parent = btn
                registerTheme(lbl, "Muted", "TextColor3")
            else
            end
        else
            -- Mode lama (Emoji / Teks)
            local ic = Instance.new("TextLabel")
            if CFG.TAB_SHOW_LABEL then
                ic.Size = UDim2.fromOffset(28, tabH)
                ic.Position = UDim2.fromOffset(10, 0)
            else
                ic.Size = UDim2.fromScale(1, 1)
                ic.Position = UDim2.fromOffset(0, 0)
            end
            ic.BackgroundTransparency = 1
            ic.Text = icon
            ic.TextSize = CFG.TAB_ICON
            ic.Font = Enum.Font.GothamBold
            ic.TextColor3 = C.Accent
            ic.ZIndex = 6
            ic.Parent = btn
            registerTheme(ic, "Accent", "TextColor3")

            if CFG.TAB_SHOW_LABEL then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -44, 1, 0)
                lbl.Position = UDim2.fromOffset(42, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = label
                lbl.TextColor3 = C.Muted
                lbl.TextSize = CFG.FONT_LABEL
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 6
                lbl.Parent = btn
                registerTheme(lbl, "Muted", "TextColor3")
                navs[id] = {btn = btn, ic = ic, lbl = lbl, isAsset = false}
            else
                navs[id] = {btn = btn, ic = ic, lbl = nil, isAsset = false}
            end
        end

                local function switchTo()
    if not pages or not navs then return end

    -- Hide semua page
    for n, p in pairs(pages) do
        if p and p.Parent then p.Visible = false end
    end
    if pages[id] and pages[id].Parent then
        pages[id].Visible = true
    end

    -- Update visual semua tab
    for n, x in pairs(navs) do
        if not x or not x.btn or not x.btn.Parent then continue end

        local isActive = (n == id)

        if isActive then
            -- ⭐ STATE AKTIF (DIKLIK) → UNGU
            x.btn.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
            x.btn.BackgroundTransparency = 0.35

            if x.box then
                x.box.BackgroundColor3 = Color3.fromRGB(140, 70, 255)
                x.box.BackgroundTransparency = 0.1
            end

            if x.isAsset then
                x.ic.ImageColor3 = Color3.fromRGB(255, 255, 255)
                x.ic.ImageTransparency = 0
            else
                x.ic.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            if x.btn:FindFirstChildOfClass("UIStroke") then
                local s = x.btn:FindFirstChildOfClass("UIStroke")
                s.Color = Color3.fromRGB(140, 70, 255)
                s.Transparency = 0.15
            end
            if x.lbl then x.lbl.TextColor3 = Color3.new(1, 1, 1) end
        else
            -- ⭐ STATE TIDAK AKTIF (GAK DIKLIK) → ORANGE
            x.btn.BackgroundColor3 = Color3.fromRGB(255, 126, 20)
            x.btn.BackgroundTransparency = 0.55

            if x.box then
                x.box.BackgroundColor3 = Color3.fromRGB(255, 126, 20)
                x.box.BackgroundTransparency = 0.25
            end

            if x.isAsset then
                x.ic.ImageColor3 = Color3.fromRGB(255, 255, 255)
                x.ic.ImageTransparency = 0
            else
                x.ic.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            if x.btn:FindFirstChildOfClass("UIStroke") then
                local s = x.btn:FindFirstChildOfClass("UIStroke")
                s.Color = Color3.fromRGB(255, 126, 20)
                s.Transparency = 0.4
            end
            if x.lbl then x.lbl.TextColor3 = Color3.fromRGB(255, 240, 220) end
        end
    end
end
                btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(switchTo)
            if not ok then warn("[TAB] switchTo error: " .. tostring(err)) end
        end)

        -- ⭐ FIX: pastikan _G.VRILZ_SwitchTab BENERAN table
        if type(_G.VRILZ_SwitchTab) ~= "table" then
            _G.VRILZ_SwitchTab = {}
        end
        _G.VRILZ_SwitchTab[id] = switchTo
    end

-- ===== 2-COLUMN PAGE HELPER (support header slot) =====
local function createTwoColumnPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollingEnabled = true
    page.Visible = false
    page.ZIndex = 7
    page.Parent = pageHolder

    -- ⭐ LAYOUT UTAMA VERTIKAL
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Padding = UDim.new(0, IS_MOBILE and 8 or 12)
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Parent = page

    -- ⭐ HEADER SLOT (full-width paling atas)
    local headerSlot = Instance.new("Frame")
    headerSlot.Name = "HeaderSlot"
    headerSlot.Size = UDim2.new(1, 0, 0, 0)
    headerSlot.AutomaticSize = Enum.AutomaticSize.Y
    headerSlot.BackgroundTransparency = 1
    headerSlot.LayoutOrder = 1
    headerSlot.ZIndex = 7
    headerSlot.Parent = page

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.Padding = UDim.new(0, IS_MOBILE and 8 or 12)
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Parent = headerSlot

    -- Row 2 kolom (kiri | kanan)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.LayoutOrder = 2
    row.ZIndex = 7
    row.Parent = page

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, IS_MOBILE and 8 or 12)
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    -- Kolom kiri
    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftColumn"
    leftCol.Size = UDim2.new(0.5, -(IS_MOBILE and 4 or 6), 0, 0)
    leftCol.AutomaticSize = Enum.AutomaticSize.Y
    leftCol.BackgroundTransparency = 1
    leftCol.LayoutOrder = 1
    leftCol.ZIndex = 7
    leftCol.Parent = row

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, IS_MOBILE and 8 or 12)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftCol

    -- Kolom kanan
    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightColumn"
    rightCol.Size = UDim2.new(0.5, -(IS_MOBILE and 4 or 6), 0, 0)
    rightCol.AutomaticSize = Enum.AutomaticSize.Y
    rightCol.BackgroundTransparency = 1
    rightCol.LayoutOrder = 2
    rightCol.ZIndex = 7
    rightCol.Parent = row

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, IS_MOBILE and 8 or 12)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightCol

    -- Sync canvas height
    local function syncCanvas()
        page.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 120)
    end
    mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
    task.defer(syncCanvas)

    -- ⭐ RETURN 4 VALUE
    return page, leftCol, rightCol, headerSlot
end

-- TAB INFO (2 KOLOM)
do
    local infoPage, infoLeft, infoRight = createTwoColumnPage("Info")
    pages.Info = infoPage

    -- ═══ KOLOM KIRI ═══
    local infoCard, infoContent = makeCard(infoLeft, "CLIENT INFORMATION", 1)

    local avRow = Instance.new("Frame")
    avRow.Size = UDim2.new(1, 0, 0, IS_MOBILE and 60 or 70)
    avRow.BackgroundTransparency = 1
    avRow.LayoutOrder = 1
    avRow.Parent = infoContent

    local avSz = IS_MOBILE and 50 or 60
    local avatarGlow = Instance.new("Frame")
    avatarGlow.Size = UDim2.fromOffset(avSz + 8, avSz + 8)
    avatarGlow.Position = UDim2.fromOffset(-4, 1)
    avatarGlow.BackgroundColor3 = C.Accent
    avatarGlow.BackgroundTransparency = 0.84
    avatarGlow.BorderSizePixel = 0
    avatarGlow.ZIndex = 2
    avatarGlow.Parent = avRow
    local avatarGlowCorner = Instance.new("UICorner")
    avatarGlowCorner.CornerRadius = UDim.new(1, 0)
    avatarGlowCorner.Parent = avatarGlow
    registerTheme(avatarGlow, "Accent", "BackgroundColor3")

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.fromOffset(avSz, avSz)
    avatar.Position = UDim2.fromOffset(0, 5)
    avatar.BackgroundColor3 = C.Surface3
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    avatar.ZIndex = 3
    avatar.Parent = avRow

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatar

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = C.Accent
    avStroke.Thickness = 2.5
    avStroke.Parent = avatar
    registerTheme(avStroke, "Accent", "Color")

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -(avSz + 15), 0, 22)
    nameLbl.Position = UDim2.fromOffset(avSz + 15, IS_MOBILE and 10 or 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = LocalPlayer.DisplayName
    nameLbl.TextColor3 = C.Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = IS_MOBILE and 13 or 15
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 3
    nameLbl.Parent = avRow
    registerTheme(nameLbl, "Text", "TextColor3")

    local userLbl = Instance.new("TextLabel")
    userLbl.Size = UDim2.new(1, -(avSz + 15), 0, 16)
    userLbl.Position = UDim2.fromOffset(avSz + 15, IS_MOBILE and 30 or 34)
    userLbl.BackgroundTransparency = 1
    userLbl.Text = "@" .. LocalPlayer.Name
    userLbl.TextColor3 = C.Muted
    userLbl.Font = Enum.Font.GothamSemibold
    userLbl.TextSize = IS_MOBILE and 10 or 11
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.TextTruncate = Enum.TextTruncate.AtEnd
    userLbl.ZIndex = 3
    userLbl.Parent = avRow
    registerTheme(userLbl, "Muted", "TextColor3")

    local sessionLbl = Instance.new("TextLabel")
    sessionLbl.Size = UDim2.new(1, 0, 0, 20)
    sessionLbl.BackgroundTransparency = 1
    sessionLbl.Text = "Session: 00:00"
    sessionLbl.TextColor3 = C.Accent2
    sessionLbl.Font = Enum.Font.GothamBold
    sessionLbl.TextSize = CFG.FONT_LABEL
    sessionLbl.TextXAlignment = Enum.TextXAlignment.Left
    sessionLbl.LayoutOrder = 2
    sessionLbl.ZIndex = 3
    sessionLbl.Parent = infoContent
    registerTheme(sessionLbl, "Accent2", "TextColor3")

    local keyTypeLbl = Instance.new("TextLabel")
    keyTypeLbl.Size = UDim2.new(1, 0, 0, 20)
    keyTypeLbl.BackgroundTransparency = 1
    keyTypeLbl.Text = "Key Type: " .. tostring(Shared.KeyType or "UNKNOWN")
    keyTypeLbl.TextColor3 = C.Text
    keyTypeLbl.Font = Enum.Font.GothamBold
    keyTypeLbl.TextSize = CFG.FONT_LABEL
    keyTypeLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyTypeLbl.LayoutOrder = 3
    keyTypeLbl.ZIndex = 3
    keyTypeLbl.Parent = infoContent
    registerTheme(keyTypeLbl, "Text", "TextColor3")

    local keyExpiryLbl = Instance.new("TextLabel")
    keyExpiryLbl.Size = UDim2.new(1, 0, 0, 20)
    keyExpiryLbl.BackgroundTransparency = 1
    keyExpiryLbl.TextColor3 = C.Muted
    keyExpiryLbl.Font = Enum.Font.GothamSemibold
    keyExpiryLbl.TextSize = CFG.FONT_LABEL
    keyExpiryLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyExpiryLbl.LayoutOrder = 4
    keyExpiryLbl.ZIndex = 3
    keyExpiryLbl.Parent = infoContent
    registerTheme(keyExpiryLbl, "Muted", "TextColor3")

    local function refreshKeyInfo()
        local keyType = tostring(Shared.KeyType or "UNKNOWN"):upper()
        local expiresAt = tonumber(Shared.KeyExpiresAt or 0) or 0
        keyTypeLbl.Text = "Key Type: " .. keyType
        if expiresAt > 0 then
            local secondsLeft = math.max(0, math.floor(expiresAt / 1000 - os.time()))
            local days = math.floor(secondsLeft / 86400)
            local hours = math.floor((secondsLeft % 86400) / 3600)
            local mins = math.floor((secondsLeft % 3600) / 60)
            local expiryText = os.date("%d/%m/%Y %H:%M:%S", math.floor(expiresAt / 1000))
            keyExpiryLbl.Text = string.format("Expired: %s\nRemaining: %dd %02dj %02dm", expiryText, days, hours, mins)
            if secondsLeft <= 0 then
                keyExpiryLbl.Text = "Expired: KEY EXPIRED"
                keyExpiryLbl.TextColor3 = C.Error
            else
                keyExpiryLbl.TextColor3 = C.Muted
            end
        else
            keyExpiryLbl.Text = "Expired: -"
        end
    end
    refreshKeyInfo()

    local sessionStart = os.clock()
    task.spawn(function()
        while sessionLbl.Parent do
            task.wait(1)
            local elapsed = math.floor(os.clock() - sessionStart)
            local m = math.floor(elapsed / 60)
            local s = elapsed % 60
            sessionLbl.Text = string.format("Session: %02d:%02d", m, s)
        end
    end)

    -- ⭐ Card update info (kiri bawah)
    local updateCard, updateContent = makeCard(infoLeft, "📢 UPDATE INFORMATION", 2)

    local infoLines = {
        "Version        : 1.0",
        "Last Update    : 02 Nov 2026",
        "Status         : Online ✅",
        "Changelog      : Window, Auto Treadmile, Auto Steal",
        "                  Anti Afk, Webhook, Live Chat",
    }
    for i, line in ipairs(infoLines) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = C.Muted
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = CFG.FONT_MUTED
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.LayoutOrder = i
        lbl.ZIndex = 3
        lbl.Parent = updateContent
        registerTheme(lbl, "Muted", "TextColor3")
    end

    -- ═══ KOLOM KANAN ═══
    local explCard, explContent = makeCard(infoRight, "🎮 EXPLOIT SUPPORT", 1)

    local explLines = {
    "✅ Delta       ✅ Fluxus",
    "✅ Xeno        ✅ Codex",
    "✅ Solara      ✅ Wave",
    "✅ Madium      ✅ Real",
    "✅ Potasium    ✅ AWP",
    "✅ Hydrogen    ✅ Velocity",
    "✅ Wave        ✅ Swift",
    "✅ Trigon      ✅ Cryptic",
    "✅ Arceus      ✅ Nihon",
}
    for i, line in ipairs(explLines) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = line
        lbl.TextColor3 = C.Muted
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = CFG.FONT_MUTED
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = i
        lbl.ZIndex = 3
        lbl.Parent = explContent
        registerTheme(lbl, "Muted", "TextColor3")
    end

    -- ⭐ Discord card (kanan bawah)
    local discordCard, discordContent = makeCard(infoRight, "💬 JOIN DISCORD", 2)
    local DISCORD_LINK = "https://discord.gg/psWhrYWbq"

    local discordLinkLbl = Instance.new("TextLabel")
    discordLinkLbl.Size = UDim2.new(1, 0, 0, 18)
    discordLinkLbl.BackgroundTransparency = 1
    discordLinkLbl.Text = "discord.gg/psWhrYWbq"
    discordLinkLbl.TextColor3 = C.Accent
    discordLinkLbl.Font = Enum.Font.GothamBold
    discordLinkLbl.TextSize = CFG.FONT_LABEL
    discordLinkLbl.TextXAlignment = Enum.TextXAlignment.Center
    discordLinkLbl.LayoutOrder = 1
    discordLinkLbl.ZIndex = 3
    discordLinkLbl.Parent = discordContent
    registerTheme(discordLinkLbl, "Accent", "TextColor3")

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(1, 0, 0, 32)
    discordBtn.BackgroundColor3 = C.Accent
    discordBtn.Text = "[ CLICK TO JOIN ]"
    discordBtn.TextColor3 = Color3.new(1, 1, 1)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = CFG.FONT_LABEL
    discordBtn.AutoButtonColor = false
    discordBtn.LayoutOrder = 2
    discordBtn.ZIndex = 3
    discordBtn.Parent = discordContent
    registerTheme(discordBtn, "Accent", "BackgroundColor3")

    local discordBtnCorner = Instance.new("UICorner")
    discordBtnCorner.CornerRadius = UDim.new(0, 8)
    discordBtnCorner.Parent = discordBtn

        local discordResetThread = nil

    discordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(DISCORD_LINK) end)

        -- Ubah teks tombol jadi COPIED!
        discordBtn.Text = "[ COPIED! ]"

        -- Kalau spam klik → reset timer dulu, biar 3 detik dihitung dari klik terakhir
        if discordResetThread then
            task.cancel(discordResetThread)
            discordResetThread = nil
        end

        -- 3 detik lagi balik ke CLICK TO JOIN
        discordResetThread = task.delay(3, function()
            if discordBtn and discordBtn.Parent then
                discordBtn.Text = "[ CLICK TO JOIN ]"
            end
            discordResetThread = nil
        end)
    end)
end

-- TAB SETTINGS
do
    local setPage, setLeft, setRight, setHeader = createTwoColumnPage("Settings")
    pages.Settings = setPage
    -- ═══ ANTI-AFK CARD (kolom kiri) ═══
    local afkCard, afkContent = makeCard(setLeft, "🛡 ANTI-AFK", 1)

    local afkLbl = Instance.new("TextLabel")
    afkLbl.Size = UDim2.new(1, 0, 0, 16)
    afkLbl.BackgroundTransparency = 1
    afkLbl.Text = "Prevent kick due to idling for 20 minutes:"
    afkLbl.TextColor3 = C.Muted
    afkLbl.Font = Enum.Font.GothamSemibold
    afkLbl.TextSize = CFG.FONT_MUTED
    afkLbl.TextXAlignment = Enum.TextXAlignment.Left
    afkLbl.ZIndex = 3
    afkLbl.Parent = afkContent
    registerTheme(afkLbl, "Muted", "TextColor3")

    makeToggle(afkContent, "Enable Anti-AFK", true, function(v)
        Shared.AntiAFK_Enabled = v
        if v then notify("🛡 Anti-AFK: ON", "success")
        else notify("🛡 Anti-AFK: OFF", "info") end
    end, "AntiAFK_Enabled")

    -- ═══ THEME CARD ═══
    local themeCard, themeContent = makeCard(setLeft, "THEME", 2)

    local themeLbl = Instance.new("TextLabel")
    themeLbl.Size = UDim2.new(1, 0, 0, 16)
    themeLbl.BackgroundTransparency = 1
    themeLbl.Text = "Select Theme:"
    themeLbl.TextColor3 = C.Muted
    themeLbl.Font = Enum.Font.GothamSemibold
    themeLbl.TextSize = CFG.FONT_MUTED
    themeLbl.TextXAlignment = Enum.TextXAlignment.Left
    themeLbl.ZIndex = 3
    themeLbl.Parent = themeContent

    local themeList = {"Brutal", "Ice", "Fire", "Pink", "Green", "Blue", "Mustard", "Olive"}
    makeDropdownGlobal(themeContent, themeList, CurrentTheme, function(v)
        applyTheme(v)
        notify("Theme: " .. v, "success")
    end)

    -- ═══ TITLE CARD ═══
    local titleCard, titleContent = makeCard(setLeft, "👑 TITLE", 3)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Show title above character:"
    titleLbl.TextColor3 = C.Muted
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextSize = CFG.FONT_MUTED
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 3
    titleLbl.Parent = titleContent
    registerTheme(titleLbl, "Muted", "TextColor3")

    makeToggle(titleContent, "Show Title", true, function(v)
        Shared.ShowTitle = v
        if _G.VRILZ_RefreshTitle then _G.VRILZ_RefreshTitle() end
        if v then notify("👑 Title: ON", "success")
        else notify("👑 Title: OFF", "info") end
    end, "ShowTitle")

    local customTitleHolder = Instance.new("Frame")
    customTitleHolder.Name = "CustomTitleHolder"
    customTitleHolder.Size = UDim2.new(1, 0, 0, 0)
    customTitleHolder.AutomaticSize = Enum.AutomaticSize.Y
    customTitleHolder.BackgroundTransparency = 1
    customTitleHolder.ZIndex = 3
    customTitleHolder.Parent = titleContent

    local customTitleLayout = Instance.new("UIListLayout")
    customTitleLayout.Padding = UDim.new(0, CFG.CARD_GAP)
    customTitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    customTitleLayout.Parent = customTitleHolder

    local function rebuildCustomTitleUI()
        for _, c in ipairs(customTitleHolder:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end

        local canCustom = false
        if LocalPlayer.UserId == OWNER_USERID then
            canCustom = true
        elseif Shared and Shared.KeyType then
            local kt = tostring(Shared.KeyType):upper()
            if kt == "PREMIUM" or kt == "OWNER" or kt == "VIP" then
                canCustom = true
            end
        end

        if canCustom then
            local customLbl = Instance.new("TextLabel")
            customLbl.Size = UDim2.new(1, 0, 0, 16)
            customLbl.BackgroundTransparency = 1
            customLbl.Text = "Custom Title (auto UPPERCASE, max 15):"
            customLbl.TextColor3 = C.Accent
            customLbl.Font = Enum.Font.GothamBold
            customLbl.TextSize = CFG.FONT_MUTED
            customLbl.TextXAlignment = Enum.TextXAlignment.Left
            customLbl.LayoutOrder = 1
            customLbl.Parent = customTitleHolder

            local customBox = Instance.new("TextBox")
            customBox.Size = UDim2.new(1, 0, 0, 34)
            customBox.BackgroundColor3 = C.Surface3
            customBox.BorderSizePixel = 0
            customBox.Text = _G.VRILZ_CustomTitle or ""
            customBox.PlaceholderText = "Enter Text"
            customBox.PlaceholderColor3 = C.Muted
            customBox.TextColor3 = C.Text
            customBox.Font = Enum.Font.GothamBold
            customBox.TextSize = CFG.FONT_LABEL
            customBox.TextXAlignment = Enum.TextXAlignment.Center
            customBox.ClearTextOnFocus = false
            customBox.LayoutOrder = 2
            customBox.Parent = customTitleHolder

            local cbCorner = Instance.new("UICorner")
            cbCorner.CornerRadius = UDim.new(0, 8)
            cbCorner.Parent = customBox

            local btnRow = Instance.new("Frame")
            btnRow.Size = UDim2.new(1, 0, 0, 32)
            btnRow.BackgroundTransparency = 1
            btnRow.LayoutOrder = 3
            btnRow.Parent = customTitleHolder

            local saveBtn = Instance.new("TextButton")
            saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
            saveBtn.BackgroundColor3 = C.Success
            saveBtn.Text = "💾 SAVE"
            saveBtn.TextColor3 = Color3.new(1, 1, 1)
            saveBtn.Font = Enum.Font.GothamBold
            saveBtn.TextSize = CFG.FONT_LABEL
            saveBtn.BorderSizePixel = 0
            saveBtn.Parent = btnRow

            local clearBtn = Instance.new("TextButton")
            clearBtn.Size = UDim2.new(0.48, 0, 1, 0)
            clearBtn.Position = UDim2.new(0.52, 0, 0, 0)
            clearBtn.BackgroundColor3 = C.Error
            clearBtn.Text = "🗑 CLEAR"
            clearBtn.TextColor3 = Color3.new(1, 1, 1)
            clearBtn.Font = Enum.Font.GothamBold
            clearBtn.TextSize = CFG.FONT_LABEL
            clearBtn.BorderSizePixel = 0
            clearBtn.Parent = btnRow

            saveBtn.MouseButton1Click:Connect(function()
                local txt = customBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if txt == "" then notify("❌ Empty!", "error") return end
                txt = txt:upper():sub(1, 15):gsub("[^%w%s]", "")
                customBox.Text = txt
                _G.VRILZ_CustomTitle = txt
                saveCustomTitle(txt)
                notify("✅ Saved: " .. txt, "success")
                if _G.VRILZ_RefreshTitle then _G.VRILZ_RefreshTitle() end
            end)

            clearBtn.MouseButton1Click:Connect(function()
                customBox.Text = ""
                clearCustomTitle()
                notify("🗑 Cleared", "info")
                if _G.VRILZ_RefreshTitle then _G.VRILZ_RefreshTitle() end
            end)
        else
            local lockedFrame = Instance.new("Frame")
            lockedFrame.Size = UDim2.new(1, 0, 0, 52)
            lockedFrame.BackgroundColor3 = C.Surface3
            lockedFrame.BackgroundTransparency = 0.5
            lockedFrame.BorderSizePixel = 0
            lockedFrame.Parent = customTitleHolder

            local lc = Instance.new("UICorner")
            lc.CornerRadius = UDim.new(0, 8)
            lc.Parent = lockedFrame

            local lt = Instance.new("TextLabel")
            lt.Size = UDim2.new(1, -20, 0, 20)
            lt.Position = UDim2.fromOffset(10, 8)
            lt.BackgroundTransparency = 1
            lt.Text = "🔒 Custom Title (Premium only)"
            lt.TextColor3 = C.Muted
            lt.Font = Enum.Font.GothamBold
            lt.TextSize = CFG.FONT_LABEL
            lt.TextXAlignment = Enum.TextXAlignment.Left
            lt.Parent = lockedFrame
        end
    end

    rebuildCustomTitleUI()
    _G.VRILZ_RebuildCustomTitle = rebuildCustomTitleUI

    -- ═══ GRAPHICS CARD ═══
    local fpsCard, fpsContent = makeCard(setRight, "⚡ GRAPHICS", 4)
    local fpsWin = buildFPSWindow(screenGui)
    UI._fpsWindow = fpsWin

    local lightsLayer = buildLightsEffectLayer(main)
    lightsLayer.Visible = true

    local lightningLayer = buildLightningEffectLayer(main)
    lightningLayer.Visible = false

    makeToggle(fpsContent, "FPS Boost", false, function(v)
        Shared.FPSBoost_Enabled = v
        if v then gfx_enableFPS() else gfx_disableFPS() end
    end, "FPSBoost_Enabled")

    makeToggle(fpsContent, "4K HD Mode", false, function(v)
        Shared.HD4K_Enabled = v
        if v then gfx_enableHD() else gfx_disableHD() end
    end, "HD4K_Enabled")

    makeToggle(fpsContent, "FPS Window", false, function(v)
        if fpsWin then fpsWin.Visible = v end
    end)

    makeToggle(fpsContent, "Lights Effect", true, function(v)
        Shared.LightsEffect_Enabled = v
        if lightsLayer then
            lightsLayer.Visible = v
        end
        if v then
            notify("✨ Lights Effect: ON (meteor + stars)", "success")
        else
            notify("✨ Lights Effect: OFF", "info")
        end
    end, "LightsEffect_Enabled")

    makeToggle(fpsContent, "Lightning Effect", false, function(v)
        Shared.LightningEffect_Enabled = v
        if lightningLayer then
            lightningLayer.Visible = v
        end
        if v then
            notify("⚡ Lightning Effect: ON (red lightning)", "success")
        else
            notify("⚡ Lightning Effect: OFF", "info")
        end
    end, "LightningEffect_Enabled")
end

-- ============================================================
-- 🎯 TAB AUTO THROW — UI (1 toggle, semua setting di-lock)
-- ============================================================
do
    local throwPage = createTwoColumnPage("AutoThrow")
    pages.AutoThrow = throwPage

    local card, content = makeCard(throwPage, "🎯 AUTO THROW", 1)

    makeToggle(content, "Auto Throw", false, function(v)
        Shared.AutoThrow_Enabled = v
        Shared.AutoBestThrow_Enabled = v

        -- ⭐ Semua setting di-lock (fix, gak bisa diubah user)
        Shared.TapPoint_Percent = 93
        Shared.UnequipDelay_Seconds = 0.3
        Shared.TpDelay_Seconds = 0.5

        if v then notify("🎯 Auto Throw: ON (semua fungsi aktif)", "success")
        else notify("🎯 Auto Throw: OFF", "info") end
    end, "AutoThrow_Enabled")
end

-- ============================================================
-- 🛒 TAB SHOP — Auto Buy Best Food + Auto Upgrade Stand
-- ============================================================
do
    local shopPage, shopLeft, shopRight = createTwoColumnPage("Shop")
    pages.Shop = shopPage

    -- ═══ FOOD SHOP ═══
    local foodCard, foodContent = makeCard(shopLeft, "🛒 FOOD SHOP", 1)

    local foodInfo = Instance.new("TextLabel")
    foodInfo.Size = UDim2.new(1, 0, 0, 30)
    foodInfo.BackgroundTransparency = 1
    foodInfo.Text = "Beli makanan terbaik yang mampu, lalu equip makanan terbaik yang dimiliki."
    foodInfo.TextColor3 = C.Muted
    foodInfo.Font = Enum.Font.GothamSemibold
    foodInfo.TextSize = CFG.FONT_MUTED
    foodInfo.TextWrapped = true
    foodInfo.TextXAlignment = Enum.TextXAlignment.Left
    foodInfo.LayoutOrder = 1
    foodInfo.ZIndex = 3
    foodInfo.Parent = foodContent
    registerTheme(foodInfo, "Muted", "TextColor3")

    makeToggle(foodContent, "Auto Buy Best Food", false, function(v)
        Shared.AutoBuy_Enabled = v
        if v then notify("🛒 Auto Buy Best Food: ON", "success")
        else notify("🛒 Auto Buy Best Food: OFF", "info") end
    end, "AutoBuy_Enabled")

    -- ═══ PULL-UP STAND ═══
    local standCard, standContent = makeCard(shopRight, "🏋 PULL-UP STAND", 1)

    local standInfo = Instance.new("TextLabel")
    standInfo.Size = UDim2.new(1, 0, 0, 30)
    standInfo.BackgroundTransparency = 1
    standInfo.Text = "Upgrade pull-up stand otomatis kalau uangnya cukup."
    standInfo.TextColor3 = C.Muted
    standInfo.Font = Enum.Font.GothamSemibold
    standInfo.TextSize = CFG.FONT_MUTED
    standInfo.TextWrapped = true
    standInfo.TextXAlignment = Enum.TextXAlignment.Left
    standInfo.LayoutOrder = 1
    standInfo.ZIndex = 3
    standInfo.Parent = standContent
    registerTheme(standInfo, "Muted", "TextColor3")

    makeToggle(standContent, "Auto Upgrade Stand", false, function(v)
        Shared.AutoUpgradeStand_Enabled = v
        if v then notify("🏋 Auto Upgrade Stand: ON", "success")
        else notify("🏋 Auto Upgrade Stand: OFF", "info") end
    end, "AutoUpgradeStand_Enabled")
end
        -- ============================================================
        -- 💬 LIVE CHAT TAB — PREMIUM CLEAN v3
        -- Gradient halus · Glow subtle · Simetris · Elegan
        -- ============================================================
        do
            local liveChatPage = Instance.new("Frame")
            liveChatPage.Name = "LiveChat"
            liveChatPage.Size = UDim2.fromScale(1, 1)
            liveChatPage.BackgroundTransparency = 1
            liveChatPage.BorderSizePixel = 0
            liveChatPage.Visible = false
            liveChatPage.ZIndex = 7
            liveChatPage.Parent = pageHolder
            pages.LiveChat = liveChatPage

            local chatShown = false
            local msgCounter = 0
            local OWNER_IDS = { [5126297278] = true }

            -- Warna premium (soft cyan-purple, bukan orange)
            local PC_ACCENT      = Color3.fromRGB(120, 180, 255)   -- soft blue
            local PC_ACCENT2     = Color3.fromRGB(180, 140, 255)   -- soft purple
            local PC_ACCENT_GLOW = Color3.fromRGB(140, 200, 255)
            local PC_BG_TOP      = Color3.fromRGB(22, 26, 38)
            local PC_BG_BOT      = Color3.fromRGB(12, 14, 22)
            local PC_ROW_TOP     = Color3.fromRGB(28, 32, 46)
            local PC_ROW_BOT     = Color3.fromRGB(18, 22, 32)
            local PC_BORDER      = Color3.fromRGB(70, 90, 130)

            
            -- ═══════════════════════════════════════════════════════════
            -- CONTENT
            -- ═══════════════════════════════════════════════════════════

            local content = Instance.new("Frame")
            content.Size = UDim2.fromScale(1, 1)
            content.Position = UDim2.new(0, 0, 0, 0)
            content.BackgroundTransparency = 1
            content.ZIndex = 2
            content.Parent = liveChatPage

            -- ═══════════════════════════════════════════════════════════
            -- STATE 1: HERO "TAP TO OPEN" — PREMIUM CARD
            -- ═══════════════════════════════════════════════════════════
            local showFrame = Instance.new("Frame")
            showFrame.Name = "ShowFrame"
            showFrame.Size = UDim2.new(1, 0, 0, 96)
            showFrame.Position = UDim2.new(0, 0, 0, 0)
            showFrame.BackgroundTransparency = 1
            showFrame.ZIndex = 3
            showFrame.Parent = content

local heroCard = Instance.new("TextButton")
heroCard.Name = "ChatHeroCard"
heroCard.Size = UDim2.new(1, 0, 1, 0)
heroCard.BackgroundTransparency = 1
heroCard.BorderSizePixel = 0
heroCard.Text = ""
heroCard.AutoButtonColor = false
heroCard.ClipsDescendants = true
heroCard.ZIndex = 4
heroCard.Parent = showFrame

            local heroCorner = Instance.new("UICorner")
            heroCorner.CornerRadius = UDim.new(0, 14)
            heroCorner.Parent = heroCard

            -- Gradient 2 arah: soft cyan-purple
            local heroGrad = Instance.new("UIGradient")
            heroGrad.Rotation = 115
            heroGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 34, 52)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 26, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 18, 28)),
            })
            heroGrad.Parent = heroCard

            -- Border tipis elegan
            local heroStroke = Instance.new("UIStroke")
            heroStroke.Color = PC_ACCENT
            heroStroke.Thickness = 1
            heroStroke.Transparency = 0.55
            heroStroke.Parent = heroCard

            -- Shine sweep tipis (premium feel, gak norak)
            local heroShine = Instance.new("Frame")
            heroShine.Size = UDim2.new(0, 100, 2, 0)
            heroShine.Position = UDim2.new(-0.5, 0, -0.5, 0)
            heroShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            heroShine.BackgroundTransparency = 0.94
            heroShine.BorderSizePixel = 0
            heroShine.Rotation = 25
            heroShine.ZIndex = 5
            heroShine.Parent = heroCard

            task.spawn(function()
                while heroShine.Parent do
                    task.wait(3.5)
                    if not heroShine.Parent then break end
                    heroShine.Position = UDim2.new(-0.5, 0, -0.5, 0)
                    TweenService:Create(heroShine, TweenInfo.new(1.3, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(1.5, 0, 1.5, 0),
                    }):Play()
                    task.wait(1.4)
                end
            end)

            -- Icon dengan soft glow
            local iconSize = 44
            local iconHolder = Instance.new("Frame")
            iconHolder.Size = UDim2.fromOffset(iconSize, iconSize)
            iconHolder.Position = UDim2.new(0, 18, 0.5, 0)
            iconHolder.AnchorPoint = Vector2.new(0, 0.5)
            iconHolder.BackgroundColor3 = PC_ACCENT
            iconHolder.BorderSizePixel = 0
            iconHolder.ZIndex = 6
            iconHolder.Parent = heroCard

            local ihCorner = Instance.new("UICorner")
            ihCorner.CornerRadius = UDim.new(0, 12)
            ihCorner.Parent = iconHolder

            local ihGrad = Instance.new("UIGradient")
            ihGrad.Rotation = 135
            ihGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, PC_ACCENT_GLOW),
                ColorSequenceKeypoint.new(1, PC_ACCENT2),
            })
            ihGrad.Parent = iconHolder

            -- Soft glow di belakang icon
            local iconGlow = Instance.new("Frame")
            iconGlow.Size = UDim2.new(1, 12, 1, 12)
            iconGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
            iconGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            iconGlow.BackgroundColor3 = PC_ACCENT
            iconGlow.BackgroundTransparency = 0.75
            iconGlow.BorderSizePixel = 0
            iconGlow.ZIndex = 5
            iconGlow.Parent = iconHolder

            local igCorner = Instance.new("UICorner")
            igCorner.CornerRadius = UDim.new(0, 12)
            igCorner.Parent = iconGlow

            task.spawn(function()
                while iconGlow.Parent do
                    TweenService:Create(iconGlow, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
                        BackgroundTransparency = 0.9,
                    }):Play()
                    task.wait(1.6)
                    if not iconGlow.Parent then break end
                    TweenService:Create(iconGlow, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
                        BackgroundTransparency = 0.75,
                    }):Play()
                    task.wait(1.6)
                end
            end)

            local chatEmoji = Instance.new("TextLabel")
            chatEmoji.Size = UDim2.fromScale(1, 1)
            chatEmoji.BackgroundTransparency = 1
            chatEmoji.Text = "💬"
            chatEmoji.TextSize = 20
            chatEmoji.Font = Enum.Font.GothamBold
            chatEmoji.ZIndex = 7
            chatEmoji.Parent = iconHolder

            -- Title + subtitle (center vertikal, simetris)
            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, -(iconSize + 18 + 30), 0, 20)
            titleLbl.Position = UDim2.new(0, iconSize + 18 + 14, 0.5, -20)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = "LIVE CHAT"
            titleLbl.TextColor3 = Color3.fromRGB(240, 245, 255)
            titleLbl.Font = Enum.Font.GothamBlack
            titleLbl.TextSize = 14
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.TextYAlignment = Enum.TextYAlignment.Center
            titleLbl.ZIndex = 6
            titleLbl.Parent = heroCard

            local subLbl = Instance.new("TextLabel")
            subLbl.Size = UDim2.new(1, -(iconSize + 18 + 30), 0, 16)
            subLbl.Position = UDim2.new(0, iconSize + 18 + 14, 0.5, 0)
            subLbl.BackgroundTransparency = 1
            subLbl.Text = "Tap to open"
            subLbl.TextColor3 = Color3.fromRGB(150, 170, 200)
            subLbl.Font = Enum.Font.GothamSemibold
            subLbl.TextSize = 11
            subLbl.TextXAlignment = Enum.TextXAlignment.Left
            subLbl.TextYAlignment = Enum.TextYAlignment.Center
            subLbl.TextTruncate = Enum.TextTruncate.AtEnd
            subLbl.ZIndex = 6
            subLbl.Parent = heroCard

            -- Chevron kanan (subtle, simetris)
            local chevron = Instance.new("TextLabel")
            chevron.Size = UDim2.fromOffset(24, 24)
            chevron.Position = UDim2.new(1, -30, 0.5, -12)
            chevron.BackgroundTransparency = 1
            chevron.Text = "›"
            chevron.TextColor3 = PC_ACCENT
            chevron.TextTransparency = 0.3
            chevron.Font = Enum.Font.GothamBlack
            chevron.TextSize = 22
            chevron.ZIndex = 6
            chevron.Parent = heroCard

            -- Hover: border lebih terang
            heroCard.MouseLeave:Connect(function()
                TweenService:Create(heroStroke, TweenInfo.new(0.2), {
                    Transparency = 0.55,
                }):Play()
                TweenService:Create(chevron, TweenInfo.new(0.2), {
                    TextTransparency = 0.3,
                    Position = UDim2.new(1, -30, 0.5, -12),
                }):Play()
            end)

            -- ═══════════════════════════════════════════════════════════
            -- STATE 2: CHAT FRAME
            -- ═══════════════════════════════════════════════════════════
            local chatFrame = Instance.new("Frame")
            chatFrame.Name = "ChatFrame"
            chatFrame.Size = UDim2.fromScale(1, 1)
            chatFrame.BackgroundTransparency = 1
            chatFrame.Visible = false
            chatFrame.ZIndex = 3
            chatFrame.Parent = content

            -- Chat Header
            local chatHeader = Instance.new("Frame")
            chatHeader.Size = UDim2.new(1, 0, 0, 30)
            chatHeader.Position = UDim2.new(0, 0, 0, 0)
            chatHeader.BackgroundColor3 = PC_BG_TOP
            chatHeader.BorderSizePixel = 0
            chatHeader.ZIndex = 4
            chatHeader.Parent = chatFrame

            local chCorner = Instance.new("UICorner")
            chCorner.CornerRadius = UDim.new(0, 8)
            chCorner.Parent = chatHeader

            local chGrad = Instance.new("UIGradient")
            chGrad.Rotation = 90
            chGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, PC_BG_TOP),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 22, 32)),
            })
            chGrad.Parent = chatHeader

            local chDot = Instance.new("Frame")
            chDot.Size = UDim2.fromOffset(7, 7)
            chDot.Position = UDim2.new(0, 12, 0.5, -3.5)
            chDot.BackgroundColor3 = PC_ACCENT
            chDot.BorderSizePixel = 0
            chDot.ZIndex = 5
            chDot.Parent = chatHeader

            local chDotCorner = Instance.new("UICorner")
            chDotCorner.CornerRadius = UDim.new(1, 0)
            chDotCorner.Parent = chDot

            task.spawn(function()
                while chDot.Parent do
                    TweenService:Create(chDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
                        BackgroundTransparency = 0.55,
                    }):Play()
                    task.wait(0.9)
                    if not chDot.Parent then break end
                    TweenService:Create(chDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
                        BackgroundTransparency = 0,
                    }):Play()
                    task.wait(0.9)
                end
            end)

            local chTitle = Instance.new("TextLabel")
            chTitle.Size = UDim2.new(1, -80, 1, 0)
            chTitle.Position = UDim2.fromOffset(26, 0)
            chTitle.BackgroundTransparency = 1
            chTitle.Text = "LIVE CHAT · GLOBAL"
            chTitle.TextColor3 = Color3.fromRGB(230, 240, 255)
            chTitle.Font = Enum.Font.GothamBold
            chTitle.TextSize = 11
            chTitle.TextXAlignment = Enum.TextXAlignment.Left
            chTitle.TextYAlignment = Enum.TextYAlignment.Center
            chTitle.ZIndex = 5
            chTitle.Parent = chatHeader

            local chHide = Instance.new("TextButton")
            chHide.Size = UDim2.fromOffset(58, 20)
            chHide.Position = UDim2.new(1, -66, 0.5, -10)
            chHide.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
            chHide.Text = "▼ HIDE"
            chHide.TextColor3 = Color3.fromRGB(150, 170, 200)
            chHide.Font = Enum.Font.GothamBold
            chHide.TextSize = 9
            chHide.BorderSizePixel = 0
            chHide.AutoButtonColor = false
            chHide.ZIndex = 5
            chHide.Parent = chatHeader

            local chHideCorner = Instance.new("UICorner")
            chHideCorner.CornerRadius = UDim.new(0, 5)
            chHideCorner.Parent = chHide

            -- ⭐ ONLINE player count — real-time, text kecil, tepat di kiri HIDE
            local playerOnlineLbl = Instance.new("TextLabel")
            playerOnlineLbl.Name = "PlayerOnlineLbl"
            playerOnlineLbl.AnchorPoint = Vector2.new(1, 0.5)
            playerOnlineLbl.Position = UDim2.new(1, -66 - 6, 0.5, 0)  -- 6px gap dari HIDE
            playerOnlineLbl.Size = UDim2.fromOffset(64, 16)
            playerOnlineLbl.BackgroundTransparency = 1
            playerOnlineLbl.Text = #Players:GetPlayers() .. " online"
            playerOnlineLbl.TextColor3 = Color3.fromRGB(150, 170, 200)
            playerOnlineLbl.Font = Enum.Font.GothamBold
            playerOnlineLbl.TextSize = 9
            playerOnlineLbl.TextXAlignment = Enum.TextXAlignment.Right
            playerOnlineLbl.TextYAlignment = Enum.TextYAlignment.Center
            playerOnlineLbl.ZIndex = 5
            playerOnlineLbl.Parent = chatHeader

            -- ⭐ Real-time update: join/leave + polling cadangan (ASLI, tanpa fake)
            local function updateOnlineCount()
                if playerOnlineLbl and playerOnlineLbl.Parent then
                    playerOnlineLbl.Text = #Players:GetPlayers() .. " online"
                end
            end
            Players.PlayerAdded:Connect(updateOnlineCount)
            Players.PlayerRemoving:Connect(function()
                task.defer(updateOnlineCount)
            end)
            task.spawn(function()
                while playerOnlineLbl and playerOnlineLbl.Parent do
                    task.wait(0.5)
                    updateOnlineCount()
                end
            end)

            chHide.MouseEnter:Connect(function()
                TweenService:Create(chHide, TweenInfo.new(0.15), {
                    BackgroundColor3 = PC_ACCENT,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                }):Play()
            end)
            chHide.MouseLeave:Connect(function()
                TweenService:Create(chHide, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 36, 50),
                    TextColor3 = Color3.fromRGB(150, 170, 200),
                }):Play()
            end)

            -- List Pesan
            local listFrame = Instance.new("ScrollingFrame")
            listFrame.Name = "ChatList"
            listFrame.Size = UDim2.new(1, 0, 1, -(30 + 40 + 12))
            listFrame.Position = UDim2.new(0, 0, 0, 30 + 6)
            listFrame.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
            listFrame.BackgroundTransparency = 0.25
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 3
            listFrame.ScrollBarImageColor3 = PC_ACCENT
            listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            listFrame.ScrollingEnabled = true
            listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            listFrame.ElasticBehavior = Enum.ElasticBehavior.Never
            listFrame.ZIndex = 4
            listFrame.Parent = chatFrame

            local lc = Instance.new("UICorner")
            lc.CornerRadius = UDim.new(0, 10)
            lc.Parent = listFrame

            local ls = Instance.new("UIStroke")
            ls.Color = PC_BORDER
            ls.Thickness = 1
            ls.Transparency = 0.65
            ls.Parent = listFrame

            local lp = Instance.new("UIPadding")
            lp.PaddingTop = UDim.new(0, 8)
            lp.PaddingBottom = UDim.new(0, 8)
            lp.PaddingLeft = UDim.new(0, 8)
            lp.PaddingRight = UDim.new(0, 8)
            lp.Parent = listFrame

            local ll = Instance.new("UIListLayout")
            ll.Padding = UDim.new(0, 7)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            ll.Parent = listFrame

            local emptyLbl = Instance.new("TextLabel")
            emptyLbl.Size = UDim2.new(1, 0, 0, 40)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = "Belum ada pesan... sapa dulu! 👋"
            emptyLbl.TextColor3 = Color3.fromRGB(130, 150, 180)
            emptyLbl.Font = Enum.Font.GothamSemibold
            emptyLbl.TextSize = 10
            emptyLbl.ZIndex = 5
            emptyLbl.Parent = listFrame

            -- Input
            local inputBg = Instance.new("Frame")
            inputBg.Size = UDim2.new(1, 0, 0, 40)
            inputBg.Position = UDim2.new(0, 0, 1, -40)
            inputBg.BackgroundColor3 = PC_BG_TOP
            inputBg.BorderSizePixel = 0
            inputBg.ZIndex = 4
            inputBg.Parent = chatFrame

            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(0, 10)
            ic.Parent = inputBg

            local igrad = Instance.new("UIGradient")
            igrad.Rotation = 90
            igrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 30, 46)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 22, 32)),
            })
            igrad.Parent = inputBg

            local is_ = Instance.new("UIStroke")
            is_.Color = PC_BORDER
            is_.Thickness = 1
            is_.Transparency = 0.5
            is_.Parent = inputBg

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -72, 1, 0)
            box.Position = UDim2.fromOffset(12, 0)
            box.BackgroundTransparency = 1
            box.Text = ""
            box.PlaceholderText = "Tulis pesan..."
            box.PlaceholderColor3 = Color3.fromRGB(120, 140, 170)
            box.TextColor3 = Color3.fromRGB(230, 240, 255)
            box.Font = Enum.Font.GothamSemibold
            box.TextSize = 11
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.ZIndex = 5
            box.Parent = inputBg

            local sendBtn = Instance.new("TextButton")
            sendBtn.Size = UDim2.fromOffset(56, 28)
            sendBtn.Position = UDim2.new(1, -62, 0.5, -14)
            sendBtn.BackgroundColor3 = PC_ACCENT
            sendBtn.Text = IS_MOBILE and "▶" or "SEND"
            sendBtn.TextColor3 = Color3.fromRGB(20, 26, 40)
            sendBtn.Font = Enum.Font.GothamBold
            sendBtn.TextSize = IS_MOBILE and 12 or 10
            sendBtn.AutoButtonColor = false
            sendBtn.BorderSizePixel = 0
            sendBtn.ZIndex = 5
            sendBtn.Parent = inputBg

            -- ⭐ COOLDOWN 10 DETIK + TIMER HITUNG MUNDUR
            local CHAT_COOLDOWN = 10
            local cooldownUntil = 0
            local cooldownRunning = false

            -- Timer label — tepat di kiri tombol SEND, selaras, gak rebutan
            local cooldownLbl = Instance.new("TextLabel")
            cooldownLbl.Name = "CooldownTimer"
            cooldownLbl.AnchorPoint = Vector2.new(1, 0.5)
            cooldownLbl.Position = UDim2.new(1, -62 - 6, 0.5, 0)  -- 62 = lebar SEND, gap 6px
            cooldownLbl.Size = UDim2.fromOffset(44, 20)
            cooldownLbl.BackgroundTransparency = 1
            cooldownLbl.Text = ""
            cooldownLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            cooldownLbl.Font = Enum.Font.GothamBold
            cooldownLbl.TextSize = IS_MOBILE and 11 or 10
            cooldownLbl.TextXAlignment = Enum.TextXAlignment.Right
            cooldownLbl.TextYAlignment = Enum.TextYAlignment.Center
            cooldownLbl.Visible = false
            cooldownLbl.ZIndex = 6
            cooldownLbl.Parent = inputBg

            -- Geser box biar gak ketiban timer
            box.Size = UDim2.new(1, -(72 + 50), 1, 0)  -- 72 = SEND + gap, 50 = timer + gap

            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(0, 7)
            sc.Parent = sendBtn

            local scGrad = Instance.new("UIGradient")
            scGrad.Rotation = 90
            scGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, PC_ACCENT_GLOW),
                ColorSequenceKeypoint.new(1, PC_ACCENT),
            })
            scGrad.Parent = sendBtn

            sendBtn.MouseEnter:Connect(function()
                TweenService:Create(sendBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = PC_ACCENT_GLOW,
                }):Play()
            end)
            sendBtn.MouseLeave:Connect(function()
                TweenService:Create(sendBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = PC_ACCENT,
                }):Play()
            end)

            -- ═══════════════════════════════════════════════════════════
            -- RENDER MESSAGE — Bubble tipis gradient, avatar ring tipis
            -- ═══════════════════════════════════════════════════════════
            local function scrollBottom()
                task.defer(function()
                    listFrame.CanvasPosition = Vector2.new(0, listFrame.AbsoluteCanvasSize.Y)
                end)
            end

local function renderMessage(msg)
                if emptyLbl.Parent then emptyLbl:Destroy() end

                local isMe = (msg.userId == LocalPlayer.UserId)
                local isOwner = (OWNER_IDS[msg.userId] == true)

                local avatarSize = IS_MOBILE and 24 or 28

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundTransparency = 1
                row.BorderSizePixel = 0
                msgCounter = msgCounter + 1
                row.LayoutOrder = msgCounter
                row.ZIndex = 5
                row.Parent = listFrame

                local rowLayout = Instance.new("UIListLayout")
                rowLayout.FillDirection = Enum.FillDirection.Horizontal
                rowLayout.VerticalAlignment = Enum.VerticalAlignment.Top
                rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                rowLayout.Padding = UDim.new(0, 8)
                rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
                rowLayout.Parent = row

                -- Avatar dengan ring tipis
                local avContainer = Instance.new("Frame")
                avContainer.Size = UDim2.fromOffset(avatarSize, avatarSize)
                avContainer.BackgroundColor3 = PC_BG_TOP
                avContainer.BorderSizePixel = 0
                avContainer.ZIndex = 6
                avContainer.LayoutOrder = 1
                avContainer.Parent = row

                local avCorner = Instance.new("UICorner")
                avCorner.CornerRadius = UDim.new(1, 0)
                avCorner.Parent = avContainer

                local avImg = Instance.new("ImageLabel")
                avImg.Size = UDim2.fromScale(1, 1)
                avImg.BackgroundTransparency = 1
                avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(msg.userId) .. "&w=100&h=100"
                avImg.ZIndex = 7
                avImg.Parent = avContainer

                local avImgCorner = Instance.new("UICorner")
                avImgCorner.CornerRadius = UDim.new(1, 0)
                avImgCorner.Parent = avImg

                local avStroke = Instance.new("UIStroke")
                avStroke.Thickness = 1.2
                avStroke.Transparency = 0.3
                avStroke.Parent = avContainer
                if isOwner then
                    avStroke.Color = Color3.fromRGB(255, 200, 80)
                elseif isMe then
                    avStroke.Color = PC_ACCENT2
                else
                    avStroke.Color = PC_ACCENT
                end

                -- Bubble tipis
                local bubble = Instance.new("Frame")
                bubble.Name = "Bubble"
                bubble.Size = UDim2.new(1, -(avatarSize + 8), 0, 0)
                bubble.AutomaticSize = Enum.AutomaticSize.Y
                bubble.BackgroundColor3 = isOwner
                    and Color3.fromRGB(40, 34, 20)
                    or (isMe and Color3.fromRGB(30, 40, 60) or PC_ROW_TOP)
                bubble.BackgroundTransparency = 0.15
                bubble.BorderSizePixel = 0
                bubble.ZIndex = 6
                bubble.LayoutOrder = 2
                bubble.Parent = row

                local bubbleCorner = Instance.new("UICorner")
                bubbleCorner.CornerRadius = UDim.new(0, 10)
                bubbleCorner.Parent = bubble

                local bubbleGrad = Instance.new("UIGradient")
                bubbleGrad.Rotation = 90
                if isOwner then
                    bubbleGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 40, 24)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 24, 14)),
                    })
                elseif isMe then
                    bubbleGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 44, 68)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 28, 44)),
                    })
                else
                    bubbleGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, PC_ROW_TOP),
                        ColorSequenceKeypoint.new(1, PC_ROW_BOT),
                    })
                end
                bubbleGrad.Parent = bubble

                local bubbleStroke = Instance.new("UIStroke")
                bubbleStroke.Thickness = 1
                bubbleStroke.Transparency = 0.6
                if isOwner then
                    bubbleStroke.Color = Color3.fromRGB(255, 200, 80)
                elseif isMe then
                    bubbleStroke.Color = PC_ACCENT2
                else
                    bubbleStroke.Color = PC_BORDER
                end
                bubbleStroke.Parent = bubble

                local bp = Instance.new("UIPadding")
                bp.PaddingTop = UDim.new(0, 6)
                bp.PaddingBottom = UDim.new(0, 6)
                bp.PaddingLeft = UDim.new(0, 10)
                bp.PaddingRight = UDim.new(0, 10)
                bp.Parent = bubble

                local bl = Instance.new("UIListLayout")
                bl.Padding = UDim.new(0, 2)
                bl.SortOrder = Enum.SortOrder.LayoutOrder
                bl.Parent = bubble

                                -- Name + time (pakai UIListLayout biar owner tag nempel ke nama)
                local nameRow = Instance.new("Frame")
                nameRow.Size = UDim2.new(1, 0, 0, 16)
                nameRow.BackgroundTransparency = 1
                nameRow.LayoutOrder = 1
                nameRow.ZIndex = 7
                nameRow.Parent = bubble

                local nameRowLayout = Instance.new("UIListLayout")
                nameRowLayout.FillDirection = Enum.FillDirection.Horizontal
                nameRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                nameRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                nameRowLayout.Padding = UDim.new(0, 6)
                nameRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
                nameRowLayout.Parent = nameRow

                -- Nama
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0, 0, 1, 0)
                nameLbl.AutomaticSize = Enum.AutomaticSize.X
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = (isMe and "You" or msg.displayName)
                nameLbl.TextColor3 = isOwner
                    and Color3.fromRGB(255, 210, 100)
                    or (isMe and PC_ACCENT2 or PC_ACCENT)
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = IS_MOBILE and 10 or 11
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextYAlignment = Enum.TextYAlignment.Center
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.LayoutOrder = 1
                nameLbl.ZIndex = 8
                nameLbl.Parent = nameRow

                -- Owner tag — NEMPEL PAS DI SAMPING NAMA
                if isOwner then
                    local ownerTag = Instance.new("TextLabel")
                    ownerTag.Size = UDim2.new(0, 0, 0, 14)
                    ownerTag.AutomaticSize = Enum.AutomaticSize.X
                    ownerTag.BackgroundTransparency = 1
                    ownerTag.Text = "👑 OWNER"
                    ownerTag.TextColor3 = Color3.fromRGB(255, 200, 80)
                    ownerTag.Font = Enum.Font.GothamBold
                    ownerTag.TextSize = IS_MOBILE and 8 or 9
                    ownerTag.TextXAlignment = Enum.TextXAlignment.Left
                    ownerTag.TextYAlignment = Enum.TextYAlignment.Center
                    ownerTag.LayoutOrder = 2
                    ownerTag.ZIndex = 8
                    ownerTag.Parent = nameRow
                end

-- 🏷 Badge game (MT SOREYA / RAP / TFF)
local msgTag = (msg.scriptTag and msg.scriptTag ~= "") and msg.scriptTag or nil
                if msgTag then
                    local tagLbl = Instance.new("TextLabel")
                    tagLbl.Size = UDim2.new(0, 0, 0, 14)
                    tagLbl.AutomaticSize = Enum.AutomaticSize.X
                    tagLbl.BackgroundTransparency = 1
                    tagLbl.Text = "[" .. msgTag .. "]"
                    tagLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
                    tagLbl.Font = Enum.Font.GothamBold
                    tagLbl.TextSize = IS_MOBILE and 8 or 9
                    tagLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tagLbl.TextYAlignment = Enum.TextYAlignment.Center
                    tagLbl.LayoutOrder = 3
                    tagLbl.ZIndex = 8
                    tagLbl.Parent = nameRow
                end

                -- Time (dorong ke kanan pakai spacer)
                local timeSpacer = Instance.new("Frame")
                timeSpacer.Size = UDim2.new(1, 0, 1, 0)
                timeSpacer.BackgroundTransparency = 1
                timeSpacer.LayoutOrder = 4
                timeSpacer.ZIndex = 7
                timeSpacer.Parent = nameRow

                local timeLbl = Instance.new("TextLabel")
                timeLbl.Size = UDim2.new(0, 0, 1, 0)
                timeLbl.AutomaticSize = Enum.AutomaticSize.X
                timeLbl.BackgroundTransparency = 1
                timeLbl.Text = msg.time
                timeLbl.TextColor3 = Color3.fromRGB(140, 160, 190)
                timeLbl.Font = Enum.Font.GothamSemibold
                timeLbl.TextSize = IS_MOBILE and 8 or 9
                timeLbl.TextXAlignment = Enum.TextXAlignment.Right
                timeLbl.TextYAlignment = Enum.TextYAlignment.Center
                timeLbl.LayoutOrder = 5
                timeLbl.ZIndex = 8
                timeLbl.Parent = nameRow

                -- Body
                local bodyLbl = Instance.new("TextLabel")
                bodyLbl.Size = UDim2.new(1, 0, 0, 0)
                bodyLbl.AutomaticSize = Enum.AutomaticSize.Y
                bodyLbl.BackgroundTransparency = 1
                bodyLbl.Text = msg.text
                bodyLbl.TextColor3 = Color3.fromRGB(230, 240, 255)
                bodyLbl.Font = Enum.Font.GothamSemibold
                bodyLbl.TextSize = IS_MOBILE and 10 or 11
                bodyLbl.TextWrapped = true
                bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
                bodyLbl.TextYAlignment = Enum.TextYAlignment.Top
                bodyLbl.LayoutOrder = 2
                bodyLbl.ZIndex = 7
                bodyLbl.Parent = bubble

                scrollBottom()
            end

            -- Hydrate
            for _, m in ipairs(Shared.LiveChat_Messages) do
                renderMessage(m)
            end

            ChatClient.onMessage(function(msg)
                if chatShown then
                    renderMessage(msg)
                end
            end)

            -- Send
                        local function doSend()
                local now = os.clock()
                if now < cooldownUntil then
                    local left = math.ceil(cooldownUntil - now)
                    notify("⏳ Tunggu " .. left .. " detik lagi", "warning")
                    return
                end

                local text = box.Text
                if text == "" then return end

                sendBtn.Text = "..."
                sendBtn.Active = false

                task.spawn(function()
                    local ok, err = ChatClient.send(text)
                    if ok then
                        box.Text = ""

                        -- Mulai cooldown 10 detik
                        cooldownUntil = os.clock() + CHAT_COOLDOWN
                        cooldownRunning = true
                        cooldownLbl.Visible = true

                        -- Timer hitung mundur
                        task.spawn(function()
                            while cooldownRunning do
                                local left = math.ceil(cooldownUntil - os.clock())
                                if left <= 0 then
                                    cooldownLbl.Visible = false
                                    cooldownLbl.Text = ""
                                    cooldownRunning = false
                                    sendBtn.Active = true
                                    break
                                end
                                cooldownLbl.Text = tostring(left) .. "s"
                                task.wait(0.2)
                            end
                        end)
                    else
                        notify("Chat: " .. tostring(err), "error")
                        sendBtn.Active = true
                    end
                    sendBtn.Text = IS_MOBILE and "▶" or "SEND"
                end)
            end

            sendBtn.MouseButton1Click:Connect(doSend)
            box.FocusLost:Connect(function(enter)
                if enter then doSend() end
            end)

            -- ═══════════════════════════════════════════════════════════
            -- OPEN / CLOSE
            -- ═══════════════════════════════════════════════════════════
            local function openChat()
                if chatShown then return end
                chatShown = true
                showFrame.Visible = false
                chatFrame.Visible = true
                pcall(function()
                    if ChatClient and ChatClient.start then ChatClient.start() end
                end)
                task.defer(scrollBottom)
            end

            local function closeChat()
                if not chatShown then return end
                chatShown = false
                chatFrame.Visible = false
                showFrame.Visible = true
                notify("💬 Live Chat ditutup", "info")
            end

            heroCard.MouseButton1Click:Connect(function()
                openChat()
            end)

            chHide.MouseButton1Click:Connect(closeChat)
        end

registerTab("Info", "129516985087314", "Info", true)
registerTab("AutoThrow", "75410123129821", "Auto Throw", true)
registerTab("Shop", "101498199599518", "Shop", true)
registerTab("LiveChat", "83047761221446", "Live Chat", true)
registerTab("Settings", "97834340359225", "Settings", true)

                -- ⭐ AUTO BUKA TAB INFO PAS PERTAMA LAUNCH
    task.defer(function()
        local tries = 0
        while tries < 30 do
            if type(_G.VRILZ_SwitchTab) == "table"
                and type(_G.VRILZ_SwitchTab.Info) == "function" then
                local ok, err = pcall(_G.VRILZ_SwitchTab.Info)
                if not ok then
                    warn("[TAB] Auto-open Info failed: " .. tostring(err))
                end
                return
            end
            task.wait(0.1)
            tries = tries + 1
        end
        warn("[TAB] _G.VRILZ_SwitchTab.Info not registered after 3s!")
    end)

        -- Drag handler (PC + Mobile) — single source of truth
do
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil

    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    header.InputBegan:Connect(function(input)
        if not isPress(input) then return end

        -- Jangan drag kalau klik area tombol close/min (kanan header)
        local posX = input.Position.X
        if posX > (header.AbsolutePosition.X + header.AbsoluteSize.X - 90) then return end
        if dragging then return end  -- ⭐ FIX: jangan re-trigger

        dragging = true
        dragStart = input.Position
        startPos = main.Position
        dragInput = input
    end)

    -- ⭐ FIX: reset via global InputEnded, gak peduli di mana jari/mouse diangkat
    UserInputService.InputEnded:Connect(function(input)
        if dragInput == input then
            dragging = false
            dragInput = nil
            dragStart = nil
            startPos = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if not dragStart or not startPos then return end

        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

   return main
end
-- ============================================================
-- KEY SYSTEM GATE
-- Only adds a window before the existing loading screen.
-- Existing main UI/loading code remains unchanged.
-- ============================================================

local function getHttpRequest()
    return (syn and syn.request)
        or (http and http.request)
        or (http_request)
        or (request)
end

local function getKeyStorage()
    local ok, env = pcall(function()
        if getgenv then
            return getgenv()
        end
        return _G
    end)
    if ok and type(env) == "table" then
        return env
    end
    return _G
end

local function loadSavedKey()
    local env = getKeyStorage()
    local saved = env.VRILZ_KEY
    if type(saved) == "string" and saved:gsub("%s+", "") ~= "" then
        return saved
    end

    if readfile and isfile then
        local okFile, exists = pcall(isfile, "vrilz_key.txt")
        if okFile and exists then
            local okRead, content = pcall(readfile, "vrilz_key.txt")
            if okRead and type(content) == "string" and content:gsub("%s+", "") ~= "" then
                return content
            end
        end
    end

    return nil
end

local function saveKey(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", ""):upper()
    if key == "" then return end

    local env = getKeyStorage()
    env.VRILZ_KEY = key

    if writefile then
        pcall(writefile, "vrilz_key.txt", key)
    end

    -- ⭐ Update _RealKeyType juga — biar transisi OFF pakai key baru
    if Shared then
        Shared._RealKeyType = Shared.KeyType
        Shared._RealKeyExpiresAt = Shared.KeyExpiresAt or 0
    end
end

local function clearSavedKey()
    local env = getKeyStorage()
    env.VRILZ_KEY = nil
    if delfile and isfile then
        local okFile, exists = pcall(isfile, "vrilz_key.txt")
        if okFile and exists then
            pcall(delfile, "vrilz_key.txt")
        end
    end
end

local function applyKeyInfo(data, key)
    if type(data) ~= "table" then return end
    Shared = Shared or {}
    Shared.KeyValue = key
    Shared.KeyType = tostring(data.type or data.key_type or "UNKNOWN"):upper()
    Shared.KeyExpiresAt = tonumber(data.expires_at or data.expiry or 0) or 0
end

-- Stable device ID for Premium device-limit tracking.
-- Persists in executor file storage when available, so the same device
-- is recognized again after rejoining/reloading the script.
local function getStableDeviceId()
    local env = getKeyStorage()
    local cached = env.VRILZ_DEVICE_ID
    if type(cached) == "string" and #cached >= 8 then
        return cached
    end

    local fileName = "vrilz_device_id.txt"

    if readfile and isfile then
        local okFile, exists = pcall(isfile, fileName)
        if okFile and exists then
            local okRead, content = pcall(readfile, fileName)
            if okRead and type(content) == "string" then
                content = content:gsub("^%s+", ""):gsub("%s+$", "")
                if #content >= 8 then
                    env.VRILZ_DEVICE_ID = content
                    return content
                end
            end
        end
    end

    local HttpService = game:GetService("HttpService")
    local generated = nil

    pcall(function()
        generated = HttpService:GenerateGUID(false)
    end)

    if type(generated) ~= "string" or #generated < 8 then
        generated = tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
    end

    env.VRILZ_DEVICE_ID = generated

    if writefile then
        pcall(writefile, fileName, generated)
    end

    return generated
end

local function verifyKeyWithServer(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", ""):upper()
    if key == "" then
        return false, "Please enter a key first."
    end

    if KEY_SYSTEM_URL:find("YOUR%-KEY%-SYSTEM") then
        return false, "Please set the Key System URL first."
    end

    local HttpService = game:GetService("HttpService")
    local payload = HttpService:JSONEncode({
        username = LocalPlayer.Name,
        key = key,
        device_id = getStableDeviceId(),
    })
    local url = KEY_SYSTEM_URL:gsub("/$", "") .. "/api/redeem"

    local ok, response = pcall(function()
        local req = getHttpRequest()
        if req then
            return req({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json",
                },
                Body = payload,
            })
        end

        return {
            StatusCode = 200,
            Body = HttpService:PostAsync(
                url,
                payload,
                Enum.HttpContentType.ApplicationJson,
                false,
                { ["Accept"] = "application/json" }
            )
        }
    end)

    if not ok or not response then
        return false, "Cannot connect to Key System."
    end

    local status = tonumber(response.StatusCode or response.Status or 0) or 0
    local body = response.Body or response.body or ""
    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if decodedOk and type(data) == "table" then
        if data.success == true then
            return true, data.message or "Key valid.", data
        end
        local serverMessage = tostring(data.message or "Invalid key.")
        if status > 0 and status ~= 200 then
            serverMessage = serverMessage .. " [HTTP " .. tostring(status) .. "]"
        end
        return false, serverMessage, data
    end

    if status >= 200 and status < 300 then
        return false, "Invalid Key System response."
    end

    return false, "Key System server error [HTTP " .. tostring(status) .. "]."
end

-- Mengecek key yang SUDAH pernah diredeem tanpa membuat redeem kedua.
-- Return: (valid, message, data, isNetworkError)
local function verifySavedKeyWithServer(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", ""):upper()
    if key == "" then
        return false, "Saved key is empty.", nil, false
    end

    local HttpService = game:GetService("HttpService")
    local payload = HttpService:JSONEncode({
        username = LocalPlayer.Name,
        key = key,
        device_id = getStableDeviceId(),
    })
    local url = KEY_SYSTEM_URL:gsub("/$", "") .. "/api/verify"

    local ok, response = pcall(function()
        local req = getHttpRequest()
        if req then
            return req({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json",
                },
                Body = payload,
            })
        end

        return {
            StatusCode = 200,
            Body = HttpService:PostAsync(
                url,
                payload,
                Enum.HttpContentType.ApplicationJson,
                false,
                { ["Accept"] = "application/json" }
            )
        }
    end)

    -- ⭐ Network / request gagal total → bukan invalid key
    if not ok or not response then
        return false, "Cannot verify saved key (network).", nil, true
    end

    local status = tonumber(response.StatusCode or response.Status or 0) or 0
    local body = response.Body or response.body or ""
    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    -- ⭐ Server error 5xx → network/server issue, bukan invalid
    if status >= 500 then
        return false, "Key server error [HTTP " .. tostring(status) .. "]", nil, true
    end

    -- ⭐ Response bukan JSON valid → anggap network error
    if not decodedOk or type(data) ~= "table" then
        if status >= 200 and status < 300 then
            return false, "Invalid Key System response.", nil, true
        end
        return false, "Invalid key.", nil, false
    end

    if data.success == true then
        return true, data.message or "Key is still active.", data, false
    end

    -- ⭐ Cek apakah ini network-ish error dari server
    local msg = tostring(data.message or "")
    local msgLower = msg:lower()
    if msgLower:find("network")
        or msgLower:find("timeout")
        or msgLower:find("connect")
        or msgLower:find("server")
        or msgLower:find("unavailable")
    then
        return false, msg, data, true
    end

    -- ⭐ Invalid key beneran
    return false, msg ~= "" and msg or "Invalid key.", data, false
end

-- ============================================================
-- 🌌 LOADING SCREEN v2 — BULAN + METEOR SHOWER
-- ============================================================
local function buildLoadingScreen(parent)
    local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)

    local winW = IS_MOBILE and 340 or 460
    local winH = IS_MOBILE and 280 or 320

    -- ═══ MAIN CONTAINER ═══
    local loading = Instance.new("Frame")
    loading.Name = "LoadingScreen"
    loading.AnchorPoint = Vector2.new(0.5, 0.5)
    loading.Position = UDim2.fromScale(0.5, 0.5)
    loading.Size = UDim2.fromOffset(0, 0)
    loading.BackgroundColor3 = Color3.fromRGB(5, 8, 20)
    loading.BorderSizePixel = 0
    loading.ZIndex = 300
    loading.ClipsDescendants = true
    loading.Parent = parent

    -- ═══ DEEP SPACE GRADIENT ═══
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Rotation = 115
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 45)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(8, 12, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 3, 10)),
    })
    bgGradient.Parent = loading

    -- ═══ STROKE (neon cyan) ═══
    local stroke1 = Instance.new("UIStroke")
    stroke1.Color = Color3.fromRGB(80, 200, 255)
    stroke1.Thickness = 2.5
    stroke1.Transparency = 0.1
    stroke1.Parent = loading

    local stroke2 = Instance.new("UIStroke")
    stroke2.Color = Color3.fromRGB(255, 255, 255)
    stroke2.Thickness = 1
    stroke2.Transparency = 0.8
    stroke2.Parent = loading

    -- ═══ STARFIELD (bintang statis) ═══
    local starfield = Instance.new("Frame")
    starfield.Size = UDim2.fromScale(1, 1)
    starfield.BackgroundTransparency = 1
    starfield.ZIndex = 301
    starfield.ClipsDescendants = true
    starfield.Parent = loading

    for i = 1, 60 do
        local star = Instance.new("Frame")
        local sz = math.random(1, 3)
        star.Size = UDim2.fromOffset(sz, sz)
        star.Position = UDim2.fromScale(math.random(0, 100) / 100, math.random(0, 100) / 100)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = math.random(20, 70) / 100
        star.BorderSizePixel = 0
        star.ZIndex = 302
        star.Parent = starfield

        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = star

        -- Twinkle animation
        task.spawn(function()
            local baseTrans = star.BackgroundTransparency
            while star.Parent do
                task.wait(math.random(15, 40) / 10)
                if not star.Parent then break end
                TweenService:Create(star, TweenInfo.new(0.6), {BackgroundTransparency = baseTrans - 0.3}):Play()
                task.wait(0.6)
                TweenService:Create(star, TweenInfo.new(0.6), {BackgroundTransparency = baseTrans}):Play()
            end
        end)
    end

    -- ═══ MOON (bulan glow) ═══
    local moonSize = IS_MOBILE and 80 or 110
    local moonX = winW * 0.72
    local moonY = winH * 0.22

    -- Outer glow (halo)
    local moonGlow = Instance.new("Frame")
    moonGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    moonGlow.Position = UDim2.fromOffset(moonX, moonY)
    moonGlow.Size = UDim2.fromOffset(moonSize + 60, moonSize + 60)
    moonGlow.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
    moonGlow.BackgroundTransparency = 0.85
    moonGlow.BorderSizePixel = 0
    moonGlow.ZIndex = 303
    moonGlow.Parent = loading
    local mg1c = Instance.new("UICorner")
    mg1c.CornerRadius = UDim.new(1, 0)
    mg1c.Parent = moonGlow

    -- Mid glow
    local moonGlow2 = Instance.new("Frame")
    moonGlow2.AnchorPoint = Vector2.new(0.5, 0.5)
    moonGlow2.Position = UDim2.fromOffset(moonX, moonY)
    moonGlow2.Size = UDim2.fromOffset(moonSize + 25, moonSize + 25)
    moonGlow2.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
    moonGlow2.BackgroundTransparency = 0.7
    moonGlow2.BorderSizePixel = 0
    moonGlow2.ZIndex = 304
    moonGlow2.Parent = loading
    local mg2c = Instance.new("UICorner")
    mg2c.CornerRadius = UDim.new(1, 0)
    mg2c.Parent = moonGlow2

    -- Moon body
    local moon = Instance.new("Frame")
    moon.AnchorPoint = Vector2.new(0.5, 0.5)
    moon.Position = UDim2.fromOffset(moonX, moonY)
    moon.Size = UDim2.fromOffset(moonSize, moonSize)
    moon.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
    moon.BorderSizePixel = 0
    moon.ZIndex = 305
    moon.Parent = loading
    local moonCorner = Instance.new("UICorner")
    moonCorner.CornerRadius = UDim.new(1, 0)
    moonCorner.Parent = moon

    -- Moon gradient (3D effect)
    local moonGradient = Instance.new("UIGradient")
    moonGradient.Rotation = 135
    moonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 230, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 160, 200)),
    })
    moonGradient.Parent = moon

    -- Moon craters
    local craters = {
        {0.3, 0.3, 0.15},
        {0.65, 0.45, 0.12},
        {0.5, 0.65, 0.10},
        {0.25, 0.55, 0.08},
    }
    for _, crater in ipairs(craters) do
        local c = Instance.new("Frame")
        c.AnchorPoint = Vector2.new(0.5, 0.5)
        c.Position = UDim2.fromScale(crater[1], crater[2])
        c.Size = UDim2.fromScale(crater[3], crater[3])
        c.BackgroundColor3 = Color3.fromRGB(180, 195, 225)
        c.BackgroundTransparency = 0.3
        c.BorderSizePixel = 0
        c.ZIndex = 306
        c.Parent = moon
        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(1, 0)
        cc.Parent = c
    end

    -- Moon pulse glow
    task.spawn(function()
        while moonGlow.Parent do
            moonGlow.BackgroundTransparency = 0.85
            TweenService:Create(moonGlow, TweenInfo.new(2.5), {BackgroundTransparency = 0.92}):Play()
            task.wait(2.5)
        end
    end)

    -- ═══ METEOR SHOWER (jatuh terus-terusan) ═══
    local meteorLayer = Instance.new("Frame")
    meteorLayer.Size = UDim2.fromScale(1, 1)
    meteorLayer.BackgroundTransparency = 1
    meteorLayer.ZIndex = 310
    meteorLayer.ClipsDescendants = true
    meteorLayer.Parent = loading

    local meteorActive = true
    loading.Destroying:Connect(function()
        meteorActive = false
    end)

    local function spawnMeteor()
        if not meteorActive or not meteorLayer.Parent then return end

        local meteor = Instance.new("Frame")
        meteor.AnchorPoint = Vector2.new(0.5, 0.5)
        
        -- Start position (random top area)
        local startX = math.random(-100, winW + 100)
        local startY = -50
        meteor.Position = UDim2.fromOffset(startX, startY)
        meteor.Size = UDim2.fromOffset(3, 3)
        meteor.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
        meteor.BorderSizePixel = 0
        meteor.Rotation = 45
        meteor.ZIndex = 311
        meteor.Parent = meteorLayer

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(1, 0)
        mc.Parent = meteor

        -- Meteor head glow
        local headGlow = Instance.new("Frame")
        headGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        headGlow.Position = UDim2.fromScale(0.5, 0.5)
        headGlow.Size = UDim2.fromOffset(12, 12)
        headGlow.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
        headGlow.BackgroundTransparency = 0.5
        headGlow.BorderSizePixel = 0
        headGlow.ZIndex = 310
        headGlow.Parent = meteor
        local hgc = Instance.new("UICorner")
        hgc.CornerRadius = UDim.new(1, 0)
        hgc.Parent = headGlow

        -- Trail (fire tail)
        local trail = Instance.new("Frame")
        trail.AnchorPoint = Vector2.new(1, 0.5)
        trail.Position = UDim2.fromScale(0.5, 0.5)
        trail.Size = UDim2.fromOffset(math.random(40, 90), 2)
        trail.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
        trail.BackgroundTransparency = 0.3
        trail.BorderSizePixel = 0
        trail.ZIndex = 309
        trail.Parent = meteor

        local trailGrad = Instance.new("UIGradient")
        trailGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.2),
            NumberSequenceKeypoint.new(1, 0),
        })
        trailGrad.Parent = trail

        -- Trail sparks (3-5 titik)
        for i = 1, math.random(3, 5) do
            local spark = Instance.new("Frame")
            spark.AnchorPoint = Vector2.new(0.5, 0.5)
            spark.Position = UDim2.new(1, math.random(-40, -10), 0.5, math.random(-3, 3))
            spark.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
            spark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            spark.BackgroundTransparency = 0.4
            spark.BorderSizePixel = 0
            spark.ZIndex = 308
            spark.Parent = meteor
            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(1, 0)
            sc.Parent = spark
        end

        -- Duration & end position
        local duration = math.random(120, 200) / 100
        local endX = startX + math.random(-80, 80)
        local endY = winH + 100

        -- Animate fall
        TweenService:Create(meteor, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.fromOffset(endX, endY),
            Rotation = 45,
        }):Play()

        -- Fade out near end
        task.delay(duration * 0.8, function()
            if meteor.Parent then
                TweenService:Create(meteor, TweenInfo.new(duration * 0.2), {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(headGlow, TweenInfo.new(duration * 0.2), {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(trail, TweenInfo.new(duration * 0.2), {
                    BackgroundTransparency = 1,
                }):Play()
            end
        end)

        -- Cleanup
        task.delay(duration + 0.1, function()
            if meteor then meteor:Destroy() end
        end)
    end

    -- Meteor spawner loop (continuous)
    task.spawn(function()
        task.wait(0.3)  -- delay awal
        while meteorActive do
            spawnMeteor()
            -- Spawn 1-2 meteor sekaligus, dengan jeda acak
            if math.random() < 0.3 then
                task.wait(0.1)
                spawnMeteor()
            end
            task.wait(math.random(30, 90) / 100)
        end
    end)

    -- ═══ SCANLINES (subtle) ═══
    local scanlines = Instance.new("Frame")
    scanlines.Size = UDim2.fromScale(1, 1)
    scanlines.BackgroundTransparency = 1
    scanlines.ZIndex = 320
    scanlines.ClipsDescendants = true
    scanlines.Parent = loading

    for i = 0, math.floor(winH / 5) do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.fromOffset(0, i * 5)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.85
        line.BorderSizePixel = 0
        line.ZIndex = 320
        line.Parent = scanlines
    end

    -- ═══ NOISE ═══
    local noise = Instance.new("Frame")
    noise.Size = UDim2.fromScale(1, 1)
    noise.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    noise.BackgroundTransparency = 0.94
    noise.BorderSizePixel = 0
    noise.ZIndex = 319
    noise.Parent = loading

    task.spawn(function()
        while noise.Parent do
            task.wait(0.06)
            noise.BackgroundTransparency = 0.90 + math.random() * 0.06
        end
    end)

    -- ═══ GLITCH BARS ═══
    local glitchBars = {}
    for i = 1, 4 do
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, math.random(2, 4))
        bar.Position = UDim2.fromScale(0, math.random())
        bar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        bar.BackgroundTransparency = 0.6
        bar.BorderSizePixel = 0
        bar.ZIndex = 330
        bar.Visible = false
        bar.Parent = loading
        table.insert(glitchBars, bar)
    end

    task.spawn(function()
        while loading.Parent do
            task.wait(math.random(15, 40) / 100)
            for _, bar in ipairs(glitchBars) do
                if math.random() < 0.3 then
                    bar.Visible = true
                    bar.Position = UDim2.fromScale(0, math.random())
                    bar.Size = UDim2.new(1, 0, 0, math.random(2, 6))
                    task.wait(0.03)
                    bar.Visible = false
                end
            end
        end
    end)

    -- ═══ VH LOGO (3D + petir) ═══
    local vHolder = Instance.new("Frame")
    vHolder.Size = UDim2.fromScale(1, 0.5)
    vHolder.Position = UDim2.fromScale(0, 0.18)
    vHolder.BackgroundTransparency = 1
    vHolder.ZIndex = 305
    vHolder.Parent = loading

    local vGlow = Instance.new("TextLabel")
    vGlow.Size = UDim2.fromScale(1, 1)
    vGlow.BackgroundTransparency = 1
    vGlow.Text = "V"
    vGlow.TextColor3 = Color3.fromRGB(100, 200, 255)
    vGlow.TextTransparency = 0.3
    vGlow.Font = Enum.Font.GothamBlack
    vGlow.TextSize = 1
    vGlow.ZIndex = 304
    vGlow.Parent = vHolder

    local vRed = Instance.new("TextLabel")
    vRed.Size = UDim2.fromScale(1, 1)
    vRed.Position = UDim2.fromOffset(-2, 0)
    vRed.BackgroundTransparency = 1
    vRed.Text = "V"
    vRed.TextColor3 = Color3.fromRGB(255, 0, 0)
    vRed.TextTransparency = 0.6
    vRed.Font = Enum.Font.GothamBlack
    vRed.TextSize = 1
    vRed.ZIndex = 305
    vRed.Parent = vHolder

    local vBlue = Instance.new("TextLabel")
    vBlue.Size = UDim2.fromScale(1, 1)
    vBlue.Position = UDim2.fromOffset(2, 0)
    vBlue.BackgroundTransparency = 1
    vBlue.Text = "V"
    vBlue.TextColor3 = Color3.fromRGB(0, 100, 255)
    vBlue.TextTransparency = 0.6
    vBlue.Font = Enum.Font.GothamBlack
    vBlue.TextSize = 1
    vBlue.ZIndex = 305
    vBlue.Parent = vHolder

    local vLabel = Instance.new("TextLabel")
    vLabel.Size = UDim2.fromScale(1, 1)
    vLabel.BackgroundTransparency = 1
    vLabel.Text = "V"
    vLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    vLabel.Font = Enum.Font.GothamBlack
    vLabel.TextSize = 1
    vLabel.ZIndex = 306
    vLabel.Parent = vHolder

    -- Glitch anim
    task.spawn(function()
        while loading.Parent do
            task.wait(math.random(8, 20) / 100)
            local offset = math.random(1, 4)
            vRed.Position = UDim2.fromOffset(-offset, 0)
            vBlue.Position = UDim2.fromOffset(offset, 0)
            task.wait(0.05)
            vRed.Position = UDim2.fromOffset(-1, 0)
            vBlue.Position = UDim2.fromOffset(1, 0)
        end
    end)

    -- Glow pulse
    task.spawn(function()
        while loading.Parent do
            task.wait(0.6)
            TweenService:Create(vGlow, TweenInfo.new(0.6), {TextTransparency = 0.05}):Play()
            task.wait(0.6)
            TweenService:Create(vGlow, TweenInfo.new(0.6), {TextTransparency = 0.4}):Play()
        end
    end)

    -- Grow animation
    task.spawn(function()
        local endSize = IS_MOBILE and 100 or 130
        local steps = 40
        for i = 1, steps do
            task.wait(1.0 / steps)
            local t = i / steps
            local eased = 1 - (1 - t) ^ 3
            local size = 1 + (endSize - 1) * eased
            vLabel.TextSize = size
            vGlow.TextSize = size
            vRed.TextSize = size
            vBlue.TextSize = size
        end

        -- Final shake
        task.wait(0.2)
        for i = 1, 6 do
            vLabel.Position = UDim2.fromOffset(math.random(-5, 5), math.random(-5, 5))
            task.wait(0.04)
            vLabel.Position = UDim2.fromOffset(0, 0)
        end
    end)

    -- ═══ LOADING TEXT (bottom) ═══
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, -20, 0, 18)
    loadingText.Position = UDim2.new(0, 10, 0, winH - 68)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "LOADING..."
    loadingText.TextColor3 = Color3.fromRGB(200, 230, 255)
    loadingText.Font = Enum.Font.GothamBlack
    loadingText.TextSize = IS_MOBILE and 11 or 12
    loadingText.TextXAlignment = Enum.TextXAlignment.Left
    loadingText.ZIndex = 306
    loadingText.Parent = loading

    -- Progress bar bg
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 6)
    barBg.Position = UDim2.new(0, 10, 0, winH - 44)
    barBg.BackgroundColor3 = Color3.fromRGB(20, 30, 60)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 305
    barBg.Parent = loading

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(80, 200, 255)
    barStroke.Thickness = 1
    barStroke.Transparency = 0.3
    barStroke.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 306
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    local barFillGlow = Instance.new("UIGradient")
    barFillGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255)),
    })
    barFillGlow.Parent = barFill

    -- Percent
    local percentLbl = Instance.new("TextLabel")
    percentLbl.Size = UDim2.new(1, -20, 0, 14)
    percentLbl.Position = UDim2.new(0, 10, 0, winH - 26)
    percentLbl.BackgroundTransparency = 1
    percentLbl.Text = "0%"
    percentLbl.TextColor3 = Color3.fromRGB(80, 200, 255)
    percentLbl.Font = Enum.Font.GothamBlack
    percentLbl.TextSize = 10
    percentLbl.TextXAlignment = Enum.TextXAlignment.Right
    percentLbl.ZIndex = 306
    percentLbl.Parent = loading

    local brandLbl = Instance.new("TextLabel")
    brandLbl.Size = UDim2.new(1, -20, 0, 14)
    brandLbl.Position = UDim2.new(0, 10, 0, winH - 26)
    brandLbl.BackgroundTransparency = 1
    brandLbl.Text = "V R I L Z H U B"
    brandLbl.TextColor3 = Color3.fromRGB(100, 140, 180)
    brandLbl.Font = Enum.Font.GothamBold
    brandLbl.TextSize = 10
    brandLbl.TextXAlignment = Enum.TextXAlignment.Left
    brandLbl.ZIndex = 306
    brandLbl.Parent = loading

    -- ═══ MAIN LOADING SEQUENCE ═══
    task.spawn(function()
        loading.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(loading, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(winW, winH)
        }):Play()
        task.wait(0.6)

        loadingText.Text = "INITIALIZING..."
        for i = 1, 30 do
            task.wait(0.1)
            local p = (i / 30) * 0.15
            barFill.Size = UDim2.new(p, 0, 1, 0)
            percentLbl.Text = math.floor(p * 100) .. "%"
        end

        local phases = {
            {text = "LOADING MODULES...", target = 0.4, duration = 2.5},
            {text = "CONNECTING SERVER...", target = 0.6, duration = 2.5},
            {text = "LOADING FEATURES...", target = 0.8, duration = 2.5},
            {text = "FINALIZING...", target = 1.0, duration = 2.5},
        }

        for _, phase in ipairs(phases) do
            loadingText.Text = phase.text
            local startP = barFill.Size.X.Scale
            local steps = math.floor(phase.duration / 0.05)
            for i = 1, steps do
                task.wait(0.05)
                local t = i / steps
                local p = startP + (phase.target - startP) * t
                barFill.Size = UDim2.new(p, 0, 1, 0)
                percentLbl.Text = math.floor(p * 100) .. "%"
            end
        end

        loadingText.Text = "READY!"
        percentLbl.Text = "100%"

        -- Final shake
        for i = 1, 8 do
            loading.Position = UDim2.fromScale(0.5 + math.random(-15, 15)/1000, 0.5 + math.random(-15, 15)/1000)
            task.wait(0.03)
        end
        loading.Position = UDim2.fromScale(0.5, 0.5)

        task.wait(0.6)

        -- Stop meteor spawn
        meteorActive = false

        TweenService:Create(loading, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        task.wait(0.5)

        if loading then loading:Destroy() end
        buildMainWindow(parent)
        notify("Welcome, " .. LocalPlayer.DisplayName, "success")

        -- Features.Init after UI ready
        task.spawn(function()
            task.wait(0.5)
            local timeout = 0
            while not _G.VRILZ_Features and timeout < 10 do
                task.wait(0.5)
                timeout = timeout + 0.5
            end

            if _G.VRILZ_Features and _G.VRILZ_Features.Init then
                local ok, err = pcall(function()
                    _G.VRILZ_Features.Init(Shared)
                end)
                if not ok then
                    warn("[UI] ❌ Features.Init failed: " .. tostring(err))
                end
            else
                warn("[UI] ❌ _G.VRILZ_Features not loaded!")
            end
        end)
    end)
end

-- ============================================================
-- ARQEL KEY SYSTEM UI — PORT PERSIS (UI only)
-- Logic verify/storage tetap VRILZHUB
-- ============================================================

local ArqelUI = {}

-- ===== SERVICES =====
local A_Tween = TweenService
local A_UIS = UserInputService
local A_Http = game:GetService("HttpService")
local A_WS = workspace
local A_Run = RunService
local A_Light = Lighting
local A_Players = Players
local A_LP = LocalPlayer
local A_hui = (gethui and gethui()) or game:GetService("CoreGui")

-- ===== APPEARANCE =====
local A_Appearance = {
    Title = "VRILZHUB",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 30, 0, 30)
}

local A_Links = {
    GetKey = KEY_SYSTEM_URL,
    Discord = "https://discord.gg/psWhrYWbq"
}

-- Changelog VRILZHUB
local A_Changelog = {
    {
        Version = "v1.0",
        Date = "19 Okt 2026",
        Changes = {
            "Ubah (Ubah ini)",
        }
    },
    {
        Version = "v1.0",
        Date = "10 Okt 2026",
        Changes = {
            "Ubah (Ubah ini)",
        }
    }
}

-- ===== THEME (Arqel persis) =====
local A_Theme = {
    Accent = Color3.fromRGB(139, 0, 0),
    AccentHover = Color3.fromRGB(170, 20, 20),
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(20, 20, 20),
    Input = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(120, 120, 120),
    Success = Color3.fromRGB(50, 205, 110),
    Error = Color3.fromRGB(245, 70, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    StatusIdle = Color3.fromRGB(180, 80, 80),
    Discord = Color3.fromRGB(88, 101, 242),
    DiscordHover = Color3.fromRGB(114, 137, 218),
    Divider = Color3.fromRGB(45, 45, 70),
    Pending = Color3.fromRGB(60, 60, 60)
}

-- ===== INTERNAL =====
local A_Internal = {
    BlurEffect = nil,
    NotificationList = {},
    IsKeylessMode = false
}

-- ===== ICONS =====
local A_IconBaseURL = "https://raw.githubusercontent.com/Cobruhehe/expert-octo-doodle/main/Icons/"
local A_IconFiles = {
    key = "lucide--key.png",
    shield = "lucide--shield-minus.png",
    check = "prime--check-square.png",
    copy = "flowbite--clipboard-outline.png",
    discord = "qlementine-icons--discord-16.png",
    alert = "mdi--alert-octagon-outline.png",
    lock = "lucide--user-lock.png",
    loading = "nonicons--loading-16.png",
    close = "material-symbols--dangerous-outline.png",
    changelog = "ant-design--sync-outlined.png",
    logo = "rrjlGmac.png",
    user = "U.png",
    clock = "Clock.png",
    cart = "Cart.png",
    nogetkey = "lucide--lock.png"
}

local A_FallbackIcons = {
    key = "rbxassetid://96510194465420",
    shield = "rbxassetid://89965059528921",
    check = "rbxassetid://76078495178149",
    copy = "rbxassetid://125851897718493",
    discord = "rbxassetid://83278450537116",
    alert = "rbxassetid://140438367956051",
    lock = "rbxassetid://114355063515473",
    loading = "rbxassetid://116535712789945",
    close = "rbxassetid://6022668916",
    changelog = "rbxassetid://138133190015277",
    logo = "rbxassetid://95721401302279",
    user = "rbxassetid://77400125196692",
    clock = "rbxassetid://87505349362628",
    cart = "rbxassetid://114754518183872",
    nogetkey = "rbxassetid://119765975153029"
}

local A_CachedIcons = {}
local A_FolderName = "VRILZHUB_KS"
local A_IconsFolder = "Icons"
local A_DefaultLogoAsset = "rbxassetid://95721401302279"

-- ===== HELPER =====
local function a_isMobile()
    return A_UIS.TouchEnabled and not A_UIS.KeyboardEnabled
end

local function a_getScale()
    local vp = A_WS.CurrentCamera.ViewportSize
    return math.clamp(math.min(vp.X, vp.Y) / 900, 0.65, 1.3)
end

local function a_hasFileSystem()
    local ok1 = pcall(function() return type(writefile) == "function" end)
    local ok2 = pcall(function() return type(readfile) == "function" end)
    local ok3 = pcall(function() return type(isfile) == "function" end)
    local ok4 = pcall(function() return type(makefolder) == "function" end)
    local ok5 = pcall(function() return type(isfolder) == "function" end)
    return ok1 and ok2 and ok3 and ok4 and ok5
end

local a_fsSupported = a_hasFileSystem()

local function a_ensureFolders()
    if not a_fsSupported then return false end
    pcall(function()
        if not isfolder(A_FolderName) then makefolder(A_FolderName) end
        if not isfolder(A_FolderName .. "/" .. A_IconsFolder) then makefolder(A_FolderName .. "/" .. A_IconsFolder) end
    end)
    return true
end

local function a_getIconPath(name)
    return A_FolderName .. "/" .. A_IconsFolder .. "/" .. A_IconFiles[name]
end

local function a_isIconCached(name)
    if not a_fsSupported then return false end
    local ok, res = pcall(function() return isfile(a_getIconPath(name)) end)
    return ok and res
end

local function a_downloadIcon(name)
    if not a_fsSupported then
        A_CachedIcons[name] = A_FallbackIcons[name]
        return false
    end
    local path = a_getIconPath(name)
    if a_isIconCached(name) then
        local ok = pcall(function() A_CachedIcons[name] = getcustomasset(path) end)
        if ok then return true end
    end
    local ok = pcall(function()
        local res = game:HttpGet(A_IconBaseURL .. A_IconFiles[name])
        if #res < 100 then error("Invalid") end
        writefile(path, res)
        A_CachedIcons[name] = getcustomasset(path)
    end)
    if not ok then A_CachedIcons[name] = A_FallbackIcons[name] end
    return ok
end

local function a_getIcon(name)
    return A_CachedIcons[name] or A_FallbackIcons[name]
end

local function a_getLogoIcon()
    if A_Appearance.Icon == A_DefaultLogoAsset then return a_getIcon("logo") end
    return A_Appearance.Icon
end

local function a_shouldDownloadLogo()
    return A_Appearance.Icon == A_DefaultLogoAsset
end

local function a_allIconsCached()
    if not a_fsSupported then return false end
    local list = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart","nogetkey"}
    if a_shouldDownloadLogo() then table.insert(list, "logo") end
    for _, n in ipairs(list) do
        if not a_isIconCached(n) then return false end
    end
    return true
end

local function a_loadAllIcons()
    a_ensureFolders()
    local list = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart","nogetkey"}
    if a_shouldDownloadLogo() then table.insert(list, "logo") end
    for _, n in ipairs(list) do a_downloadIcon(n) end
end

local function a_ensureIconsReady(cb)
    if a_allIconsCached() then
        a_loadAllIcons()
        if cb then cb() end
    else
        a_ensureFolders()
        a_loadAllIcons()
        if cb then cb() end
    end
end

local function a_getExecutorName()
    local ok, name = pcall(identifyexecutor)
    if ok and name then return tostring(name) end
    return "Unknown"
end

local function a_getDeviceType()
    local t = A_UIS.TouchEnabled
    local k = A_UIS.KeyboardEnabled
    local g = A_UIS.GamepadEnabled
    if g and not k and not t then return "Console"
    elseif t and not k then return "Mobile"
    elseif k and t then return "PC & Touch"
    elseif k then return "PC"
    else return "Unknown" end
end

local function a_getHWID()
    local hwid = nil
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        hwid = A_Http:GenerateGUID(false):gsub("-", ""):sub(1, 32)
        if A_LP then hwid = tostring(A_LP.UserId) .. hwid:sub(1, 20) end
    end
    return hwid or "N/A"
end

local function a_generateHiddenDots(w, cw)
    cw = cw or 5
    local n = math.max(math.floor(w / cw), 8)
    return string.rep("•", n)
end

local function a_formatTime12()
    local h = tonumber(os.date("%H"))
    local m = os.date("%M")
    local s = os.date("%S")
    local p = "AM"
    if h >= 12 then p = "PM" end
    if h > 12 then h = h - 12 end
    if h == 0 then h = 12 end
    return string.format("%d:%s:%s %s", h, m, s, p)
end

local function a_formatDate()
    return os.date("%b %d, %Y")
end

-- ===== BLUR =====
local function a_enableBlur()
    local existing = A_Light:FindFirstChild("VH_KS_Blur")
    if existing then existing:Destroy() end
    A_Internal.BlurEffect = Instance.new("BlurEffect")
    A_Internal.BlurEffect.Name = "VH_KS_Blur"
    A_Internal.BlurEffect.Size = 0
    A_Internal.BlurEffect.Parent = A_Light
    A_Tween:Create(A_Internal.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = 24}):Play()
end

local function a_disableBlur()
    if A_Internal.BlurEffect and A_Internal.BlurEffect.Parent then
        A_Tween:Create(A_Internal.BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = 0}):Play()
        task.delay(0.3, function()
            if A_Internal.BlurEffect and A_Internal.BlurEffect.Parent then
                A_Internal.BlurEffect:Destroy()
                A_Internal.BlurEffect = nil
            end
        end)
    else
        local ex = A_Light:FindFirstChild("VH_KS_Blur")
        if ex then ex:Destroy() end
        A_Internal.BlurEffect = nil
    end
end

-- ===== DRAG =====
local function a_setupDragging(header, main)
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragInput == input then dragging = false dragInput = nil end
                end
            end)
        end
    end)
    A_UIS.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if input == dragInput then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
end

-- ===== NOTIFY (Arqel style — bottom-right, progress bar, stacking) =====
local function a_Notify(title, message, duration, iconType)
    duration = duration or 5
    iconType = iconType or "info"
    local scale = a_getScale()
    local width = math.clamp(320 * scale, 260, 380)
    local height = math.clamp(80 * scale, 75, 105)

    local notifGui = Instance.new("ScreenGui")
    notifGui.ResetOnSpawn = false
    notifGui.DisplayOrder = 999999
    notifGui.Parent = A_hui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = UDim2.new(1, width + 20, 1, -15)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = A_Theme.Header
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = A_Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = A_Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg

    local iconSize = height - 35
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, iconSize, 0, iconSize)
    icon.Position = UDim2.new(0, 14, 0.5, -2)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = frame

    local iconMap = {
        success = {"check", A_Theme.Success}, error = {"alert", A_Theme.Error},
        warning = {"alert", A_Theme.Warning}, shield = {"shield", A_Theme.Accent},
        info = {"shield", A_Theme.Accent}, key = {"key", A_Theme.Accent},
        copy = {"copy", A_Theme.Success}, discord = {"discord", A_Theme.Discord},
        close = {"close", A_Theme.Error}, nogetkey = {"nogetkey", A_Theme.TextDim}
    }

    if iconMap[iconType] then
        icon.Image = a_getIcon(iconMap[iconType][1])
        icon.ImageColor3 = iconMap[iconType][2]
    else
        icon.Image = a_getLogoIcon()
        icon.ImageColor3 = A_Theme.Text
    end

    local textX = 14 + iconSize + 14
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -(textX + 14), 0, 24)
    titleLabel.Position = UDim2.new(0, textX, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextSize = math.clamp(15 * scale, 13, 18)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = A_Theme.Text
    titleLabel.Text = title
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -(textX + 14), 0, 22)
    messageLabel.Position = UDim2.new(0, textX, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.ArimoBold
    messageLabel.TextSize = math.clamp(13 * scale, 11, 15)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextColor3 = A_Theme.TextDim
    messageLabel.Text = message
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = frame

    local id = tick() .. A_Http:GenerateGUID(false)
    table.insert(A_Internal.NotificationList, {id = id, frame = frame, gui = notifGui, height = height})

    local function restack()
        local yOff = 0
        for i = #A_Internal.NotificationList, 1, -1 do
            local n = A_Internal.NotificationList[i]
            if n and n.frame and n.frame.Parent then
                A_Tween:Create(n.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15 - yOff)}):Play()
                yOff = yOff + n.height + 12
            end
        end
    end

    A_Tween:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15)}):Play()
    task.wait(0.1)
    restack()

    local function dismiss()
        for i, n in ipairs(A_Internal.NotificationList) do
            if n.id == id then table.remove(A_Internal.NotificationList, i) break end
        end
        A_Tween:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, width + 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.3)
        notifGui:Destroy()
        restack()
    end

    A_Tween:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.delay(duration, dismiss)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame
    clickBtn.MouseButton1Click:Connect(dismiss)
end

-- ===== DOOR OVERLAY =====
local function a_CreateDoorOverlay(parentFrame, width, height)
    local overlay = Instance.new("Frame")
    overlay.Name = "DoorOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.ClipsDescendants = true
    overlay.ZIndex = 50
    overlay.Parent = parentFrame

    local leftDoor = Instance.new("Frame")
    leftDoor.Name = "LeftDoor"
    leftDoor.Size = UDim2.new(0.5, 0, 1, 0)
    leftDoor.BackgroundColor3 = A_Theme.Header
    leftDoor.BorderSizePixel = 0
    leftDoor.ZIndex = 51
    leftDoor.Parent = overlay

    local rightDoor = Instance.new("Frame")
    rightDoor.Name = "RightDoor"
    rightDoor.Size = UDim2.new(0.5, 0, 1, 0)
    rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
    rightDoor.BackgroundColor3 = A_Theme.Header
    rightDoor.BorderSizePixel = 0
    rightDoor.ZIndex = 51
    rightDoor.Parent = overlay

       -- ===== VH LOGO (3D text + lightning) — door overlay =====
    local logoSize = math.min(width, height) * 0.28
    local logoHolder = Instance.new("Frame")
    logoHolder.Name = "DoorLogo"
    logoHolder.Size = UDim2.new(0, logoSize, 0, logoSize)
    logoHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    logoHolder.BackgroundColor3 = A_Theme.Background
    logoHolder.BackgroundTransparency = 0.1
    logoHolder.BorderSizePixel = 0
    logoHolder.ClipsDescendants = true
    logoHolder.ZIndex = 54
    logoHolder.Parent = overlay

    local dlCorner = Instance.new("UICorner")
    dlCorner.CornerRadius = UDim.new(0, 10)
    dlCorner.Parent = logoHolder

    local dlStroke = Instance.new("UIStroke")
    dlStroke.Color = A_Theme.Accent
    dlStroke.Thickness = 2
    dlStroke.Transparency = 0.15
    dlStroke.Parent = logoHolder

    local dlTextSize = math.floor(logoSize * 0.42)

    local dlShadow = Instance.new("TextLabel")
    dlShadow.Size = UDim2.fromScale(1, 1)
    dlShadow.Position = UDim2.fromOffset(2, 3)
    dlShadow.BackgroundTransparency = 1
    dlShadow.Text = "VH"
    dlShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    dlShadow.TextTransparency = 0.05
    dlShadow.Font = Enum.Font.GothamBlack
    dlShadow.TextSize = dlTextSize
    dlShadow.ZIndex = 55
    dlShadow.Parent = logoHolder

    local dlDepth = Instance.new("TextLabel")
    dlDepth.Size = UDim2.fromScale(1, 1)
    dlDepth.Position = UDim2.fromOffset(1, 1)
    dlDepth.BackgroundTransparency = 1
    dlDepth.Text = "VH"
    dlDepth.TextColor3 = A_Theme.Accent
    dlDepth.Font = Enum.Font.GothamBlack
    dlDepth.TextSize = dlTextSize
    dlDepth.ZIndex = 56
    dlDepth.Parent = logoHolder

    local dlFace = Instance.new("TextLabel")
    dlFace.Size = UDim2.fromScale(1, 1)
    dlFace.BackgroundTransparency = 1
    dlFace.Text = "VH"
    dlFace.TextColor3 = A_Theme.Text
    dlFace.Font = Enum.Font.GothamBlack
    dlFace.TextSize = dlTextSize
    dlFace.TextStrokeColor3 = A_Theme.Accent
    dlFace.TextStrokeTransparency = 0
    dlFace.ZIndex = 57
    dlFace.Parent = logoHolder

    local dlLightningHolder = Instance.new("Frame")
    dlLightningHolder.Size = UDim2.fromScale(1, 1)
    dlLightningHolder.BackgroundTransparency = 1
    dlLightningHolder.ClipsDescendants = true
    dlLightningHolder.ZIndex = 58
    dlLightningHolder.Parent = logoHolder

    local doorSegments = {
        {0.18, 0.15, logoSize * 0.35, -30},
        {0.80, 0.30, logoSize * 0.30, 35},
        {0.15, 0.55, logoSize * 0.38, -25},
        {0.85, 0.72, logoSize * 0.28, 30},
        {0.50, 0.10, logoSize * 0.22, 0},
    }

    local dlBolts = {}
    for _, seg in ipairs(doorSegments) do
        local bolt = Instance.new("Frame")
        bolt.AnchorPoint = Vector2.new(0.5, 0.5)
        bolt.Size = UDim2.fromOffset(2, seg[3])
        bolt.Position = UDim2.fromScale(seg[1], seg[2])
        bolt.Rotation = seg[4]
        bolt.BackgroundColor3 = Color3.fromRGB(170, 220, 255)
        bolt.BackgroundTransparency = 1
        bolt.BorderSizePixel = 0
        bolt.ZIndex = 59
        bolt.Parent = dlLightningHolder
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(1, 0)
        bc.Parent = bolt
        table.insert(dlBolts, bolt)
    end

    -- Lightning loop
    task.spawn(function()
        while logoHolder.Parent do
            task.wait(math.random(12, 30) / 10)
            if not logoHolder.Parent then break end
            for _, bolt in ipairs(dlBolts) do
                bolt.BackgroundTransparency = 0
                task.wait(0.05)
                bolt.BackgroundTransparency = 1
            end
            task.wait(0.08)
            for _, bolt in ipairs(dlBolts) do
                bolt.BackgroundTransparency = 0
                task.wait(0.03)
                bolt.BackgroundTransparency = 1
            end
        end
    end)

    local halfWidth = math.ceil(width / 2)

          local function openDoors(cb)
        -- Fade out VH logo (pakai BackgroundTransparency + TextTransparency)
        A_Tween:Create(logoHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
        for _, child in ipairs(logoHolder:GetChildren()) do
            if child:IsA("TextLabel") then
                A_Tween:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {TextTransparency = 1}):Play()
            end
        end
        task.wait(0.25)
        A_Tween:Create(leftDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, -halfWidth, 0, 0)}):Play()
        A_Tween:Create(rightDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.45)
        overlay.Visible = false
        if cb then cb() end
    end

            local function closeDoors(cb)
        overlay.Visible = true
        leftDoor.Position = UDim2.new(0, -halfWidth, 0, 0)
        rightDoor.Position = UDim2.new(1, 0, 0, 0)
        -- Reset VH logo ke kondisi transparan dulu
        logoHolder.BackgroundTransparency = 1
        for _, child in ipairs(logoHolder:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextTransparency = 1
            end
        end
        A_Tween:Create(leftDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        A_Tween:Create(rightDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
        task.wait(0.38)
        -- Fade in VH logo
        A_Tween:Create(logoHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.1}):Play()
        for _, child in ipairs(logoHolder:GetChildren()) do
            if child:IsA("TextLabel") then
                A_Tween:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
            end
        end
        task.wait(0.3)
        if cb then cb() end
    end

    return {overlay = overlay, open = openDoors, close = closeDoors}
end

-- ===== CHANGELOG PANEL =====
local function a_CreateChangelogPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap)
    panelWidth = panelWidth or 220
    local isOpen = false

    local panel = Instance.new("Frame")
    panel.Name = "ChangelogPanel"
    panel.Size = UDim2.new(0, 0, 0, panelHeight)
    panel.Position = UDim2.new(1, gap, 0, 0)
    panel.BackgroundColor3 = A_Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = A_Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = A_Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = A_Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = A_Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.6
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = a_getIcon("changelog")
    panelHeaderIcon.ImageColor3 = A_Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Changelog"
    panelTitle.TextColor3 = A_Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = a_getIcon("close")
    panelClose.ImageColor3 = A_Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() A_Tween:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() A_Tween:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -55)
    scrollFrame.Position = UDim2.new(0, 0, 0, 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = A_Theme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = panel

       local isMobCL = a_isMobile()
local clPadSide  = isMobCL and 14 or 10
local clPadTopBot = isMobCL and 8  or 5
local clGap      = isMobCL and 14 or 10

local sp = Instance.new("UIPadding", scrollFrame)
sp.PaddingLeft   = UDim.new(0, clPadSide)
sp.PaddingRight  = UDim.new(0, clPadSide)
sp.PaddingTop    = UDim.new(0, clPadTopBot)
sp.PaddingBottom = UDim.new(0, clPadTopBot)

local cl = Instance.new("UIListLayout", scrollFrame)
cl.Padding = UDim.new(0, clGap)
cl.SortOrder = Enum.SortOrder.LayoutOrder
        for i, update in ipairs(A_Changelog) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.LayoutOrder = i * 2
        entry.Parent = scrollFrame

        local el = Instance.new("UIListLayout", entry)
        el.Padding = UDim.new(0, isMobCL and 8 or 5)

        local vLbl = Instance.new("TextLabel")
        vLbl.Size = UDim2.new(1, 0, 0, isMobCL and 28 or 22)
        vLbl.BackgroundTransparency = 1
        vLbl.Text = update.Version .. "  •  " .. update.Date
        vLbl.TextColor3 = A_Theme.Accent
        vLbl.TextSize = 14
        vLbl.Font = Enum.Font.ArimoBold
        vLbl.TextXAlignment = Enum.TextXAlignment.Left
        vLbl.LayoutOrder = 1
        vLbl.Parent = entry

        for j, change in ipairs(update.Changes) do
            local cLbl = Instance.new("TextLabel")
            cLbl.Size = UDim2.new(1, 0, 0, 0)
            cLbl.AutomaticSize = Enum.AutomaticSize.Y
            cLbl.BackgroundTransparency = 1
            cLbl.Text = "  •  " .. change
            cLbl.TextColor3 = A_Theme.TextDim
            cLbl.TextSize = 12
            cLbl.Font = Enum.Font.ArimoBold
            cLbl.TextXAlignment = Enum.TextXAlignment.Left
            cLbl.TextWrapped = true
            cLbl.LayoutOrder = j + 1
            cLbl.Parent = entry
        end

        if i < #A_Changelog then
            local divW = Instance.new("Frame")
            divW.Size = UDim2.new(1, 0, 0, 2)
            divW.BackgroundTransparency = 1
            divW.LayoutOrder = i * 2 + 1
            divW.Parent = scrollFrame
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 2)
            div.BackgroundColor3 = A_Theme.Divider
            div.BorderSizePixel = 0
            div.Parent = divW
        end
    end

    local function toggle(changelogIcon, container, currentContainerWidth)
        isOpen = not isOpen
        if isOpen then
            A_Tween:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            A_Tween:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            A_Tween:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, currentContainerWidth + gap + panelWidth, 0, panelHeight)}):Play()
            if changelogIcon then A_Tween:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 180}):Play() end
        else
            A_Tween:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            A_Tween:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            A_Tween:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, currentContainerWidth, 0, panelHeight)}):Play()
            if changelogIcon then A_Tween:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 0}):Play() end
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

-- ===== USER INFO PANEL =====
local function a_CreateUserInfoPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap, startOpen)
    panelWidth = panelWidth or 180
    local isOpen = startOpen or false
    local isCompact = panelHeight < 300
local isMobPanel = a_isMobile()

-- ⭐ Mobile: paksa ukuran PC-style, gak peduli compact atau nggak
local avatarSize  = (isMobPanel or not isCompact) and 52 or 42
local fieldHeight = (isMobPanel or not isCompact) and 27 or 24
local titleSize   = (isMobPanel or not isCompact) and 9  or 8
local valueSize   = (isMobPanel or not isCompact) and 11 or 10
local welcomeSize = (isMobPanel or not isCompact) and 12 or 11
local spacing     = (isMobPanel or not isCompact) and 5  or 3

    local panel = Instance.new("Frame")
    panel.Name = "UserInfoPanel"
    panel.Size = UDim2.new(0, isOpen and panelWidth or 0, 0, panelHeight)
    panel.Position = UDim2.new(0, -(gap), 0, 0)
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.BackgroundColor3 = A_Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = A_Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = isOpen and 0.4 or 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = A_Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = A_Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = A_Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.6
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = a_getIcon("user")
    panelHeaderIcon.ImageColor3 = A_Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "User Info"
    panelTitle.TextColor3 = A_Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = a_getIcon("close")
    panelClose.ImageColor3 = A_Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() A_Tween:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() A_Tween:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -55)
    contentFrame.Position = UDim2.new(0, 0, 0, 55)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = panel

    local cp = Instance.new("UIPadding", contentFrame)
    cp.PaddingLeft = UDim.new(0, 8)
    cp.PaddingRight = UDim.new(0, 8)

    local cLayout = Instance.new("UIListLayout", contentFrame)
    cLayout.Padding = UDim.new(0, spacing)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local player = A_LP

    local avatarWrapper = Instance.new("Frame")
    avatarWrapper.Size = UDim2.new(0, avatarSize + 6, 0, avatarSize + 6)
    avatarWrapper.BackgroundTransparency = 1
    avatarWrapper.LayoutOrder = 1
    avatarWrapper.Parent = contentFrame

    local avatarGlow = Instance.new("Frame")
    avatarGlow.Size = UDim2.new(1, 0, 1, 0)
    avatarGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarGlow.BackgroundColor3 = A_Theme.Accent
    avatarGlow.BackgroundTransparency = 0.5
    avatarGlow.BorderSizePixel = 0
    avatarGlow.Parent = avatarWrapper
    Instance.new("UICorner", avatarGlow).CornerRadius = UDim.new(0, 4)

    local avatarGlowStroke = Instance.new("UIStroke", avatarGlow)
    avatarGlowStroke.Color = A_Theme.Accent
    avatarGlowStroke.Thickness = 1.5
    avatarGlowStroke.Transparency = 0.3

    local avatarContainer = Instance.new("Frame")
    avatarContainer.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatarContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarContainer.BackgroundColor3 = A_Theme.Input
    avatarContainer.BorderSizePixel = 0
    avatarContainer.ClipsDescendants = true
    avatarContainer.Parent = avatarWrapper
    Instance.new("UICorner", avatarContainer).CornerRadius = UDim.new(0, 4)

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarImage.BackgroundTransparency = 1
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.Parent = avatarContainer
    pcall(function()
        local content = A_Players:GetUserThumbnailAsync(player and player.UserId or 0, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImage.Image = content
    end)

    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1, 0, 0, isCompact and 14 or 18)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Welcome, " .. (player and player.DisplayName or "User")
    welcomeLabel.TextColor3 = A_Theme.Text
    welcomeLabel.TextSize = welcomeSize
    welcomeLabel.Font = Enum.Font.ArimoBold
    welcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    welcomeLabel.LayoutOrder = 2
    welcomeLabel.Parent = contentFrame

    local divider1 = Instance.new("Frame")
    divider1.Size = UDim2.new(1, 16, 0, 2)
    divider1.Position = UDim2.new(0.5, 0, 0, 0)
    divider1.AnchorPoint = Vector2.new(0.5, 0)
    divider1.BackgroundColor3 = A_Theme.Divider
    divider1.BorderSizePixel = 0
    divider1.LayoutOrder = 3
    divider1.Parent = contentFrame

    local executorContainer = Instance.new("Frame")
    executorContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    executorContainer.BackgroundTransparency = 1
    executorContainer.LayoutOrder = 4
    executorContainer.Parent = contentFrame

    local executorTitle = Instance.new("TextLabel")
    executorTitle.Size = UDim2.new(1, 0, 0, 11)
    executorTitle.BackgroundTransparency = 1
    executorTitle.Text = "Executor"
    executorTitle.TextColor3 = A_Theme.TextDim
    executorTitle.TextSize = titleSize
    executorTitle.Font = Enum.Font.ArimoBold
    executorTitle.TextXAlignment = Enum.TextXAlignment.Left
    executorTitle.Parent = executorContainer

    local executorValue = Instance.new("TextLabel")
    executorValue.Size = UDim2.new(1, 0, 0, 14)
    executorValue.Position = UDim2.new(0, 0, 0, 11)
    executorValue.BackgroundTransparency = 1
    executorValue.Text = a_getExecutorName()
    executorValue.TextColor3 = A_Theme.Accent
    executorValue.TextSize = valueSize
    executorValue.Font = Enum.Font.ArimoBold
    executorValue.TextXAlignment = Enum.TextXAlignment.Left
    executorValue.TextTruncate = Enum.TextTruncate.AtEnd
    executorValue.Parent = executorContainer

    local deviceContainer = Instance.new("Frame")
    deviceContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    deviceContainer.BackgroundTransparency = 1
    deviceContainer.LayoutOrder = 5
    deviceContainer.Parent = contentFrame

    local deviceTitle = Instance.new("TextLabel")
    deviceTitle.Size = UDim2.new(1, 0, 0, 11)
    deviceTitle.BackgroundTransparency = 1
    deviceTitle.Text = "Device"
    deviceTitle.TextColor3 = A_Theme.TextDim
    deviceTitle.TextSize = titleSize
    deviceTitle.Font = Enum.Font.ArimoBold
    deviceTitle.TextXAlignment = Enum.TextXAlignment.Left
    deviceTitle.Parent = deviceContainer

    local deviceValue = Instance.new("TextLabel")
    deviceValue.Size = UDim2.new(1, 0, 0, 14)
    deviceValue.Position = UDim2.new(0, 0, 0, 11)
    deviceValue.BackgroundTransparency = 1
    deviceValue.Text = a_getDeviceType()
    deviceValue.TextColor3 = A_Theme.Accent
    deviceValue.TextSize = valueSize
    deviceValue.Font = Enum.Font.ArimoBold
    deviceValue.TextXAlignment = Enum.TextXAlignment.Left
    deviceValue.TextTruncate = Enum.TextTruncate.AtEnd
    deviceValue.Parent = deviceContainer

    local divider2 = Instance.new("Frame")
    divider2.Size = UDim2.new(1, 16, 0, 2)
    divider2.Position = UDim2.new(0.5, 0, 0, 0)
    divider2.AnchorPoint = Vector2.new(0.5, 0)
    divider2.BackgroundColor3 = A_Theme.Divider
    divider2.BorderSizePixel = 0
    divider2.LayoutOrder = 6
    divider2.Parent = contentFrame

    local hwidContainer = Instance.new("Frame")
    hwidContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    hwidContainer.BackgroundTransparency = 1
    hwidContainer.LayoutOrder = 7
    hwidContainer.Parent = contentFrame

    local hwidTitle = Instance.new("TextLabel")
    hwidTitle.Size = UDim2.new(1, 0, 0, 11)
    hwidTitle.BackgroundTransparency = 1
    hwidTitle.Text = "HWID"
    hwidTitle.TextColor3 = A_Theme.TextDim
    hwidTitle.TextSize = titleSize
    hwidTitle.Font = Enum.Font.ArimoBold
    hwidTitle.TextXAlignment = Enum.TextXAlignment.Left
    hwidTitle.Parent = hwidContainer

    local fullHWID = a_getHWID()
    local copyBtnSize = 18
    local dotAreaWidth = panelWidth - 16 - copyBtnSize - 6
    local hiddenDots = a_generateHiddenDots(dotAreaWidth, 5)

    local hwidValue = Instance.new("TextLabel")
    hwidValue.Size = UDim2.new(1, -(copyBtnSize + 6), 0, 14)
    hwidValue.Position = UDim2.new(0, 0, 0, 11)
    hwidValue.BackgroundTransparency = 1
    hwidValue.Text = hiddenDots
    hwidValue.TextColor3 = A_Theme.TextDim
    hwidValue.TextSize = isCompact and 9 or 10
    hwidValue.Font = Enum.Font.ArimoBold
    hwidValue.TextXAlignment = Enum.TextXAlignment.Left
    hwidValue.TextTruncate = Enum.TextTruncate.AtEnd
    hwidValue.Parent = hwidContainer

    local copyBtn = Instance.new("ImageButton")
    copyBtn.Size = UDim2.new(0, copyBtnSize, 0, copyBtnSize)
    copyBtn.Position = UDim2.new(1, 0, 0.5, 1)
    copyBtn.AnchorPoint = Vector2.new(1, 0.5)
    copyBtn.BackgroundTransparency = 1
    copyBtn.Image = a_getIcon("copy")
    copyBtn.ImageColor3 = A_Theme.TextDim
    copyBtn.ScaleType = Enum.ScaleType.Fit
    copyBtn.Parent = hwidContainer
    copyBtn.MouseEnter:Connect(function() A_Tween:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Accent}):Play() end)
    copyBtn.MouseLeave:Connect(function() A_Tween:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(fullHWID) end)
        A_Tween:Create(copyBtn, TweenInfo.new(0.1), {ImageColor3 = A_Theme.Success}):Play()
        task.delay(0.3, function() A_Tween:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)
        a_Notify("Copied", "HWID copied to clipboard", 2, "copy")
    end)

    local divider3 = Instance.new("Frame")
    divider3.Size = UDim2.new(1, 16, 0, 2)
    divider3.Position = UDim2.new(0.5, 0, 0, 0)
    divider3.AnchorPoint = Vector2.new(0.5, 0)
    divider3.BackgroundColor3 = A_Theme.Divider
    divider3.BorderSizePixel = 0
    divider3.LayoutOrder = 8
    divider3.Parent = contentFrame

    local clockContainer = Instance.new("Frame")
    clockContainer.Size = UDim2.new(1, 0, 0, isCompact and 30 or 38)
    clockContainer.BackgroundTransparency = 1
    clockContainer.LayoutOrder = 9
    clockContainer.Parent = contentFrame

    local clockRow = Instance.new("Frame")
    clockRow.Size = UDim2.new(1, 0, 0, isCompact and 18 or 22)
    clockRow.Position = UDim2.new(0.5, -8, 0, 0)
    clockRow.AnchorPoint = Vector2.new(0.5, 0)
    clockRow.BackgroundTransparency = 1
    clockRow.Parent = clockContainer

    local clockRowLayout = Instance.new("UIListLayout", clockRow)
    clockRowLayout.FillDirection = Enum.FillDirection.Horizontal
    clockRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    clockRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    clockRowLayout.Padding = UDim.new(0, isCompact and 4 or 6)

    local clockIcon = Instance.new("ImageLabel")
    clockIcon.Size = UDim2.new(0, isCompact and 14 or 16, 0, isCompact and 14 or 16)
    clockIcon.BackgroundTransparency = 1
    clockIcon.Image = a_getIcon("clock")
    clockIcon.ImageColor3 = A_Theme.Accent
    clockIcon.ScaleType = Enum.ScaleType.Fit
    clockIcon.LayoutOrder = 1
    clockIcon.Parent = clockRow

    local clockTimeLabel = Instance.new("TextLabel")
    clockTimeLabel.Size = UDim2.new(0, 0, 1, 0)
    clockTimeLabel.AutomaticSize = Enum.AutomaticSize.X
    clockTimeLabel.BackgroundTransparency = 1
    clockTimeLabel.Text = a_formatTime12()
    clockTimeLabel.TextColor3 = A_Theme.Accent
    clockTimeLabel.TextSize = isCompact and 14 or 16
    clockTimeLabel.Font = Enum.Font.ArimoBold
    clockTimeLabel.LayoutOrder = 2
    clockTimeLabel.Parent = clockRow

    local clockDateLabel = Instance.new("TextLabel")
    clockDateLabel.Size = UDim2.new(1, 0, 0, isCompact and 12 or 14)
    clockDateLabel.Position = UDim2.new(0, -8, 0, isCompact and 18 or 22)
    clockDateLabel.BackgroundTransparency = 1
    clockDateLabel.Text = a_formatDate()
    clockDateLabel.TextColor3 = A_Theme.TextDim
    clockDateLabel.TextSize = isCompact and 9 or 11
    clockDateLabel.Font = Enum.Font.ArimoBold
    clockDateLabel.TextXAlignment = Enum.TextXAlignment.Center
    clockDateLabel.Parent = clockContainer

    local clockRunning = true
    task.spawn(function()
        while clockRunning do
            if not clockTimeLabel or not clockTimeLabel.Parent then clockRunning = false break end
            clockTimeLabel.Text = a_formatTime12()
            clockDateLabel.Text = a_formatDate()
            task.wait(1)
        end
    end)
    panel.Destroying:Connect(function() clockRunning = false end)

    local function toggle(userIcon, container, baseWidth)
        isOpen = not isOpen
        if isOpen then
            A_Tween:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            A_Tween:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            A_Tween:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, baseWidth + gap + panelWidth, 0, panelHeight)}):Play()
        else
            A_Tween:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            A_Tween:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            A_Tween:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, baseWidth, 0, panelHeight)}):Play()
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

-- ===== BUILD CENTERED UI =====
local function a_BuildCenteredUI(windowWidth, windowHeight, panelHeight, userPanelWidth, changelogPanelWidth, gap, buildContent)
    local gui = buildContent.gui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, windowWidth, 0, panelHeight)
    container.Position = UDim2.new(0.5, 0, 1.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = A_Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = container
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = A_Theme.Accent
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.4

    local userPanel, toggleUserPanel, isUserOpen, userPanelActualWidth = a_CreateUserInfoPanel(container, windowWidth, panelHeight, userPanelWidth, mainFrame, gap, false)
    local changelogPanel, toggleChangelog, isChangelogOpen, changelogPanelActualWidth = a_CreateChangelogPanel(container, windowWidth, panelHeight, changelogPanelWidth, mainFrame, gap)

    local function getContainerWidth()
        local w = windowWidth
        if isUserOpen() then w = w + gap + userPanelActualWidth end
        if isChangelogOpen() then w = w + gap + changelogPanelActualWidth end
        return w
    end

    local function toggleUser(userIcon)
        local currentW = getContainerWidth()
        if isUserOpen() then
            toggleUserPanel(userIcon, container, currentW - gap - userPanelActualWidth)
        else
            toggleUserPanel(userIcon, container, currentW)
        end
    end

    local function toggleCL(changelogIcon)
        local currentW = getContainerWidth()
        if isChangelogOpen() then
            toggleChangelog(changelogIcon, container, currentW - gap - changelogPanelActualWidth)
        else
            toggleChangelog(changelogIcon, container, currentW)
        end
    end

    local function closeAllPanels(userIcon, changelogIcon, callback)
        if isChangelogOpen() then toggleCL(changelogIcon) task.wait(0.35) end
        if isUserOpen() then toggleUser(userIcon) task.wait(0.35) end
        if callback then callback() end
    end

    return {
        container = container,
        mainFrame = mainFrame,
        mainStroke = mainStroke,
        toggleUser = toggleUser,
        toggleCL = toggleCL,
        isUserOpen = isUserOpen,
        isChangelogOpen = isChangelogOpen,
        closeAllPanels = closeAllPanels
    }
end

-- ===== BUILD KEY UI (Arqel persis) =====
local function a_BuildKeyUI(onSuccess)
    local existing = A_hui:FindFirstChild("VH_KeySystem")
    if existing then existing:Destroy() end
    local existing2 = A_hui:FindFirstChild("VH_KeylessSystem")
    if existing2 then existing2:Destroy() end

    a_enableBlur()

    local mobile = a_isMobile()
    local vp = A_WS.CurrentCamera and A_WS.CurrentCamera.ViewportSize or Vector2.new(1280, 720)

        -- ⭐ UKURAN KECIL — khusus HP. PC tetap sama.
    local padding = mobile and 8 or 14
    local baseWindowHeight, windowWidth, windowHeight
    local elementHeight, buttonHeight, statusHeight
    local userPanelWidth, changelogPanelWidth, gap

    if mobile then
        -- HP: window lebih kecil lagi
        windowWidth  = math.floor(math.clamp(vp.X * 0.64, 220, 270))
        windowHeight = math.floor(math.clamp(vp.Y * 0.50, 240, 310))
        baseWindowHeight = windowHeight
        elementHeight = math.clamp(math.floor(vp.Y * 0.052), 32, 40)   -- input tipis
        buttonHeight  = math.clamp(math.floor(vp.Y * 0.043), 28, 34)   -- tombol tipis
        statusHeight  = math.clamp(math.floor(vp.Y * 0.056), 34, 44)   -- status tipis
        userPanelWidth      = math.clamp(math.floor(vp.X * 0.32), 100, 130)
        changelogPanelWidth = math.clamp(math.floor(vp.X * 0.38), 110, 150)
        gap = 6
    else
        -- PC: SAMA PERSIS seperti sebelumnya (tidak diubah)
        baseWindowHeight = 360
        windowWidth  = 400
        windowHeight = 360
        elementHeight = 56
        buttonHeight  = 42
        statusHeight  = 60
        userPanelWidth      = 180
        changelogPanelWidth = 220
        gap = 12
    end

    -- ⭐ Panel samping auto-hide kalau ruang sempit
    local function getAvailableSideSpace()
        return math.max(0, (vp.X - windowWidth) / 2 - 6)
    end
    if mobile then
    local sideSpace = getAvailableSideSpace()
    -- ⭐ Mobile: perkecil window utama dulu biar panel samping dapat ruang lebih lebar
    if sideSpace < 60 then
        -- Sempit banget → matikan panel samping (biar gak dempet)
        userPanelWidth = 0
        changelogPanelWidth = 0
    elseif sideSpace < 140 then
        -- Sedang → panel kiri saja (user info), lebih lebar dari sebelumnya
        userPanelWidth      = math.clamp(sideSpace - 8, 110, 160)
        changelogPanelWidth = 0
    else
        -- Lega → dua panel, proporsi lebih seimbang
        userPanelWidth      = math.clamp(sideSpace * 0.46, 130, 180)
        changelogPanelWidth = math.clamp(sideSpace * 0.54, 150, 200)
    end
end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VH_KeySystem"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = A_hui

    local ui = a_BuildCenteredUI(windowWidth, windowHeight, baseWindowHeight, userPanelWidth, changelogPanelWidth, gap, {gui = screenGui})
    local container = ui.container
    local mainFrame = ui.mainFrame
    local mainStroke = ui.mainStroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = A_Theme.Header
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 6)
    headerFix.Position = UDim2.new(0, 0, 1, -6)
    headerFix.BackgroundColor3 = A_Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = A_Theme.Accent
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

       -- ===== VH LOGO (3D text + lightning) — header =====
    local logoHolder = Instance.new("Frame")
    logoHolder.Name = "VHLogoHeader"
    local _logoHdr = mobile and math.clamp(math.floor(windowWidth * 0.078), 22, 28) or 30
    logoHolder.Size = UDim2.fromOffset(_logoHdr, _logoHdr)
    logoHolder.Position = UDim2.new(0, padding, 0.5, 0)
    logoHolder.AnchorPoint = Vector2.new(0, 0.5)
    logoHolder.BackgroundColor3 = A_Theme.Background
    logoHolder.BackgroundTransparency = 0.15
    logoHolder.BorderSizePixel = 0
    logoHolder.ClipsDescendants = true
    logoHolder.Parent = header

    local lhCorner = Instance.new("UICorner")
    lhCorner.CornerRadius = UDim.new(0, 6)
    lhCorner.Parent = logoHolder

    local lhStroke = Instance.new("UIStroke")
    lhStroke.Color = A_Theme.Accent
    lhStroke.Thickness = 1.5
    lhStroke.Transparency = 0.2
    lhStroke.Parent = logoHolder

    -- Shadow (depth)
    local lhShadow = Instance.new("TextLabel")
    lhShadow.Size = UDim2.fromScale(1, 1)
    lhShadow.Position = UDim2.fromOffset(1, 2)
    lhShadow.BackgroundTransparency = 1
    lhShadow.Text = "VH"
    lhShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    lhShadow.TextTransparency = 0.05
    lhShadow.Font = Enum.Font.GothamBlack
    lhShadow.TextSize = 14
    lhShadow.ZIndex = 12
    lhShadow.Parent = logoHolder

    -- Depth accent (VH accent color)
    local lhDepth = Instance.new("TextLabel")
    lhDepth.Size = UDim2.fromScale(1, 1)
    lhDepth.Position = UDim2.fromOffset(1, 1)
    lhDepth.BackgroundTransparency = 1
    lhDepth.Text = "VH"
    lhDepth.TextColor3 = A_Theme.Accent
    lhDepth.Font = Enum.Font.GothamBlack
    lhDepth.TextSize = 14
    lhDepth.ZIndex = 13
    lhDepth.Parent = logoHolder

    -- Face (white + accent stroke)
    local lhFace = Instance.new("TextLabel")
    lhFace.Size = UDim2.fromScale(1, 1)
    lhFace.BackgroundTransparency = 1
    lhFace.Text = "VH"
    lhFace.TextColor3 = A_Theme.Text
    lhFace.Font = Enum.Font.GothamBlack
    lhFace.TextSize = 14
    lhFace.TextStrokeColor3 = A_Theme.Accent
    lhFace.TextStrokeTransparency = 0
    lhFace.ZIndex = 14
    lhFace.Parent = logoHolder

    -- Lightning segments
    local lhLightningHolder = Instance.new("Frame")
    lhLightningHolder.Size = UDim2.fromScale(1, 1)
    lhLightningHolder.BackgroundTransparency = 1
    lhLightningHolder.ClipsDescendants = true
    lhLightningHolder.ZIndex = 15
    lhLightningHolder.Parent = logoHolder

    local lightningSegments = {
        {0.20, 0.15, 10, -30},
        {0.78, 0.30, 9, 35},
        {0.15, 0.55, 11, -25},
        {0.82, 0.70, 8, 30},
    }

    local lhBolts = {}
    for _, seg in ipairs(lightningSegments) do
        local bolt = Instance.new("Frame")
        bolt.AnchorPoint = Vector2.new(0.5, 0.5)
        bolt.Size = UDim2.fromOffset(1.5, seg[3])
        bolt.Position = UDim2.fromScale(seg[1], seg[2])
        bolt.Rotation = seg[4]
        bolt.BackgroundColor3 = Color3.fromRGB(170, 220, 255)
        bolt.BackgroundTransparency = 1
        bolt.BorderSizePixel = 0
        bolt.ZIndex = 16
        bolt.Parent = lhLightningHolder
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(1, 0)
        bc.Parent = bolt
        table.insert(lhBolts, bolt)
    end

    -- Lightning loop
    task.spawn(function()
        while logoHolder.Parent do
            task.wait(math.random(15, 35) / 10)
            if not logoHolder.Parent then break end
            for _, bolt in ipairs(lhBolts) do
                bolt.BackgroundTransparency = 0
                task.wait(0.05)
                bolt.BackgroundTransparency = 1
            end
            task.wait(0.08)
            for _, bolt in ipairs(lhBolts) do
                bolt.BackgroundTransparency = 0
                task.wait(0.03)
                bolt.BackgroundTransparency = 1
            end
        end
    end)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, padding + A_Appearance.IconSize.X.Offset + 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = A_Appearance.Title
    titleLabel.TextColor3 = A_Theme.Text
    titleLabel.TextSize = mobile and math.clamp(math.floor(windowWidth * 0.048), 14, 17) or 26
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local closeBtn = Instance.new("ImageButton")
    local _clSz = mobile and math.clamp(math.floor(windowWidth * 0.06), 16, 22) or 22
    closeBtn.Size = UDim2.fromOffset(_clSz, _clSz)
    closeBtn.Position = UDim2.new(1, -padding, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = a_getIcon("close")
    closeBtn.ImageColor3 = A_Theme.TextDim
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = header
    closeBtn.MouseEnter:Connect(function() A_Tween:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Error}):Play() end)
    closeBtn.MouseLeave:Connect(function() A_Tween:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)

    local contentStartY = mobile and math.clamp(math.floor(windowWidth * 0.16), 42, 52) or 60

    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.94, 0, 0, statusHeight)
    statusFrame.Position = UDim2.new(0.5, 0, 0, contentStartY)
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.BackgroundColor3 = A_Theme.Input
    statusFrame.BorderSizePixel = 0
    statusFrame.ClipsDescendants = true
    statusFrame.Parent = mainFrame
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 4)

    local statusStroke = Instance.new("UIStroke", statusFrame)
    statusStroke.Color = A_Theme.Accent
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.8

    local statusIcon = Instance.new("ImageLabel")
    local _stIco = mobile and math.clamp(math.floor(windowWidth * 0.065), 16, 22) or 24
    statusIcon.Size = UDim2.fromOffset(_stIco, _stIco)
    statusIcon.Position = UDim2.new(0, mobile and 10 or 16, 0.5, 0)
    statusIcon.AnchorPoint = Vector2.new(0, 0.5)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Image = a_getIcon("lock")
    statusIcon.ImageColor3 = A_Theme.StatusIdle
    statusIcon.ScaleType = Enum.ScaleType.Fit
    statusIcon.Parent = statusFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 1, 0)
    statusLabel.Position = UDim2.new(0, mobile and (_stIco + 16) or 52, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = A_Appearance.Subtitle
    statusLabel.TextColor3 = A_Theme.StatusIdle
    statusLabel.TextSize = mobile and math.clamp(math.floor(windowWidth * 0.034), 10, 13) or 18
    statusLabel.Font = Enum.Font.ArimoBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    statusLabel.Parent = statusFrame

    local inputStartY = contentStartY + statusHeight + 10

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.94, 0, 0, elementHeight)
    inputFrame.Position = UDim2.new(0.5, 0, 0, inputStartY)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0)
    inputFrame.BackgroundColor3 = A_Theme.Input
    inputFrame.BorderSizePixel = 0
    inputFrame.ClipsDescendants = true
    inputFrame.Parent = mainFrame
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)

    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = A_Theme.Accent
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.7

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0.5, 0)
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.TextColor3 = A_Theme.Text
    textBox.PlaceholderText = "Enter your key..."
    textBox.PlaceholderColor3 = A_Theme.TextDim
    textBox.TextSize = mobile and math.clamp(math.floor(windowWidth * 0.036), 10, 13) or 18
    textBox.Font = Enum.Font.ArimoBold
    textBox.ClearTextOnFocus = false
    textBox.TextTruncate = Enum.TextTruncate.AtEnd
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    textBox.Focused:Connect(function() A_Tween:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play() end)
    textBox.FocusLost:Connect(function() A_Tween:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.7}):Play() end)

    local dividerY = inputStartY + elementHeight + 12

    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(1, 0, 0, 3)
    dividerLine.Position = UDim2.new(0, 0, 0, dividerY)
    dividerLine.BackgroundColor3 = A_Theme.Divider
    dividerLine.BorderSizePixel = 0
    dividerLine.Parent = mainFrame

    local acquireStartY = dividerY + 15

    local function createButton(text, iconKey, isPrimary, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.75, 0, 0, buttonHeight)
        btn.Position = UDim2.new(0.5, 0, 0, yPos)
        btn.AnchorPoint = Vector2.new(0.5, 0)
        btn.BackgroundColor3 = isPrimary and A_Theme.Accent or A_Theme.Input
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = isPrimary and A_Theme.AccentHover or A_Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = isPrimary and 0.5 or 0.7

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.Parent = btn

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)

        local iconImg = Instance.new("ImageLabel")
        local _btnIco = mobile and math.clamp(math.floor(windowWidth * 0.038), 11, 15) or 18
        iconImg.Size = UDim2.fromOffset(_btnIco, _btnIco)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = a_getIcon(iconKey)
        iconImg.ImageColor3 = A_Theme.Text
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.LayoutOrder = 1
        iconImg.Parent = content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 0, 20)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = A_Theme.Text
        label.TextSize = mobile and math.clamp(math.floor(windowWidth * 0.032), 10, 12) or 15
        label.Font = Enum.Font.ArimoBold
        label.LayoutOrder = 2
        label.Parent = content

        local origColor = btn.BackgroundColor3
        local hoverColor = isPrimary and A_Theme.AccentHover or A_Theme.Accent
        btn.MouseEnter:Connect(function() A_Tween:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play() end)
        btn.MouseLeave:Connect(function() A_Tween:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = origColor}):Play() end)
        return btn
    end

    local acquireBtn = createButton("Get Key", "key", false, acquireStartY)
    local redeemBtn = createButton("Redeem Key", "shield", true, acquireStartY + buttonHeight + 5)
    local bottomY = acquireStartY + buttonHeight * 2 + 10

    local iconBtnSize = mobile and math.clamp(math.floor(windowWidth * 0.075), 22, 28) or 36
    local iconBtnGap  = mobile and math.clamp(math.floor(windowWidth * 0.022), 5, 9) or 8

    local userBtn = Instance.new("TextButton")
    userBtn.Size = UDim2.fromOffset(iconBtnSize, iconBtnSize)
    userBtn.Position = UDim2.new(0.5, -(iconBtnSize + iconBtnGap), 0, bottomY)
    userBtn.AnchorPoint = Vector2.new(0.5, 0)
    userBtn.BackgroundColor3 = A_Theme.Background
    userBtn.BorderSizePixel = 0
    userBtn.Text = ""
    userBtn.AutoButtonColor = false
    userBtn.Parent = mainFrame
    Instance.new("UICorner", userBtn).CornerRadius = UDim.new(0, 4)

    local userIcon = Instance.new("ImageLabel")
    userIcon.Size = UDim2.fromOffset(iconBtnSize * 0.5, iconBtnSize * 0.5)
    userIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    userIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    userIcon.BackgroundTransparency = 1
    userIcon.Image = a_getIcon("user")
    userIcon.ImageColor3 = A_Theme.TextDim
    userIcon.ScaleType = Enum.ScaleType.Fit
    userIcon.Parent = userBtn
    userBtn.MouseEnter:Connect(function() A_Tween:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Accent}):Play() end)
    userBtn.MouseLeave:Connect(function() A_Tween:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.fromOffset(iconBtnSize, iconBtnSize)
    discordBtn.Position = UDim2.new(0.5, 0, 0, bottomY)
    discordBtn.AnchorPoint = Vector2.new(0.5, 0)
    discordBtn.BackgroundColor3 = A_Theme.Background
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = ""
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = mainFrame
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.fromOffset(iconBtnSize * 0.5, iconBtnSize * 0.5)
    discordIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    discordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = a_getIcon("discord")
    discordIcon.ImageColor3 = A_Theme.Discord
    discordIcon.ScaleType = Enum.ScaleType.Fit
    discordIcon.Parent = discordBtn
    discordBtn.MouseEnter:Connect(function() A_Tween:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.DiscordHover}):Play() end)
    discordBtn.MouseLeave:Connect(function() A_Tween:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Discord}):Play() end)

    local changelogBtn = Instance.new("TextButton")
    changelogBtn.Size = UDim2.fromOffset(iconBtnSize, iconBtnSize)
    changelogBtn.Position = UDim2.new(0.5, iconBtnSize + iconBtnGap, 0, bottomY)
    changelogBtn.AnchorPoint = Vector2.new(0.5, 0)
    changelogBtn.BackgroundColor3 = A_Theme.Background
    changelogBtn.BorderSizePixel = 0
    changelogBtn.Text = ""
    changelogBtn.AutoButtonColor = false
    changelogBtn.Parent = mainFrame
    Instance.new("UICorner", changelogBtn).CornerRadius = UDim.new(0, 4)

    local changelogIcon = Instance.new("ImageLabel")
    changelogIcon.Size = UDim2.fromOffset(iconBtnSize * 0.5, iconBtnSize * 0.5)
    changelogIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    changelogIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    changelogIcon.BackgroundTransparency = 1
    changelogIcon.Image = a_getIcon("changelog")
    changelogIcon.ImageColor3 = A_Theme.TextDim
    changelogIcon.ScaleType = Enum.ScaleType.Fit
    changelogIcon.Parent = changelogBtn
    changelogBtn.MouseEnter:Connect(function() A_Tween:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.Text}):Play() end)
    changelogBtn.MouseLeave:Connect(function() A_Tween:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = A_Theme.TextDim}):Play() end)

    if #A_Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    local doors = a_CreateDoorOverlay(mainFrame, windowWidth, windowHeight)

    userBtn.MouseButton1Click:Connect(function() ui.toggleUser(userIcon) end)
    changelogBtn.MouseButton1Click:Connect(function() ui.toggleCL(changelogIcon) end)

    local spinConnection, dotsThread

    local function setStatus(state, customText)
        if spinConnection then spinConnection:Disconnect() spinConnection = nil statusIcon.Rotation = 0 end
        if dotsThread then task.cancel(dotsThread) dotsThread = nil end
        local color, icon, text = A_Theme.StatusIdle, a_getIcon("lock"), customText or "No key detected"
        if state == "verifying" then
            color, icon, text = A_Theme.Accent, a_getIcon("loading"), "Verifying key"
            spinConnection = A_Run.Heartbeat:Connect(function(dt)
                if statusIcon and statusIcon.Parent then statusIcon.Rotation = (statusIcon.Rotation + dt * 360) % 360
                else if spinConnection then spinConnection:Disconnect() end end
            end)
            local dots, i = {".", "..", "...", ""}, 1
            dotsThread = task.spawn(function()
                while statusLabel and statusLabel.Parent and statusLabel.Text:find("Verifying", 1, true) do
                    statusLabel.Text = text .. dots[i] i = (i % #dots) + 1 task.wait(0.4)
                end
            end)
        elseif state == "success" then color, icon, text = A_Theme.Success, a_getIcon("check"), customText or "Access Granted"
        elseif state == "error" then color, icon, text = A_Theme.Error, a_getIcon("alert"), customText or "Invalid Key" end
        A_Tween:Create(statusLabel, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        A_Tween:Create(statusIcon, TweenInfo.new(0.3), {ImageColor3 = color}):Play()
        statusLabel.Text = text statusIcon.Image = icon
    end

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.3) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        a_Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            a_disableBlur()
            A_Tween:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            A_Tween:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.4)
            screenGui:Destroy()
        end)
    end)

    -- ============================================================
    -- HANDLE REDEEM — LOGIC VRILZHUB (verifyKeyWithServer)
    -- ============================================================
    local function handleRedeem()
        local key = textBox.Text:gsub("%s+", "")
        if key == "" then a_Notify("Error", "Please enter your key", 3, "warning") return end

        setStatus("verifying")
        redeemBtn.Active = false
        task.wait(0.3)

        -- ⭐ LOGIC VRILZHUB (bukan Arqel)
        local valid, message, data = verifyKeyWithServer(key)

        redeemBtn.Active = true

        if valid then
            applyKeyInfo(data, key)
            saveKey(key)  -- simpan vrilz_key.txt + _G.VRILZ_KEY
            setStatus("success", "Access Granted")
            a_Notify("Success", "Key validated successfully!", 2, "success")
            task.wait(1)

            closeDoorsThenExit(function()
                a_disableBlur()
                A_Tween:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
                A_Tween:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.4)
                screenGui:Destroy()
                if onSuccess then onSuccess() end
            end)
        else
            setStatus("error", message or "Invalid key")
            a_Notify("Invalid", message or "Invalid key", 4, "error")
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)

    acquireBtn.MouseButton1Click:Connect(function()
        if A_Links.GetKey ~= "" then
            a_Notify("Copied", "Key link copied!", 3, "copy")
            pcall(function() setclipboard(A_Links.GetKey) end)
        else
            a_Notify("Error", "No key link set", 3, "warning")
        end
    end)

    discordBtn.MouseButton1Click:Connect(function()
        if A_Links.Discord ~= "" then
            a_Notify("Discord", "Invite link copied!", 2, "discord")
            pcall(function() setclipboard(A_Links.Discord) end)
        end
    end)

    textBox.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)

    a_setupDragging(header, container)
    A_Tween:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.6)
    doors.open(function()
        task.wait(0.2)
        ui.toggleUser(userIcon)
        if #A_Changelog > 0 then task.wait(0.3) ui.toggleCL(changelogIcon) end
    end)
end

-- ===== PUBLIC ENTRY =====
function ArqelUI.ShowKeyWindow(onSuccess)
    a_ensureIconsReady(function()
        a_BuildKeyUI(onSuccess)
    end)
end

_G.VRILZ_ArqelUI = ArqelUI

-- ============================================================
-- ⭐ KEY/PREMIUM HELPERS
-- ============================================================
local function isRealPremiumKey(keyType)
    if not keyType then return false end
    local kt = tostring(keyType):upper()
    return kt == "PREMIUM" or kt == "OWNER" or kt == "VIP"
end

local function restoreSavedKeySync()
    local savedKey = loadSavedKey()

    if not savedKey then
        Shared.KeyType = Shared.KeyType or "FREE"
        Shared.KeyExpiresAt = Shared.KeyExpiresAt or 0
        Shared.KeyValue = nil
        Shared._RealKeyType = Shared.KeyType
        Shared._RealKeyExpiresAt = Shared.KeyExpiresAt
        return
    end

    Shared.KeyValue = savedKey
    local valid, message, data, isNetworkError = verifySavedKeyWithServer(savedKey)

    if valid and data then
        applyKeyInfo(data, savedKey)
        Shared._RealKeyType = Shared.KeyType
        Shared._RealKeyExpiresAt = Shared.KeyExpiresAt or 0
        return
    end

    if data and type(data) == "table" then
        local expiresAt = tonumber(data.expires_at or data.expiry or 0) or 0
        if expiresAt > 0 then
            local nowMs = os.time() * 1000
            if expiresAt <= nowMs then
                clearSavedKey()
                Shared.KeyType = "FREE"
                Shared.KeyExpiresAt = 0
                Shared._RealKeyType = "FREE"
                Shared._RealKeyExpiresAt = 0
                return
            end
        end
    end

    if isNetworkError then
        Shared.KeyType = Shared.KeyType or "PREMIUM"
        Shared.KeyExpiresAt = Shared.KeyExpiresAt or 0
        Shared._RealKeyType = Shared.KeyType
        Shared._RealKeyExpiresAt = Shared.KeyExpiresAt or 0
        return
    end

    clearSavedKey()
    Shared.KeyType = "FREE"
    Shared.KeyExpiresAt = 0
    Shared._RealKeyType = "FREE"
    Shared._RealKeyExpiresAt = 0
end

-- ============================================================
-- UI.INIT
-- ============================================================
function UI.Init(sharedState)
    Shared = sharedState
    Shared.Notify = notify
    _G.VRILZ_UI_Shared = Shared

    Shared.AntiAFK_Enabled = true
    Shared.FPSBoost_Enabled = false
    Shared.LightsEffect_Enabled = true
    Shared.HD4K_Enabled = false
    Shared.ShowTitle = true 
    Shared.AutoBuy_Enabled = false
    Shared.AutoUpgradeStand_Enabled = false

    -- Live Chat state
    Shared.LiveChat_Messages = {}
    Shared.LiveChat_MaxMessages = CFG.CHAT_MAX_MSG
    Shared.LiveChat_PollInterval = 1.5

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VRILZHUB_RideAPet"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = game:GetService("CoreGui")

    -- ⭐ PRELOAD TAB ICONS (biar gak blank pas pertama launch)
task.spawn(function()
    local preloads = {
        "rbxassetid://129516985087314",  -- Info
        "rbxassetid://75410123129821",   -- Auto Throw
        "rbxassetid://101498199599518",  -- Shop
        "rbxassetid://83047761221446",   -- Live Chat
        "rbxassetid://97834340359225",   -- Settings
    }
        pcall(function()
            game:GetService("ContentProvider"):PreloadAsync(preloads)
        end)
    end)

    setupNotifHolder(ScreenGui)
    setupDropdownLayer(ScreenGui)

    -- ⭐ Start presence tracking
    task.spawn(function()
        task.wait(2)
        pcall(function() _G.VRILZ_Presence.Start() end)
    end)

    -- Auto-start chat polling (biar selalu nyambung)
    task.spawn(function()
        task.wait(2)
        pcall(function()
            if _G.VRILZ_ChatClient and _G.VRILZ_ChatClient.start then
                _G.VRILZ_ChatClient.start()
            end
        end)
    end)

    local function startLoading()
        buildLoadingScreen(ScreenGui)
    end

        local function showKeyWindow()
        ArqelUI.ShowKeyWindow(function()
            startLoading()
        end)
    end

        -- Load custom title dari save file
    task.spawn(function()
        task.wait(1)
        local savedTitle = loadCustomTitle()
        if savedTitle then
        end
        task.wait(1)
        if _G.VRILZ_RefreshTitle then
            _G.VRILZ_RefreshTitle()
        end
    end)

    -- ============================================================
    -- ⭐ STARTUP (RINGKAS — panggil helper di luar)
    -- ============================================================
    restoreSavedKeySync()

-- ⚡ SKIP KEY SYSTEM (tetap seperti sekarang)
if true then
    Shared.KeyType = "FREE"
    Shared.KeyExpiresAt = 0
    startLoading()
else
    local hasRealPremium = isRealPremiumKey(Shared._RealKeyType)
    local savedKeyNow = loadSavedKey()
    local hasValidSavedKey = savedKeyNow ~= nil
        and (Shared.KeyType == "FREE"
            or Shared.KeyType == "PREMIUM"
            or Shared.KeyType == "VIP"
            or Shared.KeyType == "OWNER")

    if hasRealPremium or hasValidSavedKey then
        Shared.KeyType = Shared._RealKeyType
        Shared.KeyExpiresAt = Shared._RealKeyExpiresAt or 0
        startLoading()
    else
        Shared.KeyType = "FREE"
        Shared.KeyExpiresAt = 0
        showKeyWindow()
      end
   end
end

return UI
