--//======================================================
--//                    GUASTI SCRIPTS v30
--//   TUDO incluído: 45+ features + visuais profissionais
--//======================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")

if _G.GuastiCleanup then pcall(_G.GuastiCleanup); _G.GuastiCleanup = nil end

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

pcall(function()
    local old = CoreGui:FindFirstChild("GuastiGUI")
    if old then old:Destroy() end
    local oldFolder = Workspace:FindFirstChild("GuastiESPFolder")
    if oldFolder then oldFolder:Destroy() end
end)

local espFolder = Instance.new("Folder")
espFolder.Name = "GuastiESPFolder"
espFolder.Parent = Workspace

local CONFIG_FILE = "GuastiConfig.json"
local PRESETS_FILE = "GuastiPresets.json"

local TrackedConnections = {}
local function Track(conn)
    table.insert(TrackedConnections, conn)
    return conn
end

local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
}

local originalEffects = {}
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") then
        table.insert(originalEffects, {effect = effect, enabled = effect.Enabled})
    end
end

-- =========================================================
-- SETTINGS
-- =========================================================
local Settings = {
    -- Menu
    MenuKey = Enum.KeyCode.P,
    HideMenuKey = Enum.KeyCode.Insert,
    -- Aimbot
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.Q,
    AimPart = "Head",
    FOV = 120,
    FOVInner = 40,
    FOVDoubleEnabled = false,
    MaxDistance = 500,
    WallCheck = false,
    TeamCheck = false,
    Smoothness = 0,
    FOVVisible = false,
    FOVColor = Color3.fromRGB(255,255,255),
    FOVInnerColor = Color3.fromRGB(255,100,100),
    FOVTransparency = 1,
    FOVStateColor = false,
    PredictionEnabled = false,
    Prediction = 20,
    PredictVisual = false,
    AimbotTargetLine = false,
    AimAssistEnabled = false,
    AimAssistStrength = 20,
    SilentAimEnabled = false,
    SilentAimFOV = 15,
    -- Trigger Bot
    TriggerBotEnabled = false,
    TriggerBotKey = Enum.KeyCode.E,
    TriggerBotAutoFire = false,
    -- Sons
    HitSoundEnabled = false,
    HitSoundId = "rbxassetid://6042053626",
    KillSoundEnabled = false,
    KillSoundId = "rbxassetid://6042053626",
    -- ESP
    ESPEnabled = false,
    ESPTeamCheck = false,
    ESPLine = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPChams = false,
    ESPSkeleton = false,
    ESPSkeleton3D = false,
    ESPName = false,
    ESPBox = false,
    ESPBoxHorizontal = false,
    ESPBoxHealth = false,
    ESPWeapon = false,
    ESPDistanceInName = false,
    ESPRainbow = false,
    ESPDistanceColor = false,
    ESPAnimated = false,
    ESPMaxDistance = 1000,
    ESPLineColor = Color3.fromRGB(255,255,255),
    ESPNameColor = Color3.fromRGB(255,255,255),
    ESPHealthColor = Color3.fromRGB(80,255,80),
    ESPSkeletonColor = Color3.fromRGB(255,255,255),
    ESPBoxColor = Color3.fromRGB(255,80,80),
    -- Movimento
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    WalkspeedEnabled = false,
    WalkspeedValue = 16,
    AntiFlingEnabled = false,
    InfiniteJumpEnabled = false,
    AntiStunEnabled = false,
    InfiniteAmmoEnabled = false,
    BhopEnabled = false,
    SpeedBoostFallEnabled = false,
    SpeedBoostFallValue = 100,
    -- Visual
    FullbrightEnabled = false,
    FullbrightBrightness = 2,
    FPSBoostEnabled = false,
    AntiVoidEnabled = false,
    AntiVoidHeight = -50,
    TrailEnabled = false,
    TrailColor = Color3.fromRGB(255,100,220),
    -- Teleporte
    ClickTPEnabled = false,
    TPSmooth = true,
    TPSmoothSpeed = 0.3,
    Waypoints = {},
    WaypointsPerGame = {},
    -- Extras
    AntiAFKEnabled = false,
    AntiAFKEnhanced = false,
    SoundNotificationsEnabled = false,
    CustomSoundId = "",
    PlayerListEnabled = false,
    PlayerListSize = 210,
    WatermarkEnabled = false,
    WatermarkRGB = false,
    CrosshairEnabled = false,
    CrosshairSize = 10,
    CrosshairColor = Color3.fromRGB(0,255,0),
    FpsCounterEnabled = false,
    FpsAdvanced = false,
    PingCounterEnabled = false,
    RadarEnabled = false,
    RadarRange = 500,
    RadarSize = 130,
    ConsoleEnabled = false,
    ConsoleSize = 200,
    AutoClickerEnabled = false,
    AutoClickerInterval = 0.1,
    KillNotifierEnabled = false,
    JoinLeaveNotifierEnabled = false,
    DebugModeEnabled = false,
    -- Waypoints GUI
    AutoUpdaterEnabled = false,
    ConfirmCloseEnabled = true,
    GuiAnimationsEnabled = true,
    AntiBanEnabled = false,
    -- Internos
    IgnoredPlayers = {},
    Keybinds = {Fly=nil, Noclip=nil, Walkspeed=nil, ESP=nil, ClickTP=nil, TPPlayer=nil, TriggerBot=nil},
}

-- =========================================================
-- DRAWING OBJECTS
-- =========================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = Settings.FOVColor
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local FOVInnerCircle = Drawing.new("Circle")
FOVInnerCircle.Visible = false
FOVInnerCircle.Radius = Settings.FOVInner
FOVInnerCircle.Thickness = 1.5
FOVInnerCircle.Color = Settings.FOVInnerColor
FOVInnerCircle.Transparency = 1
FOVInnerCircle.Filled = false

local PredictDot = Drawing.new("Circle")
PredictDot.Visible = false
PredictDot.Radius = 4
PredictDot.Thickness = 2
PredictDot.Color = Color3.fromRGB(255,50,50)
PredictDot.Transparency = 1
PredictDot.Filled = true

local TargetLine = Drawing.new("Line")
TargetLine.Visible = false
TargetLine.Thickness = 2
TargetLine.Color = Color3.fromRGB(255,50,50)
TargetLine.Transparency = 1

local crossLines = {}
for i = 1, 2 do
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    l.Color = Settings.CrosshairColor
    l.Transparency = 1
    crossLines[i] = l
end

-- =========================================================
-- STATE VARIABLES
-- =========================================================
local toggleKey = Settings.MenuKey
local isWaitingForKey = false
local isMinimized = false
local normalSize = UDim2.new(0, 500, 0, 400)
local isOpen = true
local ESPObjects = {}
local waitingForAimbotKey = false
local waitingTriggerKey = false
local waitingHideMenuKey = false
local waitingKeybind = nil
local statusLabel, watermarkLabel, fpsLabel, pingLabel
local ToggleRefs = {}
local AllToggles = {}
local ToggleRegistry = {}
local SliderRegistry = {}
local InputRegistry = {}
local hiddenMode = false
local keybindRows = {}
local isCleanedUp = false
local colorTarget = "Line"
local currentHue = 0
local animatedESPPhase = 0
local lastHitCheck = 0
local lastKillCheck = 0
local playerJoinTimes = {}
local sessionFpsMin = 999
local sessionFpsMax = 0
local sessionFpsSum = 0
local sessionFpsCount = 0
local autoClickerActive = false
local killCount = 0
local deathCount = 0
local lastHealth = {}

print("[Guasti] Parte 1/5 carregada. Cole a parte 2 abaixo.")

-- =========================================================
-- TEMAS
-- =========================================================
local themes = {
    {name="Preto (Padrão)", bg=Color3.fromRGB(15,15,15), top=Color3.fromRGB(25,25,25), accent=Color3.fromRGB(80,150,255)},
    {name="Cinza Escuro", bg=Color3.fromRGB(28,28,30), top=Color3.fromRGB(40,40,43), accent=Color3.fromRGB(120,120,130)},
    {name="Azul Noturno", bg=Color3.fromRGB(18,22,30), top=Color3.fromRGB(28,36,50), accent=Color3.fromRGB(80,150,255)},
    {name="Roxo Escuro", bg=Color3.fromRGB(25,18,32), top=Color3.fromRGB(42,28,55), accent=Color3.fromRGB(180,100,255)},
    {name="Verde Militar", bg=Color3.fromRGB(22,30,22), top=Color3.fromRGB(35,48,35), accent=Color3.fromRGB(100,220,100)},
    {name="Vermelho Sombrio", bg=Color3.fromRGB(32,18,18), top=Color3.fromRGB(52,28,28), accent=Color3.fromRGB(255,80,80)},
    {name="Rosa Neon", bg=Color3.fromRGB(32,18,28), top=Color3.fromRGB(55,28,48), accent=Color3.fromRGB(255,100,220)},
    {name="Ciano Escuro", bg=Color3.fromRGB(16,28,32), top=Color3.fromRGB(25,42,50), accent=Color3.fromRGB(60,230,255)},
    {name="Laranja Quente", bg=Color3.fromRGB(32,22,15), top=Color3.fromRGB(52,35,25), accent=Color3.fromRGB(255,140,60)},
    {name="Cinza Chumbo", bg=Color3.fromRGB(35,35,38), top=Color3.fromRGB(50,50,55), accent=Color3.fromRGB(180,180,200)},
    {name="Cyberpunk", bg=Color3.fromRGB(12,10,25), top=Color3.fromRGB(25,15,45), accent=Color3.fromRGB(0,255,255)},
    {name="Minecraft", bg=Color3.fromRGB(30,35,25), top=Color3.fromRGB(45,55,35), accent=Color3.fromRGB(120,180,80)},
}
local currentThemeIndex = 1

-- =========================================================
-- ÍCONES (emoji por palavra-chave)
-- =========================================================
local function GetIcon(name)
    local n = name:lower()
    if n:find("aimbot") then return "🎯" end
    if n:find("esp") and not n:find("mostrar") then return "👁️" end
    if n:find("fly") then return "✈️" end
    if n:find("noclip") then return "👻" end
    if n:find("speed") or n:find("walkspeed") then return "⚡" end
    if n:find("jump") then return "🦘" end
    if n:find("god") then return "🛡️" end
    if n:find("infinite") then return "♾️" end
    if n:find("anti") then return "🛡️" end
    if n:find("fullbright") then return "💡" end
    if n:find("fps") then return "📊" end
    if n:find("ping") then return "📡" end
    if n:find("radar") then return "📡" end
    if n:find("watermark") then return "🏷️" end
    if n:find("console") then return "💻" end
    if n:find("crosshair") then return "➕" end
    if n:find("trail") then return "✨" end
    if n:find("waypoint") then return "📍" end
    if n:find("server") or n:find("rejoin") then return "🌐" end
    if n:find("team") then return "👥" end
    if n:find("wall") then return "🧱" end
    if n:find("line") then return "📏" end
    if n:find("health") or n:find("vida") then return "❤️" end
    if n:find("distance") or n:find("dist") then return "📐" end
    if n:find("box") then return "⬜" end
    if n:find("cham") then return "🎨" end
    if n:find("skeleton") or n:find("esqueleto") then return "🦴" end
    if n:find("name") or n:find("nome") then return "📛" end
    if n:find("weapon") or n:find("arma") then return "🔫" end
    if n:find("rainbow") then return "🌈" end
    if n:find("sound") or n:find("som") then return "🔊" end
    if n:find("target") or n:find("predict") then return "🎯" end
    if n:find("silent") then return "🔇" end
    if n:find("assist") then return "🤝" end
    if n:find("auto") then return "🤖" end
    if n:find("kill") then return "💀" end
    if n:find("hit") then return "💥" end
    if n:find("join") or n:find("leave") then return "🚪" end
    if n:find("player") then return "👤" end
    if n:find("theme") or n:find("tema") then return "🎨" end
    if n:find("save") or n:find("salvar") then return "💾" end
    if n:find("load") or n:find("carregar") then return "📂" end
    if n:find("reset") then return "🔄" end
    if n:find("close") or n:find("fechar") then return "❌" end
    if n:find("trigger") then return "🔫" end
    if n:find("menu") or n:find("tecla") then return "⌨️" end
    if n:find("color") or n:find("cor") then return "🎨" end
    return "•"
end

-- =========================================================
-- SOM DE NOTIFICAÇÃO
-- =========================================================
local notifSound = Instance.new("Sound")
notifSound.SoundId = "rbxassetid://6042053626"
notifSound.Volume = 0.35
notifSound.Parent = CoreGui

local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://6042053626"
hitSound.Volume = 0.5
hitSound.Parent = CoreGui

local killSound = Instance.new("Sound")
killSound.SoundId = "rbxassetid://6042053626"
killSound.Volume = 0.6
killSound.Parent = CoreGui

-- =========================================================
-- GUI BASE (com sombra, gradiente e header)
-- =========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GuastiGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- Sombra 3D (Frame atrás da janela)
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.Size = normalSize
shadowFrame.Position = UDim2.new(1, -normalSize.X.Offset - 16, 0, 24)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadowFrame.BackgroundTransparency = 0.6
shadowFrame.BorderSizePixel = 0
shadowFrame.ZIndex = 0
shadowFrame.Parent = screenGui
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0,10)
shadowCorner.Parent = shadowFrame

-- Janela principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = normalSize
mainFrame.Position = UDim2.new(1, -normalSize.X.Offset - 20, 0, 20)
mainFrame.BackgroundColor3 = themes[currentThemeIndex].bg
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
mainFrame.Visible = false
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,10)
mainCorner.Parent = mainFrame

-- Gradiente sutil no fundo
local bgGradient = Instance.new("UIGradient")
bgGradient.Rotation = 90
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, themes[currentThemeIndex].bg),
    ColorSequenceKeypoint.new(1, themes[currentThemeIndex].top),
})
bgGradient.Parent = mainFrame

-- Borda com gradiente
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = themes[currentThemeIndex].accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

-- TopBar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1,0,0,32)
topBar.BackgroundColor3 = themes[currentThemeIndex].top
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,10)
topCorner.Parent = topBar

local topBarExt = Instance.new("Frame")
topBarExt.Size = UDim2.new(1,0,0,6)
topBarExt.Position = UDim2.new(0,0,1,-6)
topBarExt.BackgroundColor3 = themes[currentThemeIndex].top
topBarExt.BorderSizePixel = 0
topBarExt.Parent = topBar

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,140,1,0)
title.Position = UDim2.new(0,36,0,0)
title.BackgroundTransparency = 1
title.Text = "Guasti Scripts"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Logo (letra G em círculo)
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0,22,0,22)
logoFrame.Position = UDim2.new(0,8,0.5,-11)
logoFrame.BackgroundColor3 = themes[currentThemeIndex].accent
logoFrame.BorderSizePixel = 0
logoFrame.Parent = topBar
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1,0)
logoCorner.Parent = logoFrame
local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1,0,1,0)
logoText.BackgroundTransparency = 1
logoText.Text = "G"
logoText.TextColor3 = Color3.fromRGB(255,255,255)
logoText.TextSize = 14
logoText.Font = Enum.Font.GothamBlack
logoText.Parent = logoFrame

-- Bandeira BR
local flagContainer = Instance.new("Frame")
flagContainer.Size = UDim2.new(0,22,0,14)
flagContainer.AnchorPoint = Vector2.new(0,0.5)
flagContainer.Position = UDim2.new(0,182,0.5,0)
flagContainer.BackgroundColor3 = Color3.fromRGB(0,156,59)
flagContainer.BorderSizePixel = 0
flagContainer.ClipsDescendants = true
flagContainer.Parent = topBar
local flagCorner = Instance.new("UICorner")
flagCorner.CornerRadius = UDim.new(0,2)
flagCorner.Parent = flagContainer
local diamond = Instance.new("Frame")
diamond.Size = UDim2.new(0,9,0,9)
diamond.AnchorPoint = Vector2.new(0.5,0.5)
diamond.Position = UDim2.new(0.5,0,0.5,0)
diamond.BackgroundColor3 = Color3.fromRGB(255,223,0)
diamond.BorderSizePixel = 0
diamond.Rotation = 45
diamond.Parent = flagContainer
local flagCircle = Instance.new("Frame")
flagCircle.Size = UDim2.new(0,4,0,4)
flagCircle.AnchorPoint = Vector2.new(0.5,0.5)
flagCircle.Position = UDim2.new(0.5,0,0.5,0)
flagCircle.BackgroundColor3 = Color3.fromRGB(0,39,118)
flagCircle.BorderSizePixel = 0
flagCircle.Parent = flagContainer
local flagCircleCorner = Instance.new("UICorner")
flagCircleCorner.CornerRadius = UDim.new(1,0)
flagCircleCorner.Parent = flagCircle

-- Botão fechar (com hover)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-32,0,2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

-- Botão minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,28,0,28)
minimizeBtn.Position = UDim2.new(1,-62,0,2)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar

-- Área de conteúdo
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,0,1,-32)
contentFrame.Position = UDim2.new(0,0,0,32)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0,110,1,-20)
tabContainer.Position = UDim2.new(0,10,0,10)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = contentFrame

local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1,-140,1,-20)
pagesContainer.Position = UDim2.new(0,130,0,10)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = contentFrame

-- Footer com versão
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,-20,0,14)
footer.Position = UDim2.new(0,10,1,-18)
footer.BackgroundTransparency = 1
footer.Text = "v30 • feito por indexcreator"
footer.TextColor3 = Color3.fromRGB(90,90,90)
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = mainFrame

print("[Guasti] Parte 2/5 carregada. Cole a parte 3 abaixo.")

-- =========================================================
-- TABS (criadas com animação + hover)
-- =========================================================
local function CreateTabButton(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. name
    btn.Size = UDim2.new(1,0,0,35)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,38)
    btn.BackgroundTransparency = 0.3
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180,180,180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = tabContainer
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn

    btn.MouseEnter:Connect(function()
        if Settings.GuiAnimationsEnabled and btn.BackgroundTransparency > 0.05 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.1}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if Settings.GuiAnimationsEnabled and btn.BackgroundTransparency > 0.05 then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.3}):Play()
        end
    end)

    return btn
end

local function CreatePage(h)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = themes[currentThemeIndex].accent
    p.Visible = false
    p.CanvasSize = UDim2.new(0,0,0,h or 500)
    p.Parent = pagesContainer
    return p
end

local tab1Btn = CreateTabButton("🎯 Aimbot", 0)
local tab2Btn = CreateTabButton("👁️ ESP", 45)
local tab3Btn = CreateTabButton("⚙️ Outros", 90)
local tab4Btn = CreateTabButton("🔧 Config", 135)
local tab5Btn = CreateTabButton("🎮 Presets", 180)

local page1 = CreatePage(900)
local page2 = CreatePage(1400)
local page3 = CreatePage(1400)
local page4 = CreatePage(1300)
local page5 = CreatePage(500)

page1.Visible = true
tab1Btn.BackgroundColor3 = Color3.fromRGB(60,60,65)
tab1Btn.BackgroundTransparency = 0
tab1Btn.TextColor3 = Color3.fromRGB(255,255,255)

local function SwitchTab(sb, sp)
    for _, c in ipairs(tabContainer:GetChildren()) do
        if c:IsA("TextButton") then
            c.BackgroundColor3 = Color3.fromRGB(35,35,38)
            c.BackgroundTransparency = 0.3
            c.TextColor3 = Color3.fromRGB(180,180,180)
        end
    end
    for _, c in ipairs(pagesContainer:GetChildren()) do
        if c:IsA("GuiObject") then c.Visible = false end
    end
    sb.BackgroundColor3 = themes[currentThemeIndex].accent
    sb.BackgroundTransparency = 0
    sb.TextColor3 = Color3.fromRGB(255,255,255)
    sp.Visible = true
end

tab1Btn.MouseButton1Click:Connect(function() SwitchTab(tab1Btn, page1) end)
tab2Btn.MouseButton1Click:Connect(function() SwitchTab(tab2Btn, page2) end)
tab3Btn.MouseButton1Click:Connect(function() SwitchTab(tab3Btn, page3) end)
tab4Btn.MouseButton1Click:Connect(function() SwitchTab(tab4Btn, page4) end)
tab5Btn.MouseButton1Click:Connect(function() SwitchTab(tab5Btn, page5) end)

-- =========================================================
-- CONSOLE LOG (arrastável + tamanho configurável)
-- =========================================================
local consoleFrame = Instance.new("Frame")
consoleFrame.Name = "Console"
consoleFrame.Size = UDim2.new(0,300,0,200)
consoleFrame.Position = UDim2.new(0,10,0,10)
consoleFrame.BackgroundColor3 = Color3.fromRGB(12,12,14)
consoleFrame.BackgroundTransparency = 0.1
consoleFrame.BorderSizePixel = 0
consoleFrame.Visible = false
consoleFrame.Active = true
consoleFrame.ZIndex = 350
consoleFrame.Parent = screenGui
local cfc = Instance.new("UICorner"); cfc.CornerRadius = UDim.new(0,8); cfc.Parent = consoleFrame
local cfs = Instance.new("UIStroke"); cfs.Color = themes[currentThemeIndex].accent; cfs.Thickness = 1.5; cfs.Parent = consoleFrame

local consoleHeader = Instance.new("Frame")
consoleHeader.Size = UDim2.new(1,0,0,24)
consoleHeader.BackgroundColor3 = Color3.fromRGB(25,25,30)
consoleHeader.BorderSizePixel = 0
consoleHeader.ZIndex = 351
consoleHeader.Parent = consoleFrame
local chc = Instance.new("UICorner"); chc.CornerRadius = UDim.new(0,8); chc.Parent = consoleHeader

local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1,-60,1,0)
consoleTitle.Position = UDim2.new(0,10,0,0)
consoleTitle.BackgroundTransparency = 1
consoleTitle.Text = "💻 Console"
consoleTitle.TextColor3 = Color3.fromRGB(255,255,255)
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.TextSize = 12
consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
consoleTitle.ZIndex = 352
consoleTitle.Parent = consoleHeader

local consoleClear = Instance.new("TextButton")
consoleClear.Size = UDim2.new(0,24,1,0)
consoleClear.Position = UDim2.new(1,-28,0,0)
consoleClear.BackgroundTransparency = 1
consoleClear.Text = "🗑"
consoleClear.TextColor3 = Color3.fromRGB(255,100,100)
consoleClear.TextSize = 12
consoleClear.Font = Enum.Font.GothamBold
consoleClear.ZIndex = 352
consoleClear.Parent = consoleHeader

local consoleScroll = Instance.new("ScrollingFrame")
consoleScroll.Size = UDim2.new(1,-10,1,-30)
consoleScroll.Position = UDim2.new(0,5,0,28)
consoleScroll.BackgroundTransparency = 1
consoleScroll.BorderSizePixel = 0
consoleScroll.ScrollBarThickness = 3
consoleScroll.CanvasSize = UDim2.new(0,0,0,0)
consoleScroll.ZIndex = 351
consoleScroll.Parent = consoleFrame

consoleClear.MouseButton1Click:Connect(function()
    for _, c in ipairs(consoleScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    consoleScroll.CanvasSize = UDim2.new(0,0,0,0)
end)

-- Drag do console
local consoleDrag, consoleDS, consoleSP
consoleHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        consoleDrag = true
        consoleDS = input.Position
        consoleSP = consoleFrame.Position
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if consoleDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - consoleDS
        consoleFrame.Position = UDim2.new(consoleSP.X.Scale, consoleSP.X.Offset + d.X, consoleSP.Y.Scale, consoleSP.Y.Offset + d.Y)
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then consoleDrag = false end
end))

local function Log(text, color)
    if not Settings.ConsoleEnabled then return end
    color = color or Color3.fromRGB(200,200,200)
    local l = Instance.new("TextLabel")
    local n = #consoleScroll:GetChildren()
    l.Size = UDim2.new(1,-8,0,16)
    l.Position = UDim2.new(0,4,0,n*16)
    l.BackgroundTransparency = 1
    l.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
    l.TextColor3 = color
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 352
    l.Parent = consoleScroll
    consoleScroll.CanvasSize = UDim2.new(0,0,0,(n+1)*16+5)
    consoleScroll.CanvasPosition = Vector2.new(0, consoleScroll.AbsoluteCanvasSize.Y)
    if n > 80 then consoleScroll:GetChildren()[1]:Destroy() end
end

-- =========================================================
-- SOM DE NOTIFICAÇÃO
-- =========================================================
local function PlayNotifSound(isOn)
    if not Settings.SoundNotificationsEnabled then return end
    if Settings.CustomSoundId ~= "" then
        local id = Settings.CustomSoundId
        if not id:match("^rbxassetid://") then id = "rbxassetid://" .. id:gsub("%D","") end
        notifSound.SoundId = id
    else
        notifSound.SoundId = "rbxassetid://6042053626"
    end
    notifSound.PlaybackSpeed = isOn and 1 or 0.7
    notifSound:Play()
end

local function PlayHitSound()
    if not Settings.HitSoundEnabled then return end
    local id = Settings.HitSoundId
    if not id:match("^rbxassetid://") then id = "rbxassetid://" .. id:gsub("%D","") end
    hitSound.SoundId = id
    hitSound:Play()
end

local function PlayKillSound()
    if not Settings.KillSoundEnabled then return end
    local id = Settings.KillSoundId
    if not id:match("^rbxassetid://") then id = "rbxassetid://" .. id:gsub("%D","") end
    killSound.SoundId = id
    killSound:Play()
end

-- =========================================================
-- NOTIFICAÇÃO COM EMOJI + EMPILHAMENTO
-- =========================================================
local notifStack = {}
local function Notify(text, color)
    color = color or themes[currentThemeIndex].accent
    Log(text, color)

    -- Ajusta pilha
    local stackHeight = 0
    for _, existing in ipairs(notifStack) do
        stackHeight = stackHeight + 50
    end

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0,300,0,42)
    n.Position = UDim2.new(0.5, -150, 0, 30 + stackHeight)
    n.BackgroundColor3 = themes[currentThemeIndex].bg
    n.BackgroundTransparency = 0.15
    n.TextColor3 = Color3.fromRGB(255,255,255)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 15
    n.Text = text
    n.TextTransparency = 1
    n.ZIndex = 500
    n.Parent = screenGui
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,8); nc.Parent = n
    local ns = Instance.new("UIStroke"); ns.Color = color; ns.Thickness = 2; ns.Transparency = 1; ns.Parent = n

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1,0,0,3)
    progressBg.Position = UDim2.new(0,0,1,-3)
    progressBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 501
    progressBg.Parent = n
    local pbc = Instance.new("UICorner"); pbc.CornerRadius = UDim.new(0,3); pbc.Parent = progressBg

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1,0,1,0)
    progressBar.BackgroundColor3 = color
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 502
    progressBar.Parent = progressBg
    local pbc2 = Instance.new("UICorner"); pbc2.CornerRadius = UDim.new(0,3); pbc2.Parent = progressBar

    table.insert(notifStack, n)

    TweenService:Create(n, TweenInfo.new(0.3), {TextTransparency=0, BackgroundTransparency=0.15}):Play()
    TweenService:Create(ns, TweenInfo.new(0.3), {Transparency=0}):Play()
    TweenService:Create(progressBar, TweenInfo.new(2), {Size=UDim2.new(0,0,1,0)}):Play()
    PlayNotifSound(color.G > color.R)

    task.delay(2.2, function()
        if not n or not n.Parent then return end
        local t1 = TweenService:Create(n, TweenInfo.new(0.4), {TextTransparency=1, BackgroundTransparency=1})
        local t2 = TweenService:Create(ns, TweenInfo.new(0.4), {Transparency=1})
        t1:Play(); t2:Play()
        t1.Completed:Connect(function()
            for i, existing in ipairs(notifStack) do
                if existing == n then
                    table.remove(notifStack, i)
                    break
                end
            end
            if n then n:Destroy() end
        end)
    end)
end

-- =========================================================
-- FPS BOOST + SMOOTH TP
-- =========================================================
local function ApplyFPSBoost(state)
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") and e.Enabled then e.Enabled = false end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                o.Enabled = false
            elseif o:IsA("Decal") or o:IsA("Texture") then
                o.Transparency = 1
            end
        end
    else
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.FogEnd = originalLighting.FogEnd
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then
                for _, o in ipairs(originalEffects) do
                    if o.effect == e then e.Enabled = o.enabled; break end
                end
            end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                pcall(function() o.Enabled = true end)
            elseif o:IsA("Decal") or o:IsA("Texture") then
                pcall(function() o.Transparency = 0 end)
            end
        end
    end
end

local function SmoothTeleport(targetCFrame)
    if not Settings.TPSmooth then
        local ch = player.Character
        local rt = ch and ch:FindFirstChild("HumanoidRootPart")
        if rt then rt.CFrame = targetCFrame end
        return
    end
    local ch = player.Character
    local rt = ch and ch:FindFirstChild("HumanoidRootPart")
    if not rt then return end
    local startCF = rt.CFrame
    local startT = tick()
    task.spawn(function()
        while tick() - startT < Settings.TPSmoothSpeed do
            if isCleanedUp then return end
            local alpha = math.clamp((tick() - startT) / Settings.TPSmoothSpeed, 0, 1)
            pcall(function() rt.CFrame = startCF:Lerp(targetCFrame, alpha) end)
            task.wait()
        end
        pcall(function() rt.CFrame = targetCFrame end)
    end)
end

local function GetRainbowColor()
    currentHue = (currentHue + 0.008) % 1
    return Color3.fromHSV(currentHue, 1, 1)
end

print("[Guasti] Parte 3/5 carregada. Cole a parte 4 abaixo.")

-- =========================================================
-- POPUP BASE (arrastável, com header e X)
-- =========================================================
local function CreatePopup(headerText)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0,300,0,360)
    p.BackgroundColor3 = themes[currentThemeIndex].bg
    p.BorderSizePixel = 0
    p.Visible = false
    p.ZIndex = 400
    p.Parent = screenGui
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,10); pc.Parent = p
    local ps = Instance.new("UIStroke"); ps.Color = themes[currentThemeIndex].accent; ps.Thickness = 1.5; ps.Parent = p

    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,30)
    h.BackgroundColor3 = themes[currentThemeIndex].top
    h.BorderSizePixel = 0
    h.ZIndex = 401
    h.Parent = p
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0,10); hc.Parent = h
    local hx = Instance.new("Frame")
    hx.Size = UDim2.new(1,0,0,5)
    hx.Position = UDim2.new(0,0,1,-5)
    hx.BackgroundColor3 = themes[currentThemeIndex].top
    hx.BorderSizePixel = 0
    hx.ZIndex = 401
    hx.Parent = h
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-40,1,0)
    t.Position = UDim2.new(0,12,0,0)
    t.BackgroundTransparency = 1
    t.Text = headerText
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 402
    t.Parent = h
    local cl = Instance.new("TextButton")
    cl.Size = UDim2.new(0,30,0,30)
    cl.Position = UDim2.new(1,-30,0,0)
    cl.BackgroundTransparency = 1
    cl.Text = "✕"
    cl.TextColor3 = Color3.fromRGB(255,100,100)
    cl.Font = Enum.Font.GothamBold
    cl.TextSize = 14
    cl.ZIndex = 402
    cl.Parent = h
    cl.MouseButton1Click:Connect(function() p.Visible = false end)

    local d = false; local ds; local sp
    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = input.Position; sp = p.Position
        end
    end)
    Track(UserInputService.InputChanged:Connect(function(input)
        if d and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dd = input.Position - ds
            p.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then d = false end
    end))
    return p
end

-- =========================================================
-- TP POPUP
-- =========================================================
local tpPopup = CreatePopup("👤 TP para Player")
local tpSearch = Instance.new("TextBox")
tpSearch.Size = UDim2.new(1,-20,0,26)
tpSearch.Position = UDim2.new(0,10,0,38)
tpSearch.BackgroundColor3 = Color3.fromRGB(30,30,35)
tpSearch.PlaceholderText = "🔍 Buscar..."
tpSearch.Text = ""
tpSearch.TextColor3 = Color3.fromRGB(255,255,255)
tpSearch.PlaceholderColor3 = Color3.fromRGB(140,140,140)
tpSearch.Font = Enum.Font.Gotham
tpSearch.TextSize = 12
tpSearch.ZIndex = 402
tpSearch.Parent = tpPopup
local tsc = Instance.new("UICorner"); tsc.CornerRadius = UDim.new(0,6); tsc.Parent = tpSearch

local tpList = Instance.new("ScrollingFrame")
tpList.Size = UDim2.new(1,-20,1,-75)
tpList.Position = UDim2.new(0,10,0,70)
tpList.BackgroundTransparency = 1
tpList.BorderSizePixel = 0
tpList.ScrollBarThickness = 4
tpList.CanvasSize = UDim2.new(0,0,0,0)
tpList.ZIndex = 402
tpList.Parent = tpPopup

local function RefreshTPList()
    for _, c in ipairs(tpList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local filter = tpSearch.Text:lower()
    local sorted = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if filter == "" or p.Name:lower():find(filter, 1, true) then
            table.insert(sorted, p)
        end
    end
    table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
    local y = 0
    for _, p in ipairs(sorted) do
        local label = p.Name
        if p == player then label = label .. " (você)" end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-5,0,30)
        btn.Position = UDim2.new(0,0,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
        btn.Text = "  " .. label
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 403
        btn.Parent = tpList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if p == player then return end
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                SmoothTeleport(tr.CFrame + Vector3.new(0,3,0))
                Notify("🎯 TP: " .. p.Name, Color3.fromRGB(60,220,60))
                tpPopup.Visible = false
            else
                Notify("❌ Alvo inválido", Color3.fromRGB(255,60,60))
            end
        end)
        y = y + 34
    end
    tpList.CanvasSize = UDim2.new(0,0,0,y+5)
end
tpSearch:GetPropertyChangedSignal("Text"):Connect(RefreshTPList)

local function OpenTPPopup()
    RefreshTPList()
    local ma = mainFrame.AbsolutePosition
    local ms = mainFrame.AbsoluteSize
    tpPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    tpPopup.Visible = true
end
local function ToggleTPPopup()
    if tpPopup.Visible then tpPopup.Visible = false else OpenTPPopup() end
end

-- =========================================================
-- IGNORE POPUP
-- =========================================================
local ignorePopup = CreatePopup("🚫 Ignorar Players")
local ignoreList = Instance.new("ScrollingFrame")
ignoreList.Size = UDim2.new(1,-20,1,-50)
ignoreList.Position = UDim2.new(0,10,0,44)
ignoreList.BackgroundTransparency = 1
ignoreList.BorderSizePixel = 0
ignoreList.ScrollBarThickness = 4
ignoreList.CanvasSize = UDim2.new(0,0,0,0)
ignoreList.ZIndex = 402
ignoreList.Parent = ignorePopup

local function RefreshIgnoreList()
    for _, c in ipairs(ignoreList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local sorted = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(sorted, p) end
    end
    table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
    local y = 0
    for _, p in ipairs(sorted) do
        local isIgn = Settings.IgnoredPlayers[p.UserId] == true
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-5,0,30)
        btn.Position = UDim2.new(0,0,0,y)
        btn.BackgroundColor3 = isIgn and Color3.fromRGB(60,180,60) or Color3.fromRGB(40,40,45)
        btn.Text = "  " .. p.Name .. (isIgn and "  [IGNORADO]" or "")
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 403
        btn.Parent = ignoreList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if Settings.IgnoredPlayers[p.UserId] then
                Settings.IgnoredPlayers[p.UserId] = nil
                Notify("👋 Deixou de ignorar: " .. p.Name, Color3.fromRGB(255,200,60))
            else
                Settings.IgnoredPlayers[p.UserId] = true
                Notify("🚫 Ignorando: " .. p.Name, Color3.fromRGB(60,220,60))
            end
            RefreshIgnoreList()
        end)
        y = y + 34
    end
    ignoreList.CanvasSize = UDim2.new(0,0,0,y+5)
end

local function OpenIgnorePopup()
    RefreshIgnoreList()
    local ma = mainFrame.AbsolutePosition
    local ms = mainFrame.AbsoluteSize
    ignorePopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    ignorePopup.Visible = true
end

-- =========================================================
-- WAYPOINTS POPUP (com suporte por jogo)
-- =========================================================
local wpPopup = CreatePopup("📍 Waypoints")

local wpInputCont = Instance.new("Frame")
wpInputCont.Size = UDim2.new(1,-20,0,30)
wpInputCont.Position = UDim2.new(0,10,0,40)
wpInputCont.BackgroundColor3 = Color3.fromRGB(40,40,45)
wpInputCont.BorderSizePixel = 0
wpInputCont.ZIndex = 402
wpInputCont.Parent = wpPopup
local wpc = Instance.new("UICorner"); wpc.CornerRadius = UDim.new(0,6); wpc.Parent = wpInputCont
local wpNameBox = Instance.new("TextBox")
wpNameBox.Size = UDim2.new(1,-80,1,0)
wpNameBox.Position = UDim2.new(0,5,0,0)
wpNameBox.BackgroundTransparency = 1
wpNameBox.Text = "WP1"
wpNameBox.TextColor3 = Color3.fromRGB(255,255,255)
wpNameBox.Font = Enum.Font.GothamMedium
wpNameBox.TextSize = 12
wpNameBox.ClearTextOnFocus = false
wpNameBox.ZIndex = 403
wpNameBox.Parent = wpInputCont
local wpSaveBtn = Instance.new("TextButton")
wpSaveBtn.Size = UDim2.new(0,70,1,0)
wpSaveBtn.Position = UDim2.new(1,-70,0,0)
wpSaveBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
wpSaveBtn.Text = "💾 Salvar"
wpSaveBtn.TextColor3 = Color3.fromRGB(255,255,255)
wpSaveBtn.Font = Enum.Font.GothamBold
wpSaveBtn.TextSize = 11
wpSaveBtn.ZIndex = 403
wpSaveBtn.Parent = wpInputCont
local wsc = Instance.new("UICorner"); wsc.CornerRadius = UDim.new(0,6); wsc.Parent = wpSaveBtn

local wpList = Instance.new("ScrollingFrame")
wpList.Size = UDim2.new(1,-20,1,-85)
wpList.Position = UDim2.new(0,10,0,80)
wpList.BackgroundTransparency = 1
wpList.BorderSizePixel = 0
wpList.ScrollBarThickness = 4
wpList.CanvasSize = UDim2.new(0,0,0,0)
wpList.ZIndex = 402
wpList.Parent = wpPopup

local function GetWPList()
    if Settings.WaypointsPerGame then
        local pid = tostring(game.PlaceId)
        if not Settings.WaypointsPerGame[pid] then
            Settings.WaypointsPerGame[pid] = Settings.Waypoints or {}
        end
        return Settings.WaypointsPerGame[pid]
    end
    return Settings.Waypoints
end

local function RefreshWPs()
    for _, c in ipairs(wpList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local list = GetWPList()
    local y = 0
    for i, wp in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-5,0,30)
        row.Position = UDim2.new(0,0,0,y)
        row.BackgroundColor3 = Color3.fromRGB(40,40,45)
        row.BorderSizePixel = 0
        row.ZIndex = 403
        row.Parent = wpList
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,5); rc.Parent = row
        local nL = Instance.new("TextLabel")
        nL.Size = UDim2.new(1,-90,1,0)
        nL.Position = UDim2.new(0,8,0,0)
        nL.BackgroundTransparency = 1
        nL.Text = wp.name
        nL.TextColor3 = Color3.fromRGB(255,255,255)
        nL.Font = Enum.Font.GothamMedium
        nL.TextSize = 12
        nL.TextXAlignment = Enum.TextXAlignment.Left
        nL.TextTruncate = Enum.TextTruncate.AtEnd
        nL.ZIndex = 404
        nL.Parent = row
        local tpB = Instance.new("TextButton")
        tpB.Size = UDim2.new(0,45,1,0)
        tpB.Position = UDim2.new(1,-85,0,0)
        tpB.BackgroundColor3 = Color3.fromRGB(60,130,60)
        tpB.Text = "TP"
        tpB.TextColor3 = Color3.fromRGB(255,255,255)
        tpB.Font = Enum.Font.GothamBold
        tpB.TextSize = 11
        tpB.ZIndex = 404
        tpB.Parent = row
        local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,5); tc.Parent = tpB
        local xB = Instance.new("TextButton")
        xB.Size = UDim2.new(0,30,1,0)
        xB.Position = UDim2.new(1,-35,0,0)
        xB.BackgroundColor3 = Color3.fromRGB(120,50,50)
        xB.Text = "✕"
        xB.TextColor3 = Color3.fromRGB(255,255,255)
        xB.Font = Enum.Font.GothamBold
        xB.TextSize = 11
        xB.ZIndex = 404
        xB.Parent = row
        local xc = Instance.new("UICorner"); xc.CornerRadius = UDim.new(0,5); xc.Parent = xB
        tpB.MouseButton1Click:Connect(function()
            SmoothTeleport(CFrame.new(wp.pos))
            Notify("📍 TP: " .. wp.name, Color3.fromRGB(60,220,60))
            wpPopup.Visible = false
        end)
        xB.MouseButton1Click:Connect(function()
            table.remove(list, i)
            RefreshWPs()
            Notify("🗑️ WP removido", Color3.fromRGB(255,200,60))
        end)
        y = y + 34
    end
    wpList.CanvasSize = UDim2.new(0,0,0,y+5)
end

wpSaveBtn.MouseButton1Click:Connect(function()
    local rt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rt then return end
    local list = GetWPList()
    local name = wpNameBox.Text
    if name == "" then name = "WP" .. (#list + 1) end
    table.insert(list, {name=name, pos=rt.Position})
    Notify("📍 WP salvo: " .. name, Color3.fromRGB(60,220,60))
    RefreshWPs()
    wpNameBox.Text = "WP" .. (#list + 1)
end)

local function OpenWPPopup()
    RefreshWPs()
    local ma = mainFrame.AbsolutePosition
    local ms = mainFrame.AbsoluteSize
    wpPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    wpPopup.Visible = true
end

-- =========================================================
-- PLAYER INFO POPUP
-- =========================================================
local infoPopup = CreatePopup("👤 Player Info")
local infoContent = Instance.new("ScrollingFrame")
infoContent.Size = UDim2.new(1,-20,1,-50)
infoContent.Position = UDim2.new(0,10,0,44)
infoContent.BackgroundTransparency = 1
infoContent.BorderSizePixel = 0
infoContent.ScrollBarThickness = 4
infoContent.CanvasSize = UDim2.new(0,0,0,0)
infoContent.ZIndex = 402
infoContent.Parent = infoPopup

local function ShowPlayerInfo(targetPlayer)
    for _, c in ipairs(infoContent:GetChildren()) do c:Destroy() end
    if not targetPlayer then return end
    local y = 0
    local function addLine(label, value, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,-5,0,24)
        lbl.Position = UDim2.new(0,0,0,y)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. label .. ": " .. tostring(value)
        lbl.TextColor3 = color or Color3.fromRGB(220,220,220)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 403
        lbl.Parent = infoContent
        y = y + 26
    end
    addLine("Nome", targetPlayer.Name, Color3.fromRGB(255,255,255))
    addLine("Display", targetPlayer.DisplayName, Color3.fromRGB(200,200,200))
    addLine("UserId", targetPlayer.UserId, Color3.fromRGB(200,200,200))
    local accAge = "Desconhecido"
    pcall(function()
        local req = game:HttpGet("https://users.roblox.com/v1/users/" .. targetPlayer.UserId)
        local data = HttpService:JSONDecode(req)
        if data.created then
            local created = data.created:sub(1,10)
            accAge = created
        end
    end)
    addLine("Conta criada em", accAge, Color3.fromRGB(200,200,200))
    local ch = targetPlayer.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        addLine("Vida", math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth), Color3.fromRGB(80,255,80))
    end
    if ch then
        local tool = ch:FindFirstChildOfClass("Tool")
        addLine("Arma atual", tool and tool.Name or "Nenhuma", Color3.fromRGB(255,255,100))
    end
    infoContent.CanvasSize = UDim2.new(0,0,0,y+5)
end

local function OpenInfoPopup(target)
    ShowPlayerInfo(target)
    local ma = mainFrame.AbsolutePosition
    local ms = mainFrame.AbsoluteSize
    infoPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    infoPopup.Visible = true
end

-- =========================================================
-- PLAYER LIST FLUTUANTE
-- =========================================================
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(0,210,0,280)
playerListFrame.Position = UDim2.new(0,10,0,10)
playerListFrame.BackgroundColor3 = themes[currentThemeIndex].bg
playerListFrame.BorderSizePixel = 0
playerListFrame.Visible = false
playerListFrame.ZIndex = 300
playerListFrame.Active = true
playerListFrame.Parent = screenGui
local plCorner = Instance.new("UICorner"); plCorner.CornerRadius = UDim.new(0,8); plCorner.Parent = playerListFrame
local plStroke = Instance.new("UIStroke"); plStroke.Color = themes[currentThemeIndex].accent; plStroke.Thickness = 1.5; plStroke.Parent = playerListFrame

local plHeader = Instance.new("Frame")
plHeader.Size = UDim2.new(1,0,0,26)
plHeader.BackgroundColor3 = themes[currentThemeIndex].top
plHeader.BorderSizePixel = 0
plHeader.ZIndex = 301
plHeader.Parent = playerListFrame
local plHC = Instance.new("UICorner"); plHC.CornerRadius = UDim.new(0,8); plHC.Parent = plHeader

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1,-30,1,0)
plTitle.Position = UDim2.new(0,8,0,0)
plTitle.BackgroundTransparency = 1
plTitle.Text = "👥 Players"
plTitle.TextColor3 = Color3.fromRGB(255,255,255)
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 12
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.ZIndex = 302
plTitle.Parent = plHeader

local plClose = Instance.new("TextButton")
plClose.Size = UDim2.new(0,26,0,26)
plClose.Position = UDim2.new(1,-26,0,0)
plClose.BackgroundTransparency = 1
plClose.Text = "✕"
plClose.TextColor3 = Color3.fromRGB(255,100,100)
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 13
plClose.ZIndex = 302
plClose.Parent = plHeader

local plList = Instance.new("ScrollingFrame")
plList.Size = UDim2.new(1,-10,1,-35)
plList.Position = UDim2.new(0,5,0,30)
plList.BackgroundTransparency = 1
plList.BorderSizePixel = 0
plList.ScrollBarThickness = 3
plList.CanvasSize = UDim2.new(0,0,0,0)
plList.ZIndex = 302
plList.Parent = playerListFrame

plClose.MouseButton1Click:Connect(function()
    Settings.PlayerListEnabled = false
    playerListFrame.Visible = false
    Notify("👥 Player List: OFF", Color3.fromRGB(220,60,60))
    if ToggleRefs.PlayerList then ToggleRefs.PlayerList(false, true) end
end)

local plDrag, plDS, plSP
plHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        plDrag = true
        plDS = input.Position
        plSP = playerListFrame.Position
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if plDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - plDS
        playerListFrame.Position = UDim2.new(plSP.X.Scale, plSP.X.Offset + d.X, plSP.Y.Scale, plSP.Y.Offset + d.Y)
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then plDrag = false end
end))

-- =========================================================
-- WATERMARK
-- =========================================================
watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Size = UDim2.new(0,220,0,26)
watermarkLabel.Position = UDim2.new(0,15,1,-40)
watermarkLabel.BackgroundColor3 = themes[currentThemeIndex].bg
watermarkLabel.BackgroundTransparency = 0.15
watermarkLabel.Text = "🛡️ Guasti Scripts | v30"
watermarkLabel.TextColor3 = Color3.fromRGB(255,255,255)
watermarkLabel.Font = Enum.Font.GothamBold
watermarkLabel.TextSize = 12
watermarkLabel.Visible = false
watermarkLabel.ZIndex = 100
watermarkLabel.Parent = screenGui
local wmc = Instance.new("UICorner"); wmc.CornerRadius = UDim.new(0,6); wmc.Parent = watermarkLabel
local wms = Instance.new("UIStroke"); wms.Color = themes[currentThemeIndex].accent; wms.Thickness = 1.5; wms.Parent = watermarkLabel

-- FPS Counter
fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0,140,0,24)
fpsLabel.Position = UDim2.new(1,-150,0,10)
fpsLabel.BackgroundColor3 = themes[currentThemeIndex].bg
fpsLabel.BackgroundTransparency = 0.15
fpsLabel.Text = "📊 FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 13
fpsLabel.Visible = false
fpsLabel.ZIndex = 100
fpsLabel.Parent = screenGui
local fpsc = Instance.new("UICorner"); fpsc.CornerRadius = UDim.new(0,4); fpsc.Parent = fpsLabel
local fpsStroke = Instance.new("UIStroke"); fpsStroke.Color = themes[currentThemeIndex].accent; fpsStroke.Thickness = 1; fpsStroke.Parent = fpsLabel

-- Ping Counter
pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0,140,0,24)
pingLabel.Position = UDim2.new(1,-150,0,38)
pingLabel.BackgroundColor3 = themes[currentThemeIndex].bg
pingLabel.BackgroundTransparency = 0.15
pingLabel.Text = "📡 Ping: --"
pingLabel.TextColor3 = Color3.fromRGB(0,255,0)
pingLabel.Font = Enum.Font.Code
pingLabel.TextSize = 13
pingLabel.Visible = false
pingLabel.ZIndex = 100
pingLabel.Parent = screenGui
local pingc = Instance.new("UICorner"); pingc.CornerRadius = UDim.new(0,4); pingc.Parent = pingLabel
local pingStroke = Instance.new("UIStroke"); pingStroke.Color = themes[currentThemeIndex].accent; pingStroke.Thickness = 1; pingStroke.Parent = pingLabel

-- =========================================================
-- RADAR 2D (arrastável, com slider de tamanho, gira com câmera)
-- =========================================================
local radarFrame = Instance.new("Frame")
radarFrame.Size = UDim2.new(0,130,0,130)
radarFrame.Position = UDim2.new(0,10,1,-150)
radarFrame.BackgroundColor3 = Color3.fromRGB(12,12,15)
radarFrame.BackgroundTransparency = 0.2
radarFrame.BorderSizePixel = 0
radarFrame.Visible = false
radarFrame.Active = true
radarFrame.ZIndex = 100
radarFrame.Parent = screenGui
local rfc = Instance.new("UICorner"); rfc.CornerRadius = UDim.new(1,0); rfc.Parent = radarFrame
local rfs = Instance.new("UIStroke"); rfs.Color = themes[currentThemeIndex].accent; rfs.Thickness = 2; rfs.Parent = radarFrame

local radarCenter = Instance.new("Frame")
radarCenter.Size = UDim2.new(0,6,0,6)
radarCenter.Position = UDim2.new(0.5,-3,0.5,-3)
radarCenter.BackgroundColor3 = Color3.fromRGB(80,255,80)
radarCenter.BorderSizePixel = 0
radarCenter.ZIndex = 101
radarCenter.Parent = radarFrame
local rcc = Instance.new("UICorner"); rcc.CornerRadius = UDim.new(1,0); rcc.Parent = radarCenter

local radarDots = {}
local radarDrag, radarDS, radarSP
radarFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        radarDrag = true
        radarDS = input.Position
        radarSP = radarFrame.Position
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if radarDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - radarDS
        radarFrame.Position = UDim2.new(radarSP.X.Scale, radarSP.X.Offset + d.X, radarSP.Y.Scale, radarSP.Y.Offset + d.Y)
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then radarDrag = false end
end))

-- =========================================================
-- ITEM CREATORS (com hover e ícones)
-- =========================================================
local function CreateToggleItem(parent, name, yPos, callback, initialState, notifyText, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,34)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0,24,1,0)
    icon.Position = UDim2.new(0,6,0,0)
    icon.BackgroundTransparency = 1
    icon.Text = GetIcon(name)
    icon.TextSize = 14
    icon.TextColor3 = Color3.fromRGB(255,255,255)
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-80,1,0)
    label.Position = UDim2.new(0,30,0,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0,26,0,12)
    indicator.Position = UDim2.new(1,-32,0.5,-6)
    indicator.BackgroundColor3 = Color3.fromRGB(180,50,50)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(1,0); ic.Parent = indicator

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,8,0,8)
    knob.Position = UDim2.new(0,2,0.5,-4)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = indicator
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob

    local state = initialState or false
    local function Update(anim)
        local targetColor = state and Color3.fromRGB(60,180,60) or Color3.fromRGB(180,50,50)
        local targetPos = state and UDim2.new(0,16,0.5,-4) or UDim2.new(0,2,0.5,-4)
        if anim then
            TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3=targetColor}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position=targetPos}):Play()
        else
            indicator.BackgroundColor3 = targetColor
            knob.Position = targetPos
        end
    end

    local function SetState(v, silent)
        if v == nil then state = not state else state = (v == true) end
        Update(true)
        if settingKey then Settings[settingKey] = state end
        if callback then callback(state) end
        if not silent and notifyText then
            Notify((state and "✅ " or "❌ ") .. name .. ": " .. (state and "ON" or "OFF"),
                state and Color3.fromRGB(60,220,60) or Color3.fromRGB(220,60,60))
        end
    end

    btn.MouseEnter:Connect(function()
        if Settings.GuiAnimationsEnabled then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(50,50,58)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if Settings.GuiAnimationsEnabled then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(35,35,40)}):Play()
        end
    end)

    Update(false)
    btn.MouseButton1Click:Connect(function() SetState() end)

    table.insert(AllToggles, {setter=SetState, default=initialState or false})
    if settingKey then table.insert(ToggleRegistry, {key=settingKey, setter=SetState}) end
    return btn, function() return state end, SetState
end

local function CreateButtonItem(parent, name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,34)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.Text = "  " .. GetIcon(name) .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn

    btn.MouseEnter:Connect(function()
        if Settings.GuiAnimationsEnabled then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(50,50,58)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if Settings.GuiAnimationsEnabled then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(35,35,40)}):Play()
        end
    end)

    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function CreateSmallButton(parent, name, xPos, yPos, width, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,width,0,34)
    btn.Position = UDim2.new(0,xPos,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function CreateSlider(parent, label, yPos, minVal, maxVal, getValue, setValue, suffix, settingKey)
    suffix = suffix or ""
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,50)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(35,35,40)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container

    local label_ = Instance.new("TextLabel")
    label_.Size = UDim2.new(1,-12,0,20)
    label_.Position = UDim2.new(0,10,0,2)
    label_.BackgroundTransparency = 1
    label_.Text = GetIcon(label) .. "  " .. label .. ": " .. tostring(getValue()) .. suffix
    label_.TextColor3 = Color3.fromRGB(220,220,220)
    label_.Font = Enum.Font.GothamMedium
    label_.TextSize = 12
    label_.TextXAlignment = Enum.TextXAlignment.Left
    label_.Parent = container

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1,-20,0,8)
    barBg.Position = UDim2.new(0,10,1,-16)
    barBg.BackgroundColor3 = Color3.fromRGB(20,20,24)
    barBg.BorderSizePixel = 0
    barBg.Parent = container
    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(1,0); c2.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = themes[currentThemeIndex].accent
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(1,0); c3.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,14,0,14)
    handle.Position = UDim2.new(0,0,0.5,0)
    handle.AnchorPoint = Vector2.new(0.5,0.5)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 3
    handle.Parent = barBg
    local c4 = Instance.new("UICorner"); c4.CornerRadius = UDim.new(1,0); c4.Parent = handle

    local function UpdateVisual(value)
        local alpha = (value - minVal) / (maxVal - minVal)
        alpha = math.clamp(alpha, 0, 1)
        fill.Size = UDim2.new(alpha,0,1,0)
        handle.Position = UDim2.new(alpha,0,0.5,0)
        label_.Text = GetIcon(label) .. "  " .. label .. ": " .. tostring(math.floor(value*100+0.5)/100) .. suffix
    end

    UpdateVisual(getValue())
    local dragging = false
    local function SetFromX(absX)
        local barAbsX = barBg.AbsolutePosition.X
        local barAbsW = barBg.AbsoluteSize.X
        if barAbsW <= 0 then return end
        local alpha = math.clamp((absX - barAbsX) / barAbsW, 0, 1)
        local newVal = minVal + alpha * (maxVal - minVal)
        newVal = math.floor(newVal*100+0.5)/100
        setValue(newVal)
        UpdateVisual(newVal)
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(input.Position.X)
        end
    end)
    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    if settingKey then
        table.insert(SliderRegistry, {key=settingKey, updateFn=function() UpdateVisual(Settings[settingKey]) end})
    end
    return UpdateVisual
end

local function CreateInputItem(parent, label, yPos, getValue, setValue, minVal, maxVal, settingKey, isText)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,34)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(35,35,40)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container

    local label_ = Instance.new("TextLabel")
    label_.Size = UDim2.new(0.5,0,1,0)
    label_.Position = UDim2.new(0,10,0,0)
    label_.BackgroundTransparency = 1
    label_.Text = GetIcon(label) .. "  " .. label
    label_.TextColor3 = Color3.fromRGB(220,220,220)
    label_.Font = Enum.Font.GothamMedium
    label_.TextSize = 12
    label_.TextXAlignment = Enum.TextXAlignment.Left
    label_.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0,120,0,24)
    textBox.Position = UDim2.new(1,-130,0.5,-12)
    textBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
    textBox.Text = tostring(getValue())
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.GothamMedium
    textBox.TextSize = 12
    textBox.PlaceholderText = isText and "ID" or "0"
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,4); tc.Parent = textBox
    textBox.FocusLost:Connect(function()
        if isText then
            setValue(textBox.Text)
        else
            local num = tonumber(textBox.Text)
            if num then
                if minVal then num = math.max(num, minVal) end
                if maxVal then num = math.min(num, maxVal) end
                setValue(num)
                textBox.Text = tostring(num)
            else
                textBox.Text = tostring(getValue())
            end
        end
    end)
    if settingKey then
        table.insert(InputRegistry, {key=settingKey, textBox=textBox, getValue=getValue})
    end
    return textBox
end

local function CreateColorPalette(parent, yPos, getColor, setColor, title, settingKey)
    title = title or "Cor"
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,64)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(35,35,40)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-12,0,20)
    lbl.Position = UDim2.new(0,10,0,2)
    lbl.BackgroundTransparency = 1
    lbl.Text = GetIcon(title) .. "  " .. title
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local colors = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(255,60,60),
        Color3.fromRGB(60,255,60), Color3.fromRGB(60,120,255),
        Color3.fromRGB(255,220,60), Color3.fromRGB(255,100,220),
        Color3.fromRGB(60,230,255), Color3.fromRGB(255,140,60),
    }
    local btnSize = 24
    local gap = 4
    local buttons = {}
    for i, cc in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,btnSize,0,btnSize)
        b.Position = UDim2.new(0,10 + (i-1)*(btnSize+gap),0,30)
        b.BackgroundColor3 = cc
        b.Text = ""
        b.BorderSizePixel = 2
        b.BorderColor3 = Color3.fromRGB(0,0,0)
        b.Parent = container
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = b
        table.insert(buttons, {btn=b, color=cc})
        b.MouseButton1Click:Connect(function()
            setColor(cc)
            for _, e in ipairs(buttons) do
                e.btn.BorderColor3 = (e.color == cc) and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
            end
        end)
    end
    for _, e in ipairs(buttons) do
        if e.color == getColor() then e.btn.BorderColor3 = Color3.fromRGB(255,255,255) end
    end
    if settingKey then
        table.insert(SliderRegistry, {key=settingKey, updateFn=function()
            local cur = Settings[settingKey]
            for _, e in ipairs(buttons) do
                e.btn.BorderColor3 = (e.color == cur) and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
            end
        end})
    end
    return container
end

print("[Guasti] Parte 4/5 carregada. Cole a parte 5 abaixo.")

-- =========================================================
-- PÁGINA 1: AIMBOT
-- =========================================================
local _, _, SetAimbotState = CreateToggleItem(page1, "Aimbot", 0, function(s) Settings.AimbotEnabled = s end, false, true, "AimbotEnabled")
ToggleRefs.Aimbot = SetAimbotState

local _, _, SetFOVDouble = CreateToggleItem(page1, "FOV Circle 2 (Duplo)", 40, function(s) Settings.FOVDoubleEnabled = s end, false, true, "FOVDoubleEnabled")

CreateSlider(page1, "FOV Externo", 78, 10, 500,
    function() return Settings.FOV end,
    function(v) Settings.FOV = v; FOVCircle.Radius = v end, "", "FOV")

CreateSlider(page1, "FOV Interno", 132, 5, 500,
    function() return Settings.FOVInner end,
    function(v) Settings.FOVInner = v; FOVInnerCircle.Radius = v end, "", "FOVInner")

CreateColorPalette(page1, 186, function() return Settings.FOVColor end, function(c)
    Settings.FOVColor = c; FOVCircle.Color = c
end, "Cor do FOV Externo", "FOVColor")

CreateColorPalette(page1, 254, function() return Settings.FOVInnerColor end, function(c)
    Settings.FOVInnerColor = c; FOVInnerCircle.Color = c
end, "Cor do FOV Interno", "FOVInnerColor")

CreateToggleItem(page1, "FOV colorido por estado", 322, function(s) Settings.FOVStateColor = s end, false, true, "FOVStateColor")

local partLabel = Instance.new("TextLabel")
partLabel.Size = UDim2.new(1,-10,0,18)
partLabel.Position = UDim2.new(0,4,0,360)
partLabel.BackgroundTransparency = 1
partLabel.Text = "  🎯 Mirar em:"
partLabel.TextColor3 = Color3.fromRGB(200,200,200)
partLabel.Font = Enum.Font.GothamMedium
partLabel.TextSize = 11
partLabel.TextXAlignment = Enum.TextXAlignment.Left
partLabel.Parent = page1

local headBtn, torsoBtn
headBtn = CreateSmallButton(page1, "Cabeça", 0, 380, 165, function()
    Settings.AimPart = "Head"
    headBtn.BackgroundColor3 = themes[currentThemeIndex].accent
    torsoBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
end)
torsoBtn = CreateSmallButton(page1, "Torso", 172, 380, 165, function()
    Settings.AimPart = "Torso"
    torsoBtn.BackgroundColor3 = themes[currentThemeIndex].accent
    headBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
end)
headBtn.BackgroundColor3 = themes[currentThemeIndex].accent

table.insert(SliderRegistry, {key="AimPart", updateFn=function()
    if Settings.AimPart == "Head" then
        headBtn.BackgroundColor3 = themes[currentThemeIndex].accent
        torsoBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    else
        torsoBtn.BackgroundColor3 = themes[currentThemeIndex].accent
        headBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    end
end})

CreateSlider(page1, "Alcance", 420, 50, 2000,
    function() return Settings.MaxDistance end,
    function(v) Settings.MaxDistance = v end, " studs", "MaxDistance")

CreateToggleItem(page1, "Wall Check", 474, function(s) Settings.WallCheck = s end, false, false, "WallCheck")
CreateToggleItem(page1, "Team Check", 512, function(s) Settings.TeamCheck = s end, false, false, "TeamCheck")
CreateToggleItem(page1, "Mostrar FOV", 550, function(s) Settings.FOVVisible = s end, false, false, "FOVVisible")
CreateToggleItem(page1, "Prediction", 588, function(s) Settings.PredictionEnabled = s end, false, true, "PredictionEnabled")

CreateSlider(page1, "Prediction", 626, 0, 100,
    function() return Settings.Prediction end,
    function(v) Settings.Prediction = v end, "%", "Prediction")

CreateToggleItem(page1, "Predict Visual", 680, function(s) Settings.PredictVisual = s end, false, true, "PredictVisual")
CreateToggleItem(page1, "Aimbot Target Line", 718, function(s) Settings.AimbotTargetLine = s end, false, true, "AimbotTargetLine")
CreateToggleItem(page1, "Aim Assist", 756, function(s) Settings.AimAssistEnabled = s end, false, true, "AimAssistEnabled")

CreateSlider(page1, "Força Aim Assist", 794, 1, 100,
    function() return Settings.AimAssistStrength end,
    function(v) Settings.AimAssistStrength = v end, "%", "AimAssistStrength")

CreateToggleItem(page1, "Silent Aim", 848, function(s) Settings.SilentAimEnabled = s end, false, true, "SilentAimEnabled")
CreateToggleItem(page1, "Trigger Bot", 886, function(s) Settings.TriggerBotEnabled = s end, false, true, "TriggerBotEnabled")
CreateToggleItem(page1, "Trigger Auto-Fire", 924, function(s) Settings.TriggerBotAutoFire = s end, false, true, "TriggerBotAutoFire")

local aimbotKeyBtn = CreateButtonItem(page1, "Tecla Aimbot: " .. Settings.AimbotKey.Name, 962, function()
    waitingForAimbotKey = true
    aimbotKeyBtn.Text = "  Pressione uma tecla..."
end)

-- =========================================================
-- PÁGINA 2: ESP
-- =========================================================
local _, _, SetESPState = CreateToggleItem(page2, "ESP", 0, function(s) Settings.ESPEnabled = s end, false, true, "ESPEnabled")
ToggleRefs.ESP = SetESPState

CreateToggleItem(page2, "Team Check", 40, function(s) Settings.ESPTeamCheck = s end, false, false, "ESPTeamCheck")
CreateToggleItem(page2, "Linha", 78, function(s) Settings.ESPLine = s end, false, false, "ESPLine")
CreateToggleItem(page2, "Vida", 116, function(s) Settings.ESPHealth = s end, false, false, "ESPHealth")
CreateToggleItem(page2, "Distância", 154, function(s) Settings.ESPDistance = s end, false, false, "ESPDistance")
CreateToggleItem(page2, "Nome", 192, function(s) Settings.ESPName = s end, false, false, "ESPName")
CreateToggleItem(page2, "Distância no Nome", 230, function(s) Settings.ESPDistanceInName = s end, false, false, "ESPDistanceInName")
CreateToggleItem(page2, "Arma", 268, function(s) Settings.ESPWeapon = s end, false, false, "ESPWeapon")
CreateToggleItem(page2, "Box 2D", 306, function(s) Settings.ESPBox = s end, false, false, "ESPBox")
CreateToggleItem(page2, "Box Horizontal (barra)", 344, function(s) Settings.ESPBoxHorizontal = s end, false, false, "ESPBoxHorizontal")
CreateToggleItem(page2, "Box de Vida", 382, function(s) Settings.ESPBoxHealth = s end, false, false, "ESPBoxHealth")
CreateToggleItem(page2, "Chams", 420, function(s) Settings.ESPChams = s end, false, false, "ESPChams")
CreateToggleItem(page2, "Esqueleto", 458, function(s) Settings.ESPSkeleton = s end, false, false, "ESPSkeleton")
CreateToggleItem(page2, "Esqueleto 3D", 496, function(s) Settings.ESPSkeleton3D = s end, false, false, "ESPSkeleton3D")
CreateToggleItem(page2, "Rainbow ESP", 534, function(s) Settings.ESPRainbow = s end, false, true, "ESPRainbow")
CreateToggleItem(page2, "Cor por Distância", 572, function(s) Settings.ESPDistanceColor = s end, false, true, "ESPDistanceColor")
CreateToggleItem(page2, "ESP Animado", 610, function(s) Settings.ESPAnimated = s end, false, false, "ESPAnimated")

CreateSlider(page2, "Alcance do ESP", 648, 50, 5000,
    function() return Settings.ESPMaxDistance end,
    function(v) Settings.ESPMaxDistance = v end, " studs", "ESPMaxDistance")

-- Seletor de cor por elemento
local ctCont = Instance.new("Frame")
ctCont.Size = UDim2.new(1,-10,0,34)
ctCont.Position = UDim2.new(0,0,0,702)
ctCont.BackgroundColor3 = Color3.fromRGB(35,35,40)
ctCont.BorderSizePixel = 0
ctCont.Parent = page2
local ctc = Instance.new("UICorner"); ctc.CornerRadius = UDim.new(0,6); ctc.Parent = ctCont

local ctLbl = Instance.new("TextLabel")
ctLbl.Size = UDim2.new(0.5,0,1,0)
ctLbl.Position = UDim2.new(0,10,0,0)
ctLbl.BackgroundTransparency = 1
ctLbl.Text = "  🎨 Elemento p/ cor:"
ctLbl.TextColor3 = Color3.fromRGB(200,200,200)
ctLbl.Font = Enum.Font.GothamMedium
ctLbl.TextSize = 11
ctLbl.TextXAlignment = Enum.TextXAlignment.Left
ctLbl.Parent = ctCont

local ctBtn = Instance.new("TextButton")
ctBtn.Size = UDim2.new(0,120,0,24)
ctBtn.Position = UDim2.new(1,-130,0.5,-12)
ctBtn.BackgroundColor3 = themes[currentThemeIndex].accent
ctBtn.Text = "Linha"
ctBtn.TextColor3 = Color3.fromRGB(255,255,255)
ctBtn.Font = Enum.Font.GothamBold
ctBtn.TextSize = 11
ctBtn.Parent = ctCont
local ctbc = Instance.new("UICorner"); ctbc.CornerRadius = UDim.new(0,4); ctbc.Parent = ctBtn

local ctNames = {"Line", "Name", "Health", "Skeleton", "Box"}
local ctLabels = {"Linha", "Nome", "Vida", "Esqueleto", "Box"}
local ctIndex = 1

local function getEspColor()
    if colorTarget == "Line" then return Settings.ESPLineColor
    elseif colorTarget == "Name" then return Settings.ESPNameColor
    elseif colorTarget == "Health" then return Settings.ESPHealthColor
    elseif colorTarget == "Skeleton" then return Settings.ESPSkeletonColor
    elseif colorTarget == "Box" then return Settings.ESPBoxColor end
    return Settings.ESPLineColor
end

local function setEspColor(c)
    if colorTarget == "Line" then Settings.ESPLineColor = c
    elseif colorTarget == "Name" then Settings.ESPNameColor = c
    elseif colorTarget == "Health" then Settings.ESPHealthColor = c
    elseif colorTarget == "Skeleton" then Settings.ESPSkeletonColor = c
    elseif colorTarget == "Box" then Settings.ESPBoxColor = c end
end

local espPaletteRefresh
local function RefreshEspPalette()
    if espPaletteRefresh then espPaletteRefresh() end
end

ctBtn.MouseButton1Click:Connect(function()
    ctIndex = ctIndex + 1
    if ctIndex > #ctNames then ctIndex = 1 end
    colorTarget = ctNames[ctIndex]
    ctBtn.Text = ctLabels[ctIndex]
    RefreshEspPalette()
end)

espPaletteRefresh = CreateColorPalette(page2, 744, getEspColor, setEspColor, "Cor do Elemento")

CreateButtonItem(page2, "Ignorar Players", 812, function() OpenIgnorePopup() end)

-- =========================================================
-- PÁGINA 3: OUTROS
-- =========================================================
local sec1 = Instance.new("TextLabel")
sec1.Size = UDim2.new(1,-10,0,22)
sec1.Position = UDim2.new(0,4,0,0)
sec1.BackgroundTransparency = 1
sec1.Text = "  🎮 MOVIMENTO"
sec1.TextColor3 = themes[currentThemeIndex].accent
sec1.Font = Enum.Font.GothamBold
sec1.TextSize = 12
sec1.TextXAlignment = Enum.TextXAlignment.Left
sec1.Parent = page3

local _, _, SetFlyState = CreateToggleItem(page3, "Fly", 28, function(state)
    Settings.FlyEnabled = state
    local ch = player.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local rt = ch:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = state
            hum.AutoRotate = not state
            if not state and rt then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
        if rt then
            rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
            rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end
end, false, true, "FlyEnabled")
ToggleRefs.Fly = SetFlyState

CreateInputItem(page3, "Velocidade do Fly", 66,
    function() return Settings.FlySpeed end,
    function(v) Settings.FlySpeed = v end, 1, 500, "FlySpeed")

local _, _, SetNoclipState = CreateToggleItem(page3, "Noclip", 104, function(s) Settings.NoclipEnabled = s end, false, true, "NoclipEnabled")
ToggleRefs.Noclip = SetNoclipState

local _, _, SetWalkspeedState = CreateToggleItem(page3, "Walkspeed", 142, function(state)
    Settings.WalkspeedEnabled = state
    local ch = player.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then
            if state then hum.WalkSpeed = Settings.WalkspeedValue else hum.WalkSpeed = 16 end
        end
    end
end, false, true, "WalkspeedEnabled")
ToggleRefs.Walkspeed = SetWalkspeedState

CreateInputItem(page3, "Velocidade da Caminhada", 180,
    function() return Settings.WalkspeedValue end,
    function(v)
        Settings.WalkspeedValue = v
        if Settings.WalkspeedEnabled then
            local ch = player.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end
        end
    end, 1, 1000, "WalkspeedValue")

CreateToggleItem(page3, "Anti-Fling", 218, function(s) Settings.AntiFlingEnabled = s end, false, true, "AntiFlingEnabled")
CreateToggleItem(page3, "Infinite Jump", 256, function(s) Settings.InfiniteJumpEnabled = s end, false, true, "InfiniteJumpEnabled")
CreateToggleItem(page3, "Bunny Hop", 294, function(s) Settings.BhopEnabled = s end, false, true, "BhopEnabled")
CreateToggleItem(page3, "Anti-Stun / Anti-Ragdoll", 332, function(s) Settings.AntiStunEnabled = s end, false, true, "AntiStunEnabled")
CreateToggleItem(page3, "Infinite Ammo / Auto-Reload", 370, function(s) Settings.InfiniteAmmoEnabled = s end, false, true, "InfiniteAmmoEnabled")
CreateToggleItem(page3, "Speed Boost em Queda", 408, function(s) Settings.SpeedBoostFallEnabled = s end, false, true, "SpeedBoostFallEnabled")

CreateSlider(page3, "Velocidade da Queda", 446, 20, 500,
    function() return Settings.SpeedBoostFallValue end,
    function(v) Settings.SpeedBoostFallValue = v end, "", "SpeedBoostFallValue")

CreateToggleItem(page3, "Fullbright", 500, function(state)
    Settings.FullbrightEnabled = state
    if state then
        Lighting.Ambient = Color3.fromRGB(150,150,150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
        Lighting.Brightness = Settings.FullbrightBrightness
        Lighting.ClockTime = 12
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
    end
end, false, true, "FullbrightEnabled")

CreateSlider(page3, "Brilho Fullbright", 538, 0.5, 5,
    function() return Settings.FullbrightBrightness end,
    function(v)
        Settings.FullbrightBrightness = v
        if Settings.FullbrightEnabled then Lighting.Brightness = v end
    end, "", "FullbrightBrightness")

CreateToggleItem(page3, "FPS Boost", 592, function(s)
    Settings.FPSBoostEnabled = s
    ApplyFPSBoost(s)
end, false, true, "FPSBoostEnabled")

CreateToggleItem(page3, "Anti-Void", 630, function(s) Settings.AntiVoidEnabled = s end, false, true, "AntiVoidEnabled")

CreateSlider(page3, "Altura do Anti-Void", 668, -500, 50,
    function() return Settings.AntiVoidHeight end,
    function(v) Settings.AntiVoidHeight = v end, "", "AntiVoidHeight")

CreateToggleItem(page3, "Trail Colorido", 722, function(state)
    Settings.TrailEnabled = state
    local ch = player.Character
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local old = hrp:FindFirstChild("GuastiTrail"); if old then old:Destroy() end
            local oldA0 = hrp:FindFirstChild("GuastiTrailA0"); if oldA0 then oldA0:Destroy() end
            local oldA1 = hrp:FindFirstChild("GuastiTrailA1"); if oldA1 then oldA1:Destroy() end
            if state then
                local a0 = Instance.new("Attachment"); a0.Name = "GuastiTrailA0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "GuastiTrailA1"; a1.Position = Vector3.new(0,-1,0); a1.Parent = hrp
                local t = Instance.new("Trail")
                t.Name = "GuastiTrail"
                t.Attachment0 = a0
                t.Attachment1 = a1
                t.Lifetime = 0.5
                t.Color = ColorSequence.new(Settings.TrailColor)
                t.Parent = hrp
            end
        end
    end
end, false, true, "TrailEnabled")

CreateColorPalette(page3, 760, function() return Settings.TrailColor end, function(c)
    Settings.TrailColor = c
    local ch = player.Character
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local t = hrp:FindFirstChild("GuastiTrail")
            if t then t.Color = ColorSequence.new(c) end
        end
    end
end, "Cor do Trail", "TrailColor")

local sec2 = Instance.new("TextLabel")
sec2.Size = UDim2.new(1,-10,0,22)
sec2.Position = UDim2.new(0,4,0,830)
sec2.BackgroundTransparency = 1
sec2.Text = "  📍 TELEPORTE"
sec2.TextColor3 = themes[currentThemeIndex].accent
sec2.Font = Enum.Font.GothamBold
sec2.TextSize = 12
sec2.TextXAlignment = Enum.TextXAlignment.Left
sec2.Parent = page3

CreateToggleItem(page3, "Click TP", 858, function(s) Settings.ClickTPEnabled = s end, false, true, "ClickTPEnabled")
CreateToggleItem(page3, "TP Suave", 896, function(s) Settings.TPSmooth = s end, false, true, "TPSmooth")

CreateSlider(page3, "Duração Smooth", 934, 0.1, 1,
    function() return Settings.TPSmoothSpeed end,
    function(v) Settings.TPSmoothSpeed = v end, "s", "TPSmoothSpeed")

local clickTPKeyBtn = CreateButtonItem(page3, "Tecla Click TP: " .. (Settings.Keybinds.ClickTP and Settings.Keybinds.ClickTP.Name or "NENHUMA"), 988, function()
    waitingKeybind = "ClickTP"
    clickTPKeyBtn.Text = "  Pressione uma tecla..."
end)

CreateButtonItem(page3, "TP para Player", 1026, function() OpenTPPopup() end)
CreateButtonItem(page3, "Waypoints (por jogo)", 1064, function() OpenWPPopup() end)

local tpPlayerKeyBtn = CreateButtonItem(page3, "Tecla TP Player: " .. (Settings.Keybinds.TPPlayer and Settings.Keybinds.TPPlayer.Name or "NENHUMA"), 1102, function()
    waitingKeybind = "TPPlayer"
    tpPlayerKeyBtn.Text = "  Pressione uma tecla..."
end)

local sec3 = Instance.new("TextLabel")
sec3.Size = UDim2.new(1,-10,0,22)
sec3.Position = UDim2.new(0,4,0,1146)
sec3.BackgroundTransparency = 1
sec3.Text = "  🌐 SERVIDOR"
sec3.TextColor3 = themes[currentThemeIndex].accent
sec3.Font = Enum.Font.GothamBold
sec3.TextSize = 12
sec3.TextXAlignment = Enum.TextXAlignment.Left
sec3.Parent = page3

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-10,0,18)
statusLabel.Position = UDim2.new(0,4,0,1172)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = page3

local function ServerHop()
    statusLabel.Text = "  🔍 Procurando servidor..."
    task.spawn(function()
        local placeId = game.PlaceId
        local ok, response = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if not ok or not response then statusLabel.Text = "  ❌ Erro ao buscar."; return end
        local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
        if not ok2 or not data or not data.data then statusLabel.Text = "  ❌ Nenhum servidor."; return end
        local servers = {}
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers, s.id) end
        end
        if #servers == 0 then statusLabel.Text = "  ❌ Nada disponível."; return end
        local newS = servers[math.random(1, #servers)]
        statusLabel.Text = "  🚀 Entrando..."
        local ok3, err = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, newS, player) end)
        if not ok3 then statusLabel.Text = "  ❌ Falha: " .. tostring(err) end
    end)
end

local function Rejoin()
    statusLabel.Text = "  🔄 Reconectando..."
    task.spawn(function()
        local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
        if not ok then statusLabel.Text = "  ❌ Falha: " .. tostring(err) end
    end)
end

CreateButtonItem(page3, "Server Hop (novo servidor)", 1192, ServerHop)
CreateButtonItem(page3, "Rejoin (mesmo servidor)", 1230, Rejoin)

-- =========================================================
-- PÁGINA 4: CONFIG
-- =========================================================
local keybindBtn = CreateButtonItem(page4, "Tecla Menu: " .. toggleKey.Name, 0, function()
    isWaitingForKey = true
    keybindBtn.Text = "  Pressione uma tecla..."
end)

local function UpdateAllThemedColors()
    local t = themes[currentThemeIndex]
    mainFrame.BackgroundColor3 = t.bg
    topBar.BackgroundColor3 = t.top
    topBarExt.BackgroundColor3 = t.top
    mainStroke.Color = t.accent
    bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.bg), ColorSequenceKeypoint.new(1, t.top)})
    tpPopup.BackgroundColor3 = t.bg
    ignorePopup.BackgroundColor3 = t.bg
    wpPopup.BackgroundColor3 = t.bg
    infoPopup.BackgroundColor3 = t.bg
    playerListFrame.BackgroundColor3 = t.bg
    plHeader.BackgroundColor3 = t.top
    consoleFrame.BackgroundColor3 = t.bg
    consoleHeader.BackgroundColor3 = t.top
    radarFrame.BackgroundColor3 = t.bg
    rfs.Color = t.accent
    watermarkLabel.BackgroundColor3 = t.bg
    wms.Color = t.accent
    fpsLabel.BackgroundColor3 = t.bg
    pingLabel.BackgroundColor3 = t.bg
end

local colorBtn = CreateButtonItem(page4, "Tema: " .. themes[currentThemeIndex].name, 38, function()
    currentThemeIndex = currentThemeIndex + 1
    if currentThemeIndex > #themes then currentThemeIndex = 1 end
    UpdateAllThemedColors()
    colorBtn.Text = "  🎨 Tema: " .. themes[currentThemeIndex].name
    Notify("🎨 Tema: " .. themes[currentThemeIndex].name, themes[currentThemeIndex].accent)
end)

local function SerializeSettings()
    local out = {}
    for k, v in pairs(Settings) do
        if k ~= "Keybinds" and k ~= "IgnoredPlayers" and k ~= "Waypoints" and k ~= "WaypointsPerGame" then
            if typeof(v) == "EnumItem" then
                local es = tostring(v):match("Enum%.(.+)$")
                out[k] = "ENUM:" .. (es or "KeyCode.Unknown")
            elseif typeof(v) == "Color3" then
                out[k] = "COLOR:" .. tostring(v.R) .. "," .. tostring(v.G) .. "," .. tostring(v.B)
            else out[k] = v end
        end
    end
    local kb = {}
    for k, v in pairs(Settings.Keybinds) do
        if v and typeof(v) == "EnumItem" then
            local es = tostring(v):match("Enum%.(.+)$")
            kb[k] = es or ""
        end
    end
    out._Keybinds = kb
    local ig = {}
    for uid, val in pairs(Settings.IgnoredPlayers) do if val then ig[tostring(uid)] = true end end
    out._IgnoredPlayers = ig
    out._WaypointsPerGame = Settings.WaypointsPerGame
    out._ThemeIndex = currentThemeIndex
    return out
end

local function ApplyLoadedSettings(data)
    local wasFPS = Settings.FPSBoostEnabled
    for k, v in pairs(data) do
        if k == "_Keybinds" then
            for kk, vv in pairs(v) do
                local eT, eN = vv:match("^(%w+)%.(%w+)$")
                if eT and eN then
                    local ok, res = pcall(function() return Enum[eT][eN] end)
                    if ok then Settings.Keybinds[kk] = res end
                end
            end
        elseif k == "_IgnoredPlayers" then
            Settings.IgnoredPlayers = {}
            for uid, val in pairs(v) do if val then Settings.IgnoredPlayers[tonumber(uid)] = true end end
        elseif k == "_WaypointsPerGame" then
            Settings.WaypointsPerGame = v or {}
        elseif k == "_ThemeIndex" then
            currentThemeIndex = tonumber(v) or 1
            if currentThemeIndex < 1 or currentThemeIndex > #themes then currentThemeIndex = 1 end
            UpdateAllThemedColors()
            colorBtn.Text = "  🎨 Tema: " .. themes[currentThemeIndex].name
        elseif k ~= "Keybinds" then
            if type(v) == "string" and v:sub(1,5) == "ENUM:" then
                local eT, eN = v:sub(6):match("^(%w+)%.(%w+)$")
                if eT and eN then
                    local ok, res = pcall(function() return Enum[eT][eN] end)
                    if ok then Settings[k] = res end
                end
            elseif type(v) == "string" and v:sub(1,6) == "COLOR:" then
                local r, g, b = v:sub(7):match("^([%d%.]+),([%d%.]+),([%d%.]+)$")
                if r and g and b then Settings[k] = Color3.new(tonumber(r), tonumber(g), tonumber(b)) end
            else Settings[k] = v end
        end
    end
    for _, e in ipairs(ToggleRegistry) do
        local val = Settings[e.key]
        if type(val) ~= "boolean" then Settings[e.key] = (val == true) end
        e.setter(Settings[e.key], true)
    end
    for _, e in ipairs(SliderRegistry) do pcall(function() e.updateFn() end) end
    for _, e in ipairs(InputRegistry) do e.textBox.Text = tostring(e.getValue()) end
    if aimbotKeyBtn then aimbotKeyBtn.Text = "  🎯 Tecla Aimbot: " .. Settings.AimbotKey.Name end
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Settings.FOVColor
    FOVInnerCircle.Radius = Settings.FOVInner
    FOVInnerCircle.Color = Settings.FOVInnerColor
    if Settings.FullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(150,150,150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
        Lighting.Brightness = Settings.FullbrightBrightness
        Lighting.ClockTime = 12
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
    end
    if wasFPS ~= Settings.FPSBoostEnabled then ApplyFPSBoost(Settings.FPSBoostEnabled) end
    playerListFrame.Visible = Settings.PlayerListEnabled and not hiddenMode or false
    watermarkLabel.Visible = Settings.WatermarkEnabled and not hiddenMode or false
    fpsLabel.Visible = Settings.FpsCounterEnabled and not hiddenMode or false
    pingLabel.Visible = Settings.PingCounterEnabled and not hiddenMode or false
    radarFrame.Visible = Settings.RadarEnabled and not hiddenMode or false
    consoleFrame.Visible = Settings.ConsoleEnabled and not hiddenMode or false
end

local saveBtn = CreateButtonItem(page4, "Salvar Configurações", 76, function()
    if writefile then
        local ok, err = pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(SerializeSettings())) end)
        if ok then Notify("💾 Config salva!", Color3.fromRGB(60,220,60))
        else Notify("❌ Erro: " .. tostring(err), Color3.fromRGB(255,60,60)) end
    else Notify("❌ Sem writefile", Color3.fromRGB(255,60,60)) end
end)
saveBtn.BackgroundColor3 = Color3.fromRGB(50,90,50)

local loadBtn = CreateButtonItem(page4, "Carregar Configurações", 114, function()
    if isfile and readfile then
        if isfile(CONFIG_FILE) then
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
            if ok and data then
                ApplyLoadedSettings(data)
                Notify("📂 Config carregada!", Color3.fromRGB(60,220,60))
            else Notify("❌ Config inválida", Color3.fromRGB(255,60,60)) end
        else Notify("⚠️ Nenhuma config salva", Color3.fromRGB(255,200,60)) end
    else Notify("❌ Sem readfile", Color3.fromRGB(255,60,60)) end
end)
loadBtn.BackgroundColor3 = Color3.fromRGB(50,50,90)

local resetBtn = CreateButtonItem(page4, "Resetar Tudo", 152, function()
    for _, e in ipairs(AllToggles) do e.setter(e.default, true) end
    Settings.AimbotKey = Enum.KeyCode.Q
    Settings.AimPart = "Head"
    Settings.FOV = 120
    Settings.FOVInner = 40
    Settings.MaxDistance = 500
    Settings.FOVColor = Color3.fromRGB(255,255,255)
    Settings.FOVInnerColor = Color3.fromRGB(255,100,100)
    Settings.Prediction = 20
    Settings.ESPLineColor = Color3.fromRGB(255,255,255)
    Settings.ESPNameColor = Color3.fromRGB(255,255,255)
    Settings.ESPHealthColor = Color3.fromRGB(80,255,80)
    Settings.ESPSkeletonColor = Color3.fromRGB(255,255,255)
    Settings.ESPBoxColor = Color3.fromRGB(255,80,80)
    Settings.ESPMaxDistance = 1000
    Settings.FlySpeed = 50
    Settings.WalkspeedValue = 16
    Settings.FullbrightBrightness = 2
    Settings.AntiVoidHeight = -50
    Settings.TrailColor = Color3.fromRGB(255,100,220)
    Settings.TPSmoothSpeed = 0.3
    Settings.CrosshairSize = 10
    Settings.CrosshairColor = Color3.fromRGB(0,255,0)
    Settings.RadarRange = 500
    Settings.RadarSize = 130
    Settings.ConsoleSize = 200
    Settings.CustomSoundId = ""
    Settings.HideMenuKey = Enum.KeyCode.Insert
    Settings.IgnoredPlayers = {}
    for k, _ in pairs(Settings.Keybinds) do Settings.Keybinds[k] = nil end
    Lighting.Ambient = originalLighting.Ambient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.ClockTime = originalLighting.ClockTime
    ApplyFPSBoost(false)
    currentThemeIndex = 1
    UpdateAllThemedColors()
    for _, e in ipairs(SliderRegistry) do pcall(function() e.updateFn() end) end
    for _, e in ipairs(InputRegistry) do e.textBox.Text = tostring(e.getValue()) end
    Notify("🔄 Tudo resetado!", Color3.fromRGB(60,220,60))
end)
resetBtn.BackgroundColor3 = Color3.fromRGB(90,40,40)

local sec4 = Instance.new("TextLabel")
sec4.Size = UDim2.new(1,-10,0,22)
sec4.Position = UDim2.new(0,4,0,196)
sec4.BackgroundTransparency = 1
sec4.Text = "  🔊 SOM / NOTIFICAÇÕES"
sec4.TextColor3 = themes[currentThemeIndex].accent
sec4.Font = Enum.Font.GothamBold
sec4.TextSize = 12
sec4.TextXAlignment = Enum.TextXAlignment.Left
sec4.Parent = page4

CreateToggleItem(page4, "Notificações com Som", 224, function(s) Settings.SoundNotificationsEnabled = s end, false, true, "SoundNotificationsEnabled")
CreateInputItem(page4, "ID do Som de Notificação", 262,
    function() return Settings.CustomSoundId end,
    function(v) Settings.CustomSoundId = v end, nil, nil, "CustomSoundId", true)

CreateToggleItem(page4, "Hit Sound", 300, function(s) Settings.HitSoundEnabled = s end, false, true, "HitSoundEnabled")
CreateInputItem(page4, "ID do Hit Sound", 338,
    function() return Settings.HitSoundId end,
    function(v) Settings.HitSoundId = v end, nil, nil, "HitSoundId", true)

CreateToggleItem(page4, "Kill Sound", 376, function(s) Settings.KillSoundEnabled = s end, false, true, "KillSoundEnabled")
CreateInputItem(page4, "ID do Kill Sound", 414,
    function() return Settings.KillSoundId end,
    function(v) Settings.KillSoundId = v end, nil, nil, "KillSoundId", true)

local sec5 = Instance.new("TextLabel")
sec5.Size = UDim2.new(1,-10,0,22)
sec5.Position = UDim2.new(0,4,0,454)
sec5.BackgroundTransparency = 1
sec5.Text = "  🖥️ HUD / EXTRAS"
sec5.TextColor3 = themes[currentThemeIndex].accent
sec5.Font = Enum.Font.GothamBold
sec5.TextSize = 12
sec5.TextXAlignment = Enum.TextXAlignment.Left
sec5.Parent = page4

CreateToggleItem(page4, "Anti-AFK", 482, function(s) Settings.AntiAFKEnabled = s end, false, true, "AntiAFKEnabled")
CreateToggleItem(page4, "Anti-AFK Melhorado", 520, function(s) Settings.AntiAFKEnhanced = s end, false, true, "AntiAFKEnhanced")
CreateToggleItem(page4, "Auto-Clicker", 558, function(state)
    Settings.AutoClickerEnabled = state
    autoClickerActive = state
end, false, true, "AutoClickerEnabled")

CreateSlider(page4, "Intervalo Auto-Clicker", 596, 0.05, 1,
    function() return Settings.AutoClickerInterval end,
    function(v) Settings.AutoClickerInterval = v end, "s", "AutoClickerInterval")

CreateToggleItem(page4, "Watermark", 650, function(s)
    Settings.WatermarkEnabled = s
    watermarkLabel.Visible = s and not hiddenMode or false
end, false, true, "WatermarkEnabled")

CreateToggleItem(page4, "Watermark RGB", 688, function(s) Settings.WatermarkRGB = s end, false, true, "WatermarkRGB")
CreateToggleItem(page4, "FPS Counter", 726, function(s)
    Settings.FpsCounterEnabled = s
    fpsLabel.Visible = s and not hiddenMode or false
end, false, true, "FpsCounterEnabled")

CreateToggleItem(page4, "FPS Avançado", 764, function(s) Settings.FpsAdvanced = s end, false, true, "FpsAdvanced")
CreateToggleItem(page4, "Ping Counter", 802, function(s)
    Settings.PingCounterEnabled = s
    pingLabel.Visible = s and not hiddenMode or false
end, false, true, "PingCounterEnabled")

CreateToggleItem(page4, "Radar 2D", 840, function(s)
    Settings.RadarEnabled = s
    radarFrame.Visible = s and not hiddenMode or false
end, false, true, "RadarEnabled")

CreateSlider(page4, "Alcance Radar", 878, 100, 2000,
    function() return Settings.RadarRange end,
    function(v) Settings.RadarRange = v end, " studs", "RadarRange")

CreateSlider(page4, "Tamanho Radar", 932, 80, 300,
    function() return Settings.RadarSize end,
    function(v) Settings.RadarSize = v; radarFrame.Size = UDim2.new(0,v,0,v); rcc.Parent = radarCenter end, "", "RadarSize")

CreateToggleItem(page4, "Console Log", 986, function(s)
    Settings.ConsoleEnabled = s
    consoleFrame.Visible = s and not hiddenMode or false
end, false, true, "ConsoleEnabled")

CreateSlider(page4, "Altura Console", 1024, 100, 500,
    function() return Settings.ConsoleSize end,
    function(v) Settings.ConsoleSize = v; consoleFrame.Size = UDim2.new(0,300,0,v) end, "", "ConsoleSize")

CreateToggleItem(page4, "Custom Crosshair", 1078, function(s) Settings.CrosshairEnabled = s end, false, true, "CrosshairEnabled")

CreateSlider(page4, "Tamanho Crosshair", 1116, 3, 30,
    function() return Settings.CrosshairSize end,
    function(v) Settings.CrosshairSize = v end, "", "CrosshairSize")

CreateColorPalette(page4, 1170, function() return Settings.CrosshairColor end, function(c)
    Settings.CrosshairColor = c
    for _, l in ipairs(crossLines) do l.Color = c end
end, "Cor do Crosshair", "CrosshairColor")

local sec6 = Instance.new("TextLabel")
sec6.Size = UDim2.new(1,-10,0,22)
sec6.Position = UDim2.new(0,4,0,1238)
sec6.BackgroundTransparency = 1
sec6.Text = "  🔔 NOTIFICAÇÕES EXTRAS"
sec6.TextColor3 = themes[currentThemeIndex].accent
sec6.Font = Enum.Font.GothamBold
sec6.TextSize = 12
sec6.TextXAlignment = Enum.TextXAlignment.Left
sec6.Parent = page4

CreateToggleItem(page4, "Kill Notifier", 1266, function(s) Settings.KillNotifierEnabled = s end, false, true, "KillNotifierEnabled")
CreateToggleItem(page4, "Join/Leave Notifier", 1304, function(s) Settings.JoinLeaveNotifierEnabled = s end, false, true, "JoinLeaveNotifierEnabled")

-- =========================================================
-- PÁGINA 5: PRESETS / INFO
-- =========================================================
local infoSec = Instance.new("TextLabel")
infoSec.Size = UDim2.new(1,-10,0,22)
infoSec.Position = UDim2.new(0,4,0,0)
infoSec.BackgroundTransparency = 1
infoSec.Text = "  📋 PRESETS"
infoSec.TextColor3 = themes[currentThemeIndex].accent
infoSec.Font = Enum.Font.GothamBold
infoSec.TextSize = 12
infoSec.TextXAlignment = Enum.TextXAlignment.Left
infoSec.Parent = page5

local presetsInfo = Instance.new("TextLabel")
presetsInfo.Size = UDim2.new(1,-10,0,60)
presetsInfo.Position = UDim2.new(0,4,0,30)
presetsInfo.BackgroundTransparency = 1
presetsInfo.Text = "  Salva até 5 combos de configuração.\n  Clica em SALVAR pra guardar o atual,\n  ou num preset salvo pra carregar."
presetsInfo.TextColor3 = Color3.fromRGB(180,180,180)
presetsInfo.Font = Enum.Font.Gotham
presetsInfo.TextSize = 11
presetsInfo.TextXAlignment = Enum.TextXAlignment.Left
presetsInfo.TextYAlignment = Enum.TextYAlignment.Top
presetsInfo.TextWrapped = true
presetsInfo.Parent = page5

local presetBtns = {}
for i = 1, 5 do
    local btn = CreateButtonItem(page5, "Preset " .. i .. " — vazio", 100 + (i-1)*38, function()
        if presetBtns[i] and presetBtns[i].data then
            ApplyLoadedSettings(presetBtns[i].data)
            Notify("📂 Preset " .. i .. " carregado!", Color3.fromRGB(60,220,60))
        else
            Notify("⚠️ Preset " .. i .. " vazio", Color3.fromRGB(255,200,60))
        end
    end)
    presetBtns[i] = {btn=btn, data=nil}
end

local savePresetBtn = CreateButtonItem(page5, "💾 Salvar Config Atual num Preset", 100 + 5*38, function()
    local data = SerializeSettings()
    local selected = nil
    for i = 1, 5 do
        if not presetBtns[i].data then
            selected = i
            break
        end
    end
    if not selected then selected = 1 end
    presetBtns[selected].data = data
    presetBtns[selected].btn.Text = "  Preset " .. selected .. " — salvo"
    Notify("💾 Salvo no Preset " .. selected, Color3.fromRGB(60,220,60))
end)
savePresetBtn.BackgroundColor3 = Color3.fromRGB(50,90,50)

local clearPresetsBtn = CreateButtonItem(page5, "🗑️ Limpar Todos os Presets", 100 + 6*38, function()
    for i = 1, 5 do
        presetBtns[i].data = nil
        presetBtns[i].btn.Text = "  Preset " .. i .. " — vazio"
    end
    Notify("🗑️ Presets limpos", Color3.fromRGB(255,200,60))
end)
clearPresetsBtn.BackgroundColor3 = Color3.fromRGB(90,40,40)

print("[Guasti] Parte 5a carregada. Cole a parte 5b abaixo.")

-- =========================================================
-- UTILITÁRIOS DE ESTADO
-- =========================================================
local function GetDistColor(dist)
    if dist < 100 then return Color3.fromRGB(255,50,50)
    elseif dist < 300 then return Color3.fromRGB(255,220,50)
    else return Color3.fromRGB(50,255,50) end
end

local function IsPlayerBlocked(p)
    return Settings.IgnoredPlayers[p.UserId] == true
end

local function IsTeammate(p)
    if not Settings.TeamCheck then return false end
    if player.Team and p.Team then return player.Team == p.Team end
    return false
end

local function IsESPTeammate(p)
    if Settings.IgnoredPlayers[p.UserId] then return true end
    if not Settings.ESPTeamCheck then return false end
    if player.Team and p.Team then return player.Team == p.Team end
    return false
end

local function CanSeePart(tp, part)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    local r = Workspace:Raycast(origin, dir, params)
    if not r then return false end
    return r.Instance:IsDescendantOf(tp.Character)
end

local function GetAimPart(ch)
    if Settings.AimPart == "Head" then return ch:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart")
    end
    return ch:FindFirstChild("Head")
end

local function GetClosestTarget()
    local mp = UserInputService:GetMouseLocation()
    local innerBest, innerBD = nil, math.huge
    local outerBest, outerBD = nil, math.huge
    local useInner = Settings.FOVDoubleEnabled
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            if not IsPlayerBlocked(p) and not IsTeammate(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local part = GetAimPart(p.Character)
                if hum and part and hum.Health > 0 then
                    local d = (Camera.CFrame.Position - part.Position).Magnitude
                    if d <= Settings.MaxDistance then
                        local sp, on = Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local sd = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                            if CanSeePart(p, part) then
                                if useInner and sd <= Settings.FOVInner and sd < innerBD then
                                    innerBD = sd
                                    innerBest = part
                                end
                                if sd <= Settings.FOV and sd < outerBD then
                                    outerBD = sd
                                    outerBest = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if innerBest then return innerBest end
    return outerBest
end

-- =========================================================
-- ESP OBJECTS
-- =========================================================
local r15Conns = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local r6Conns = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function NewLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 1
    l.Transparency = 1
    l.Color = Color3.fromRGB(255,255,255)
    return l
end

local function NewText()
    local t = Drawing.new("Text")
    t.Visible = false
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.fromRGB(0,0,0)
    t.Size = 13
    t.Font = 2
    t.Color = Color3.fromRGB(255,255,255)
    return t
end

local function CreateESPObj(p)
    if p == player or ESPObjects[p] then return end
    local d = {}
    d.Line = NewLine()
    d.Health = NewText()
    d.Distance = NewText()
    d.NameTag = NewText()
    d.NameTag.Size = 15
    d.Weapon = NewText()
    d.Weapon.Size = 12
    d.BoxTop = NewLine()
    d.BoxBottom = NewLine()
    d.BoxLeft = NewLine()
    d.BoxRight = NewLine()
    d.BoxHBar = NewLine()
    d.BoxHBar.Thickness = 5
    d.HPBarBg = NewLine()
    d.HPBarFg = NewLine()
    d.HPBarBg.Thickness = 4
    d.HPBarFg.Thickness = 4
    d.R15Lines = {}
    for _, pair in ipairs(r15Conns) do
        table.insert(d.R15Lines, {Line=NewLine(), A=pair[1], B=pair[2]})
    end
    d.R6Lines = {}
    for _, pair in ipairs(r6Conns) do
        table.insert(d.R6Lines, {Line=NewLine(), A=pair[1], B=pair[2]})
    end
    local chams = Instance.new("Highlight")
    chams.Name = "GuastiESP_Chams"
    chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    chams.FillTransparency = 0.5
    chams.OutlineTransparency = 0.4
    chams.FillColor = Color3.fromRGB(255,70,70)
    chams.OutlineColor = Color3.fromRGB(255,70,70)
    chams.Enabled = false
    chams.Parent = espFolder
    d.Chams = chams
    ESPObjects[p] = d
end

local function RemoveESPObj(p)
    local d = ESPObjects[p]
    if not d then return end
    pcall(function()
        for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight","BoxHBar","HPBarBg","HPBarFg"}) do
            if d[key] then d[key]:Remove() end
        end
        for _, i in ipairs(d.R15Lines) do i.Line:Remove() end
        for _, i in ipairs(d.R6Lines) do i.Line:Remove() end
        d.Chams:Destroy()
    end)
    ESPObjects[p] = nil
end

for _, p in ipairs(Players:GetPlayers()) do CreateESPObj(p) end
Track(Players.PlayerAdded:Connect(function(p)
    CreateESPObj(p)
    if Settings.JoinLeaveNotifierEnabled then
        Notify("🚪 + " .. p.Name .. " entrou", Color3.fromRGB(80,220,80))
    end
end))
Track(Players.PlayerRemoving:Connect(function(p)
    RemoveESPObj(p)
    if Settings.JoinLeaveNotifierEnabled then
        Notify("🚪 - " .. p.Name .. " saiu", Color3.fromRGB(220,80,80))
    end
end))

local function HideESP(d)
    for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight","BoxHBar","HPBarBg","HPBarFg"}) do
        if d[key] then d[key].Visible = false end
    end
    for _, i in ipairs(d.R15Lines) do i.Line.Visible = false end
    for _, i in ipairs(d.R6Lines) do i.Line.Visible = false end
    if d.Chams then d.Chams.Enabled = false end
end

-- =========================================================
-- RENDER STEPS
-- =========================================================
RunService:BindToRenderStep("Guasti_FOV", Enum.RenderPriority.Camera.Value + 1, function()
    if isCleanedUp then return end
    local mp = UserInputService:GetMouseLocation()
    local hasTarget = false
    if Settings.AimbotEnabled then
        local t = GetClosestTarget()
        hasTarget = t ~= nil
    end

    local outerC = Settings.FOVColor
    local innerC = Settings.FOVInnerColor
    if Settings.FOVStateColor and Settings.AimbotEnabled then
        if hasTarget then
            outerC = Color3.fromRGB(60,220,60)
            innerC = Color3.fromRGB(60,220,60)
        else
            outerC = Color3.fromRGB(220,60,60)
            innerC = Color3.fromRGB(220,60,60)
        end
    end

    FOVCircle.Position = mp
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = outerC
    FOVCircle.Transparency = Settings.FOVTransparency
    FOVCircle.Visible = Settings.AimbotEnabled and Settings.FOVVisible

    FOVInnerCircle.Position = mp
    FOVInnerCircle.Radius = Settings.FOVInner
    FOVInnerCircle.Color = innerC
    FOVInnerCircle.Visible = Settings.AimbotEnabled and Settings.FOVVisible and Settings.FOVDoubleEnabled

    if Settings.CrosshairEnabled and not hiddenMode then
        local vp = Camera.ViewportSize
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz = Settings.CrosshairSize
        crossLines[1].From = Vector2.new(cx - sz, cy)
        crossLines[1].To = Vector2.new(cx + sz, cy)
        crossLines[2].From = Vector2.new(cx, cy - sz)
        crossLines[2].To = Vector2.new(cx, cy + sz)
        for _, l in ipairs(crossLines) do
            l.Color = Settings.CrosshairColor
            l.Visible = true
        end
    else
        for _, l in ipairs(crossLines) do l.Visible = false end
    end
end)

RunService:BindToRenderStep("Guasti_Aimbot", Enum.RenderPriority.Camera.Value + 2, function()
    if isCleanedUp then return end
    if not Settings.AimbotEnabled then
        PredictDot.Visible = false
        TargetLine.Visible = false
        return
    end
    local tp = GetClosestTarget()
    if not tp then
        PredictDot.Visible = false
        TargetLine.Visible = false
        return
    end
    local tPos = tp.Position
    if Settings.PredictionEnabled then
        local v = tp.AssemblyLinearVelocity
        if v and v.Magnitude > 0.1 then
            tPos = tPos + v * (Settings.Prediction / 100)
        end
    end
    if Settings.PredictVisual then
        local sp, on = Camera:WorldToViewportPoint(tPos)
        if on then
            PredictDot.Position = Vector2.new(sp.X, sp.Y)
            PredictDot.Visible = true
        else PredictDot.Visible = false end
    else PredictDot.Visible = false end

    if Settings.AimbotTargetLine then
        local sp, on = Camera:WorldToViewportPoint(tPos)
        if on then
            TargetLine.From = UserInputService:GetMouseLocation()
            TargetLine.To = Vector2.new(sp.X, sp.Y)
            TargetLine.Visible = true
        else TargetLine.Visible = false end
    else TargetLine.Visible = false end

    local tc = CFrame.new(Camera.CFrame.Position, tPos)
    if Settings.SilentAimEnabled then
        return
    end
    if Settings.Smoothness <= 0 then
        Camera.CFrame = tc
    else
        local a = math.clamp(1 - (Settings.Smoothness / 100), 0.001, 1)
        Camera.CFrame = Camera.CFrame:Lerp(tc, a)
    end
end)

-- Aim Assist (suave)
RunService.RenderStepped:Connect(function()
    if isCleanedUp then return end
    if not Settings.AimAssistEnabled then return end
    local tp = GetClosestTarget()
    if not tp then return end
    local tc = CFrame.new(Camera.CFrame.Position, tp.Position)
    local a = math.clamp(Settings.AimAssistStrength / 1000, 0.001, 0.1)
    Camera.CFrame = Camera.CFrame:Lerp(tc, a)
end)

RunService:BindToRenderStep("Guasti_ESP", Enum.RenderPriority.Camera.Value + 3, function()
    if isCleanedUp then return end
    local vp = Camera.ViewportSize
    animatedESPPhase = (animatedESPPhase + 0.03) % 1
    local animAlpha = 0.5 + math.sin(animatedESPPhase * math.pi * 2) * 0.5

    for tp, d in pairs(ESPObjects) do
        local ch = tp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not Settings.ESPEnabled or not ch or not hum or hum.Health <= 0 or IsESPTeammate(tp) then
            HideESP(d)
        else
            local root = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
            if not root then HideESP(d)
            else
                local head = ch:FindFirstChild("Head")
                local sp, on = Camera:WorldToViewportPoint(root.Position)
                if not on then HideESP(d)
                else
                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    if dist > Settings.ESPMaxDistance then HideESP(d)
                    else
                        local lineC = Settings.ESPLineColor
                        local nameC = Settings.ESPNameColor
                        local hpC = Settings.ESPHealthColor
                        local skC = Settings.ESPSkeletonColor
                        local bxC = Settings.ESPBoxColor
                        if Settings.ESPRainbow then
                            local rb = GetRainbowColor()
                            lineC = rb; nameC = rb; hpC = rb; skC = rb; bxC = rb
                        end
                        if Settings.ESPDistanceColor then lineC = GetDistColor(dist) end

                        if Settings.ESPLine then
                            d.Line.From = Vector2.new(vp.X/2, 0)
                            d.Line.To = Vector2.new(sp.X, sp.Y)
                            d.Line.Color = lineC
                            d.Line.Thickness = Settings.ESPAnimated and (1 + animAlpha) or 1
                            d.Line.Visible = true
                        else d.Line.Visible = false end

                        if Settings.ESPHealth then
                            d.Health.Text = "❤️ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                            d.Health.Position = Vector2.new(sp.X, sp.Y - 32)
                            d.Health.Color = hpC
                            d.Health.Visible = true
                        else d.Health.Visible = false end

                        if Settings.ESPDistance and not Settings.ESPDistanceInName then
                            d.Distance.Text = "📐 " .. math.floor(dist) .. "m"
                            d.Distance.Position = Vector2.new(sp.X, sp.Y + 24)
                            d.Distance.Color = lineC
                            d.Distance.Visible = true
                        else d.Distance.Visible = false end

                        if Settings.ESPName and head then
                            local hp, ho = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.8,0))
                            if ho then
                                local txt = tp.Name
                                if Settings.ESPDistanceInName then
                                    txt = txt .. " [" .. math.floor(dist) .. "m]"
                                end
                                d.NameTag.Text = txt
                                d.NameTag.Position = Vector2.new(hp.X, hp.Y)
                                d.NameTag.Color = nameC
                                d.NameTag.Visible = true
                            else d.NameTag.Visible = false end
                        else d.NameTag.Visible = false end

                        if Settings.ESPWeapon and head then
                            local tool = ch:FindFirstChildOfClass("Tool")
                            if tool then
                                local hp, ho = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2.6,0))
                                if ho then
                                    d.Weapon.Text = "🔫 " .. tool.Name
                                    d.Weapon.Position = Vector2.new(hp.X, hp.Y)
                                    d.Weapon.Color = Color3.fromRGB(255,255,100)
                                    d.Weapon.Visible = true
                                else d.Weapon.Visible = false end
                            else d.Weapon.Visible = false end
                        else d.Weapon.Visible = false end

                        -- Box 2D
                        if Settings.ESPBox and head then
                            local hpos, hon = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            local fpos, fon = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                            if hon and fon then
                                local top = hpos.Y
                                local bot = fpos.Y
                                local hgt = bot - top
                                local w = hgt * 0.5
                                local lft = hpos.X - w/2
                                local rgt = hpos.X + w/2
                                d.BoxTop.From = Vector2.new(lft, top); d.BoxTop.To = Vector2.new(rgt, top)
                                d.BoxBottom.From = Vector2.new(lft, bot); d.BoxBottom.To = Vector2.new(rgt, bot)
                                d.BoxLeft.From = Vector2.new(lft, top); d.BoxLeft.To = Vector2.new(lft, bot)
                                d.BoxRight.From = Vector2.new(rgt, top); d.BoxRight.To = Vector2.new(rgt, bot)
                                for _, l in ipairs({d.BoxTop, d.BoxBottom, d.BoxLeft, d.BoxRight}) do
                                    l.Color = bxC; l.Visible = true
                                end
                            else
                                d.BoxTop.Visible=false; d.BoxBottom.Visible=false; d.BoxLeft.Visible=false; d.BoxRight.Visible=false
                            end
                        else
                            d.BoxTop.Visible=false; d.BoxBottom.Visible=false; d.BoxLeft.Visible=false; d.BoxRight.Visible=false
                        end

                        -- Box Horizontal (barra)
                        if Settings.ESPBoxHorizontal and head then
                            local hpos, hon = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            if hon then
                                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local barW = 40
                                local bx = hpos.X
                                local by = hpos.Y - 45
                                d.BoxHBar.From = Vector2.new(bx - barW/2, by)
                                d.BoxHBar.To = Vector2.new(bx - barW/2 + barW * pct, by)
                                d.BoxHBar.Color = hpC
                                d.BoxHBar.Visible = true
                            else d.BoxHBar.Visible = false end
                        else d.BoxHBar.Visible = false end

                        -- Box de Vida (barra vertical)
                        if Settings.ESPBoxHealth and head then
                            local hpos, hon = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            local fpos, fon = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                            if hon and fon then
                                local bx = hpos.X - 55
                                local ty = hpos.Y
                                local by = fpos.Y
                                d.HPBarBg.From = Vector2.new(bx, ty); d.HPBarBg.To = Vector2.new(bx, by)
                                d.HPBarBg.Color = Color3.fromRGB(40,40,40); d.HPBarBg.Visible = true
                                local maxH = hum.MaxHealth
                                if not maxH or maxH <= 0 then maxH = 100 end
                                local curH = hum.Health
                                if not curH or curH < 0 then curH = 0 end
                                local pct = math.clamp(curH / maxH, 0, 1)
                                local ft = by - (by - ty) * pct
                                d.HPBarFg.From = Vector2.new(bx, ft); d.HPBarFg.To = Vector2.new(bx, by)
                                local hc
                                if pct > 0.65 then hc = Color3.fromRGB(60,220,60)
                                elseif pct > 0.30 then hc = Color3.fromRGB(255,200,60)
                                else hc = Color3.fromRGB(255,60,60) end
                                d.HPBarFg.Color = hc; d.HPBarFg.Visible = true
                            else
                                d.HPBarBg.Visible=false; d.HPBarFg.Visible=false
                            end
                        else
                            d.HPBarBg.Visible=false; d.HPBarFg.Visible=false
                        end

                        if Settings.ESPChams then
                            d.Chams.Adornee = ch
                            d.Chams.Enabled = true
                            d.Chams.FillColor = lineC
                            d.Chams.OutlineColor = lineC
                        else d.Chams.Enabled = false end

                        -- Esqueleto
                        local isR15 = ch:FindFirstChild("UpperTorso") ~= nil
                        local active = isR15 and d.R15Lines or d.R6Lines
                        local inactive = isR15 and d.R6Lines or d.R15Lines
                        if Settings.ESPSkeleton then
                            for _, i in ipairs(inactive) do i.Line.Visible = false end
                            for _, i in ipairs(active) do
                                local pa = ch:FindFirstChild(i.A)
                                local pb = ch:FindFirstChild(i.B)
                                if pa and pb then
                                    local posA, vA = Camera:WorldToViewportPoint(pa.Position)
                                    local posB, vB = Camera:WorldToViewportPoint(pb.Position)
                                    if vA and vB then
                                        i.Line.From = Vector2.new(posA.X, posA.Y)
                                        i.Line.To = Vector2.new(posB.X, posB.Y)
                                        i.Line.Color = skC
                                        i.Line.Thickness = Settings.ESPSkeleton3D and 2 or 1
                                        i.Line.Visible = true
                                    else i.Line.Visible = false end
                                else i.Line.Visible = false end
                            end
                        else
                            for _, i in ipairs(d.R6Lines) do i.Line.Visible = false end
                            for _, i in ipairs(d.R15Lines) do i.Line.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)

-- Fly
RunService:BindToRenderStep("Guasti_Fly", Enum.RenderPriority.Camera.Value + 4, function(dt)
    if isCleanedUp then return end
    if not Settings.FlyEnabled then return end
    local ch = player.Character
    if not ch then return end
    local rt = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not rt or not hum then return end
    hum.PlatformStand = true
    hum.AutoRotate = false
    local cam = Camera.CFrame
    rt.CFrame = CFrame.new(rt.Position, rt.Position + cam.LookVector)
    rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
    rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
    local move = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
    if move.Magnitude > 0 then
        move = move.Unit
        rt.CFrame = rt.CFrame + move * Settings.FlySpeed * dt
    end
    rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
    rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
end)

-- =========================================================
-- LOOPS GERAIS
-- =========================================================
local fpsAcc = 0
local fpsFrames = 0
Track(RunService.Heartbeat:Connect(function(dt)
    if isCleanedUp then return end
    fpsAcc = fpsAcc + dt
    fpsFrames = fpsFrames + 1
    if fpsAcc >= 0.5 then
        local fps = math.floor(fpsFrames / fpsAcc)
        fpsAcc = 0; fpsFrames = 0
        if Settings.FpsCounterEnabled then
            if Settings.FpsAdvanced then
                if fps < sessionFpsMin then sessionFpsMin = fps end
                if fps > sessionFpsMax then sessionFpsMax = fps end
                sessionFpsSum = sessionFpsSum + fps
                sessionFpsCount = sessionFpsCount + 1
                local avg = math.floor(sessionFpsSum / math.max(1, sessionFpsCount))
                fpsLabel.Size = UDim2.new(0, 200, 0, 24)
                fpsLabel.Text = "📊 FPS: " .. fps .. " | min " .. sessionFpsMin .. " | max " .. sessionFpsMax .. " | avg " .. avg
            else
                fpsLabel.Text = "📊 FPS: " .. fps
            end
            if fps >= 50 then fpsLabel.TextColor3 = Color3.fromRGB(60,220,60)
            elseif fps >= 30 then fpsLabel.TextColor3 = Color3.fromRGB(255,200,60)
            else fpsLabel.TextColor3 = Color3.fromRGB(255,60,60) end
        end
        if Settings.PingCounterEnabled then
            local ping = 0
            pcall(function()
                local item = Stats.Network.ServerStatsItem["Data Ping"]
                ping = math.floor(item:GetValue())
            end)
            if ping == 0 then
                pcall(function() ping = math.floor(Players:GetNetworkPing() * 1000) end)
            end
            if ping > 0 then
                pingLabel.Text = "📡 Ping: " .. ping .. "ms"
                if ping <= 80 then pingLabel.TextColor3 = Color3.fromRGB(60,220,60)
                elseif ping <= 150 then pingLabel.TextColor3 = Color3.fromRGB(255,200,60)
                else pingLabel.TextColor3 = Color3.fromRGB(255,60,60) end
            end
        end
    end

    -- Walkspeed
    if Settings.WalkspeedEnabled then
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= Settings.WalkspeedValue then
                hum.WalkSpeed = Settings.WalkspeedValue
            end
        end
    end

    -- Anti-Fling
    if Settings.AntiFlingEnabled then
        local ch = player.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            if rt then
                local v = rt.AssemblyLinearVelocity
                if v.Magnitude > 150 then rt.AssemblyLinearVelocity = v.Unit * 100 end
            end
        end
    end

    -- Anti-Stun
    if Settings.AntiStunEnabled then
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                end)
            end
        end
    end

    -- Infinite Ammo
    if Settings.InfiniteAmmoEnabled then
        local ch = player.Character
        if ch then
            local tool = ch:FindFirstChildOfClass("Tool")
            local roots = {}
            if tool then table.insert(roots, tool) end
            table.insert(roots, ch)
            for _, root in ipairs(roots) do
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = obj.Name:lower()
                        if n:find("ammo") or n:find("clip") or n:find("bullet") or n:find("mag") then
                            pcall(function() obj.Value = 999 end)
                        end
                    end
                end
            end
        end
    end

    -- Anti-Void
    if Settings.AntiVoidEnabled then
        local ch = player.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if rt and hum and hum.Health > 0 and rt.Position.Y < Settings.AntiVoidHeight then
                rt.CFrame = CFrame.new(rt.Position.X, 100, rt.Position.Z)
                rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
                Notify("🛡️ Anti-Void: resgatado!", Color3.fromRGB(60,220,60))
            end
        end
    end

    -- Trigger Bot auto-fire
    if Settings.TriggerBotEnabled then
        local target = GetClosestTarget()
        if target then
            pcall(function()
                if mouse1click then mouse1click()
                else
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
        end
    end
end))

-- Bhop
Track(UserInputService.JumpRequest:Connect(function()
    if Settings.BhopEnabled and not isCleanedUp then
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end))

-- Speed Boost em queda
Track(RunService.Stepped:Connect(function()
    if isCleanedUp then return end
    if not Settings.SpeedBoostFallEnabled then return end
    local ch = player.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local rt = ch:FindFirstChild("HumanoidRootPart")
    if hum and rt and hum:GetState() == Enum.HumanoidStateType.Freefall then
        local v = rt.AssemblyLinearVelocity
        rt.AssemblyLinearVelocity = Vector3.new(v.X, math.max(-Settings.SpeedBoostFallValue, v.Y), v.Z)
    end
end))

-- Noclip
Track(RunService.Stepped:Connect(function()
    if isCleanedUp or not Settings.NoclipEnabled then return end
    local ch = player.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

-- Anti-AFK
Track(player.Idled:Connect(function()
    if Settings.AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

-- Anti-AFK melhorado
Track(RunService.Heartbeat:Connect(function()
    if isCleanedUp or not Settings.AntiAFKEnhanced then return end
    pcall(function()
        VirtualUser:CaptureController()
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
        end
    end)
end))

-- Auto-Clicker
Track(task.spawn(function()
    while not isCleanedUp do
        if Settings.AutoClickerEnabled then
            pcall(function()
                if mouse1click then mouse1click()
                else
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
            task.wait(Settings.AutoClickerInterval)
        else
            task.wait(0.3)
        end
    end
end))

-- Kill Notifier (monitor de mortes)
Track(RunService.Heartbeat:Connect(function()
    if isCleanedUp then return end
    if not Settings.KillNotifierEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local prev = lastHealth[p.UserId] or hum.MaxHealth
                if prev > 0 and hum.Health <= 0 then
                    Notify("💀 " .. p.Name .. " morreu", Color3.fromRGB(255,80,80))
                    PlayKillSound()
                end
                lastHealth[p.UserId] = hum.Health
            end
        end
    end
end))

-- Radar
Track(task.spawn(function()
    while not isCleanedUp do
        task.wait(0.12)
        if Settings.RadarEnabled and radarFrame.Visible then
            radarFrame.Size = UDim2.new(0, Settings.RadarSize, 0, Settings.RadarSize)
            for _, d in pairs(radarDots) do
                if d and d.Parent then d:Destroy() end
            end
            radarDots = {}
            local myRt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if myRt then
                local myPos = myRt.Position
                local camDir = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                local range = Settings.RadarRange
                local r = Settings.RadarSize / 2 - 6
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local pr = p.Character:FindFirstChild("HumanoidRootPart")
                        local ph = p.Character:FindFirstChildOfClass("Humanoid")
                        if pr and ph and ph.Health > 0 then
                            local rel = pr.Position - myPos
                            local dist = rel.Magnitude
                            if dist <= range then
                                local dot = Instance.new("Frame")
                                dot.Size = UDim2.new(0,8,0,8)
                                dot.BackgroundColor3 = Settings.IgnoredPlayers[p.UserId] and Color3.fromRGB(100,100,100) or Color3.fromRGB(255,80,80)
                                dot.BorderSizePixel = 0
                                dot.ZIndex = 102
                                dot.Parent = radarFrame
                                local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
                                local relX = rel:Dot(camRight)
                                local relZ = rel:Dot(camDir)
                                local angle = math.atan2(relX, relZ)
                                local px = math.sin(angle) * (dist / range) * r
                                local py = -math.cos(angle) * (dist / range) * r
                                dot.Position = UDim2.new(0.5, px - 4, 0.5, py - 4)
                                table.insert(radarDots, dot)
                            end
                        end
                    end
                end
            end
        else
            task.wait(0.4)
        end
    end
end))

-- Player List
Track(task.spawn(function()
    while not isCleanedUp do
        task.wait(0.4)
        if Settings.PlayerListEnabled and playerListFrame.Visible and not hiddenMode then
            playerListFrame.Size = UDim2.new(0, 210, 0, 280)
            for _, c in ipairs(plList:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            local sorted = {}
            for _, p in ipairs(Players:GetPlayers()) do table.insert(sorted, p) end
            table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
            local y = 0
            for _, p in ipairs(sorted) do
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local rt = ch and ch:FindFirstChild("HumanoidRootPart")
                local mrt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.floor(hum.MaxHealth) or 100
                local dist = 0
                if rt and mrt then dist = math.floor((mrt.Position - rt.Position).Magnitude) end
                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1,-3,0,20)
                row.Position = UDim2.new(0,0,0,y)
                row.BackgroundTransparency = 1
                row.Text = ""
                row.AutoButtonColor = false
                row.ZIndex = 302
                row.Parent = plList
                row.MouseButton1Click:Connect(function() OpenInfoPopup(p) end)

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.55,0,1,0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = (p == player and "★ " or "  ") .. p.Name
                nameLbl.TextColor3 = (p == player) and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,255,255)
                nameLbl.Font = Enum.Font.GothamMedium
                nameLbl.TextSize = 11
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex = 302
                nameLbl.Parent = row

                local hpLbl = Instance.new("TextLabel")
                hpLbl.Size = UDim2.new(0.2,0,1,0)
                hpLbl.Position = UDim2.new(0.55,0,0,0)
                hpLbl.BackgroundTransparency = 1
                hpLbl.Text = hp .. "hp"
                local pct = hp / maxHp
                hpLbl.TextColor3 = pct > 0.65 and Color3.fromRGB(60,220,60) or (pct > 0.30 and Color3.fromRGB(255,200,60) or Color3.fromRGB(255,60,60))
                hpLbl.Font = Enum.Font.GothamBold
                hpLbl.TextSize = 11
                hpLbl.ZIndex = 302
                hpLbl.Parent = row

                local distLbl = Instance.new("TextLabel")
                distLbl.Size = UDim2.new(0.25,0,1,0)
                distLbl.Position = UDim2.new(0.75,0,0,0)
                distLbl.BackgroundTransparency = 1
                distLbl.Text = dist .. "m"
                distLbl.TextColor3 = Color3.fromRGB(200,200,200)
                distLbl.Font = Enum.Font.GothamBold
                distLbl.TextSize = 11
                distLbl.TextXAlignment = Enum.TextXAlignment.Right
                distLbl.ZIndex = 302
                distLbl.Parent = row

                y = y + 22
            end
            plList.CanvasSize = UDim2.new(0,0,0,y+3)
        end
    end
end))

-- Watermark RGB
Track(RunService.RenderStepped:Connect(function()
    if isCleanedUp or not Settings.WatermarkRGB or not Settings.WatermarkEnabled then return end
    local h = (tick() * 0.1) % 1
    watermarkLabel.TextColor3 = Color3.fromHSV(h, 1, 1)
    wms.Color = Color3.fromHSV(h, 1, 1)
end))

-- Anti-Ban básico
Track(RunService.Heartbeat:Connect(function()
    if isCleanedUp or not Settings.AntiBanEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local n = p.Name:lower()
            local dn = p.DisplayName:lower()
            if n:find("mod") or n:find("admin") or dn:find("moderador") or dn:find("admin") then
                if Settings.AimbotEnabled then
                    SetAimbotState(false, true)
                end
                if Settings.ESPEnabled then
                    ToggleRefs.ESP(false, true)
                end
            end
        end
    end
end))

-- =========================================================
-- CLEANUP
-- =========================================================
_G.GuastiCleanup = function()
    if isCleanedUp then return end
    isCleanedUp = true
    for _, c in ipairs(TrackedConnections) do
        pcall(function() c:Disconnect() end)
    end
    TrackedConnections = {}
    pcall(function() RunService:UnbindFromRenderStep("Guasti_FOV") end)
    pcall(function() RunService:UnbindFromRenderStep("Guasti_Aimbot") end)
    pcall(function() RunService:UnbindFromRenderStep("Guasti_ESP") end)
    pcall(function() RunService:UnbindFromRenderStep("Guasti_Fly") end)
    pcall(function() FOVCircle:Remove() end)
    pcall(function() FOVInnerCircle:Remove() end)
    pcall(function() PredictDot:Remove() end)
    pcall(function() TargetLine:Remove() end)
    for _, l in ipairs(crossLines) do
        pcall(function() l:Remove() end)
    end
    for p, d in pairs(ESPObjects) do
        pcall(function()
            for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight","BoxHBar","HPBarBg","HPBarFg"}) do
                if d[key] then d[key]:Remove() end
            end
            for _, i in ipairs(d.R15Lines) do i.Line:Remove() end
            for _, i in ipairs(d.R6Lines) do i.Line:Remove() end
            if d.Chams then d.Chams:Destroy() end
        end)
    end
    ESPObjects = {}
    pcall(function()
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.FogEnd = originalLighting.FogEnd
    end)
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then
                for _, o in ipairs(originalEffects) do
                    if o.effect == e then e.Enabled = o.enabled; break end
                end
            end
        end
    end)
    pcall(function() espFolder:Destroy() end)
    pcall(function() screenGui:Destroy() end)
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
    pcall(function()
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local rt = ch:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.WalkSpeed = 16
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
            if rt then
                rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
                rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
                local t = rt:FindFirstChild("GuastiTrail"); if t then t:Destroy() end
                local a0 = rt:FindFirstChild("GuastiTrailA0"); if a0 then a0:Destroy() end
                local a1 = rt:FindFirstChild("GuastiTrailA1"); if a1 then a1:Destroy() end
            end
        end
    end)
    _G.GuastiCleanup = nil
end

-- =========================================================
-- INPUT HANDLERS
-- =========================================================
local function IsAimbotKeyInput(input)
    local k = Settings.AimbotKey
    if typeof(k) == "EnumItem" then
        if k.EnumType == Enum.KeyCode then
            return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == k
        elseif k.EnumType == Enum.UserInputType then
            return input.UserInputType == k
        end
    end
    return false
end

local function UpdateKeybindButtonsUI()
    if clickTPKeyBtn then clickTPKeyBtn.Text = "  📍 Tecla Click TP: " .. (Settings.Keybinds.ClickTP and Settings.Keybinds.ClickTP.Name or "NENHUMA") end
    if tpPlayerKeyBtn then tpPlayerKeyBtn.Text = "  👤 Tecla TP Player: " .. (Settings.Keybinds.TPPlayer and Settings.Keybinds.TPPlayer.Name or "NENHUMA") end
    for k, e in pairs(keybindRows) do
        e.btn.Text = "  " .. e.label .. ": " .. (Settings.Keybinds[k] and Settings.Keybinds[k].Name or "NENHUMA")
    end
end

Track(UserInputService.InputBegan:Connect(function(input, gp)
    if isWaitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        Settings.MenuKey = input.KeyCode
        isWaitingForKey = false
        keybindBtn.Text = "  ⌨️ Tecla Menu: " .. toggleKey.Name
        return
    end
    if waitingForAimbotKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Settings.AimbotKey = input.KeyCode
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  🎯 Tecla Aimbot: " .. input.KeyCode.Name
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton4 then
            Settings.AimbotKey = Enum.UserInputType.MouseButton4
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  🎯 Tecla Aimbot: Mouse4"
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton5 then
            Settings.AimbotKey = Enum.UserInputType.MouseButton5
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  🎯 Tecla Aimbot: Mouse5"
            return
        end
    end
    if waitingKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.Keybinds[waitingKeybind] = input.KeyCode
        UpdateKeybindButtonsUI()
        waitingKeybind = nil
        return
    end

    local fb = UserInputService:GetFocusedTextBox()
    if fb then return end

    if IsAimbotKeyInput(input) then SetAimbotState() end

    if not gp then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Settings.MenuKey then
                ToggleMenu()
                return
            end
            if input.KeyCode == Settings.HideMenuKey then
                ToggleHiddenMode()
                return
            end
            if input.KeyCode == Settings.TriggerBotKey then
                if ToggleRefs.TriggerBot then ToggleRefs.TriggerBot() end
                return
            end
            for name, key in pairs(Settings.Keybinds) do
                if key and input.KeyCode == key then
                    if name == "Fly" and ToggleRefs.Fly then ToggleRefs.Fly()
                    elseif name == "Noclip" and ToggleRefs.Noclip then ToggleRefs.Noclip()
                    elseif name == "Walkspeed" and ToggleRefs.Walkspeed then ToggleRefs.Walkspeed()
                    elseif name == "ESP" and ToggleRefs.ESP then ToggleRefs.ESP()
                    elseif name == "TPPlayer" then ToggleTPPopup() end
                    return
                end
            end
        end
    end
end))

Track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Settings.ClickTPEnabled and Settings.Keybinds.ClickTP
        and input.UserInputType == Enum.UserInputType.MouseButton1
        and UserInputService:IsKeyDown(Settings.Keybinds.ClickTP) then
        local rt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if rt and mouse and mouse.Hit then
            SmoothTeleport(CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)))
        end
    end
end))

-- Chat Commands
Track(player.Chatted:Connect(function(msg)
    local cmd, arg = msg:match("^/(%w+)%s*(.*)$")
    if not cmd then return end
    cmd = cmd:lower()
    if cmd == "fly" and ToggleRefs.Fly then ToggleRefs.Fly()
    elseif cmd == "noclip" and ToggleRefs.Noclip then ToggleRefs.Noclip()
    elseif cmd == "aimbot" and ToggleRefs.Aimbot then ToggleRefs.Aimbot()
    elseif cmd == "esp" and ToggleRefs.ESP then ToggleRefs.ESP()
    elseif cmd == "cmds" then
        Notify("📖 /fly /noclip /aimbot /esp /ws /tp", themes[currentThemeIndex].accent)
    end
end))

-- =========================================================
-- GUI CONTROL (drag, resize, toggle)
-- =========================================================
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0,16,0,16)
resizeHandle.Position = UDim2.new(1,-18,1,-18)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = "◢"
resizeHandle.TextColor3 = Color3.fromRGB(150,150,150)
resizeHandle.TextSize = 12
resizeHandle.Parent = mainFrame

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        mainFrame.Position = newPos
        shadowFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 4, newPos.Y.Scale, newPos.Y.Offset + 4)
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

local resizing, rsP, rsS
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimized then
        resizing = true; rsP = input.Position; rsS = mainFrame.AbsoluteSize
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - rsP
        local nw = math.clamp(rsS.X + d.X, 400, 900)
        local nh = math.clamp(rsS.Y + d.Y, 300, 700)
        mainFrame.Size = UDim2.new(0,nw,0,nh)
        shadowFrame.Size = UDim2.new(0,nw,0,nh)
        normalSize = mainFrame.Size
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end))

local function UpdateMouseLock()
    if isOpen and not hiddenMode then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    else
        if player.CameraMode == Enum.CameraMode.LockFirstPerson then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
    end
end

local function ToggleMenu()
    if hiddenMode then return end
    isOpen = not isOpen
    if isOpen then
        mainFrame.Visible = true
        shadowFrame.Visible = true
        mainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
        TweenService:Create(shadowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
    else
        local t = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size=UDim2.new(0,0,0,0)})
        TweenService:Create(shadowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size=UDim2.new(0,0,0,0)}):Play()
        t:Play()
        t.Completed:Connect(function()
            if not isOpen then
                mainFrame.Visible = false
                shadowFrame.Visible = false
                mainFrame.Size = normalSize
                shadowFrame.Size = normalSize
            end
        end)
        tpPopup.Visible = false
        ignorePopup.Visible = false
        wpPopup.Visible = false
        infoPopup.Visible = false
    end
    UpdateMouseLock()
end

local function ToggleHiddenMode()
    hiddenMode = not hiddenMode
    if hiddenMode then
        mainFrame.Visible = false
        shadowFrame.Visible = false
        tpPopup.Visible = false
        ignorePopup.Visible = false
        wpPopup.Visible = false
        infoPopup.Visible = false
        playerListFrame.Visible = false
        watermarkLabel.Visible = false
        fpsLabel.Visible = false
        pingLabel.Visible = false
        radarFrame.Visible = false
        consoleFrame.Visible = false
        for _, l in ipairs(crossLines) do l.Visible = false end
        Notify("📸 Screenshot: ON", themes[currentThemeIndex].accent)
    else
        mainFrame.Visible = isOpen
        shadowFrame.Visible = isOpen
        if Settings.PlayerListEnabled then playerListFrame.Visible = true end
        if Settings.WatermarkEnabled then watermarkLabel.Visible = true end
        if Settings.FpsCounterEnabled then fpsLabel.Visible = true end
        if Settings.PingCounterEnabled then pingLabel.Visible = true end
        if Settings.RadarEnabled then radarFrame.Visible = true end
        if Settings.ConsoleEnabled then consoleFrame.Visible = true end
        Notify("📸 Screenshot: OFF", themes[currentThemeIndex].accent)
    end
    UpdateMouseLock()
end

local function ConfirmClose()
    if not Settings.ConfirmCloseEnabled then
        if _G.GuastiCleanup then _G.GuastiCleanup() end
        return
    end
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0,300,0,140)
    confirmFrame.Position = UDim2.new(0.5,-150,0.5,-70)
    confirmFrame.BackgroundColor3 = themes[currentThemeIndex].bg
    confirmFrame.ZIndex = 600
    confirmFrame.Parent = screenGui
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,10); cc.Parent = confirmFrame
    local cs = Instance.new("UIStroke"); cs.Color = Color3.fromRGB(255,60,60); cs.Thickness = 2; cs.Parent = confirmFrame

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-20,0,60)
    t.Position = UDim2.new(0,10,0,20)
    t.BackgroundTransparency = 1
    t.Text = "⚠️ Tem certeza que quer fechar\no Guasti Scripts?"
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextWrapped = true
    t.ZIndex = 601
    t.Parent = confirmFrame

    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0,100,0,34)
    yes.Position = UDim2.new(0,30,1,-50)
    yes.BackgroundColor3 = Color3.fromRGB(200,60,60)
    yes.Text = "✅ Sim, fechar"
    yes.TextColor3 = Color3.fromRGB(255,255,255)
    yes.Font = Enum.Font.GothamBold
    yes.TextSize = 12
    yes.ZIndex = 601
    yes.Parent = confirmFrame
    local yc = Instance.new("UICorner"); yc.CornerRadius = UDim.new(0,6); yc.Parent = yes

    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0,100,0,34)
    no.Position = UDim2.new(1,-130,1,-50)
    no.BackgroundColor3 = Color3.fromRGB(60,130,60)
    no.Text = "❌ Cancelar"
    no.TextColor3 = Color3.fromRGB(255,255,255)
    no.Font = Enum.Font.GothamBold
    no.TextSize = 12
    no.ZIndex = 601
    no.Parent = confirmFrame
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,6); nc.Parent = no

    no.MouseButton1Click:Connect(function() confirmFrame:Destroy() end)
    yes.MouseButton1Click:Connect(function()
        confirmFrame:Destroy()
        if _G.GuastiCleanup then _G.GuastiCleanup() end
    end)
end

closeBtn.MouseButton1Click:Connect(function() if isOpen then ToggleMenu() end end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentFrame.Visible = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, normalSize.X.Offset, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        shadowFrame:TweenSize(UDim2.new(0, normalSize.X.Offset, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = false
    else
        mainFrame:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        shadowFrame:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = true
    end
end)

-- Botão fechar total no final da page4
local destroyBtn = CreateButtonItem(page4, "❌ Fechar Totalmente o Script", 1342, function()
    ConfirmClose()
end)
destroyBtn.BackgroundTransparency = 1
destroyBtn.TextColor3 = Color3.fromRGB(255,60,60)
destroyBtn.Font = Enum.Font.GothamBold

-- =========================================================
-- SPLASH SCREEN
-- =========================================================
local splashBg = Instance.new("Frame")
splashBg.Size = UDim2.new(1,0,1,0)
splashBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
splashBg.BackgroundTransparency = 1
splashBg.BorderSizePixel = 0
splashBg.ZIndex = 700
splashBg.Parent = screenGui

local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(1,0,0,60)
splashTitle.Position = UDim2.new(0,0,0.5,-50)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "Guasti Scripts"
splashTitle.TextColor3 = Color3.fromRGB(255,255,255)
splashTitle.TextSize = 44
splashTitle.Font = Enum.Font.GothamBlack
splashTitle.TextTransparency = 1
splashTitle.ZIndex = 701
splashTitle.Parent = splashBg

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(1,0,0,25)
splashSub.Position = UDim2.new(0,0,0.5,10)
splashSub.BackgroundTransparency = 1
splashSub.Text = "(Carregando...)"
splashSub.TextColor3 = Color3.fromRGB(220,220,220)
splashSub.TextSize = 18
splashSub.Font = Enum.Font.GothamMedium
splashSub.TextTransparency = 1
splashSub.ZIndex = 701
splashSub.Parent = splashBg

TweenService:Create(splashBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

local rgbActive = true
task.spawn(function()
    local h = 0
    while rgbActive do
        h = (h + 0.006) % 1
        splashTitle.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

local dotsActive = true
task.spawn(function()
    local fr = {".", "..", "..."}
    local i = 1
    while dotsActive do
        splashSub.Text = "(Carregando" .. fr[i] .. ")"
        i = i + 1
        if i > #fr then i = 1 end
        task.wait(0.35)
    end
end)

task.wait(4)
rgbActive = false
dotsActive = false

TweenService:Create(splashBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
task.wait(0.55)
splashBg:Destroy()

mainFrame.Visible = true
shadowFrame.Visible = true
mainFrame.Size = UDim2.new(0,0,0,0)
shadowFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
TweenService:Create(shadowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
isOpen = true
UpdateMouseLock()

-- =========================================================
-- AUTO-UPDATER
-- =========================================================
if Settings.AutoUpdaterEnabled then
    task.spawn(function()
        local ok, version = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/indexcreator/guasti/main/version.txt")
        end)
        if ok and version and version:find("v31") then
            Notify("⬆️ Atualização disponível! v31", Color3.fromRGB(80,220,80))
        end
    end)
end

-- =========================================================
-- FINAL
-- =========================================================
Notify("✅ Guasti Scripts v30 carregado!", themes[currentThemeIndex].accent)
print("[Guasti] v30 carregado com sucesso!")
