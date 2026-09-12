--//======================================================
--//                    GUASTI SCRIPTS v29
--//   TUDO incluído: Aimbot2/Trigger/Predict/Radar/etc
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

local Settings = {
    MenuKey = Enum.KeyCode.P,
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
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVInnerColor = Color3.fromRGB(255, 100, 100),
    FOVTransparency = 1,
    PredictionEnabled = false,
    Prediction = 20,
    PredictVisual = false,
    TriggerBotEnabled = false,
    TriggerBotKey = Enum.KeyCode.E,
    TriggerBotFOV = 8,
    ESPEnabled = false,
    ESPTeamCheck = false,
    ESPLine = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPChams = false,
    ESPSkeleton = false,
    ESPName = false,
    ESPBox = false,
    ESPBoxHealth = false,
    ESPWeapon = false,
    ESPDistanceInName = false,
    ESPRainbow = false,
    ESPDistanceColor = false,
    ESPMaxDistance = 1000,
    ESPLineColor = Color3.fromRGB(255, 255, 255),
    ESPNameColor = Color3.fromRGB(255, 255, 255),
    ESPHealthColor = Color3.fromRGB(80, 255, 80),
    ESPSkeletonColor = Color3.fromRGB(255, 255, 255),
    ESPBoxColor = Color3.fromRGB(255, 80, 80),
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    WalkspeedEnabled = false,
    WalkspeedValue = 16,
    AntiFlingEnabled = false,
    InfiniteJumpEnabled = false,
    AntiStunEnabled = false,
    InfiniteAmmoEnabled = false,
    FullbrightEnabled = false,
    FullbrightBrightness = 2,
    FPSBoostEnabled = false,
    AntiVoidEnabled = false,
    AntiVoidHeight = -50,
    TrailEnabled = false,
    TrailColor = Color3.fromRGB(255, 100, 220),
    ClickTPEnabled = false,
    TPSmooth = true,
    TPSmoothSpeed = 0.3,
    Waypoints = {},
    AntiAFKEnabled = false,
    SoundNotificationsEnabled = false,
    CustomSoundId = "",
    PlayerListEnabled = false,
    HideMenuKey = Enum.KeyCode.Insert,
    WatermarkEnabled = false,
    CrosshairEnabled = false,
    CrosshairSize = 10,
    CrosshairColor = Color3.fromRGB(0, 255, 0),
    FpsCounterEnabled = false,
    PingCounterEnabled = false,
    RadarEnabled = false,
    RadarRange = 500,
    ConsoleEnabled = false,
    IgnoredPlayers = {},
    Keybinds = {Fly=nil, Noclip=nil, Walkspeed=nil, ESP=nil, ClickTP=nil, TPPlayer=nil},
}

-- Drawing objects
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
PredictDot.Color = Color3.fromRGB(255, 50, 50)
PredictDot.Transparency = 1
PredictDot.Filled = true

local crossLines = {}
for i = 1, 2 do
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    l.Color = Settings.CrosshairColor
    l.Transparency = 1
    crossLines[i] = l
end

local toggleKey = Settings.MenuKey
local isWaitingForKey = false
local isMinimized = false
local normalSize = UDim2.new(0, 480, 0, 380)
local isOpen = true
local ESPObjects = {}
local waitingForAimbotKey = false
local waitingTriggerKey = false
local waitingKeybind = nil
local waitingHideMenuKey = false
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

local themes = {
    {name="Preto (Padrão)", bg=Color3.fromRGB(15,15,15), top=Color3.fromRGB(25,25,25)},
    {name="Cinza Escuro", bg=Color3.fromRGB(30,30,30), top=Color3.fromRGB(45,45,45)},
    {name="Azul Noturno", bg=Color3.fromRGB(20,25,35), top=Color3.fromRGB(30,40,55)},
    {name="Roxo Escuro", bg=Color3.fromRGB(30,20,35), top=Color3.fromRGB(45,30,55)},
    {name="Verde Militar", bg=Color3.fromRGB(25,35,25), top=Color3.fromRGB(35,50,35)},
    {name="Vermelho Sombrio", bg=Color3.fromRGB(35,20,20), top=Color3.fromRGB(55,30,30)},
    {name="Rosa Neon", bg=Color3.fromRGB(35,20,30), top=Color3.fromRGB(60,30,50)},
    {name="Ciano Escuro", bg=Color3.fromRGB(18,32,35), top=Color3.fromRGB(28,48,52)},
    {name="Laranja Quente", bg=Color3.fromRGB(35,24,16), top=Color3.fromRGB(55,38,26)},
    {name="Cinza Chumbo", bg=Color3.fromRGB(38,38,42), top=Color3.fromRGB(55,55,60)},
}
local currentThemeIndex = 1

-- GUI Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GuastiGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local notifSound = Instance.new("Sound")
notifSound.SoundId = "rbxassetid://6042053626"
notifSound.Volume = 0.35
notifSound.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = normalSize
mainFrame.Position = UDim2.new(1, -normalSize.X.Offset - 20, 0, 20)
mainFrame.BackgroundColor3 = themes[currentThemeIndex].bg
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
mainFrame.Visible = false
local mainCorner = Instance.new("UICorner"); mainCorner.CornerRadius = UDim.new(0,8); mainCorner.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = themes[currentThemeIndex].top
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
local topCorner = Instance.new("UICorner"); topCorner.CornerRadius = UDim.new(0,8); topCorner.Parent = topBar

local topBarExt = Instance.new("Frame")
topBarExt.Size = UDim2.new(1,0,0,5)
topBarExt.Position = UDim2.new(0,0,1,-5)
topBarExt.BackgroundColor3 = themes[currentThemeIndex].top
topBarExt.BorderSizePixel = 0
topBarExt.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,115,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Guasti Scripts"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Bandeira BR
local flagContainer = Instance.new("Frame")
flagContainer.Size = UDim2.new(0,26,0,18)
flagContainer.AnchorPoint = Vector2.new(0,0.5)
flagContainer.Position = UDim2.new(0,128,0.5,0)
flagContainer.BackgroundColor3 = Color3.fromRGB(0,156,59)
flagContainer.BorderSizePixel = 0
flagContainer.ClipsDescendants = true
flagContainer.ZIndex = 2
flagContainer.Parent = topBar
local flagCorner = Instance.new("UICorner"); flagCorner.CornerRadius = UDim.new(0,2); flagCorner.Parent = flagContainer
local diamond = Instance.new("Frame")
diamond.Size = UDim2.new(0,11,0,11)
diamond.AnchorPoint = Vector2.new(0.5,0.5)
diamond.Position = UDim2.new(0.5,0,0.5,0)
diamond.BackgroundColor3 = Color3.fromRGB(255,223,0)
diamond.BorderSizePixel = 0
diamond.Rotation = 45
diamond.ZIndex = 3
diamond.Parent = flagContainer
local flagCircle = Instance.new("Frame")
flagCircle.Size = UDim2.new(0,5,0,5)
flagCircle.AnchorPoint = Vector2.new(0.5,0.5)
flagCircle.Position = UDim2.new(0.5,0,0.5,0)
flagCircle.BackgroundColor3 = Color3.fromRGB(0,39,118)
flagCircle.BorderSizePixel = 0
flagCircle.ZIndex = 4
flagCircle.Parent = flagContainer
local flagCircleCorner = Instance.new("UICorner"); flagCircleCorner.CornerRadius = UDim.new(1,0); flagCircleCorner.Parent = flagCircle

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,30,0,30)
minimizeBtn.Position = UDim2.new(1,-60,0,0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,0,1,-30)
contentFrame.Position = UDim2.new(0,0,0,30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0,110,1,-15)
tabContainer.Position = UDim2.new(0,10,0,10)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = contentFrame

local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1,-130,1,-15)
pagesContainer.Position = UDim2.new(0,125,0,10)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = contentFrame

local function CreateTabButton(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,35)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = tabContainer
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
    return btn
end

local function CreatePage(h)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.Visible = false
    p.CanvasSize = UDim2.new(0,0,0,h or 420)
    p.Parent = pagesContainer
    return p
end

local tab1Btn = CreateTabButton("Aimbot", 0)
local tab2Btn = CreateTabButton("ESP", 45)
local tab3Btn = CreateTabButton("Outros", 90)
local tab4Btn = CreateTabButton("Config", 135)

local page1 = CreatePage(820)
local page2 = CreatePage(1300)
local page3 = CreatePage(1260)
local page4 = CreatePage(1180)

page1.Visible = true
tab1Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
tab1Btn.TextColor3 = Color3.fromRGB(255,255,255)

local function SwitchTab(sb, sp)
    for _, c in ipairs(tabContainer:GetChildren()) do
        if c:IsA("TextButton") then
            c.BackgroundColor3 = Color3.fromRGB(45,45,45)
            c.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end
    for _, c in ipairs(pagesContainer:GetChildren()) do
        if c:IsA("GuiObject") then c.Visible = false end
    end
    sb.BackgroundColor3 = Color3.fromRGB(60,60,60)
    sb.TextColor3 = Color3.fromRGB(255,255,255)
    sp.Visible = true
end

tab1Btn.MouseButton1Click:Connect(function() SwitchTab(tab1Btn, page1) end)
tab2Btn.MouseButton1Click:Connect(function() SwitchTab(tab2Btn, page2) end)
tab3Btn.MouseButton1Click:Connect(function() SwitchTab(tab3Btn, page3) end)
tab4Btn.MouseButton1Click:Connect(function() SwitchTab(tab4Btn, page4) end)

-- Console log
local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(0,280,0,200)
consoleFrame.Position = UDim2.new(0,10,0,10)
consoleFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
consoleFrame.BackgroundTransparency = 0.2
consoleFrame.BorderSizePixel = 0
consoleFrame.ScrollBarThickness = 4
consoleFrame.CanvasSize = UDim2.new(0,0,0,0)
consoleFrame.Visible = false
consoleFrame.ZIndex = 350
consoleFrame.Parent = screenGui
local cfc = Instance.new("UICorner"); cfc.CornerRadius = UDim.new(0,6); cfc.Parent = consoleFrame

local function Log(text, color)
    if not Settings.ConsoleEnabled then return end
    color = color or Color3.fromRGB(200,200,200)
    local l = Instance.new("TextLabel")
    local n = #consoleFrame:GetChildren()
    l.Size = UDim2.new(1,-8,0,18)
    l.Position = UDim2.new(0,4,0,n*18)
    l.BackgroundTransparency = 1
    l.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
    l.TextColor3 = color
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 351
    l.Parent = consoleFrame
    consoleFrame.CanvasSize = UDim2.new(0,0,0,(n+1)*18+5)
    consoleFrame.CanvasPosition = Vector2.new(0, consoleFrame.AbsoluteCanvasSize.Y)
    if n > 50 then consoleFrame:GetChildren()[1]:Destroy() end
end

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

local function Notify(text, color)
    color = color or Color3.fromRGB(80,150,255)
    Log(text, color)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0,280,0,44)
    n.Position = UDim2.new(0.5,-140,0,30)
    n.BackgroundColor3 = Color3.fromRGB(20,20,20)
    n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(255,255,255)
    n.Font = Enum.Font.GothamBold
    n.TextSize = 16
    n.Text = text
    n.TextTransparency = 1
    n.ZIndex = 400
    n.Parent = screenGui
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,8); nc.Parent = n
    local ns = Instance.new("UIStroke"); ns.Color = color; ns.Thickness = 2; ns.Transparency = 1; ns.Parent = n
    TweenService:Create(n, TweenInfo.new(0.3), {TextTransparency=0, BackgroundTransparency=0.15}):Play()
    TweenService:Create(ns, TweenInfo.new(0.3), {Transparency=0}):Play()
    PlayNotifSound(color.G > color.R)
    task.delay(1.6, function()
        if not n or not n.Parent then return end
        local t1 = TweenService:Create(n, TweenInfo.new(0.4), {TextTransparency=1, BackgroundTransparency=1})
        local t2 = TweenService:Create(ns, TweenInfo.new(0.4), {Transparency=1})
        t1:Play(); t2:Play()
        t1.Completed:Connect(function() if n then n:Destroy() end end)
    end)
end

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

-- Item creators
local function CreateToggleItem(parent, name, yPos, callback, initialState, notifyText, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,32)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0,20,0,10)
    ind.Position = UDim2.new(1,-30,0.5,-5)
    ind.BorderSizePixel = 0
    ind.Parent = btn
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(1,0); ic.Parent = ind
    local state = initialState or false
    local function Update()
        ind.BackgroundColor3 = state and Color3.fromRGB(60,220,60) or Color3.fromRGB(220,60,60)
    end
    local function SetState(v, silent)
        if v == nil then state = not state else state = (v == true) end
        Update()
        if settingKey then Settings[settingKey] = state end
        if callback then callback(state) end
        if not silent and notifyText then
            Notify(name .. ": " .. (state and "ON" or "OFF"),
                state and Color3.fromRGB(60,220,60) or Color3.fromRGB(220,60,60))
        end
    end
    Update()
    btn.MouseButton1Click:Connect(function() SetState() end)
    table.insert(AllToggles, {setter=SetState, default=initialState or false})
    if settingKey then table.insert(ToggleRegistry, {key=settingKey, setter=SetState}) end
    return btn, function() return state end, SetState
end

local function CreateButtonItem(parent, name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,32)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function CreateSmallButton(parent, name, xPos, yPos, width, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,width,0,32)
    btn.Position = UDim2.new(0,xPos,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function CreateSlider(parent, label, yPos, minVal, maxVal, getValue, setValue, suffix, settingKey)
    suffix = suffix or ""
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,46)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(45,45,45)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container
    local label_ = Instance.new("TextLabel")
    label_.Size = UDim2.new(1,-12,0,20)
    label_.Position = UDim2.new(0,6,0,2)
    label_.BackgroundTransparency = 1
    label_.Text = label .. ": " .. tostring(getValue()) .. suffix
    label_.TextColor3 = Color3.fromRGB(255,255,255)
    label_.Font = Enum.Font.GothamMedium
    label_.TextSize = 12
    label_.TextXAlignment = Enum.TextXAlignment.Left
    label_.Parent = container
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1,-20,0,10)
    barBg.Position = UDim2.new(0,10,1,-18)
    barBg.BackgroundColor3 = Color3.fromRGB(25,25,25)
    barBg.BorderSizePixel = 0
    barBg.Parent = container
    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(1,0); c2.Parent = barBg
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(80,150,255)
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
        label_.Text = label .. ": " .. tostring(math.floor(value*100+0.5)/100) .. suffix
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
    container.Size = UDim2.new(1,-10,0,32)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(45,45,45)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container
    local label_ = Instance.new("TextLabel")
    label_.Size = UDim2.new(0.5,0,1,0)
    label_.Position = UDim2.new(0,10,0,0)
    label_.BackgroundTransparency = 1
    label_.Text = label
    label_.TextColor3 = Color3.fromRGB(255,255,255)
    label_.Font = Enum.Font.GothamMedium
    label_.TextSize = 12
    label_.TextXAlignment = Enum.TextXAlignment.Left
    label_.Parent = container
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0,120,0,24)
    textBox.Position = UDim2.new(1,-130,0.5,-12)
    textBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
    container.Size = UDim2.new(1,-10,0,60)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(45,45,45)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-12,0,20)
    lbl.Position = UDim2.new(0,6,0,2)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
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
    local btnSize = 26
    local gap = 4
    local buttons = {}
    for i, cc in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,btnSize,0,btnSize)
        b.Position = UDim2.new(0,8 + (i-1)*(btnSize+gap),0,26)
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
                if e.color == cc then
                    e.btn.BorderColor3 = Color3.fromRGB(255,255,255)
                else
                    e.btn.BorderColor3 = Color3.fromRGB(0,0,0)
                end
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
                if e.color == cur then
                    e.btn.BorderColor3 = Color3.fromRGB(255,255,255)
                else
                    e.btn.BorderColor3 = Color3.fromRGB(0,0,0)
                end
            end
        end})
    end
    return container
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

-- Popup base
local function CreatePopup(headerText)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0,280,0,340)
    p.BackgroundColor3 = themes[currentThemeIndex].bg
    p.BorderSizePixel = 0
    p.Visible = false
    p.ZIndex = 300
    p.Parent = screenGui
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,8); pc.Parent = p
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,30)
    h.BackgroundColor3 = themes[currentThemeIndex].top
    h.BorderSizePixel = 0
    h.ZIndex = 301
    h.Parent = p
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0,8); hc.Parent = h
    local hx = Instance.new("Frame")
    hx.Size = UDim2.new(1,0,0,5)
    hx.Position = UDim2.new(0,0,1,-5)
    hx.BackgroundColor3 = themes[currentThemeIndex].top
    hx.BorderSizePixel = 0
    hx.ZIndex = 301
    hx.Parent = h
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-40,1,0)
    t.Position = UDim2.new(0,10,0,0)
    t.BackgroundTransparency = 1
    t.Text = headerText
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 302
    t.Parent = h
    local cl = Instance.new("TextButton")
    cl.Size = UDim2.new(0,30,0,30)
    cl.Position = UDim2.new(1,-30,0,0)
    cl.BackgroundTransparency = 1
    cl.Text = "X"
    cl.TextColor3 = Color3.fromRGB(255,100,100)
    cl.Font = Enum.Font.GothamBold
    cl.TextSize = 14
    cl.ZIndex = 302
    cl.Parent = h
    cl.MouseButton1Click:Connect(function() p.Visible = false end)
    local d = false
    local ds
    local sp
    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true
            ds = input.Position
            sp = p.Position
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

-- TP POPUP
local tpPopup = CreatePopup("TP para Player")
local tpList = Instance.new("ScrollingFrame")
tpList.Size = UDim2.new(1,-20,1,-45)
tpList.Position = UDim2.new(0,10,0,40)
tpList.BackgroundTransparency = 1
tpList.BorderSizePixel = 0
tpList.ScrollBarThickness = 4
tpList.CanvasSize = UDim2.new(0,0,0,0)
tpList.ZIndex = 302
tpList.Parent = tpPopup

local function RefreshTPList()
    for _, c in ipairs(tpList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local sorted = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(sorted, p)
    end
    table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
    local y = 0
    for _, p in ipairs(sorted) do
        local label = p.Name
        if p == player then label = label .. " (você)" end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-5,0,30)
        btn.Position = UDim2.new(0,0,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.Text = "  " .. label
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 303
        btn.Parent = tpList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if p == player then return end
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            local mr = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if tr and mr then
                SmoothTeleport(tr.CFrame + Vector3.new(0,3,0))
                Notify("TP: " .. p.Name, Color3.fromRGB(60,220,60))
                tpPopup.Visible = false
            else
                Notify("Alvo inválido", Color3.fromRGB(255,60,60))
            end
        end)
        y = y + 34
    end
    tpList.CanvasSize = UDim2.new(0,0,0,y+5)
end

local function OpenTPPopup()
    RefreshTPList()
    local mainAbs = mainFrame.AbsolutePosition
    local mainSize = mainFrame.AbsoluteSize
    tpPopup.Position = UDim2.fromOffset(mainAbs.X, mainAbs.Y + mainSize.Y + 10)
    tpPopup.Visible = true
end

local function ToggleTPPopup()
    if tpPopup.Visible then tpPopup.Visible = false else OpenTPPopup() end
end

-- IGNORE POPUP
local ignorePopup = CreatePopup("Ignorar Players")
local ignoreList = Instance.new("ScrollingFrame")
ignoreList.Size = UDim2.new(1,-20,1,-50)
ignoreList.Position = UDim2.new(0,10,0,44)
ignoreList.BackgroundTransparency = 1
ignoreList.BorderSizePixel = 0
ignoreList.ScrollBarThickness = 4
ignoreList.CanvasSize = UDim2.new(0,0,0,0)
ignoreList.ZIndex = 302
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
        btn.BackgroundColor3 = isIgn and Color3.fromRGB(60,220,60) or Color3.fromRGB(45,45,45)
        btn.Text = "  " .. p.Name .. (isIgn and "  [IGNORADO]" or "")
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 303
        btn.Parent = ignoreList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if Settings.IgnoredPlayers[p.UserId] then
                Settings.IgnoredPlayers[p.UserId] = nil
                Notify("Deixou de ignorar: " .. p.Name, Color3.fromRGB(255,200,60))
            else
                Settings.IgnoredPlayers[p.UserId] = true
                Notify("Ignorando: " .. p.Name, Color3.fromRGB(60,220,60))
            end
            RefreshIgnoreList()
        end)
        y = y + 34
    end
    ignoreList.CanvasSize = UDim2.new(0,0,0,y+5)
end

local function OpenIgnorePopup()
    RefreshIgnoreList()
    local mainAbs = mainFrame.AbsolutePosition
    local mainSize = mainFrame.AbsoluteSize
    ignorePopup.Position = UDim2.fromOffset(mainAbs.X, mainAbs.Y + mainSize.Y + 10)
    ignorePopup.Visible = true
end

-- WAYPOINTS POPUP
local wpPopup = CreatePopup("Waypoints")
local wpInputCont = Instance.new("Frame")
wpInputCont.Size = UDim2.new(1,-20,0,30)
wpInputCont.Position = UDim2.new(0,10,0,40)
wpInputCont.BackgroundColor3 = Color3.fromRGB(45,45,45)
wpInputCont.BorderSizePixel = 0
wpInputCont.ZIndex = 302
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
wpNameBox.ZIndex = 303
wpNameBox.Parent = wpInputCont
local wpSaveBtn = Instance.new("TextButton")
wpSaveBtn.Size = UDim2.new(0,70,1,0)
wpSaveBtn.Position = UDim2.new(1,-70,0,0)
wpSaveBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
wpSaveBtn.Text = "Salvar"
wpSaveBtn.TextColor3 = Color3.fromRGB(255,255,255)
wpSaveBtn.Font = Enum.Font.GothamBold
wpSaveBtn.TextSize = 11
wpSaveBtn.ZIndex = 303
wpSaveBtn.Parent = wpInputCont
local wsc = Instance.new("UICorner"); wsc.CornerRadius = UDim.new(0,6); wsc.Parent = wpSaveBtn

local wpList = Instance.new("ScrollingFrame")
wpList.Size = UDim2.new(1,-20,1,-85)
wpList.Position = UDim2.new(0,10,0,80)
wpList.BackgroundTransparency = 1
wpList.BorderSizePixel = 0
wpList.ScrollBarThickness = 4
wpList.CanvasSize = UDim2.new(0,0,0,0)
wpList.ZIndex = 302
wpList.Parent = wpPopup

local function RefreshWPs()
    for _, c in ipairs(wpList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local y = 0
    for i, wp in ipairs(Settings.Waypoints) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-5,0,30)
        row.Position = UDim2.new(0,0,0,y)
        row.BackgroundColor3 = Color3.fromRGB(45,45,45)
        row.BorderSizePixel = 0
        row.ZIndex = 303
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
        nL.ZIndex = 304
        nL.Parent = row
        local tpB = Instance.new("TextButton")
        tpB.Size = UDim2.new(0,45,1,0)
        tpB.Position = UDim2.new(1,-85,0,0)
        tpB.BackgroundColor3 = Color3.fromRGB(60,130,60)
        tpB.Text = "TP"
        tpB.TextColor3 = Color3.fromRGB(255,255,255)
        tpB.Font = Enum.Font.GothamBold
        tpB.TextSize = 11
        tpB.ZIndex = 304
        tpB.Parent = row
        local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,5); tc.Parent = tpB
        local xB = Instance.new("TextButton")
        xB.Size = UDim2.new(0,30,1,0)
        xB.Position = UDim2.new(1,-35,0,0)
        xB.BackgroundColor3 = Color3.fromRGB(120,50,50)
        xB.Text = "X"
        xB.TextColor3 = Color3.fromRGB(255,255,255)
        xB.Font = Enum.Font.GothamBold
        xB.TextSize = 11
        xB.ZIndex = 304
        xB.Parent = row
        local xc = Instance.new("UICorner"); xc.CornerRadius = UDim.new(0,5); xc.Parent = xB
        tpB.MouseButton1Click:Connect(function()
            SmoothTeleport(CFrame.new(wp.pos))
            Notify("TP: " .. wp.name, Color3.fromRGB(60,220,60))
            wpPopup.Visible = false
        end)
        xB.MouseButton1Click:Connect(function()
            table.remove(Settings.Waypoints, i)
            RefreshWPs()
            Notify("WP removido", Color3.fromRGB(255,200,60))
        end)
        y = y + 34
    end
    wpList.CanvasSize = UDim2.new(0,0,0,y+5)
end

wpSaveBtn.MouseButton1Click:Connect(function()
    local rt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rt then return end
    local name = wpNameBox.Text
    if name == "" then name = "WP" .. (#Settings.Waypoints + 1) end
    table.insert(Settings.Waypoints, {name=name, pos=rt.Position})
    Notify("WP salvo: " .. name, Color3.fromRGB(60,220,60))
    RefreshWPs()
    wpNameBox.Text = "WP" .. (#Settings.Waypoints + 1)
end)

local function OpenWPPopup()
    RefreshWPs()
    local mainAbs = mainFrame.AbsolutePosition
    local mainSize = mainFrame.AbsoluteSize
    wpPopup.Position = UDim2.fromOffset(mainAbs.X, mainAbs.Y + mainSize.Size + 10)
    wpPopup.Position = UDim2.fromOffset(mainAbs.X, mainAbs.Y + mainSize.Y + 10)
    wpPopup.Visible = true
end

-- PLAYER LIST FLUTUANTE
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(0,210,0,280)
playerListFrame.Position = UDim2.new(0,10,0,10)
playerListFrame.BackgroundColor3 = themes[currentThemeIndex].bg
playerListFrame.BorderSizePixel = 0
playerListFrame.Visible = false
playerListFrame.ZIndex = 250
playerListFrame.Parent = screenGui
local plCorner = Instance.new("UICorner"); plCorner.CornerRadius = UDim.new(0,8); plCorner.Parent = playerListFrame

local plHeader = Instance.new("Frame")
plHeader.Size = UDim2.new(1,0,0,26)
plHeader.BackgroundColor3 = themes[currentThemeIndex].top
plHeader.BorderSizePixel = 0
plHeader.ZIndex = 251
plHeader.Parent = playerListFrame
local plHC = Instance.new("UICorner"); plHC.CornerRadius = UDim.new(0,8); plHC.Parent = plHeader

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1,-30,1,0)
plTitle.Position = UDim2.new(0,8,0,0)
plTitle.BackgroundTransparency = 1
plTitle.Text = "Players no Servidor"
plTitle.TextColor3 = Color3.fromRGB(255,255,255)
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 12
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.ZIndex = 252
plTitle.Parent = plHeader

local plClose = Instance.new("TextButton")
plClose.Size = UDim2.new(0,26,0,26)
plClose.Position = UDim2.new(1,-26,0,0)
plClose.BackgroundTransparency = 1
plClose.Text = "X"
plClose.TextColor3 = Color3.fromRGB(255,100,100)
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 13
plClose.ZIndex = 252
plClose.Parent = plHeader

local plList = Instance.new("ScrollingFrame")
plList.Size = UDim2.new(1,-10,1,-35)
plList.Position = UDim2.new(0,5,0,30)
plList.BackgroundTransparency = 1
plList.BorderSizePixel = 0
plList.ScrollBarThickness = 3
plList.CanvasSize = UDim2.new(0,0,0,0)
plList.ZIndex = 252
plList.Parent = playerListFrame

plClose.MouseButton1Click:Connect(function()
    Settings.PlayerListEnabled = false
    playerListFrame.Visible = false
    Notify("Player List: OFF", Color3.fromRGB(220,60,60))
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

Track(task.spawn(function()
    while true do
        task.wait(0.4)
        if isCleanedUp then return end
        if Settings.PlayerListEnabled and playerListFrame.Visible and not hiddenMode then
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
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1,-3,0,20)
                row.Position = UDim2.new(0,0,0,y)
                row.BackgroundTransparency = 1
                row.ZIndex = 252
                row.Parent = plList
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.55,0,1,0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = (p == player and "★ " or "  ") .. p.Name
                nameLbl.TextColor3 = (p == player) and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,255,255)
                nameLbl.Font = Enum.Font.GothamMedium
                nameLbl.TextSize = 11
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.ZIndex = 252
                nameLbl.Parent = row
                local hpc
                local pct = hp / maxHp
                if pct > 0.65 then hpc = Color3.fromRGB(60,220,60)
                elseif pct > 0.30 then hpc = Color3.fromRGB(255,200,60)
                else hpc = Color3.fromRGB(255,60,60) end
                local hpLbl = Instance.new("TextLabel")
                hpLbl.Size = UDim2.new(0.2,0,1,0)
                hpLbl.Position = UDim2.new(0.55,0,0,0)
                hpLbl.BackgroundTransparency = 1
                hpLbl.Text = hp .. "hp"
                hpLbl.TextColor3 = hpc
                hpLbl.Font = Enum.Font.GothamBold
                hpLbl.TextSize = 11
                hpLbl.ZIndex = 252
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
                distLbl.ZIndex = 252
                distLbl.Parent = row
                y = y + 22
            end
            plList.CanvasSize = UDim2.new(0,0,0,y+3)
        end
    end
end))

-- WATERMARK
watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Size = UDim2.new(0,200,0,24)
watermarkLabel.Position = UDim2.new(0,15,1,-40)
watermarkLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
watermarkLabel.BackgroundTransparency = 0.4
watermarkLabel.Text = "Guasti Scripts | v29"
watermarkLabel.TextColor3 = Color3.fromRGB(255,255,255)
watermarkLabel.Font = Enum.Font.GothamBold
watermarkLabel.TextSize = 12
watermarkLabel.Visible = false
watermarkLabel.ZIndex = 100
watermarkLabel.Parent = screenGui
local wmc = Instance.new("UICorner"); wmc.CornerRadius = UDim.new(0,4); wmc.Parent = watermarkLabel
local wms = Instance.new("UIStroke"); wms.Color = Color3.fromRGB(80,150,255); wms.Thickness = 1.5; wms.Parent = watermarkLabel

-- FPS
fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0,130,0,22)
fpsLabel.Position = UDim2.new(1,-140,0,10)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
fpsLabel.BackgroundTransparency = 0.4
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 13
fpsLabel.Visible = false
fpsLabel.ZIndex = 100
fpsLabel.Parent = screenGui
local fpsc = Instance.new("UICorner"); fpsc.CornerRadius = UDim.new(0,4); fpsc.Parent = fpsLabel

-- PING
pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0,130,0,22)
pingLabel.Position = UDim2.new(1,-140,0,36)
pingLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
pingLabel.BackgroundTransparency = 0.4
pingLabel.Text = "Ping: --"
pingLabel.TextColor3 = Color3.fromRGB(0,255,0)
pingLabel.Font = Enum.Font.Code
pingLabel.TextSize = 13
pingLabel.Visible = false
pingLabel.ZIndex = 100
pingLabel.Parent = screenGui
local pingc = Instance.new("UICorner"); pingc.CornerRadius = UDim.new(0,4); pingc.Parent = pingLabel

-- RADAR
local radarFrame = Instance.new("Frame")
radarFrame.Size = UDim2.new(0,130,0,130)
radarFrame.Position = UDim2.new(0,10,1,-150)
radarFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
radarFrame.BackgroundTransparency = 0.3
radarFrame.BorderSizePixel = 0
radarFrame.Visible = false
radarFrame.ZIndex = 100
radarFrame.Parent = screenGui
local rfc = Instance.new("UICorner"); rfc.CornerRadius = UDim.new(1,0); rfc.Parent = radarFrame
local rfs = Instance.new("UIStroke"); rfs.Color = Color3.fromRGB(80,150,255); rfs.Thickness = 2; rfs.Parent = radarFrame
local radarCenter = Instance.new("Frame")
radarCenter.Size = UDim2.new(0,6,0,6)
radarCenter.Position = UDim2.new(0.5,-3,0.5,-3)
radarCenter.BackgroundColor3 = Color3.fromRGB(80,255,80)
radarCenter.BorderSizePixel = 0
radarCenter.ZIndex = 101
radarCenter.Parent = radarFrame
local rcc = Instance.new("UICorner"); rcc.CornerRadius = UDim.new(1,0); rcc.Parent = radarCenter
local radarDots = {}

--==============================================================
-- PÁGINA 1: AIMBOT
--==============================================================
local _, _, SetAimbotState = CreateToggleItem(page1, "Aimbot", 0, function(s) Settings.AimbotEnabled = s end, false, true, "AimbotEnabled")
ToggleRefs.Aimbot = SetAimbotState

CreateToggleItem(page1, "FOV Circle 2 (Duplo)", 38, function(s) Settings.FOVDoubleEnabled = s end, false, true, "FOVDoubleEnabled")

CreateSlider(page1, "FOV Interno", 76, 5, 500,
    function() return Settings.FOVInner end,
    function(v) Settings.FOVInner = v; FOVInnerCircle.Radius = v end, "", "FOVInner")

CreateColorPalette(page1, 128, function() return Settings.FOVInnerColor end, function(c)
    Settings.FOVInnerColor = c
    FOVInnerCircle.Color = c
end, "Cor do FOV Interno", "FOVInnerColor")

local partLabel = Instance.new("TextLabel")
partLabel.Size = UDim2.new(1,-10,0,18)
partLabel.Position = UDim2.new(0,4,0,196)
partLabel.BackgroundTransparency = 1
partLabel.Text = "  Mirar em:"
partLabel.TextColor3 = Color3.fromRGB(200,200,200)
partLabel.Font = Enum.Font.GothamMedium
partLabel.TextSize = 11
partLabel.TextXAlignment = Enum.TextXAlignment.Left
partLabel.Parent = page1

local headBtn, torsoBtn
headBtn = CreateSmallButton(page1, "Cabeça", 0, 216, 155, function()
    Settings.AimPart = "Head"
    headBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
    torsoBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
end)
torsoBtn = CreateSmallButton(page1, "Torso", 162, 216, 155, function()
    Settings.AimPart = "Torso"
    torsoBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
    headBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
end)
headBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)

table.insert(SliderRegistry, {key="AimPart", updateFn=function()
    if Settings.AimPart == "Head" then
        headBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
        torsoBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    else
        torsoBtn.BackgroundColor3 = Color3.fromRGB(60,130,60)
        headBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    end
end})

CreateSlider(page1, "FOV Externo", 256, 10, 500,
    function() return Settings.FOV end,
    function(v) Settings.FOV = v; FOVCircle.Radius = v end, "", "FOV")

CreateSlider(page1, "Distância", 308, 50, 2000,
    function() return Settings.MaxDistance end,
    function(v) Settings.MaxDistance = v end, "", "MaxDistance")

CreateToggleItem(page1, "Wall Check", 360, function(s) Settings.WallCheck = s end, false, false, "WallCheck")
CreateToggleItem(page1, "Team Check", 398, function(s) Settings.TeamCheck = s end, false, false, "TeamCheck")
CreateToggleItem(page1, "Mostrar FOV", 436, function(s) Settings.FOVVisible = s end, false, false, "FOVVisible")

CreateColorPalette(page1, 474, function() return Settings.FOVColor end, function(c)
    Settings.FOVColor = c
    FOVCircle.Color = c
end, "Cor do FOV", "FOVColor")

CreateSlider(page1, "Transparência FOV", 542, 0.1, 1,
    function() return Settings.FOVTransparency end,
    function(v) Settings.FOVTransparency = v; FOVCircle.Transparency = v end, "", "FOVTransparency")

CreateToggleItem(page1, "Prediction", 594, function(s) Settings.PredictionEnabled = s end, false, true, "PredictionEnabled")
CreateSlider(page1, "Prediction", 632, 0, 100,
    function() return Settings.Prediction end,
    function(v) Settings.Prediction = v end, "%", "Prediction")
CreateToggleItem(page1, "Predict Visual (ponto)", 684, function(s) Settings.PredictVisual = s end, false, true, "PredictVisual")

local aimbotKeyBtn = CreateButtonItem(page1, "Tecla Aimbot: " .. Settings.AimbotKey.Name, 722, function()
    waitingForAimbotKey = true
    aimbotKeyBtn.Text = "  Pressione uma tecla..."
end)

CreateToggleItem(page1, "Trigger Bot", 760, function(s) Settings.TriggerBotEnabled = s end, false, true, "TriggerBotEnabled")

--==============================================================
-- PÁGINA 2: ESP
--==============================================================
local _, _, SetESPState = CreateToggleItem(page2, "ESP", 0, function(s) Settings.ESPEnabled = s end, false, true, "ESPEnabled")
ToggleRefs.ESP = SetESPState

CreateToggleItem(page2, "Team Check", 38, function(s) Settings.ESPTeamCheck = s end, false, false, "ESPTeamCheck")
CreateToggleItem(page2, "Linha", 76, function(s) Settings.ESPLine = s end, false, false, "ESPLine")
CreateToggleItem(page2, "Vida", 114, function(s) Settings.ESPHealth = s end, false, false, "ESPHealth")
CreateToggleItem(page2, "Distância", 152, function(s) Settings.ESPDistance = s end, false, false, "ESPDistance")
CreateToggleItem(page2, "Box 2D", 190, function(s) Settings.ESPBox = s end, false, false, "ESPBox")
CreateToggleItem(page2, "Box de Vida", 228, function(s) Settings.ESPBoxHealth = s end, false, false, "ESPBoxHealth")
CreateToggleItem(page2, "Chams", 266, function(s) Settings.ESPChams = s end, false, false, "ESPChams")
CreateToggleItem(page2, "Esqueleto", 304, function(s) Settings.ESPSkeleton = s end, false, false, "ESPSkeleton")
CreateToggleItem(page2, "Mostrar Nome", 342, function(s) Settings.ESPName = s end, false, false, "ESPName")
CreateToggleItem(page2, "Mostrar Arma", 380, function(s) Settings.ESPWeapon = s end, false, false, "ESPWeapon")
CreateToggleItem(page2, "Distância no Nome", 418, function(s) Settings.ESPDistanceInName = s end, false, false, "ESPDistanceInName")
CreateToggleItem(page2, "Rainbow ESP", 456, function(s) Settings.ESPRainbow = s end, false, true, "ESPRainbow")
CreateToggleItem(page2, "Cor por Distância", 494, function(s) Settings.ESPDistanceColor = s end, false, true, "ESPDistanceColor")

CreateSlider(page2, "Alcance do ESP", 532, 50, 5000,
    function() return Settings.ESPMaxDistance end,
    function(v) Settings.ESPMaxDistance = v end, " studs", "ESPMaxDistance")

local ctCont = Instance.new("Frame")
ctCont.Size = UDim2.new(1,-10,0,32)
ctCont.Position = UDim2.new(0,0,0,584)
ctCont.BackgroundColor3 = Color3.fromRGB(45,45,45)
ctCont.BorderSizePixel = 0
ctCont.Parent = page2
local ctc = Instance.new("UICorner"); ctc.CornerRadius = UDim.new(0,6); ctc.Parent = ctCont

local ctLbl = Instance.new("TextLabel")
ctLbl.Size = UDim2.new(0.5,0,1,0)
ctLbl.Position = UDim2.new(0,10,0,0)
ctLbl.BackgroundTransparency = 1
ctLbl.Text = "Elemento p/ cor:"
ctLbl.TextColor3 = Color3.fromRGB(200,200,200)
ctLbl.Font = Enum.Font.GothamMedium
ctLbl.TextSize = 11
ctLbl.TextXAlignment = Enum.TextXAlignment.Left
ctLbl.Parent = ctCont

local ctBtn = Instance.new("TextButton")
ctBtn.Size = UDim2.new(0,120,0,24)
ctBtn.Position = UDim2.new(1,-130,0.5,-12)
ctBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
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

espPaletteRefresh = CreateColorPalette(page2, 624, getEspColor, setEspColor, "Cor do Elemento")

CreateButtonItem(page2, "Ignorar Players", 692, function() OpenIgnorePopup() end)

--==============================================================
-- PÁGINA 3: OUTROS
--==============================================================
local secLabel1 = Instance.new("TextLabel")
secLabel1.Size = UDim2.new(1,-10,0,22)
secLabel1.Position = UDim2.new(0,4,0,0)
secLabel1.BackgroundTransparency = 1
secLabel1.Text = "  MOVIMENTO"
secLabel1.TextColor3 = Color3.fromRGB(150,200,255)
secLabel1.Font = Enum.Font.GothamBold
secLabel1.TextSize = 12
secLabel1.TextXAlignment = Enum.TextXAlignment.Left
secLabel1.Parent = page3

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
CreateToggleItem(page3, "Anti-Stun / Anti-Ragdoll", 294, function(s) Settings.AntiStunEnabled = s end, false, true, "AntiStunEnabled")
CreateToggleItem(page3, "Infinite Ammo / Auto-Reload", 332, function(s) Settings.InfiniteAmmoEnabled = s end, false, true, "InfiniteAmmoEnabled")

CreateToggleItem(page3, "Fullbright", 370, function(state)
    Settings.FullbrightEnabled = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = Settings.FullbrightBrightness
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.ClockTime = 12
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
    end
end, false, true, "FullbrightEnabled")

CreateSlider(page3, "Brilho do Fullbright", 408, 0.5, 5,
    function() return Settings.FullbrightBrightness end,
    function(v)
        Settings.FullbrightBrightness = v
        if Settings.FullbrightEnabled then Lighting.Brightness = v end
    end, "", "FullbrightBrightness")

CreateToggleItem(page3, "FPS Boost", 460, function(s)
    Settings.FPSBoostEnabled = s
    ApplyFPSBoost(s)
end, false, true, "FPSBoostEnabled")

CreateToggleItem(page3, "Anti-Void", 498, function(s) Settings.AntiVoidEnabled = s end, false, true, "AntiVoidEnabled")

CreateSlider(page3, "Altura do Anti-Void", 536, -500, 50,
    function() return Settings.AntiVoidHeight end,
    function(v) Settings.AntiVoidHeight = v end, "", "AntiVoidHeight")

CreateToggleItem(page3, "Trail Colorido", 588, function(state)
    Settings.TrailEnabled = state
    local ch = player.Character
    if ch then
        local old = ch:FindFirstChild("GuastiTrail")
        if old then old:Destroy() end
        if state then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local a0 = Instance.new("Attachment"); a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Position = Vector3.new(0,-1,0); a1.Parent = hrp
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

CreateColorPalette(page3, 626, function() return Settings.TrailColor end, function(c)
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

local secLabel2 = Instance.new("TextLabel")
secLabel2.Size = UDim2.new(1,-10,0,22)
secLabel2.Position = UDim2.new(0,4,0,696)
secLabel2.BackgroundTransparency = 1
secLabel2.Text = "  TELEPORTE"
secLabel2.TextColor3 = Color3.fromRGB(255,200,150)
secLabel2.Font = Enum.Font.GothamBold
secLabel2.TextSize = 12
secLabel2.TextXAlignment = Enum.TextXAlignment.Left
secLabel2.Parent = page3

CreateToggleItem(page3, "Click TP", 724, function(s) Settings.ClickTPEnabled = s end, false, true, "ClickTPEnabled")
CreateToggleItem(page3, "TP Suave (Smooth)", 762, function(s) Settings.TPSmooth = s end, false, true, "TPSmooth")

CreateSlider(page3, "Duração do Smooth", 800, 0.1, 1,
    function() return Settings.TPSmoothSpeed end,
    function(v) Settings.TPSmoothSpeed = v end, "s", "TPSmoothSpeed")

local clickTPKeyBtn = CreateButtonItem(page3, "Tecla Click TP: " .. (Settings.Keybinds.ClickTP and Settings.Keybinds.ClickTP.Name or "NENHUMA"), 852, function()
    waitingKeybind = "ClickTP"
    clickTPKeyBtn.Text = "  Pressione uma tecla..."
end)

CreateButtonItem(page3, "TP para Player", 890, function() OpenTPPopup() end)
CreateButtonItem(page3, "Waypoints", 928, function() OpenWPPopup() end)

local tpPlayerKeyBtn = CreateButtonItem(page3, "Tecla TP Player: " .. (Settings.Keybinds.TPPlayer and Settings.Keybinds.TPPlayer.Name or "NENHUMA"), 966, function()
    waitingKeybind = "TPPlayer"
    tpPlayerKeyBtn.Text = "  Pressione uma tecla..."
end)

local secLabel3 = Instance.new("TextLabel")
secLabel3.Size = UDim2.new(1,-10,0,22)
secLabel3.Position = UDim2.new(0,4,0,1010)
secLabel3.BackgroundTransparency = 1
secLabel3.Text = "  SERVIDOR"
secLabel3.TextColor3 = Color3.fromRGB(150,255,150)
secLabel3.Font = Enum.Font.GothamBold
secLabel3.TextSize = 12
secLabel3.TextXAlignment = Enum.TextXAlignment.Left
secLabel3.Parent = page3

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-10,0,18)
statusLabel.Position = UDim2.new(0,4,0,1036)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = page3

local function ServerHop()
    statusLabel.Text = "  Procurando servidor..."
    task.spawn(function()
        local placeId = game.PlaceId
        local ok, response = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if not ok or not response then
            statusLabel.Text = "  Erro ao buscar."
            return
        end
        local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
        if not ok2 or not data or not data.data then
            statusLabel.Text = "  Nenhum servidor."
            return
        end
        local servers = {}
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers == 0 then
            statusLabel.Text = "  Nada disponível."
            return
        end
        local newS = servers[math.random(1, #servers)]
        statusLabel.Text = "  Entrando..."
        local ok3, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, newS, player)
        end)
        if not ok3 then statusLabel.Text = "  Falha: " .. tostring(err) end
    end)
end

local function Rejoin()
    statusLabel.Text = "  Reconectando..."
    task.spawn(function()
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
        if not ok then statusLabel.Text = "  Falha: " .. tostring(err) end
    end)
end

CreateButtonItem(page3, "Server Hop", 1056, ServerHop)
CreateButtonItem(page3, "Rejoin", 1094, Rejoin)

--==============================================================
-- PÁGINA 4: CONFIG
--==============================================================
local keybindBtn = CreateButtonItem(page4, "Tecla Menu: " .. toggleKey.Name, 0, function()
    isWaitingForKey = true
    keybindBtn.Text = "  Pressione uma tecla..."
    keybindBtn.BackgroundColor3 = Color3.fromRGB(100,60,60)
end)
keybindBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

local function UpdateAllThemedColors()
    local t = themes[currentThemeIndex]
    mainFrame.BackgroundColor3 = t.bg
    topBar.BackgroundColor3 = t.top
    topBarExt.BackgroundColor3 = t.top
    tpPopup.BackgroundColor3 = t.bg
    ignorePopup.BackgroundColor3 = t.bg
    wpPopup.BackgroundColor3 = t.bg
    playerListFrame.BackgroundColor3 = t.bg
    plHeader.BackgroundColor3 = t.top
end

local colorBtn = CreateButtonItem(page4, "Tema: " .. themes[currentThemeIndex].name, 38, function()
    currentThemeIndex = currentThemeIndex + 1
    if currentThemeIndex > #themes then currentThemeIndex = 1 end
    UpdateAllThemedColors()
    colorBtn.Text = "  Tema: " .. themes[currentThemeIndex].name
    Notify("Tema: " .. themes[currentThemeIndex].name, Color3.fromRGB(80,150,255))
end)
colorBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

local function SerializeSettings()
    local out = {}
    for k, v in pairs(Settings) do
        if k ~= "Keybinds" and k ~= "IgnoredPlayers" and k ~= "Waypoints" then
            if typeof(v) == "EnumItem" then
                local es = tostring(v):match("Enum%.(.+)$")
                out[k] = "ENUM:" .. (es or "KeyCode.Unknown")
            elseif typeof(v) == "Color3" then
                out[k] = "COLOR:" .. tostring(v.R) .. "," .. tostring(v.G) .. "," .. tostring(v.B)
            else
                out[k] = v
            end
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
    for uid, val in pairs(Settings.IgnoredPlayers) do
        if val then ig[tostring(uid)] = true end
    end
    out._IgnoredPlayers = ig
    local wp = {}
    for _, w in ipairs(Settings.Waypoints) do
        table.insert(wp, {name=w.name, x=w.pos.X, y=w.pos.Y, z=w.pos.Z})
    end
    out._Waypoints = wp
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
            for uid, val in pairs(v) do
                if val then Settings.IgnoredPlayers[tonumber(uid)] = true end
            end
        elseif k == "_Waypoints" then
            Settings.Waypoints = {}
            for _, w in ipairs(v) do
                if w.name and w.x and w.y and w.z then
                    table.insert(Settings.Waypoints, {name=w.name, pos=Vector3.new(w.x, w.y, w.z)})
                end
            end
        elseif k == "_ThemeIndex" then
            currentThemeIndex = tonumber(v) or 1
            if currentThemeIndex < 1 or currentThemeIndex > #themes then currentThemeIndex = 1 end
            UpdateAllThemedColors()
            colorBtn.Text = "  Tema: " .. themes[currentThemeIndex].name
        elseif k ~= "Keybinds" then
            if type(v) == "string" and v:sub(1,5) == "ENUM:" then
                local eT, eN = v:sub(6):match("^(%w+)%.(%w+)$")
                if eT and eN then
                    local ok, res = pcall(function() return Enum[eT][eN] end)
                    if ok then Settings[k] = res end
                end
            elseif type(v) == "string" and v:sub(1,6) == "COLOR:" then
                local r, g, b = v:sub(7):match("^([%d%.]+),([%d%.]+),([%d%.]+)$")
                if r and g and b then
                    Settings[k] = Color3.new(tonumber(r), tonumber(g), tonumber(b))
                end
            else
                Settings[k] = v
            end
        end
    end
    for _, entry in ipairs(ToggleRegistry) do
        local val = Settings[entry.key]
        if type(val) ~= "boolean" then Settings[entry.key] = (val == true) end
        entry.setter(Settings[entry.key], true)
    end
    for _, entry in ipairs(SliderRegistry) do pcall(function() entry.updateFn() end) end
    for _, entry in ipairs(InputRegistry) do entry.textBox.Text = tostring(entry.getValue()) end
    UpdateKeybindButtonsUI()
    if aimbotKeyBtn then aimbotKeyBtn.Text = "  Tecla Aimbot: " .. Settings.AimbotKey.Name end
    if hideMenuKeyBtn then hideMenuKeyBtn.Text = "  Tecla Ocultar Menu: " .. Settings.HideMenuKey.Name end
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Settings.FOVColor
    FOVCircle.Transparency = Settings.FOVTransparency
    FOVInnerCircle.Radius = Settings.FOVInner
    FOVInnerCircle.Color = Settings.FOVInnerColor
    if Settings.FullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = Settings.FullbrightBrightness
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
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

local saveConfigBtn = CreateButtonItem(page4, "Salvar Configurações", 76, function()
    if writefile then
        local ok, err = pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(SerializeSettings()))
        end)
        if ok then Notify("Config salva!", Color3.fromRGB(60,220,60))
        else Notify("Erro: " .. tostring(err), Color3.fromRGB(255,60,60)) end
    else
        Notify("Executor sem writefile", Color3.fromRGB(255,60,60))
    end
end)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(60,90,60)

local loadConfigBtn = CreateButtonItem(page4, "Carregar Configurações", 114, function()
    if isfile and readfile then
        if isfile(CONFIG_FILE) then
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
            if ok and data then
                ApplyLoadedSettings(data)
                Notify("Config carregada!", Color3.fromRGB(60,220,60))
            else
                Notify("Config inválida", Color3.fromRGB(255,60,60))
            end
        else
            Notify("Nenhuma config salva", Color3.fromRGB(255,200,60))
        end
    else
        Notify("Executor sem readfile", Color3.fromRGB(255,60,60))
    end
end)
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)

local resetBtn = CreateButtonItem(page4, "Resetar Tudo", 152, function()
    for _, entry in ipairs(AllToggles) do entry.setter(entry.default, true) end
    Settings.AimbotKey = Enum.KeyCode.Q
    Settings.AimPart = "Head"
    Settings.FOV = 120
    Settings.FOVInner = 40
    Settings.MaxDistance = 500
    Settings.FOVColor = Color3.fromRGB(255,255,255)
    Settings.FOVInnerColor = Color3.fromRGB(255,100,100)
    Settings.FOVTransparency = 1
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
    Settings.CustomSoundId = ""
    Settings.RadarRange = 500
    Settings.HideMenuKey = Enum.KeyCode.Insert
    Settings.IgnoredPlayers = {}
    Settings.Waypoints = {}
    for k, _ in pairs(Settings.Keybinds) do Settings.Keybinds[k] = nil end
    Lighting.Ambient = originalLighting.Ambient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.ClockTime = originalLighting.ClockTime
    ApplyFPSBoost(false)
    currentThemeIndex = 1
    UpdateAllThemedColors()
    FOVCircle.Radius = 120
    FOVCircle.Color = Color3.fromRGB(255,255,255)
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false
    FOVInnerCircle.Radius = 40
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
        end
    end
    aimbotKeyBtn.Text = "  Tecla Aimbot: Q"
    hideMenuKeyBtn.Text = "  Tecla Ocultar Menu: Insert"
    colorBtn.Text = "  Tema: " .. themes[1].name
    clickTPKeyBtn.Text = "  Tecla Click TP: NENHUMA"
    tpPlayerKeyBtn.Text = "  Tecla TP Player: NENHUMA"
    for k, e in pairs(keybindRows) do e.btn.Text = "  " .. e.label .. ": NENHUMA" end
    for _, entry in ipairs(SliderRegistry) do pcall(function() entry.updateFn() end) end
    for _, entry in ipairs(InputRegistry) do entry.textBox.Text = tostring(entry.getValue()) end
    playerListFrame.Visible = false
    watermarkLabel.Visible = false
    fpsLabel.Visible = false
    pingLabel.Visible = false
    radarFrame.Visible = false
    consoleFrame.Visible = false
    Notify("Tudo resetado!", Color3.fromRGB(60,220,60))
end)
resetBtn.BackgroundColor3 = Color3.fromRGB(120,50,50)
resetBtn.TextColor3 = Color3.fromRGB(255,255,255)

CreateToggleItem(page4, "Anti-AFK", 190, function(s) Settings.AntiAFKEnabled = s end, false, true, "AntiAFKEnabled")
CreateToggleItem(page4, "Notificações com Som", 228, function(s) Settings.SoundNotificationsEnabled = s end, false, true, "SoundNotificationsEnabled")

CreateInputItem(page4, "ID do Som Custom", 266,
    function() return Settings.CustomSoundId end,
    function(v) Settings.CustomSoundId = v end, nil, nil, "CustomSoundId", true)

CreateToggleItem(page4, "Watermark", 304, function(s)
    Settings.WatermarkEnabled = s
    watermarkLabel.Visible = s and not hiddenMode or false
end, false, true, "WatermarkEnabled")

CreateToggleItem(page4, "FPS Counter", 342, function(s)
    Settings.FpsCounterEnabled = s
    fpsLabel.Visible = s and not hiddenMode or false
end, false, true, "FpsCounterEnabled")

CreateToggleItem(page4, "Ping Counter", 380, function(s)
    Settings.PingCounterEnabled = s
    pingLabel.Visible = s and not hiddenMode or false
end, false, true, "PingCounterEnabled")

CreateToggleItem(page4, "Radar 2D", 418, function(s)
    Settings.RadarEnabled = s
    radarFrame.Visible = s and not hiddenMode or false
end, false, true, "RadarEnabled")

CreateSlider(page4, "Alcance do Radar", 456, 100, 2000,
    function() return Settings.RadarRange end,
    function(v) Settings.RadarRange = v end, " studs", "RadarRange")

CreateToggleItem(page4, "Console Log", 508, function(s)
    Settings.ConsoleEnabled = s
    consoleFrame.Visible = s and not hiddenMode or false
end, false, true, "ConsoleEnabled")

CreateToggleItem(page4, "Custom Crosshair", 546, function(s) Settings.CrosshairEnabled = s end, false, true, "CrosshairEnabled")

CreateSlider(page4, "Tamanho do Crosshair", 584, 3, 30,
    function() return Settings.CrosshairSize end,
    function(v) Settings.CrosshairSize = v end, "", "CrosshairSize")

CreateColorPalette(page4, 632, function() return Settings.CrosshairColor end, function(c)
    Settings.CrosshairColor = c
    for _, l in ipairs(crossLines) do l.Color = c end
end, "Cor do Crosshair", "CrosshairColor")

local _, _, SetPlayerListState = CreateToggleItem(page4, "Player List Flutuante", 700, function(state)
    Settings.PlayerListEnabled = state
    playerListFrame.Visible = state and not hiddenMode or false
end, false, true, "PlayerListEnabled")
ToggleRefs.PlayerList = SetPlayerListState

local hideMenuKeyBtn = CreateButtonItem(page4, "Tecla Ocultar Menu: " .. Settings.HideMenuKey.Name, 738, function()
    waitingHideMenuKey = true
    hideMenuKeyBtn.Text = "  Pressione uma tecla..."
end)

local triggerKeyBtn = CreateButtonItem(page4, "Tecla Trigger Bot: " .. Settings.TriggerBotKey.Name, 776, function()
    waitingTriggerKey = true
    triggerKeyBtn.Text = "  Pressione uma tecla..."
end)

local keybindSection = Instance.new("TextLabel")
keybindSection.Size = UDim2.new(1,-10,0,22)
keybindSection.Position = UDim2.new(0,4,0,818)
keybindSection.BackgroundTransparency = 1
keybindSection.Text = "  TECLAS RÁPIDAS"
keybindSection.TextColor3 = Color3.fromRGB(255,200,150)
keybindSection.Font = Enum.Font.GothamBold
keybindSection.TextSize = 12
keybindSection.TextXAlignment = Enum.TextXAlignment.Left
keybindSection.Parent = page4

local function CreateKeybindRow(parent, yPos, label, keybindKey)
    local btn = CreateButtonItem(parent, label .. ": " .. (Settings.Keybinds[keybindKey] and Settings.Keybinds[keybindKey].Name or "NENHUMA"), yPos, function()
        waitingKeybind = keybindKey
        btn.Text = "  " .. label .. ": pressione..."
    end)
    keybindRows[keybindKey] = {btn=btn, label=label}
    return btn
end

CreateKeybindRow(page4, 846, "Fly", "Fly")
CreateKeybindRow(page4, 884, "Noclip", "Noclip")
CreateKeybindRow(page4, 922, "Walkspeed", "Walkspeed")
CreateKeybindRow(page4, 960, "ESP", "ESP")
CreateKeybindRow(page4, 998, "TP Player", "TPPlayer")

local destroyBtn = CreateButtonItem(page4, "Fechar Totalmente o Script", 1042, function()
    if _G.GuastiCleanup then _G.GuastiCleanup() end
end)
destroyBtn.BackgroundTransparency = 1
destroyBtn.TextColor3 = Color3.fromRGB(255,60,60)
destroyBtn.Font = Enum.Font.GothamBold

-- RESIZE + DRAG
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0,15,0,15)
resizeHandle.Position = UDim2.new(1,-15,1,-15)
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
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

local resizing = false
local resizeStartPos, startSize
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimized then
        resizing = true
        resizeStartPos = input.Position
        startSize = mainFrame.AbsoluteSize
    end
end)
Track(UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - resizeStartPos
        local nw = math.clamp(startSize.X + d.X, 360, 800)
        local nh = math.clamp(startSize.Y + d.Y, 260, 600)
        mainFrame.Size = UDim2.new(0,nw,0,nh)
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
        mainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
    else
        local t = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size=UDim2.new(0,0,0,0)})
        t:Play()
        t.Completed:Connect(function()
            if not isOpen then
                mainFrame.Visible = false
                mainFrame.Size = normalSize
            end
        end)
        tpPopup.Visible = false
        ignorePopup.Visible = false
        wpPopup.Visible = false
    end
    UpdateMouseLock()
end

local function ToggleHiddenMode()
    hiddenMode = not hiddenMode
    if hiddenMode then
        mainFrame.Visible = false
        tpPopup.Visible = false
        ignorePopup.Visible = false
        wpPopup.Visible = false
        playerListFrame.Visible = false
        watermarkLabel.Visible = false
        fpsLabel.Visible = false
        pingLabel.Visible = false
        radarFrame.Visible = false
        consoleFrame.Visible = false
        for _, l in ipairs(crossLines) do l.Visible = false end
        Notify("Modo Screenshot: ON", Color3.fromRGB(80,150,255))
    else
        mainFrame.Visible = isOpen
        if Settings.PlayerListEnabled then playerListFrame.Visible = true end
        if Settings.WatermarkEnabled then watermarkLabel.Visible = true end
        if Settings.FpsCounterEnabled then fpsLabel.Visible = true end
        if Settings.PingCounterEnabled then pingLabel.Visible = true end
        if Settings.RadarEnabled then radarFrame.Visible = true end
        if Settings.ConsoleEnabled then consoleFrame.Visible = true end
        Notify("Modo Screenshot: OFF", Color3.fromRGB(80,150,255))
    end
    UpdateMouseLock()
end

closeBtn.MouseButton1Click:Connect(function() if isOpen then ToggleMenu() end end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentFrame.Visible = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, normalSize.X.Offset, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = false
    else
        mainFrame:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = true
    end
end)

Track(player.Idled:Connect(function()
    if Settings.AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

Track(UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJumpEnabled then
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end))

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
    if clickTPKeyBtn then clickTPKeyBtn.Text = "  Tecla Click TP: " .. (Settings.Keybinds.ClickTP and Settings.Keybinds.ClickTP.Name or "NENHUMA") end
    if tpPlayerKeyBtn then tpPlayerKeyBtn.Text = "  Tecla TP Player: " .. (Settings.Keybinds.TPPlayer and Settings.Keybinds.TPPlayer.Name or "NENHUMA") end
    for k, e in pairs(keybindRows) do
        e.btn.Text = "  " .. e.label .. ": " .. (Settings.Keybinds[k] and Settings.Keybinds[k].Name or "NENHUMA")
    end
end

Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isWaitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        Settings.MenuKey = input.KeyCode
        isWaitingForKey = false
        keybindBtn.Text = "  Tecla Menu: " .. toggleKey.Name
        keybindBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        return
    end
    if waitingHideMenuKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.HideMenuKey = input.KeyCode
        waitingHideMenuKey = false
        hideMenuKeyBtn.Text = "  Tecla Ocultar Menu: " .. input.KeyCode.Name
        return
    end
    if waitingTriggerKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.TriggerBotKey = input.KeyCode
        waitingTriggerKey = false
        triggerKeyBtn.Text = "  Tecla Trigger Bot: " .. input.KeyCode.Name
        return
    end
    if waitingForAimbotKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Settings.AimbotKey = input.KeyCode
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  Tecla Aimbot: " .. input.KeyCode.Name
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton4 then
            Settings.AimbotKey = Enum.UserInputType.MouseButton4
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  Tecla Aimbot: Mouse4"
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton5 then
            Settings.AimbotKey = Enum.UserInputType.MouseButton5
            waitingForAimbotKey = false
            aimbotKeyBtn.Text = "  Tecla Aimbot: Mouse5"
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
    if IsAimbotKeyInput(input) then
        SetAimbotState()
        return
    end
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Settings.HideMenuKey then
        ToggleHiddenMode()
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Settings.MenuKey then
        if hiddenMode then
            hiddenMode = false
            mainFrame.Visible = true
            if Settings.PlayerListEnabled then playerListFrame.Visible = true end
            if Settings.WatermarkEnabled then watermarkLabel.Visible = true end
            UpdateMouseLock()
        else
            ToggleMenu()
        end
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
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
end))

Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.ClickTPEnabled and Settings.Keybinds.ClickTP
        and input.UserInputType == Enum.UserInputType.MouseButton1
        and UserInputService:IsKeyDown(Settings.Keybinds.ClickTP) then
        local rt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if rt and mouse and mouse.Hit then
            SmoothTeleport(CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)))
        end
    end
end))

Track(player.Chatted:Connect(function(message)
    local cmd, arg = message:match("^/(%w+)%s*(.*)$")
    if not cmd then return end
    cmd = cmd:lower()
    if cmd == "fly" and ToggleRefs.Fly then ToggleRefs.Fly()
    elseif cmd == "noclip" and ToggleRefs.Noclip then ToggleRefs.Noclip()
    elseif cmd == "aimbot" and ToggleRefs.Aimbot then ToggleRefs.Aimbot()
    elseif cmd == "esp" and ToggleRefs.ESP then ToggleRefs.ESP()
    elseif cmd == "ws" then
        local n = tonumber(arg)
        if n then
            Settings.WalkspeedValue = n
            if ToggleRefs.Walkspeed and not Settings.WalkspeedEnabled then ToggleRefs.Walkspeed() end
            Notify("Walkspeed: " .. n, Color3.fromRGB(60,220,60))
        end
    elseif cmd == "tp" and arg and arg ~= "" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #arg) == arg:lower() and p ~= player then
                local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local mr = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then
                    SmoothTeleport(tr.CFrame + Vector3.new(0,3,0))
                    Notify("TP: " .. p.Name, Color3.fromRGB(60,220,60))
                end
                break
            end
        end
    elseif cmd == "cmds" then
        Notify("/fly /noclip /aimbot /esp /ws /tp", Color3.fromRGB(80,150,255))
    end
end))

local function IsPlayerBlocked(p)
    if Settings.IgnoredPlayers[p.UserId] then return true end
    return false
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
    if Settings.AimPart == "Head" then
        return ch:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart")
    end
    return ch:FindFirstChild("Head")
end

local function GetClosestTarget()
    local mp = UserInputService:GetMouseLocation()
    local best, bd = nil, math.huge
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
                            if sd <= Settings.FOV and CanSeePart(p, part) and sd < bd then
                                bd = sd
                                best = part
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

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
        d.Line:Remove()
        d.Health:Remove()
        d.Distance:Remove()
        d.NameTag:Remove()
        d.Weapon:Remove()
        d.BoxTop:Remove()
        d.BoxBottom:Remove()
        d.BoxLeft:Remove()
        d.BoxRight:Remove()
        d.HPBarBg:Remove()
        d.HPBarFg:Remove()
        for _, i in ipairs(d.R15Lines) do i.Line:Remove() end
        for _, i in ipairs(d.R6Lines) do i.Line:Remove() end
        d.Chams:Destroy()
    end)
    ESPObjects[p] = nil
end

for _, p in ipairs(Players:GetPlayers()) do CreateESPObj(p) end
Track(Players.PlayerAdded:Connect(CreateESPObj))
Track(Players.PlayerRemoving:Connect(RemoveESPObj))

local function HideESP(d)
    d.Line.Visible = false
    d.Health.Visible = false
    d.Distance.Visible = false
    d.NameTag.Visible = false
    d.Weapon.Visible = false
    d.BoxTop.Visible = false
    d.BoxBottom.Visible = false
    d.BoxLeft.Visible = false
    d.BoxRight.Visible = false
    d.HPBarBg.Visible = false
    d.HPBarFg.Visible = false
    for _, i in ipairs(d.R15Lines) do i.Line.Visible = false end
    for _, i in ipairs(d.R6Lines) do i.Line.Visible = false end
    if d.Chams then d.Chams.Enabled = false end
end

local function GetDistColor(dist)
    if dist < 100 then return Color3.fromRGB(255,50,50)
    elseif dist < 300 then return Color3.fromRGB(255,220,50)
    else return Color3.fromRGB(50,255,50) end
end

-- RENDER STEPS
RunService:BindToRenderStep("Guasti_FOV", Enum.RenderPriority.Camera.Value + 1, function()
    if isCleanedUp then return end
    local mp = UserInputService:GetMouseLocation()
    FOVCircle.Position = mp
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Settings.FOVColor
    FOVCircle.Transparency = Settings.FOVTransparency
    FOVCircle.Visible = Settings.AimbotEnabled and Settings.FOVVisible
    FOVInnerCircle.Position = mp
    FOVInnerCircle.Radius = Settings.FOVInner
    FOVInnerCircle.Color = Settings.FOVInnerColor
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
        return
    end
    local tp = GetClosestTarget()
    if not tp then
        PredictDot.Visible = false
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
        else
            PredictDot.Visible = false
        end
    else
        PredictDot.Visible = false
    end
    local tc = CFrame.new(Camera.CFrame.Position, tPos)
    if Settings.Smoothness <= 0 then
        Camera.CFrame = tc
    else
        local alpha = math.clamp(1 - (Settings.Smoothness / 100), 0.001, 1)
        Camera.CFrame = Camera.CFrame:Lerp(tc, alpha)
    end
end)

RunService:BindToRenderStep("Guasti_ESP", Enum.RenderPriority.Camera.Value + 3, function()
    if isCleanedUp then return end
    local vp = Camera.ViewportSize
    for tp, d in pairs(ESPObjects) do
        local ch = tp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not Settings.ESPEnabled or not ch or not hum or hum.Health <= 0 or IsESPTeammate(tp) then
            HideESP(d)
        else
            local root = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
            if not root then
                HideESP(d)
            else
                local head = ch:FindFirstChild("Head")
                local sp, on = Camera:WorldToViewportPoint(root.Position)
                if not on then
                    HideESP(d)
                else
                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    if dist > Settings.ESPMaxDistance then
                        HideESP(d)
                    else
                        local lineC = Settings.ESPLineColor
                        local nameC = Settings.ESPNameColor
                        local hpC = Settings.ESPHealthColor
                        local skC = Settings.ESPSkeletonColor
                        local bxC = Settings.ESPBoxColor
                        if Settings.ESPRainbow then
                            local rb = GetRainbowColor()
                            lineC = rb
                            nameC = rb
                            hpC = rb
                            skC = rb
                            bxC = rb
                        end
                        if Settings.ESPDistanceColor then
                            lineC = GetDistColor(dist)
                        end

                        if Settings.ESPLine then
                            d.Line.From = Vector2.new(vp.X / 2, 0)
                            d.Line.To = Vector2.new(sp.X, sp.Y)
                            d.Line.Color = lineC
                            d.Line.Visible = true
                        else
                            d.Line.Visible = false
                        end

                        if Settings.ESPHealth then
                            d.Health.Text = "HP: " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
                            d.Health.Position = Vector2.new(sp.X, sp.Y - 32)
                            d.Health.Color = hpC
                            d.Health.Visible = true
                        else
                            d.Health.Visible = false
                        end

                        if Settings.ESPDistance and not Settings.ESPDistanceInName then
                            d.Distance.Text = math.floor(dist) .. " studs"
                            d.Distance.Position = Vector2.new(sp.X, sp.Y + 24)
                            d.Distance.Color = lineC
                            d.Distance.Visible = true
                        else
                            d.Distance.Visible = false
                        end

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
                            else
                                d.NameTag.Visible = false
                            end
                        else
                            d.NameTag.Visible = false
                        end

                        if Settings.ESPWeapon and head then
                            local tool = ch:FindFirstChildOfClass("Tool")
                            if tool then
                                local hp, ho = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2.6,0))
                                if ho then
                                    d.Weapon.Text = "[ " .. tool.Name .. " ]"
                                    d.Weapon.Position = Vector2.new(hp.X, hp.Y)
                                    d.Weapon.Color = Color3.fromRGB(255,255,100)
                                    d.Weapon.Visible = true
                                else
                                    d.Weapon.Visible = false
                                end
                            else
                                d.Weapon.Visible = false
                            end
                        else
                            d.Weapon.Visible = false
                        end

                        if Settings.ESPBox and head then
                            local hpos, hon = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            local fpos, fon = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                            if hon and fon then
                                local top = hpos.Y
                                local bot = fpos.Y
                                local hgt = bot - top
                                local w = hgt * 0.5
                                local lft = hpos.X - w / 2
                                local rgt = hpos.X + w / 2
                                d.BoxTop.From = Vector2.new(lft, top)
                                d.BoxTop.To = Vector2.new(rgt, top)
                                d.BoxBottom.From = Vector2.new(lft, bot)
                                d.BoxBottom.To = Vector2.new(rgt, bot)
                                d.BoxLeft.From = Vector2.new(lft, top)
                                d.BoxLeft.To = Vector2.new(lft, bot)
                                d.BoxRight.From = Vector2.new(rgt, top)
                                d.BoxRight.To = Vector2.new(rgt, bot)
                                for _, l in ipairs({d.BoxTop, d.BoxBottom, d.BoxLeft, d.BoxRight}) do
                                    l.Color = bxC
                                    l.Visible = true
                                end
                            else
                                d.BoxTop.Visible = false
                                d.BoxBottom.Visible = false
                                d.BoxLeft.Visible = false
                                d.BoxRight.Visible = false
                            end
                        else
                            d.BoxTop.Visible = false
                            d.BoxBottom.Visible = false
                            d.BoxLeft.Visible = false
                            d.BoxRight.Visible = false
                        end

                        if Settings.ESPBoxHealth and head then
                            local hpos, hon = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            local fpos, fon = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                            if hon and fon then
                                local bx = hpos.X - 55
                                local ty = hpos.Y
                                local by = fpos.Y
                                d.HPBarBg.From = Vector2.new(bx, ty)
                                d.HPBarBg.To = Vector2.new(bx, by)
                                d.HPBarBg.Color = Color3.fromRGB(40,40,40)
                                d.HPBarBg.Visible = true
                                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local ft = by - (by - ty) * pct
                                d.HPBarFg.From = Vector2.new(bx, ft)
                                d.HPBarFg.To = Vector2.new(bx, by)
                                local hc
                                if pct > 0.65 then
                                    hc = Color3.fromRGB(60,220,60)
                                elseif pct > 0.30 then
                                    hc = Color3.fromRGB(255,200,60)
                                else
                                    hc = Color3.fromRGB(255,60,60)
                                end
                                d.HPBarFg.Color = hc
                                d.HPBarFg.Visible = true
                            else
                                d.HPBarBg.Visible = false
                                d.HPBarFg.Visible = false
                            end
                        else
                            d.HPBarBg.Visible = false
                            d.HPBarFg.Visible = false
                        end

                        if Settings.ESPChams then
                            d.Chams.Adornee = ch
                            d.Chams.Enabled = true
                            d.Chams.FillColor = lineC
                            d.Chams.OutlineColor = lineC
                        else
                            d.Chams.Enabled = false
                        end

                        local isR15 = ch:FindFirstChild("UpperTorso") ~= nil
                        local active = isR15 and d.R15Lines or d.R6Lines
                        local inactive = isR15 and d.R6Lines or d.R15Lines
                        if Settings.ESPSkeleton then
                            for _, i in ipairs(inactive) do
                                i.Line.Visible = false
                            end
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
                                        i.Line.Visible = true
                                    else
                                        i.Line.Visible = false
                                    end
                                else
                                    i.Line.Visible = false
                                end
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
    rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
    rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
    local cam = Camera.CFrame
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
end)

-- LOOPS
local fpsAcc = 0
local fpsFrames = 0
Track(RunService.Heartbeat:Connect(function(dt)
    if isCleanedUp then return end
    fpsAcc = fpsAcc + dt
    fpsFrames = fpsFrames + 1
    if fpsAcc >= 0.5 then
        local fps = math.floor(fpsFrames / fpsAcc)
        fpsAcc = 0
        fpsFrames = 0
        if Settings.FpsCounterEnabled then
            fpsLabel.Text = "FPS: " .. fps
            if fps >= 50 then fpsLabel.TextColor3 = Color3.fromRGB(60,220,60)
            elseif fps >= 30 then fpsLabel.TextColor3 = Color3.fromRGB(255,200,60)
            else fpsLabel.TextColor3 = Color3.fromRGB(255,60,60) end
        end
        if Settings.PingCounterEnabled then
            local ok, ping = pcall(function()
                return math.floor(Players:GetNetworkPing() * 1000)
            end)
            if ok and ping then
                pingLabel.Text = "Ping: " .. ping .. "ms"
                if ping <= 80 then pingLabel.TextColor3 = Color3.fromRGB(60,220,60)
                elseif ping <= 150 then pingLabel.TextColor3 = Color3.fromRGB(255,200,60)
                else pingLabel.TextColor3 = Color3.fromRGB(255,60,60) end
            end
        end
    end
end))

Track(RunService.Stepped:Connect(function()
    if isCleanedUp then return end
    if not Settings.NoclipEnabled then return end
    local ch = player.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

Track(RunService.Heartbeat:Connect(function()
    if isCleanedUp then return end
    if Settings.WalkspeedEnabled then
        local ch = player.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= Settings.WalkspeedValue then
                hum.WalkSpeed = Settings.WalkspeedValue
            end
        end
    end
    if Settings.AntiFlingEnabled then
        local ch = player.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            if rt then
                local v = rt.AssemblyLinearVelocity
                if v.Magnitude > 150 then
                    rt.AssemblyLinearVelocity = v.Unit * 100
                end
            end
        end
    end
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
    if Settings.InfiniteAmmoEnabled then
        local ch = player.Character
        if ch then
            local tool = ch:FindFirstChildOfClass("Tool")
            if tool then
                local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount") or tool:FindFirstChild("Clip")
                if ammo and ammo:IsA("ValueBase") and typeof(ammo.Value) == "number" then
                    pcall(function() ammo.Value = 999 end)
                end
            end
        end
    end
    if Settings.AntiVoidEnabled then
        local ch = player.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if rt and hum and hum.Health > 0 and rt.Position.Y < Settings.AntiVoidHeight then
                rt.CFrame = CFrame.new(rt.Position.X, 100, rt.Position.Z)
                rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
                Notify("Anti-Void: resgatado!", Color3.fromRGB(60,220,60))
            end
        end
    end
    if Settings.TriggerBotEnabled then
        local key = Settings.TriggerBotKey
        local pressed = false
        if typeof(key) == "EnumItem" then
            if key.EnumType == Enum.KeyCode then
                pressed = UserInputService:IsKeyDown(key)
            end
        end
        if pressed then
            local target = GetClosestTarget()
            if target then
                pcall(function()
                    local virtualUser = VirtualUser
                    mouse1click()
                end)
            end
        end
    end
end))

-- RADAR UPDATE LOOP
Track(task.spawn(function()
    while not isCleanedUp do
        task.wait(0.15)
        if Settings.RadarEnabled and radarFrame.Visible then
            for _, d in pairs(radarDots) do
                if d and d.Parent then d:Destroy() end
            end
            radarDots = {}
            local myRt = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if myRt then
                local myPos = myRt.Position
                local camDir = Camera.CFrame.LookVector
                local range = Settings.RadarRange
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
                                local dc = Instance.new("UICorner")
                                dc.CornerRadius = UDim.new(1,0)
                                dc.Parent = dot
                                local angle = math.atan2(rel.Z, rel.X)
                                local camAngle = math.atan2(camDir.Z, camDir.X)
                                local relAngle = angle - camAngle
                                local px = (math.cos(relAngle) * dist / range) * (65 - 8)
                                local py = (math.sin(relAngle) * dist / range) * (65 - 8)
                                dot.Position = UDim2.new(0.5, px - 4, 0.5, py - 4)
                                table.insert(radarDots, dot)
                            end
                        end
                    end
                end
            end
        else
            task.wait(0.3)
        end
    end
end))

Track(player.CharacterAdded:Connect(function(ch)
    if isCleanedUp then return end
    task.wait(0.5)
    if isCleanedUp then return end
    if Settings.WalkspeedEnabled then
        local h = ch:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Settings.WalkspeedValue end
    end
    if Settings.TrailEnabled then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local old = hrp:FindFirstChild("GuastiTrail")
            if old then old:Destroy() end
            local a0 = Instance.new("Attachment"); a0.Parent = hrp
            local a1 = Instance.new("Attachment"); a1.Position = Vector3.new(0,-1,0); a1.Parent = hrp
            local t = Instance.new("Trail")
            t.Name = "GuastiTrail"
            t.Attachment0 = a0
            t.Attachment1 = a1
            t.Lifetime = 0.5
            t.Color = ColorSequence.new(Settings.TrailColor)
            t.Parent = hrp
        end
    end
end))

-- CLEANUP
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
    for _, l in ipairs(crossLines) do
        pcall(function() l:Remove() end)
    end
    for p, d in pairs(ESPObjects) do
        pcall(function()
            d.Line:Remove()
            d.Health:Remove()
            d.Distance:Remove()
            d.NameTag:Remove()
            d.Weapon:Remove()
            d.BoxTop:Remove()
            d.BoxBottom:Remove()
            d.BoxLeft:Remove()
            d.BoxRight:Remove()
            d.HPBarBg:Remove()
            d.HPBarFg:Remove()
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
                    if o.effect == e then
                        e.Enabled = o.enabled
                        break
                    end
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
                local t = rt:FindFirstChild("GuastiTrail")
                if t then t:Destroy() end
            end
        end
    end)
    _G.GuastiCleanup = nil
end

-- SPLASH
local splashBg = Instance.new("Frame")
splashBg.Size = UDim2.new(1,0,1,0)
splashBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
splashBg.BackgroundTransparency = 1
splashBg.BorderSizePixel = 0
splashBg.ZIndex = 500
splashBg.Parent = screenGui

local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(1,0,0,50)
splashTitle.Position = UDim2.new(0,0,0.5,-40)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "Guasti Scripts"
splashTitle.TextColor3 = Color3.fromRGB(255,255,255)
splashTitle.TextSize = 40
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextTransparency = 1
splashTitle.ZIndex = 501
splashTitle.Parent = splashBg

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(1,0,0,25)
splashSub.Position = UDim2.new(0,0,0.5,10)
splashSub.BackgroundTransparency = 1
splashSub.Text = "(Carregando.)"
splashSub.TextColor3 = Color3.fromRGB(220,220,220)
splashSub.TextSize = 18
splashSub.Font = Enum.Font.GothamMedium
splashSub.TextTransparency = 1
splashSub.ZIndex = 501
splashSub.Parent = splashBg

TweenService:Create(splashBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.45}):Play()
TweenService:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

local rgbActive = true
task.spawn(function()
    local hue = 0
    while rgbActive do
        hue = (hue + 0.006) % 1
        splashTitle.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

local dotsActive = true
task.spawn(function()
    local frames = {".", "..", "..."}
    local i = 1
    while dotsActive do
        splashSub.Text = "(Carregando" .. frames[i] .. ")"
        i = i + 1
        if i > #frames then i = 1 end
        task.wait(0.35)
    end
end)

task.wait(5)

rgbActive = false
dotsActive = false

TweenService:Create(splashBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()

task.wait(0.55)
splashBg:Destroy()

mainFrame.Visible = true
mainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=normalSize}):Play()
isOpen = true
UpdateMouseLock()

print("[Guasti] v29 carregado com sucesso!")
