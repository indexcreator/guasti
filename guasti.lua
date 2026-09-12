--//======================================================
--//                    GUASTI SCRIPTS v31
--//   Conversão G. completa — sem necessidade de patcher
--//======================================================

-- =========================================================
-- SERVIÇOS E VARIÁVEIS BASE
-- =========================================================
local G = {}

G.Svc = {
    UIS = game:GetService("UserInputService"),
    Tw = game:GetService("TweenService"),
    Pl = game:GetService("Players"),
    RS = game:GetService("RunService"),
    CG = game:GetService("CoreGui"),
    WS = game:GetService("Workspace"),
    H = game:GetService("HttpService"),
    Tp = game:GetService("TeleportService"),
    L = game:GetService("Lighting"),
    VU = game:GetService("VirtualUser"),
    VIM = game:GetService("VirtualInputManager"),
    Stats = game:GetService("Stats"),
}

G.pl = G.Svc.Pl.LocalPlayer
G.cam = G.Svc.WS.CurrentCamera
G.mouse = G.pl:GetMouse()

-- Limpa instância antiga
pcall(function()
    local o = G.Svc.CG:FindFirstChild("GuastiGUI")
    if o then o:Destroy() end
    local f = G.Svc.WS:FindFirstChild("GuastiESPFolder")
    if f then f:Destroy() end
end)

G.espFolder = Instance.new("Folder")
G.espFolder.Name = "GuastiESPFolder"
G.espFolder.Parent = G.Svc.WS

G.CFG_FILE = "GuastiConfig.json"

G.Conns = {}
G.Tr = function(c)
    table.insert(G.Conns, c)
    return c
end

-- Salva iluminação original
G.origL = {
    Ambient = G.Svc.L.Ambient,
    Brightness = G.Svc.L.Brightness,
    OutdoorAmbient = G.Svc.L.OutdoorAmbient,
    ClockTime = G.Svc.L.ClockTime,
    GlobalShadows = G.Svc.L.GlobalShadows,
    FogEnd = G.Svc.L.FogEnd,
}
G.origEff = {}
for _, e in ipairs(G.Svc.L:GetChildren()) do
    if e:IsA("PostEffect") then
        table.insert(G.origEff, {effect=e, enabled=e.Enabled})
    end
end

-- =========================================================
-- SETTINGS
-- =========================================================
G.Set = {
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
    MaxDistance = 10000,   -- NOVO: máximo do aimbot
    WallCheck = false,
    TeamCheck = false,
    Smoothness = 0,        -- suavização 0-100
    FOVVisible = false,
    FOVColor = Color3.fromRGB(255,255,255),
    FOVInnerColor = Color3.fromRGB(255,100,100),
    FOVTransparency = 1,
    FOVStateColor = false,
    PredictionEnabled = false,
    Prediction = 20,
    PredictVisual = false,
    AimbotTargetLine = false,
    SilentAimEnabled = false,
    -- Trigger Bot
    TriggerBotEnabled = false,
    TriggerBotKey = Enum.KeyCode.E,
    TriggerBotAutoFire = false,
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
    ESPWeapon = false,
    ESPDistanceInName = false,
    ESPRainbow = false,
    ESPDistanceColor = false,
    ESPMaxDistance = 10000, -- NOVO: máximo do ESP
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
    -- Visual
    FullbrightEnabled = false,
    FullbrightBrightness = 2,
    FPSBoostEnabled = false,
    AntiVoidEnabled = false,
    AntiVoidHeight = -50,
    -- Teleporte
    ClickTPEnabled = false,
    TPSmooth = false,       -- CORRIGIDO: desligado por padrão
    TPSmoothSpeed = 0.3,
    -- Extras
    AntiAFKEnabled = false,
    SoundNotificationsEnabled = false,
    CustomSoundId = "",
    PlayerListEnabled = false,
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
    ConfirmCloseEnabled = true,
    GuiAnimationsEnabled = true,
    AntiBanEnabled = false,
    -- Temas
    CustomBg = Color3.fromRGB(15,15,15),
    CustomTop = Color3.fromRGB(25,25,25),
    CustomAccent = Color3.fromRGB(80,150,255),
    -- Internos
    IgnoredPlayers = {},
    Keybinds = {
        Fly = nil, Noclip = nil, Walkspeed = nil, ESP = nil,
        ClickTP = nil, TPPlayer = nil, TriggerBot = nil, Aimbot = nil,
    },
}

-- =========================================================
-- DRAWING OBJECTS
-- =========================================================
G.D = {}
G.D.FOV = Drawing.new("Circle")
G.D.FOV.Visible = false
G.D.FOV.Radius = G.Set.FOV
G.D.FOV.Thickness = 1.5
G.D.FOV.Color = G.Set.FOVColor
G.D.FOV.Transparency = 1
G.D.FOV.Filled = false

G.D.FOVInner = Drawing.new("Circle")
G.D.FOVInner.Visible = false
G.D.FOVInner.Radius = G.Set.FOVInner
G.D.FOVInner.Thickness = 1.5
G.D.FOVInner.Color = G.Set.FOVInnerColor
G.D.FOVInner.Transparency = 1
G.D.FOVInner.Filled = false

G.D.PredDot = Drawing.new("Circle")
G.D.PredDot.Visible = false
G.D.PredDot.Radius = 4
G.D.PredDot.Thickness = 2
G.D.PredDot.Color = Color3.fromRGB(255,50,50)
G.D.PredDot.Transparency = 1
G.D.PredDot.Filled = true

G.D.TargetLine = Drawing.new("Line")
G.D.TargetLine.Visible = false
G.D.TargetLine.Thickness = 2
G.D.TargetLine.Color = Color3.fromRGB(255,50,50)
G.D.TargetLine.Transparency = 1

G.D.Cross = {}
for i = 1, 2 do
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    l.Color = G.Set.CrosshairColor
    l.Transparency = 1
    G.D.Cross[i] = l
end

-- =========================================================
-- ESTADO (variáveis que mudam em tempo real)
-- =========================================================
G.V = {
    tKey = G.Set.MenuKey,
    waitingMenuKey = false,
    waitingAimbotKey = false,
    waitingTriggerKey = false,
    waitingHideKey = false,
    waitingBind = nil,
    minimized = false,
    nSize = UDim2.new(0, 500, 0, 400),
    open = true,
    hidden = false,
    cleaned = false,
    colorTarget = "Line",
    currentHue = 0,
    themeIdx = 1,
    animPhase = 0,
    autoClickerActive = false,
    sessionFpsMin = 999,
    sessionFpsMax = 0,
    sessionFpsSum = 0,
    sessionFpsCount = 0,
    lastHealth = {},
    lastPositions = {},
    playerJoinTimes = {},
    keyCombos = {},
    espObjects = {},
    toggles = {},
    sliders = {},
    inputs = {},
    tgRefs = {},
    keybindRows = {},
    notifStack = {},
    radarDots = {},
}

-- =========================================================
-- TEMAS
-- =========================================================
G.TH = {
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
    {name="RGB (Arco-íris)", bg=Color3.fromRGB(15,15,15), top=Color3.fromRGB(25,25,25), accent=Color3.fromRGB(255,100,100), rgb=true},
    {name="Customizado", bg=G.Set.CustomBg, top=G.Set.CustomTop, accent=G.Set.CustomAccent, custom=true},
}

-- =========================================================
-- FUNÇÕES BASE
-- =========================================================
G.F = {}

-- Ícone por palavra-chave
G.F.GetIcon = function(name)
    local n = name:lower()
    if n:find("aimbot") then return "🎯" end
    if n:find("esp") and not n:find("mostrar") then return "👁️" end
    if n:find("fly") then return "✈️" end
    if n:find("noclip") then return "👻" end
    if n:find("speed") or n:find("walkspeed") then return "⚡" end
    if n:find("jump") then return "🦘" end
    if n:find("infinite") then return "♾️" end
    if n:find("anti") then return "🛡️" end
    if n:find("fullbright") then return "💡" end
    if n:find("fps") then return "📊" end
    if n:find("ping") then return "📡" end
    if n:find("radar") then return "📡" end
    if n:find("console") then return "💻" end
    if n:find("crosshair") then return "➕" end
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
    if n:find("auto") then return "🤖" end
    if n:find("kill") then return "💀" end
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

G.F.PlayNotifSound = function(isOn)
    if not G.Set.SoundNotificationsEnabled then return end
    if G.Set.CustomSoundId ~= "" then
        local id = G.Set.CustomSoundId
        if not id:match("^rbxassetid://") then id = "rbxassetid://" .. id:gsub("%D","") end
        G.Sound.SoundId = id
    else
        G.Sound.SoundId = "rbxassetid://6042053626"
    end
    G.Sound.PlaybackSpeed = isOn and 1 or 0.7
    G.Sound:Play()
end

G.F.Log = function(text, color)
    if not G.Set.ConsoleEnabled then return end
    color = color or Color3.fromRGB(200,200,200)
    local l = Instance.new("TextLabel")
    local n = #G.UI.consoleScroll:GetChildren()
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
    l.Parent = G.UI.consoleScroll
    G.UI.consoleScroll.CanvasSize = UDim2.new(0,0,0,(n+1)*16+5)
    G.UI.consoleScroll.CanvasPosition = Vector2.new(0, G.UI.consoleScroll.AbsoluteCanvasSize.Y)
    if n > 80 then G.UI.consoleScroll:GetChildren()[1]:Destroy() end
end

-- Notificação com pilha, letras brancas, sem borda
G.F.Notify = function(text, color)
    color = color or G.TH[G.V.themeIdx].accent
    G.F.Log(text, color)

    local stackHeight = 0
    for _, existing in ipairs(G.V.notifStack) do
        stackHeight = stackHeight + 46
    end

    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0,300,0,40)
    n.Position = UDim2.new(0.5, -150, 0, 30 + stackHeight)
    n.BackgroundColor3 = G.TH[G.V.themeIdx].bg
    n.BackgroundTransparency = 0.15
    n.TextColor3 = Color3.fromRGB(255,255,255)  -- BRANCO
    n.Font = Enum.Font.GothamBold
    n.TextSize = 14
    n.Text = text
    n.TextTransparency = 1
    n.ZIndex = 500
    n.Parent = G.UI.gui
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,8); nc.Parent = n
    -- sem UIStroke

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

    table.insert(G.V.notifStack, n)

    G.Svc.Tw:Create(n, TweenInfo.new(0.3), {TextTransparency=0, BackgroundTransparency=0.15}):Play()
    G.Svc.Tw:Create(progressBar, TweenInfo.new(2), {Size=UDim2.new(0,0,1,0)}):Play()
    G.F.PlayNotifSound(color.G > color.R)

    task.delay(2.2, function()
        if not n or not n.Parent then return end
        local t1 = G.Svc.Tw:Create(n, TweenInfo.new(0.4), {TextTransparency=1, BackgroundTransparency=1})
        t1:Play()
        t1.Completed:Connect(function()
            for i, existing in ipairs(G.V.notifStack) do
                if existing == n then
                    table.remove(G.V.notifStack, i)
                    break
                end
            end
            if n then n:Destroy() end
        end)
    end)
end

G.F.ApplyFPSBoost = function(state)
    if state then
        G.Svc.L.GlobalShadows = false
        G.Svc.L.FogEnd = 100000
        for _, e in ipairs(G.Svc.L:GetChildren()) do
            if e:IsA("PostEffect") and e.Enabled then e.Enabled = false end
        end
        for _, o in ipairs(G.Svc.WS:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                o.Enabled = false
            elseif o:IsA("Decal") or o:IsA("Texture") then
                o.Transparency = 1
            end
        end
    else
        G.Svc.L.GlobalShadows = G.origL.GlobalShadows
        G.Svc.L.FogEnd = G.origL.FogEnd
        for _, e in ipairs(G.Svc.L:GetChildren()) do
            if e:IsA("PostEffect") then
                for _, o in ipairs(G.origEff) do
                    if o.effect == e then e.Enabled = o.enabled; break end
                end
            end
        end
        for _, o in ipairs(G.Svc.WS:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
                pcall(function() o.Enabled = true end)
            elseif o:IsA("Decal") or o:IsA("Texture") then
                pcall(function() o.Transparency = 0 end)
            end
        end
    end
end

-- Aplica Fullbright em loop (não é resetado pelo jogo)
G.F.ApplyFullbrightLoop = function()
    if G.V.cleaned then return end
    if G.Set.FullbrightEnabled then
        G.Svc.L.Ambient = Color3.fromRGB(150,150,150)
        G.Svc.L.OutdoorAmbient = Color3.fromRGB(150,150,150)
        G.Svc.L.Brightness = G.Set.FullbrightBrightness
        G.Svc.L.ClockTime = 12
    end
end

G.F.SmoothTP = function(targetCF)
    if not G.Set.TPSmooth then
        local ch = G.pl.Character
        local rt = ch and ch:FindFirstChild("HumanoidRootPart")
        if rt then rt.CFrame = targetCF end
        return
    end
    local ch = G.pl.Character
    local rt = ch and ch:FindFirstChild("HumanoidRootPart")
    if not rt then return end
    local startCF = rt.CFrame
    local startT = tick()
    task.spawn(function()
        while tick() - startT < G.Set.TPSmoothSpeed do
            if G.V.cleaned then return end
            local a = math.clamp((tick() - startT) / G.Set.TPSmoothSpeed, 0, 1)
            pcall(function() rt.CFrame = startCF:Lerp(targetCF, a) end)
            task.wait()
        end
        pcall(function() rt.CFrame = targetCF end)
    end)
end

G.F.Rainbow = function()
    G.V.currentHue = (G.V.currentHue + 0.008) % 1
    return Color3.fromHSV(G.V.currentHue, 1, 1)
end

-- =========================================================
-- SOM DE NOTIFICAÇÃO
-- =========================================================
G.Sound = Instance.new("Sound")
G.Sound.SoundId = "rbxassetid://6042053626"
G.Sound.Volume = 0.35
G.Sound.Parent = G.Svc.CG

-- =========================================================
-- GUI BASE
-- =========================================================
G.UI = {}

G.UI.gui = Instance.new("ScreenGui")
G.UI.gui.Name = "GuastiGUI"
G.UI.gui.ResetOnSpawn = false
G.UI.gui.IgnoreGuiInset = true
G.UI.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() G.UI.gui.Parent = G.Svc.CG end)
if not G.UI.gui.Parent then
    G.UI.gui.Parent = G.pl:WaitForChild("PlayerGui")
end

-- Sombra 3D (invisível inicialmente até splash acabar)
G.UI.shadow = Instance.new("Frame")
G.UI.shadow.Size = G.V.nSize
G.UI.shadow.Position = UDim2.new(1, -G.V.nSize.X.Offset - 16, 0, 24)
G.UI.shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
G.UI.shadow.BackgroundTransparency = 0.6
G.UI.shadow.BorderSizePixel = 0
G.UI.shadow.ZIndex = 0
G.UI.shadow.Visible = false
G.UI.shadow.Parent = G.UI.gui
local shadowC = Instance.new("UICorner"); shadowC.CornerRadius = UDim.new(0,10); shadowC.Parent = G.UI.shadow

-- Janela principal
G.UI.main = Instance.new("Frame")
G.UI.main.Size = G.V.nSize
G.UI.main.Position = UDim2.new(1, -G.V.nSize.X.Offset - 20, 0, 20)
G.UI.main.BackgroundColor3 = G.TH[G.V.themeIdx].bg
G.UI.main.BorderSizePixel = 0
G.UI.main.ClipsDescendants = true
G.UI.main.Visible = false
G.UI.main.Parent = G.UI.gui
local mainC = Instance.new("UICorner"); mainC.CornerRadius = UDim.new(0,10); mainC.Parent = G.UI.main

local bgGrad = Instance.new("UIGradient")
bgGrad.Rotation = 90
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, G.TH[G.V.themeIdx].bg),
    ColorSequenceKeypoint.new(1, G.TH[G.V.themeIdx].top),
})
bgGrad.Parent = G.UI.main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = G.TH[G.V.themeIdx].accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.Parent = G.UI.main
G.UI.mainStroke = mainStroke
G.UI.bgGrad = bgGrad

-- TopBar
G.UI.topBar = Instance.new("Frame")
G.UI.topBar.Size = UDim2.new(1,0,0,32)
G.UI.topBar.BackgroundColor3 = G.TH[G.V.themeIdx].top
G.UI.topBar.BorderSizePixel = 0
G.UI.topBar.Parent = G.UI.main
local topC = Instance.new("UICorner"); topC.CornerRadius = UDim.new(0,10); topC.Parent = G.UI.topBar

local topExt = Instance.new("Frame")
topExt.Size = UDim2.new(1,0,0,6)
topExt.Position = UDim2.new(0,0,1,-6)
topExt.BackgroundColor3 = G.TH[G.V.themeIdx].top
topExt.BorderSizePixel = 0
topExt.Parent = G.UI.topBar
G.UI.topExt = topExt

-- Logo "G" com fundo cinza claro
G.UI.logo = Instance.new("Frame")
G.UI.logo.Size = UDim2.new(0,24,0,24)
G.UI.logo.Position = UDim2.new(0,8,0.5,-12)
G.UI.logo.BackgroundColor3 = Color3.fromRGB(200,200,200)  -- CINZA CLARO
G.UI.logo.BorderSizePixel = 0
G.UI.logo.Parent = G.UI.topBar
local logoC = Instance.new("UICorner"); logoC.CornerRadius = UDim.new(1,0); logoC.Parent = G.UI.logo

G.UI.logoText = Instance.new("TextLabel")
G.UI.logoText.Size = UDim2.new(1,0,1,0)
G.UI.logoText.BackgroundTransparency = 1
G.UI.logoText.Text = "G"
G.UI.logoText.TextColor3 = Color3.fromRGB(30,30,30)  -- G escuro pra contraste
G.UI.logoText.TextSize = 15
G.UI.logoText.Font = Enum.Font.GothamBlack
G.UI.logoText.Parent = G.UI.logo

-- Título
G.UI.title = Instance.new("TextLabel")
G.UI.title.Size = UDim2.new(0,140,1,0)
G.UI.title.Position = UDim2.new(0,38,0,0)
G.UI.title.BackgroundTransparency = 1
G.UI.title.Text = "Guasti Scripts"
G.UI.title.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.title.TextSize = 14
G.UI.title.Font = Enum.Font.GothamBold
G.UI.title.TextXAlignment = Enum.TextXAlignment.Left
G.UI.title.Parent = G.UI.topBar

-- Bandeira BR
G.UI.flag = Instance.new("Frame")
G.UI.flag.Size = UDim2.new(0,22,0,14)
G.UI.flag.AnchorPoint = Vector2.new(0,0.5)
G.UI.flag.Position = UDim2.new(0,184,0.5,0)
G.UI.flag.BackgroundColor3 = Color3.fromRGB(0,156,59)
G.UI.flag.BorderSizePixel = 0
G.UI.flag.ClipsDescendants = true
G.UI.flag.Parent = G.UI.topBar
local flagC = Instance.new("UICorner"); flagC.CornerRadius = UDim.new(0,2); flagC.Parent = G.UI.flag

local dia = Instance.new("Frame")
dia.Size = UDim2.new(0,9,0,9)
dia.AnchorPoint = Vector2.new(0.5,0.5)
dia.Position = UDim2.new(0.5,0,0.5,0)
dia.BackgroundColor3 = Color3.fromRGB(255,223,0)
dia.BorderSizePixel = 0
dia.Rotation = 45
dia.Parent = G.UI.flag

local fc = Instance.new("Frame")
fc.Size = UDim2.new(0,4,0,4)
fc.AnchorPoint = Vector2.new(0.5,0.5)
fc.Position = UDim2.new(0.5,0,0.5,0)
fc.BackgroundColor3 = Color3.fromRGB(0,39,118)
fc.BorderSizePixel = 0
fc.Parent = G.UI.flag
local fcc = Instance.new("UICorner"); fcc.CornerRadius = UDim.new(1,0); fcc.Parent = fc

-- Botão fechar
G.UI.closeBtn = Instance.new("TextButton")
G.UI.closeBtn.Size = UDim2.new(0,28,0,28)
G.UI.closeBtn.Position = UDim2.new(1,-32,0,2)
G.UI.closeBtn.BackgroundTransparency = 1
G.UI.closeBtn.Text = "✕"
G.UI.closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
G.UI.closeBtn.TextSize = 14
G.UI.closeBtn.Font = Enum.Font.GothamBold
G.UI.closeBtn.Parent = G.UI.topBar

-- Botão minimizar
G.UI.minBtn = Instance.new("TextButton")
G.UI.minBtn.Size = UDim2.new(0,28,0,28)
G.UI.minBtn.Position = UDim2.new(1,-62,0,2)
G.UI.minBtn.BackgroundTransparency = 1
G.UI.minBtn.Text = "—"
G.UI.minBtn.TextColor3 = Color3.fromRGB(200,200,200)
G.UI.minBtn.TextSize = 18
G.UI.minBtn.Font = Enum.Font.GothamBold
G.UI.minBtn.Parent = G.UI.topBar

-- Área de conteúdo
G.UI.content = Instance.new("Frame")
G.UI.content.Size = UDim2.new(1,0,1,-32)
G.UI.content.Position = UDim2.new(0,0,0,32)
G.UI.content.BackgroundTransparency = 1
G.UI.content.Parent = G.UI.main

G.UI.tabs = Instance.new("Frame")
G.UI.tabs.Size = UDim2.new(0,110,1,-20)
G.UI.tabs.Position = UDim2.new(0,10,0,10)
G.UI.tabs.BackgroundTransparency = 1
G.UI.tabs.Parent = G.UI.content

G.UI.pages = Instance.new("Frame")
G.UI.pages.Size = UDim2.new(1,-140,1,-20)
G.UI.pages.Position = UDim2.new(0,130,0,10)
G.UI.pages.BackgroundTransparency = 1
G.UI.pages.Parent = G.UI.content

-- Footer com versão
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,-20,0,14)
footer.Position = UDim2.new(0,10,1,-18)
footer.BackgroundTransparency = 1
footer.Text = "v31 • por indexcreator"
footer.TextColor3 = Color3.fromRGB(90,90,90)
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = G.UI.main

-- =========================================================
-- CONSOLE LOG
-- =========================================================
G.UI.console = Instance.new("Frame")
G.UI.console.Size = UDim2.new(0,300,0,200)
G.UI.console.Position = UDim2.new(0,10,0,10)
G.UI.console.BackgroundColor3 = Color3.fromRGB(12,12,14)
G.UI.console.BackgroundTransparency = 0.1
G.UI.console.BorderSizePixel = 0
G.UI.console.Visible = false
G.UI.console.Active = true
G.UI.console.ZIndex = 350
G.UI.console.Parent = G.UI.gui
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,8); cc.Parent = G.UI.console
local cs = Instance.new("UIStroke"); cs.Color = G.TH[G.V.themeIdx].accent; cs.Thickness = 1.5; cs.Parent = G.UI.console

G.UI.consoleHeader = Instance.new("Frame")
G.UI.consoleHeader.Size = UDim2.new(1,0,0,24)
G.UI.consoleHeader.BackgroundColor3 = Color3.fromRGB(25,25,30)
G.UI.consoleHeader.BorderSizePixel = 0
G.UI.consoleHeader.ZIndex = 351
G.UI.consoleHeader.Parent = G.UI.console
local chc = Instance.new("UICorner"); chc.CornerRadius = UDim.new(0,8); chc.Parent = G.UI.consoleHeader

G.UI.consoleTitle = Instance.new("TextLabel")
G.UI.consoleTitle.Size = UDim2.new(1,-60,1,0)
G.UI.consoleTitle.Position = UDim2.new(0,10,0,0)
G.UI.consoleTitle.BackgroundTransparency = 1
G.UI.consoleTitle.Text = "Console"
G.UI.consoleTitle.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.consoleTitle.Font = Enum.Font.GothamBold
G.UI.consoleTitle.TextSize = 12
G.UI.consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
G.UI.consoleTitle.ZIndex = 352
G.UI.consoleTitle.Parent = G.UI.consoleHeader

G.UI.consoleClear = Instance.new("TextButton")
G.UI.consoleClear.Size = UDim2.new(0,24,1,0)
G.UI.consoleClear.Position = UDim2.new(1,-28,0,0)
G.UI.consoleClear.BackgroundTransparency = 1
G.UI.consoleClear.Text = "🗑"
G.UI.consoleClear.TextColor3 = Color3.fromRGB(255,100,100)
G.UI.consoleClear.TextSize = 12
G.UI.consoleClear.Font = Enum.Font.GothamBold
G.UI.consoleClear.ZIndex = 352
G.UI.consoleClear.Parent = G.UI.consoleHeader

G.UI.consoleScroll = Instance.new("ScrollingFrame")
G.UI.consoleScroll.Size = UDim2.new(1,-10,1,-30)
G.UI.consoleScroll.Position = UDim2.new(0,5,0,28)
G.UI.consoleScroll.BackgroundTransparency = 1
G.UI.consoleScroll.BorderSizePixel = 0
G.UI.consoleScroll.ScrollBarThickness = 3
G.UI.consoleScroll.CanvasSize = UDim2.new(0,0,0,0)
G.UI.consoleScroll.ZIndex = 351
G.UI.consoleScroll.Parent = G.UI.console

G.UI.consoleClear.MouseButton1Click:Connect(function()
    for _, c in ipairs(G.UI.consoleScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    G.UI.consoleScroll.CanvasSize = UDim2.new(0,0,0,0)
end)

-- Drag do console
local cDrag, cDS, cSP
G.UI.consoleHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        cDrag = true; cDS = input.Position; cSP = G.UI.console.Position
    end
end)
G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
    if cDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - cDS
        G.UI.console.Position = UDim2.new(cSP.X.Scale, cSP.X.Offset + d.X, cSP.Y.Scale, cSP.Y.Offset + d.Y)
    end
end))
G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then cDrag = false end
end))

print("[Guasti] Parte 1/3 carregada.")

-- =========================================================
-- TABS (com animação de abertura)
-- =========================================================
G.UI.tabButtons = {}

G.F.CreateTab = function(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,35)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,38)
    btn.BackgroundTransparency = 0.3
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180,180,180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = G.UI.tabs
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn

    btn.MouseEnter:Connect(function()
        if G.Set.GuiAnimationsEnabled and btn.BackgroundTransparency > 0.05 then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.1}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if G.Set.GuiAnimationsEnabled and btn.BackgroundTransparency > 0.05 then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.3}):Play()
        end
    end)

    table.insert(G.UI.tabButtons, btn)
    return btn
end

G.F.CreatePage = function(h)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = G.TH[G.V.themeIdx].accent
    p.Visible = false
    p.CanvasSize = UDim2.new(0,0,0,h or 500)
    p.Parent = G.UI.pages
    return p
end

G.UI.tab1 = G.F.CreateTab("🎯 Aimbot", 0)
G.UI.tab2 = G.F.CreateTab("👁️ ESP", 45)
G.UI.tab3 = G.F.CreateTab("⚙️ Outros", 90)
G.UI.tab4 = G.F.CreateTab("🔧 Config", 135)
G.UI.tab5 = G.F.CreateTab("🎮 Presets", 180)

G.UI.p1 = G.F.CreatePage(900)
G.UI.p2 = G.F.CreatePage(1400)
G.UI.p3 = G.F.CreatePage(1400)
G.UI.p4 = G.F.CreatePage(1300)
G.UI.p5 = G.F.CreatePage(500)

G.UI.p1.Visible = true
G.UI.tab1.BackgroundColor3 = G.TH[G.V.themeIdx].accent
G.UI.tab1.BackgroundTransparency = 0
G.UI.tab1.TextColor3 = Color3.fromRGB(255,255,255)

G.F.SwitchTab = function(sb, sp)
    for _, c in ipairs(G.UI.tabButtons) do
        c.BackgroundColor3 = Color3.fromRGB(35,35,38)
        c.BackgroundTransparency = 0.3
        c.TextColor3 = Color3.fromRGB(180,180,180)
    end
    for _, c in ipairs(G.UI.pages:GetChildren()) do
        if c:IsA("GuiObject") then c.Visible = false end
    end
    sb.BackgroundColor3 = G.TH[G.V.themeIdx].accent
    sb.BackgroundTransparency = 0
    sb.TextColor3 = Color3.fromRGB(255,255,255)
    sp.Visible = true

    -- Animação de abertura (slide in dos botões)
    if G.Set.GuiAnimationsEnabled then
        local children = sp:GetChildren()
        for _, child in ipairs(children) do
            if child:IsA("GuiObject") and (child:IsA("TextButton") or child:IsA("Frame")) then
                local finalPos = child.Position
                child.Position = UDim2.new(finalPos.X.Scale, finalPos.X.Offset + 15, finalPos.Y.Scale, finalPos.Y.Offset)
                task.spawn(function()
                    G.Svc.Tw:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position=finalPos}):Play()
                end)
            end
        end
    end
end

G.UI.tab1.MouseButton1Click:Connect(function() G.F.SwitchTab(G.UI.tab1, G.UI.p1) end)
G.UI.tab2.MouseButton1Click:Connect(function() G.F.SwitchTab(G.UI.tab2, G.UI.p2) end)
G.UI.tab3.MouseButton1Click:Connect(function() G.F.SwitchTab(G.UI.tab3, G.UI.p3) end)
G.UI.tab4.MouseButton1Click:Connect(function() G.F.SwitchTab(G.UI.tab4, G.UI.p4) end)
G.UI.tab5.MouseButton1Click:Connect(function() G.F.SwitchTab(G.UI.tab5, G.UI.p5) end)

-- =========================================================
-- POPUP BASE
-- =========================================================
G.F.CreatePopup = function(headerText)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0,300,0,360)
    p.BackgroundColor3 = G.TH[G.V.themeIdx].bg
    p.BorderSizePixel = 0
    p.Visible = false
    p.ZIndex = 400
    p.Parent = G.UI.gui
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,10); pc.Parent = p

    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,30)
    h.BackgroundColor3 = G.TH[G.V.themeIdx].top
    h.BorderSizePixel = 0
    h.ZIndex = 401
    h.Parent = p
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0,10); hc.Parent = h
    local hx = Instance.new("Frame")
    hx.Size = UDim2.new(1,0,0,5)
    hx.Position = UDim2.new(0,0,1,-5)
    hx.BackgroundColor3 = G.TH[G.V.themeIdx].top
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

    local d, ds, sp
    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = input.Position; sp = p.Position
        end
    end)
    G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
        if d and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dd = input.Position - ds
            p.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
        end
    end))
    G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then d = false end
    end))
    return p
end

-- =========================================================
-- TP POPUP (com barra de busca)
-- =========================================================
G.UI.tpPopup = G.F.CreatePopup("👤 TP para Player")
G.UI.tpSearch = Instance.new("TextBox")
G.UI.tpSearch.Size = UDim2.new(1,-20,0,26)
G.UI.tpSearch.Position = UDim2.new(0,10,0,38)
G.UI.tpSearch.BackgroundColor3 = Color3.fromRGB(30,30,35)
G.UI.tpSearch.PlaceholderText = "🔍 Buscar..."
G.UI.tpSearch.Text = ""
G.UI.tpSearch.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.tpSearch.PlaceholderColor3 = Color3.fromRGB(140,140,140)
G.UI.tpSearch.Font = Enum.Font.Gotham
G.UI.tpSearch.TextSize = 12
G.UI.tpSearch.ZIndex = 402
G.UI.tpSearch.Parent = G.UI.tpPopup
local tsc = Instance.new("UICorner"); tsc.CornerRadius = UDim.new(0,6); tsc.Parent = G.UI.tpSearch

G.UI.tpList = Instance.new("ScrollingFrame")
G.UI.tpList.Size = UDim2.new(1,-20,1,-75)
G.UI.tpList.Position = UDim2.new(0,10,0,70)
G.UI.tpList.BackgroundTransparency = 1
G.UI.tpList.BorderSizePixel = 0
G.UI.tpList.ScrollBarThickness = 4
G.UI.tpList.CanvasSize = UDim2.new(0,0,0,0)
G.UI.tpList.ZIndex = 402
G.UI.tpList.Parent = G.UI.tpPopup

G.F.RefreshTPList = function()
    for _, c in ipairs(G.UI.tpList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local filter = G.UI.tpSearch.Text:lower()
    local sorted = {}
    for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
        if filter == "" or p.Name:lower():find(filter, 1, true) then
            table.insert(sorted, p)
        end
    end
    table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
    local y = 0
    for _, p in ipairs(sorted) do
        local label = p.Name
        if p == G.pl then label = label .. " (você)" end
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
        btn.Parent = G.UI.tpList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if p == G.pl then return end
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                G.F.SmoothTP(tr.CFrame + Vector3.new(0,3,0))
                G.F.Notify("🎯 TP: " .. p.Name)
                G.UI.tpPopup.Visible = false
            else
                G.F.Notify("❌ Alvo inválido", Color3.fromRGB(255,60,60))
            end
        end)
        y = y + 34
    end
    G.UI.tpList.CanvasSize = UDim2.new(0,0,0,y+5)
end
G.UI.tpSearch:GetPropertyChangedSignal("Text"):Connect(G.F.RefreshTPList)

G.F.OpenTPPopup = function()
    G.F.RefreshTPList()
    local ma = G.UI.main.AbsolutePosition
    local ms = G.UI.main.AbsoluteSize
    G.UI.tpPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    G.UI.tpPopup.Visible = true
end

-- =========================================================
-- IGNORE POPUP
-- =========================================================
G.UI.igPopup = G.F.CreatePopup("🚫 Ignorar Players")
G.UI.igList = Instance.new("ScrollingFrame")
G.UI.igList.Size = UDim2.new(1,-20,1,-50)
G.UI.igList.Position = UDim2.new(0,10,0,44)
G.UI.igList.BackgroundTransparency = 1
G.UI.igList.BorderSizePixel = 0
G.UI.igList.ScrollBarThickness = 4
G.UI.igList.CanvasSize = UDim2.new(0,0,0,0)
G.UI.igList.ZIndex = 402
G.UI.igList.Parent = G.UI.igPopup

G.F.RefreshIG = function()
    for _, c in ipairs(G.UI.igList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local sorted = {}
    for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
        if p ~= G.pl then table.insert(sorted, p) end
    end
    table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
    local y = 0
    for _, p in ipairs(sorted) do
        local isIgn = G.Set.IgnoredPlayers[p.UserId] == true
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
        btn.Parent = G.UI.igList
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,5); c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if G.Set.IgnoredPlayers[p.UserId] then
                G.Set.IgnoredPlayers[p.UserId] = nil
                G.F.Notify("👋 Deixou de ignorar: " .. p.Name, Color3.fromRGB(255,200,60))
            else
                G.Set.IgnoredPlayers[p.UserId] = true
                G.F.Notify("🚫 Ignorando: " .. p.Name)
            end
            G.F.RefreshIG()
        end)
        y = y + 34
    end
    G.UI.igList.CanvasSize = UDim2.new(0,0,0,y+5)
end

G.F.OpenIGPopup = function()
    G.F.RefreshIG()
    local ma = G.UI.main.AbsolutePosition
    local ms = G.UI.main.AbsoluteSize
    G.UI.igPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    G.UI.igPopup.Visible = true
end

-- =========================================================
-- WAYPOINTS POPUP (com ícone no mapa)
-- =========================================================
G.UI.wpPopup = G.F.CreatePopup("📍 Waypoints")

G.UI.wpInput = Instance.new("Frame")
G.UI.wpInput.Size = UDim2.new(1,-20,0,30)
G.UI.wpInput.Position = UDim2.new(0,10,0,40)
G.UI.wpInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
G.UI.wpInput.BorderSizePixel = 0
G.UI.wpInput.ZIndex = 402
G.UI.wpInput.Parent = G.UI.wpPopup
local wic = Instance.new("UICorner"); wic.CornerRadius = UDim.new(0,6); wic.Parent = G.UI.wpInput

G.UI.wpName = Instance.new("TextBox")
G.UI.wpName.Size = UDim2.new(1,-80,1,0)
G.UI.wpName.Position = UDim2.new(0,5,0,0)
G.UI.wpName.BackgroundTransparency = 1
G.UI.wpName.Text = "WP1"
G.UI.wpName.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.wpName.Font = Enum.Font.GothamMedium
G.UI.wpName.TextSize = 12
G.UI.wpName.ClearTextOnFocus = false
G.UI.wpName.ZIndex = 403
G.UI.wpName.Parent = G.UI.wpInput

G.UI.wpSave = Instance.new("TextButton")
G.UI.wpSave.Size = UDim2.new(0,70,1,0)
G.UI.wpSave.Position = UDim2.new(1,-70,0,0)
G.UI.wpSave.BackgroundColor3 = Color3.fromRGB(60,130,60)
G.UI.wpSave.Text = "💾 Salvar"
G.UI.wpSave.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.wpSave.Font = Enum.Font.GothamBold
G.UI.wpSave.TextSize = 11
G.UI.wpSave.ZIndex = 403
G.UI.wpSave.Parent = G.UI.wpInput
local wsc = Instance.new("UICorner"); wsc.CornerRadius = UDim.new(0,6); wsc.Parent = G.UI.wpSave

G.UI.wpList = Instance.new("ScrollingFrame")
G.UI.wpList.Size = UDim2.new(1,-20,1,-85)
G.UI.wpList.Position = UDim2.new(0,10,0,80)
G.UI.wpList.BackgroundTransparency = 1
G.UI.wpList.BorderSizePixel = 0
G.UI.wpList.ScrollBarThickness = 4
G.UI.wpList.CanvasSize = UDim2.new(0,0,0,0)
G.UI.wpList.ZIndex = 402
G.UI.wpList.Parent = G.UI.wpPopup

-- Ícones dos waypoints no mapa (Beam + Billboard)
G.wpIcons = {}

G.F.AddWPIcon = function(wp)
    local attach = Instance.new("Attachment")
    attach.Position = wp.pos
    attach.WorldPosition = wp.pos
    attach.Name = "GuastiWP_" .. wp.name
    attach.Parent = G.Svc.WS.Terrain or G.Svc.WS

    local beam = Instance.new("Beam")
    beam.Attachment0 = attach
    beam.Attachment1 = attach
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Color = ColorSequence.new(Color3.fromRGB(80,220,80))
    beam.FaceCamera = true
    beam.Parent = attach
    beam.Enabled = false

    local bp = Instance.new("BillboardGui")
    bp.Size = UDim2.new(0, 100, 0, 30)
    bp.StudsOffset = Vector3.new(0, 5, 0)
    bp.AlwaysOnTop = false
    bp.MaxDistance = 500
    bp.Parent = attach

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "📍 " .. wp.name
    lbl.TextColor3 = Color3.fromRGB(80,220,80)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bp

    table.insert(G.wpIcons, {attach=attach, beam=beam, billboard=bp, name=wp.name})
end

G.F.RefreshWPList = function()
    for _, c in ipairs(G.UI.wpList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, icon in ipairs(G.wpIcons) do
        pcall(function() icon.attach:Destroy() end)
    end
    G.wpIcons = {}

    local list = G.Set.WaypointsPerGame[tostring(game.PlaceId)] or {}
    local y = 0
    for i, wp in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-5,0,30)
        row.Position = UDim2.new(0,0,0,y)
        row.BackgroundColor3 = Color3.fromRGB(40,40,45)
        row.BorderSizePixel = 0
        row.ZIndex = 403
        row.Parent = G.UI.wpList
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,5); rc.Parent = row

        local nL = Instance.new("TextLabel")
        nL.Size = UDim2.new(1,-90,1,0)
        nL.Position = UDim2.new(0,8,0,0)
        nL.BackgroundTransparency = 1
        nL.Text = "📍 " .. wp.name
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
            G.F.SmoothTP(CFrame.new(wp.pos))
            G.F.Notify("📍 TP: " .. wp.name)
            G.UI.wpPopup.Visible = false
        end)
        xB.MouseButton1Click:Connect(function()
            table.remove(list, i)
            G.F.RefreshWPList()
            G.F.Notify("🗑️ WP removido", Color3.fromRGB(255,200,60))
        end)

        G.F.AddWPIcon(wp)
        y = y + 34
    end
    G.UI.wpList.CanvasSize = UDim2.new(0,0,0,y+5)
end

G.UI.wpSave.MouseButton1Click:Connect(function()
    local rt = G.pl.Character and G.pl.Character:FindFirstChild("HumanoidRootPart")
    if not rt then return end
    local pid = tostring(game.PlaceId)
    if not G.Set.WaypointsPerGame[pid] then
        G.Set.WaypointsPerGame[pid] = {}
    end
    local list = G.Set.WaypointsPerGame[pid]
    local name = G.UI.wpName.Text
    if name == "" then name = "WP" .. (#list + 1) end
    table.insert(list, {name=name, pos=rt.Position})
    G.F.Notify("📍 WP salvo: " .. name)
    G.F.RefreshWPList()
    G.UI.wpName.Text = "WP" .. (#list + 1)
end)

G.F.OpenWPPopup = function()
    G.F.RefreshWPList()
    local ma = G.UI.main.AbsolutePosition
    local ms = G.UI.main.AbsoluteSize
    G.UI.wpPopup.Position = UDim2.fromOffset(ma.X, ma.Y + ms.Y + 10)
    G.UI.wpPopup.Visible = true
end

-- =========================================================
-- PLAYER LIST FLUTUANTE
-- =========================================================
G.UI.plFrame = Instance.new("Frame")
G.UI.plFrame.Size = UDim2.new(0,210,0,280)
G.UI.plFrame.Position = UDim2.new(0,10,0,10)
G.UI.plFrame.BackgroundColor3 = G.TH[G.V.themeIdx].bg
G.UI.plFrame.BorderSizePixel = 0
G.UI.plFrame.Visible = false
G.UI.plFrame.ZIndex = 300
G.UI.plFrame.Active = true
G.UI.plFrame.Parent = G.UI.gui
local plC = Instance.new("UICorner"); plC.CornerRadius = UDim.new(0,8); plC.Parent = G.UI.plFrame
local plS = Instance.new("UIStroke"); plS.Color = G.TH[G.V.themeIdx].accent; plS.Thickness = 1.5; plS.Parent = G.UI.plFrame

G.UI.plHeader = Instance.new("Frame")
G.UI.plHeader.Size = UDim2.new(1,0,0,26)
G.UI.plHeader.BackgroundColor3 = G.TH[G.V.themeIdx].top
G.UI.plHeader.BorderSizePixel = 0
G.UI.plHeader.ZIndex = 301
G.UI.plHeader.Parent = G.UI.plFrame
local plHC = Instance.new("UICorner"); plHC.CornerRadius = UDim.new(0,8); plHC.Parent = G.UI.plHeader

G.UI.plTitle = Instance.new("TextLabel")
G.UI.plTitle.Size = UDim2.new(1,-30,1,0)
G.UI.plTitle.Position = UDim2.new(0,8,0,0)
G.UI.plTitle.BackgroundTransparency = 1
G.UI.plTitle.Text = "👥 Players"
G.UI.plTitle.TextColor3 = Color3.fromRGB(255,255,255)
G.UI.plTitle.Font = Enum.Font.GothamBold
G.UI.plTitle.TextSize = 12
G.UI.plTitle.TextXAlignment = Enum.TextXAlignment.Left
G.UI.plTitle.ZIndex = 302
G.UI.plTitle.Parent = G.UI.plHeader

G.UI.plClose = Instance.new("TextButton")
G.UI.plClose.Size = UDim2.new(0,26,0,26)
G.UI.plClose.Position = UDim2.new(1,-26,0,0)
G.UI.plClose.BackgroundTransparency = 1
G.UI.plClose.Text = "✕"
G.UI.plClose.TextColor3 = Color3.fromRGB(255,100,100)
G.UI.plClose.Font = Enum.Font.GothamBold
G.UI.plClose.TextSize = 13
G.UI.plClose.ZIndex = 302
G.UI.plClose.Parent = G.UI.plHeader

G.UI.plList = Instance.new("ScrollingFrame")
G.UI.plList.Size = UDim2.new(1,-10,1,-35)
G.UI.plList.Position = UDim2.new(0,5,0,30)
G.UI.plList.BackgroundTransparency = 1
G.UI.plList.BorderSizePixel = 0
G.UI.plList.ScrollBarThickness = 3
G.UI.plList.CanvasSize = UDim2.new(0,0,0,0)
G.UI.plList.ZIndex = 302
G.UI.plList.Parent = G.UI.plFrame

G.UI.plClose.MouseButton1Click:Connect(function()
    G.Set.PlayerListEnabled = false
    G.UI.plFrame.Visible = false
    G.F.Notify("👥 Player List: OFF", Color3.fromRGB(220,60,60))
    if G.V.tgRefs.PlayerList then G.V.tgRefs.PlayerList(false, true) end
end)

local plDrag, plDS, plSP
G.UI.plHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        plDrag = true; plDS = input.Position; plSP = G.UI.plFrame.Position
    end
end)
G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
    if plDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - plDS
        G.UI.plFrame.Position = UDim2.new(plSP.X.Scale, plSP.X.Offset + d.X, plSP.Y.Scale, plSP.Y.Offset + d.Y)
    end
end))
G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then plDrag = false end
end))

-- =========================================================
-- HUDs (FPS, Ping, Radar, Crosshair)
-- =========================================================
G.UI.fps = Instance.new("TextLabel")
G.UI.fps.Size = UDim2.new(0,140,0,24)
G.UI.fps.Position = UDim2.new(1,-150,0,10)
G.UI.fps.BackgroundColor3 = G.TH[G.V.themeIdx].bg
G.UI.fps.BackgroundTransparency = 0.15
G.UI.fps.Text = "📊 FPS: --"
G.UI.fps.TextColor3 = Color3.fromRGB(200,200,200)
G.UI.fps.Font = Enum.Font.Code
G.UI.fps.TextSize = 13
G.UI.fps.Visible = false
G.UI.fps.ZIndex = 100
G.UI.fps.Parent = G.UI.gui
local fpsc = Instance.new("UICorner"); fpsc.CornerRadius = UDim.new(0,4); fpsc.Parent = G.UI.fps
local fpsStroke = Instance.new("UIStroke"); fpsStroke.Color = G.TH[G.V.themeIdx].accent; fpsStroke.Thickness = 1; fpsStroke.Parent = G.UI.fps

G.UI.ping = Instance.new("TextLabel")
G.UI.ping.Size = UDim2.new(0,140,0,24)
G.UI.ping.Position = UDim2.new(1,-150,0,38)
G.UI.ping.BackgroundColor3 = G.TH[G.V.themeIdx].bg
G.UI.ping.BackgroundTransparency = 0.15
G.UI.ping.Text = "📡 Ping: --"
G.UI.ping.TextColor3 = Color3.fromRGB(200,200,200)
G.UI.ping.Font = Enum.Font.Code
G.UI.ping.TextSize = 13
G.UI.ping.Visible = false
G.UI.ping.ZIndex = 100
G.UI.ping.Parent = G.UI.gui
local pingc = Instance.new("UICorner"); pingc.CornerRadius = UDim.new(0,4); pingc.Parent = G.UI.ping
local pingStroke = Instance.new("UIStroke"); pingStroke.Color = G.TH[G.V.themeIdx].accent; pingStroke.Thickness = 1; pingStroke.Parent = G.UI.ping

-- Radar (SEM BORDA)
G.UI.radar = Instance.new("Frame")
G.UI.radar.Size = UDim2.new(0,130,0,130)
G.UI.radar.Position = UDim2.new(0,10,1,-150)
G.UI.radar.BackgroundColor3 = Color3.fromRGB(12,12,15)
G.UI.radar.BackgroundTransparency = 0.2
G.UI.radar.BorderSizePixel = 0
G.UI.radar.Visible = false
G.UI.radar.Active = true
G.UI.radar.ZIndex = 100
G.UI.radar.Parent = G.UI.gui
local rC = Instance.new("UICorner"); rC.CornerRadius = UDim.new(1,0); rC.Parent = G.UI.radar
-- SEM UIStroke

G.UI.radarCenter = Instance.new("Frame")
G.UI.radarCenter.Size = UDim2.new(0,6,0,6)
G.UI.radarCenter.Position = UDim2.new(0.5,-3,0.5,-3)
G.UI.radarCenter.BackgroundColor3 = Color3.fromRGB(80,255,80)
G.UI.radarCenter.BorderSizePixel = 0
G.UI.radarCenter.ZIndex = 101
G.UI.radarCenter.Parent = G.UI.radar
local rcc = Instance.new("UICorner"); rcc.CornerRadius = UDim.new(1,0); rcc.Parent = G.UI.radarCenter

-- Drag do radar
local rDrag, rDS, rSP
G.UI.radar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rDrag = true; rDS = input.Position; rSP = G.UI.radar.Position
    end
end)
G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
    if rDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - rDS
        G.UI.radar.Position = UDim2.new(rSP.X.Scale, rSP.X.Offset + d.X, rSP.Y.Scale, rSP.Y.Offset + d.Y)
    end
end))
G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then rDrag = false end
end))

print("[Guasti] Parte 2a carregada.")
-- =========================================================
-- ITEM CREATORS
-- =========================================================
G.F.CreateToggleItem = function(parent, name, yPos, callback, initialState, notifyText, settingKey)
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
    icon.Text = G.F.GetIcon(name)
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
            G.Svc.Tw:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3=targetColor}):Play()
            G.Svc.Tw:Create(knob, TweenInfo.new(0.15), {Position=targetPos}):Play()
        else
            indicator.BackgroundColor3 = targetColor
            knob.Position = targetPos
        end
    end

    local function SetState(v, silent)
        if v == nil then state = not state else state = (v == true) end
        Update(true)
        if settingKey then G.Set[settingKey] = state end
        if callback then callback(state) end
        if not silent and notifyText then
            G.F.Notify((state and "✅ " or "❌ ") .. name .. ": " .. (state and "ON" or "OFF"),
                state and Color3.fromRGB(60,220,60) or Color3.fromRGB(220,60,60))
        end
    end

    btn.MouseEnter:Connect(function()
        if G.Set.GuiAnimationsEnabled then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(50,50,58)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if G.Set.GuiAnimationsEnabled then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(35,35,40)}):Play()
        end
    end)

    Update(false)
    btn.MouseButton1Click:Connect(function() SetState() end)

    table.insert(G.V.toggles, {setter=SetState, default=initialState or false})
    if settingKey then table.insert(G.V.tgRefs, {key=settingKey, setter=SetState}) end
    return btn, function() return state end, SetState
end

G.F.CreateButtonItem = function(parent, name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,34)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.Text = "  " .. G.F.GetIcon(name) .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn

    btn.MouseEnter:Connect(function()
        if G.Set.GuiAnimationsEnabled then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(50,50,58)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if G.Set.GuiAnimationsEnabled then
            G.Svc.Tw:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(35,35,40)}):Play()
        end
    end)

    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

G.F.CreateSmallButton = function(parent, name, xPos, yPos, width, callback)
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

G.F.CreateSlider = function(parent, label, yPos, minVal, maxVal, getValue, setValue, suffix, settingKey)
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
    label_.Text = G.F.GetIcon(label) .. "  " .. label .. ": " .. tostring(getValue()) .. suffix
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
    fill.BackgroundColor3 = G.TH[G.V.themeIdx].accent
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
        label_.Text = G.F.GetIcon(label) .. "  " .. label .. ": " .. tostring(math.floor(value*100+0.5)/100) .. suffix
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
    G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end))
    G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    if settingKey then
        table.insert(G.V.sliders, {key=settingKey, updateFn=function() UpdateVisual(G.Set[settingKey]) end})
    end
    return UpdateVisual
end

G.F.CreateInputItem = function(parent, label, yPos, getValue, setValue, minVal, maxVal, settingKey, isText)
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
    label_.Text = G.F.GetIcon(label) .. "  " .. label
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
        table.insert(G.V.inputs, {key=settingKey, textBox=textBox, getValue=getValue})
    end
    return textBox
end

-- Paleta de cores fixas
G.F.CreateColorPalette = function(parent, yPos, getColor, setColor, title, settingKey)
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
    lbl.Text = G.F.GetIcon(title) .. "  " .. title
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
        table.insert(G.V.sliders, {key=settingKey, updateFn=function()
            local cur = G.Set[settingKey]
            for _, e in ipairs(buttons) do
                e.btn.BorderColor3 = (e.color == cur) and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
            end
        end})
    end
    return container
end

-- RGB Picker (NOVO - tema customizável)
G.F.CreateRGBPicker = function(parent, yPos, getColor, setColor, title)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-10,0,130)
    container.Position = UDim2.new(0,0,0,yPos)
    container.BackgroundColor3 = Color3.fromRGB(35,35,40)
    container.BorderSizePixel = 0
    container.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-12,0,20)
    lbl.Position = UDim2.new(0,10,0,2)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🎨  " .. title
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0,50,0,20)
    preview.Position = UDim2.new(1,-60,0,4)
    preview.BackgroundColor3 = getColor()
    preview.BorderSizePixel = 1
    preview.BorderColor3 = Color3.fromRGB(255,255,255)
    preview.Parent = container
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,4); pc.Parent = preview

    local function makeRGBSlider(label, yOff, getV, setV)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-20,0,24)
        row.Position = UDim2.new(0,10,0,yOff)
        row.BackgroundTransparency = 1
        row.Parent = container

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0,20,1,0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Color3.fromRGB(220,220,220)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,-60,0,10)
        bar.Position = UDim2.new(0,20,0.5,-5)
        bar.BackgroundColor3 = Color3.fromRGB(20,20,24)
        bar.BorderSizePixel = 0
        bar.Parent = row
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1,0); bc.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(getV()/255,0,1,0)
        fill.BackgroundColor3 = (label == "R" and Color3.fromRGB(255,60,60))
                            or (label == "G" and Color3.fromRGB(60,255,60))
                            or Color3.fromRGB(60,120,255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0,36,1,0)
        valLbl.Position = UDim2.new(1,-38,0,0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(getV())
        valLbl.TextColor3 = Color3.fromRGB(220,220,220)
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = row

        local dragging = false
        local function setFromX(absX)
            local bx = bar.AbsolutePosition.X
            local bw = bar.AbsoluteSize.X
            if bw <= 0 then return end
            local a = math.clamp((absX - bx) / bw, 0, 1)
            local v = math.floor(a * 255 + 0.5)
            setV(v)
            fill.Size = UDim2.new(a,0,1,0)
            valLbl.Text = tostring(v)
            preview.BackgroundColor3 = getColor()
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; setFromX(input.Position.X)
            end
        end)
        G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end))
        G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        return fill, valLbl
    end

    local rFill = makeRGBSlider("R", 26, function() return math.floor(getColor().R*255) end, function(v)
        setColor(Color3.fromRGB(v, math.floor(getColor().G*255), math.floor(getColor().B*255)))
    end)
    local gFill = makeRGBSlider("G", 54, function() return math.floor(getColor().G*255) end, function(v)
        setColor(Color3.fromRGB(math.floor(getColor().R*255), v, math.floor(getColor().B*255)))
    end)
    local bFill = makeRGBSlider("B", 82, function() return math.floor(getColor().B*255) end, function(v)
        setColor(Color3.fromRGB(math.floor(getColor().R*255), math.floor(getColor().G*255), v))
    end)

    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(1,-20,0,22)
    applyBtn.Position = UDim2.new(0,10,1,-28)
    applyBtn.BackgroundColor3 = G.TH[G.V.themeIdx].accent
    applyBtn.Text = "✅ Aplicar Cor"
    applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 11
    applyBtn.Parent = container
    local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(0,4); abc.Parent = applyBtn

    applyBtn.MouseButton1Click:Connect(function()
        G.F.Notify("🎨 Cor aplicada!", G.TH[G.V.themeIdx].accent)
    end)

    return preview, function()
        preview.BackgroundColor3 = getColor()
    end
end

print("[Guasti] Item Creators carregados.")

-- =========================================================
-- PÁGINA 1: AIMBOT
-- =========================================================
local _, _, SetAimbot = G.F.CreateToggleItem(G.UI.p1, "Aimbot", 0, function(s) G.Set.AimbotEnabled = s end, false, true, "AimbotEnabled")
G.V.tgRefs.Aimbot = SetAimbot

G.F.CreateToggleItem(G.UI.p1, "FOV Circle 2 (Duplo)", 40, function(s) G.Set.FOVDoubleEnabled = s end, false, true, "FOVDoubleEnabled")

G.F.CreateSlider(G.UI.p1, "FOV Externo", 78, 10, 500,
    function() return G.Set.FOV end,
    function(v) G.Set.FOV = v; G.D.FOV.Radius = v end, "", "FOV")

G.F.CreateSlider(G.UI.p1, "FOV Interno", 132, 5, 500,
    function() return G.Set.FOVInner end,
    function(v) G.Set.FOVInner = v; G.D.FOVInner.Radius = v end, "", "FOVInner")

G.F.CreateSlider(G.UI.p1, "Suavização", 186, 0, 100,
    function() return G.Set.Smoothness end,
    function(v) G.Set.Smoothness = v end, "%", "Smoothness")

G.F.CreateColorPalette(G.UI.p1, 240, function() return G.Set.FOVColor end, function(c)
    G.Set.FOVColor = c; G.D.FOV.Color = c
end, "Cor do FOV Externo", "FOVColor")

G.F.CreateColorPalette(G.UI.p1, 308, function() return G.Set.FOVInnerColor end, function(c)
    G.Set.FOVInnerColor = c; G.D.FOVInner.Color = c
end, "Cor do FOV Interno", "FOVInnerColor")

G.F.CreateToggleItem(G.UI.p1, "FOV colorido por estado", 376, function(s) G.Set.FOVStateColor = s end, false, true, "FOVStateColor")

local partLbl = Instance.new("TextLabel")
partLbl.Size = UDim2.new(1,-10,0,18)
partLbl.Position = UDim2.new(0,4,0,414)
partLbl.BackgroundTransparency = 1
partLbl.Text = "  🎯 Mirar em:"
partLbl.TextColor3 = Color3.fromRGB(200,200,200)
partLbl.Font = Enum.Font.GothamMedium
partLbl.TextSize = 11
partLbl.TextXAlignment = Enum.TextXAlignment.Left
partLbl.Parent = G.UI.p1

local headBtn, torsoBtn
headBtn = G.F.CreateSmallButton(G.UI.p1, "Cabeça", 0, 434, 165, function()
    G.Set.AimPart = "Head"
    headBtn.BackgroundColor3 = G.TH[G.V.themeIdx].accent
    torsoBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
end)
torsoBtn = G.F.CreateSmallButton(G.UI.p1, "Torso", 172, 434, 165, function()
    G.Set.AimPart = "Torso"
    torsoBtn.BackgroundColor3 = G.TH[G.V.themeIdx].accent
    headBtn.BackgroundColor3 = Color3.fromRGB(35,35,40)
end)
headBtn.BackgroundColor3 = G.TH[G.V.themeIdx].accent

G.F.CreateSlider(G.UI.p1, "Alcance", 474, 50, 10000,
    function() return G.Set.MaxDistance end,
    function(v) G.Set.MaxDistance = v end, " studs", "MaxDistance")

G.F.CreateToggleItem(G.UI.p1, "Wall Check", 528, function(s) G.Set.WallCheck = s end, false, false, "WallCheck")
G.F.CreateToggleItem(G.UI.p1, "Team Check", 566, function(s) G.Set.TeamCheck = s end, false, false, "TeamCheck")
G.F.CreateToggleItem(G.UI.p1, "Mostrar FOV", 604, function(s) G.Set.FOVVisible = s end, false, false, "FOVVisible")
G.F.CreateToggleItem(G.UI.p1, "Prediction", 642, function(s) G.Set.PredictionEnabled = s end, false, true, "PredictionEnabled")

G.F.CreateSlider(G.UI.p1, "Prediction", 680, 0, 100,
    function() return G.Set.Prediction end,
    function(v) G.Set.Prediction = v end, "%", "Prediction")

G.F.CreateToggleItem(G.UI.p1, "Predict Visual", 734, function(s) G.Set.PredictVisual = s end, false, true, "PredictVisual")
G.F.CreateToggleItem(G.UI.p1, "Aimbot Target Line", 772, function(s) G.Set.AimbotTargetLine = s end, false, true, "AimbotTargetLine")
G.F.CreateToggleItem(G.UI.p1, "Silent Aim", 810, function(s) G.Set.SilentAimEnabled = s end, false, true, "SilentAimEnabled")

G.F.CreateToggleItem(G.UI.p1, "Trigger Bot", 848, function(s) G.Set.TriggerBotEnabled = s end, false, true, "TriggerBotEnabled")
G.F.CreateToggleItem(G.UI.p1, "Trigger Auto-Fire", 886, function(s) G.Set.TriggerBotAutoFire = s end, false, true, "TriggerBotAutoFire")

local aimKeyBtn = G.F.CreateButtonItem(G.UI.p1, "Tecla Aimbot: " .. G.Set.AimbotKey.Name, 924, function()
    G.V.waitingAimbotKey = true
    aimKeyBtn.Text = "  Pressione uma tecla..."
end)
G.UI.aimKeyBtn = aimKeyBtn

local trigKeyBtn = G.F.CreateButtonItem(G.UI.p1, "Tecla Trigger: " .. G.Set.TriggerBotKey.Name, 962, function()
    G.V.waitingTriggerKey = true
    trigKeyBtn.Text = "  Pressione uma tecla..."
end)
G.UI.trigKeyBtn = trigKeyBtn

-- =========================================================
-- PÁGINA 2: ESP
-- =========================================================
local _, _, SetESP = G.F.CreateToggleItem(G.UI.p2, "ESP", 0, function(s) G.Set.ESPEnabled = s end, false, true, "ESPEnabled")
G.V.tgRefs.ESP = SetESP

G.F.CreateToggleItem(G.UI.p2, "Team Check", 40, function(s) G.Set.ESPTeamCheck = s end, false, false, "ESPTeamCheck")
G.F.CreateToggleItem(G.UI.p2, "Linha", 78, function(s) G.Set.ESPLine = s end, false, false, "ESPLine")
G.F.CreateToggleItem(G.UI.p2, "Vida", 116, function(s) G.Set.ESPHealth = s end, false, false, "ESPHealth")
G.F.CreateToggleItem(G.UI.p2, "Distância", 154, function(s) G.Set.ESPDistance = s end, false, false, "ESPDistance")
G.F.CreateToggleItem(G.UI.p2, "Nome", 192, function(s) G.Set.ESPName = s end, false, false, "ESPName")
G.F.CreateToggleItem(G.UI.p2, "Distância no Nome", 230, function(s) G.Set.ESPDistanceInName = s end, false, false, "ESPDistanceInName")
G.F.CreateToggleItem(G.UI.p2, "Arma", 268, function(s) G.Set.ESPWeapon = s end, false, false, "ESPWeapon")
G.F.CreateToggleItem(G.UI.p2, "Box 2D", 306, function(s) G.Set.ESPBox = s end, false, false, "ESPBox")
G.F.CreateToggleItem(G.UI.p2, "Chams", 344, function(s) G.Set.ESPChams = s end, false, false, "ESPChams")
G.F.CreateToggleItem(G.UI.p2, "Esqueleto", 382, function(s) G.Set.ESPSkeleton = s end, false, false, "ESPSkeleton")
G.F.CreateToggleItem(G.UI.p2, "Esqueleto 3D", 420, function(s) G.Set.ESPSkeleton3D = s end, false, false, "ESPSkeleton3D")
G.F.CreateToggleItem(G.UI.p2, "Rainbow ESP", 458, function(s) G.Set.ESPRainbow = s end, false, true, "ESPRainbow")
G.F.CreateToggleItem(G.UI.p2, "Cor por Distância", 496, function(s) G.Set.ESPDistanceColor = s end, false, true, "ESPDistanceColor")

G.F.CreateSlider(G.UI.p2, "Alcance do ESP", 534, 50, 10000,
    function() return G.Set.ESPMaxDistance end,
    function(v) G.Set.ESPMaxDistance = v end, " studs", "ESPMaxDistance")

-- Seletor de cor por elemento
local ctCont = Instance.new("Frame")
ctCont.Size = UDim2.new(1,-10,0,34)
ctCont.Position = UDim2.new(0,0,0,588)
ctCont.BackgroundColor3 = Color3.fromRGB(35,35,40)
ctCont.BorderSizePixel = 0
ctCont.Parent = G.UI.p2
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
ctBtn.BackgroundColor3 = G.TH[G.V.themeIdx].accent
ctBtn.Text = "Linha"
ctBtn.TextColor3 = Color3.fromRGB(255,255,255)
ctBtn.Font = Enum.Font.GothamBold
ctBtn.TextSize = 11
ctBtn.Parent = ctCont
local ctbc = Instance.new("UICorner"); ctbc.CornerRadius = UDim.new(0,4); ctbc.Parent = ctBtn

local ctNames = {"Line", "Name", "Health", "Skeleton", "Box"}
local ctLabels = {"Linha", "Nome", "Vida", "Esqueleto", "Box"}
local ctIndex = 1

G.F.GetEspColor = function()
    if G.V.colorTarget == "Line" then return G.Set.ESPLineColor
    elseif G.V.colorTarget == "Name" then return G.Set.ESPNameColor
    elseif G.V.colorTarget == "Health" then return G.Set.ESPHealthColor
    elseif G.V.colorTarget == "Skeleton" then return G.Set.ESPSkeletonColor
    elseif G.V.colorTarget == "Box" then return G.Set.ESPBoxColor end
    return G.Set.ESPLineColor
end

G.F.SetEspColor = function(c)
    if G.V.colorTarget == "Line" then G.Set.ESPLineColor = c
    elseif G.V.colorTarget == "Name" then G.Set.ESPNameColor = c
    elseif G.V.colorTarget == "Health" then G.Set.ESPHealthColor = c
    elseif G.V.colorTarget == "Skeleton" then G.Set.ESPSkeletonColor = c
    elseif G.V.colorTarget == "Box" then G.Set.ESPBoxColor = c end
end

local espPaletteRefresh
local function RefreshEspPalette()
    if espPaletteRefresh then espPaletteRefresh() end
end

ctBtn.MouseButton1Click:Connect(function()
    ctIndex = ctIndex + 1
    if ctIndex > #ctNames then ctIndex = 1 end
    G.V.colorTarget = ctNames[ctIndex]
    ctBtn.Text = ctLabels[ctIndex]
    RefreshEspPalette()
end)

espPaletteRefresh = G.F.CreateColorPalette(G.UI.p2, 630, G.F.GetEspColor, G.F.SetEspColor, "Cor do Elemento")

G.F.CreateButtonItem(G.UI.p2, "Ignorar Players", 698, function() G.F.OpenIGPopup() end)

-- =========================================================
-- PÁGINA 3: OUTROS
-- =========================================================
local sec1 = Instance.new("TextLabel")
sec1.Size = UDim2.new(1,-10,0,22)
sec1.Position = UDim2.new(0,4,0,0)
sec1.BackgroundTransparency = 1
sec1.Text = "  🎮 MOVIMENTO"
sec1.TextColor3 = G.TH[G.V.themeIdx].accent
sec1.Font = Enum.Font.GothamBold
sec1.TextSize = 12
sec1.TextXAlignment = Enum.TextXAlignment.Left
sec1.Parent = G.UI.p3

local _, _, SetFly = G.F.CreateToggleItem(G.UI.p3, "Fly", 28, function(state)
    G.Set.FlyEnabled = state
    local ch = G.pl.Character
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
G.V.tgRefs.Fly = SetFly

G.F.CreateInputItem(G.UI.p3, "Velocidade do Fly", 66,
    function() return G.Set.FlySpeed end,
    function(v) G.Set.FlySpeed = v end, 1, 500, "FlySpeed")

local _, _, SetNoclip = G.F.CreateToggleItem(G.UI.p3, "Noclip", 104, function(s) G.Set.NoclipEnabled = s end, false, true, "NoclipEnabled")
G.V.tgRefs.Noclip = SetNoclip

local _, _, SetWS = G.F.CreateToggleItem(G.UI.p3, "Walkspeed", 142, function(state)
    G.Set.WalkspeedEnabled = state
    local ch = G.pl.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then
            if state then hum.WalkSpeed = G.Set.WalkspeedValue else hum.WalkSpeed = 16 end
        end
    end
end, false, true, "WalkspeedEnabled")
G.V.tgRefs.Walkspeed = SetWS

G.F.CreateInputItem(G.UI.p3, "Velocidade da Caminhada", 180,
    function() return G.Set.WalkspeedValue end,
    function(v)
        G.Set.WalkspeedValue = v
        if G.Set.WalkspeedEnabled then
            local ch = G.pl.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end
        end
    end, 1, 1000, "WalkspeedValue")

G.F.CreateToggleItem(G.UI.p3, "Anti-Fling", 218, function(s) G.Set.AntiFlingEnabled = s end, false, true, "AntiFlingEnabled")
G.F.CreateToggleItem(G.UI.p3, "Infinite Jump", 256, function(s) G.Set.InfiniteJumpEnabled = s end, false, true, "InfiniteJumpEnabled")
G.F.CreateToggleItem(G.UI.p3, "Anti-Stun / Anti-Ragdoll", 294, function(s) G.Set.AntiStunEnabled = s end, false, true, "AntiStunEnabled")
G.F.CreateToggleItem(G.UI.p3, "Infinite Ammo / Auto-Reload", 332, function(s) G.Set.InfiniteAmmoEnabled = s end, false, true, "InfiniteAmmoEnabled")

G.F.CreateToggleItem(G.UI.p3, "Fullbright", 370, function(state)
    G.Set.FullbrightEnabled = state
end, false, true, "FullbrightEnabled")

G.F.CreateSlider(G.UI.p3, "Brilho Fullbright", 408, 0.5, 5,
    function() return G.Set.FullbrightBrightness end,
    function(v) G.Set.FullbrightBrightness = v end, "", "FullbrightBrightness")

G.F.CreateToggleItem(G.UI.p3, "FPS Boost", 462, function(s)
    G.Set.FPSBoostEnabled = s
    G.F.ApplyFPSBoost(s)
end, false, true, "FPSBoostEnabled")

G.F.CreateToggleItem(G.UI.p3, "Anti-Void", 500, function(s) G.Set.AntiVoidEnabled = s end, false, true, "AntiVoidEnabled")

G.F.CreateSlider(G.UI.p3, "Altura do Anti-Void", 538, -500, 50,
    function() return G.Set.AntiVoidHeight end,
    function(v) G.Set.AntiVoidHeight = v end, "", "AntiVoidHeight")

local sec2 = Instance.new("TextLabel")
sec2.Size = UDim2.new(1,-10,0,22)
sec2.Position = UDim2.new(0,4,0,600)
sec2.BackgroundTransparency = 1
sec2.Text = "  📍 TELEPORTE"
sec2.TextColor3 = G.TH[G.V.themeIdx].accent
sec2.Font = Enum.Font.GothamBold
sec2.TextSize = 12
sec2.TextXAlignment = Enum.TextXAlignment.Left
sec2.Parent = G.UI.p3

G.F.CreateToggleItem(G.UI.p3, "Click TP", 628, function(s) G.Set.ClickTPEnabled = s end, false, true, "ClickTPEnabled")
G.F.CreateToggleItem(G.UI.p3, "TP Suave", 666, function(s) G.Set.TPSmooth = s end, false, true, "TPSmooth")

G.F.CreateSlider(G.UI.p3, "Duração Smooth", 704, 0.1, 1,
    function() return G.Set.TPSmoothSpeed end,
    function(v) G.Set.TPSmoothSpeed = v end, "s", "TPSmoothSpeed")

G.UI.clickTPKeyBtn = G.F.CreateButtonItem(G.UI.p3, "Tecla Click TP: " .. (G.Set.Keybinds.ClickTP and G.Set.Keybinds.ClickTP.Name or "NENHUMA"), 758, function()
    G.V.waitingBind = "ClickTP"
    G.UI.clickTPKeyBtn.Text = "  Pressione uma tecla..."
end)

G.F.CreateButtonItem(G.UI.p3, "TP para Player", 796, function() G.F.OpenTPPopup() end)
G.F.CreateButtonItem(G.UI.p3, "Waypoints (por jogo)", 834, function() G.F.OpenWPPopup() end)

G.UI.tpPlayerKeyBtn = G.F.CreateButtonItem(G.UI.p3, "Tecla TP Player: " .. (G.Set.Keybinds.TPPlayer and G.Set.Keybinds.TPPlayer.Name or "NENHUMA"), 872, function()
    G.V.waitingBind = "TPPlayer"
    G.UI.tpPlayerKeyBtn.Text = "  Pressione uma tecla..."
end)

local sec3 = Instance.new("TextLabel")
sec3.Size = UDim2.new(1,-10,0,22)
sec3.Position = UDim2.new(0,4,0,916)
sec3.BackgroundTransparency = 1
sec3.Text = "  🌐 SERVIDOR"
sec3.TextColor3 = G.TH[G.V.themeIdx].accent
sec3.Font = Enum.Font.GothamBold
sec3.TextSize = 12
sec3.TextXAlignment = Enum.TextXAlignment.Left
sec3.Parent = G.UI.p3

G.UI.status = Instance.new("TextLabel")
G.UI.status.Size = UDim2.new(1,-10,0,18)
G.UI.status.Position = UDim2.new(0,4,0,942)
G.UI.status.BackgroundTransparency = 1
G.UI.status.Text = ""
G.UI.status.TextColor3 = Color3.fromRGB(180,180,180)
G.UI.status.Font = Enum.Font.GothamMedium
G.UI.status.TextSize = 11
G.UI.status.TextXAlignment = Enum.TextXAlignment.Left
G.UI.status.Parent = G.UI.p3

G.F.ServerHop = function()
    G.UI.status.Text = "  🔍 Procurando servidor..."
    task.spawn(function()
        local placeId = game.PlaceId
        local ok, response = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        end)
        if not ok or not response then G.UI.status.Text = "  ❌ Erro ao buscar."; return end
        local ok2, data = pcall(function() return G.Svc.H:JSONDecode(response) end)
        if not ok2 or not data or not data.data then G.UI.status.Text = "  ❌ Nenhum servidor."; return end
        local servers = {}
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers, s.id) end
        end
        if #servers == 0 then G.UI.status.Text = "  ❌ Nada disponível."; return end
        local newS = servers[math.random(1, #servers)]
        G.UI.status.Text = "  🚀 Entrando..."
        local ok3, err = pcall(function() G.Svc.Tp:TeleportToPlaceInstance(placeId, newS, G.pl) end)
        if not ok3 then G.UI.status.Text = "  ❌ Falha: " .. tostring(err) end
    end)
end

G.F.Rejoin = function()
    G.UI.status.Text = "  🔄 Reconectando..."
    task.spawn(function()
        local ok, err = pcall(function() G.Svc.Tp:TeleportToPlaceInstance(game.PlaceId, game.JobId, G.pl) end)
        if not ok then G.UI.status.Text = "  ❌ Falha: " .. tostring(err) end
    end)
end

G.F.CreateButtonItem(G.UI.p3, "Server Hop (novo servidor)", 962, G.F.ServerHop)
G.F.CreateButtonItem(G.UI.p3, "Rejoin (mesmo servidor)", 1000, G.F.Rejoin)

print("[Guasti] Parte 2b carregada.")
-- =========================================================
-- PÁGINA 4: CONFIG
-- =========================================================
G.UI.menuKeyBtn = G.F.CreateButtonItem(G.UI.p4, "Tecla Menu: " .. G.V.tKey.Name, 0, function()
    G.V.waitingMenuKey = true
    G.UI.menuKeyBtn.Text = "  Pressione uma tecla..."
end)

G.UI.hideKeyBtn = G.F.CreateButtonItem(G.UI.p4, "Tecla Esconder: " .. G.Set.HideMenuKey.Name, 38, function()
    G.V.waitingHideKey = true
    G.UI.hideKeyBtn.Text = "  Pressione uma tecla..."
end)

G.F.UpdateAllThemedColors = function()
    local t = G.TH[G.V.themeIdx]
    -- Se for tema RGB, calcula cor do momento
    if t.rgb then
        local rb = Color3.fromHSV((tick() * 0.05) % 1, 1, 1)
        t.accent = rb
    end
    -- Se for custom, pega do Settings
    if t.custom then
        t.bg = G.Set.CustomBg
        t.top = G.Set.CustomTop
        t.accent = G.Set.CustomAccent
    end

    G.UI.main.BackgroundColor3 = t.bg
    G.UI.topBar.BackgroundColor3 = t.top
    G.UI.topExt.BackgroundColor3 = t.top
    G.UI.mainStroke.Color = t.accent
    G.UI.bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, t.bg),
        ColorSequenceKeypoint.new(1, t.top),
    })
    G.UI.tpPopup.BackgroundColor3 = t.bg
    G.UI.igPopup.BackgroundColor3 = t.bg
    G.UI.wpPopup.BackgroundColor3 = t.bg
    G.UI.plFrame.BackgroundColor3 = t.bg
    G.UI.plHeader.BackgroundColor3 = t.top
    G.UI.console.BackgroundColor3 = t.bg
    G.UI.consoleHeader.BackgroundColor3 = t.top
    G.UI.radar.BackgroundColor3 = t.bg
    G.UI.fps.BackgroundColor3 = t.bg
    G.UI.ping.BackgroundColor3 = t.bg
    -- Atualiza aba ativa
    for _, tab in ipairs(G.UI.tabButtons) do
        if tab.BackgroundTransparency == 0 then
            tab.BackgroundColor3 = t.accent
        end
    end
end

G.UI.themeBtn = G.F.CreateButtonItem(G.UI.p4, "Tema: " .. G.TH[G.V.themeIdx].name, 76, function()
    G.V.themeIdx = G.V.themeIdx + 1
    if G.V.themeIdx > #G.TH then G.V.themeIdx = 1 end
    G.F.UpdateAllThemedColors()
    G.UI.themeBtn.Text = "  🎨 Tema: " .. G.TH[G.V.themeIdx].name
    G.F.Notify("🎨 Tema: " .. G.TH[G.V.themeIdx].name, G.TH[G.V.themeIdx].accent)
end)

G.F.SerializeSettings = function()
    local out = {}
    for k, v in pairs(G.Set) do
        if k ~= "Keybinds" and k ~= "IgnoredPlayers" and k ~= "WaypointsPerGame" then
            if typeof(v) == "EnumItem" then
                local es = tostring(v):match("Enum%.(.+)$")
                out[k] = "ENUM:" .. (es or "KeyCode.Unknown")
            elseif typeof(v) == "Color3" then
                out[k] = "COLOR:" .. tostring(v.R) .. "," .. tostring(v.G) .. "," .. tostring(v.B)
            else out[k] = v end
        end
    end
    local kb = {}
    for k, v in pairs(G.Set.Keybinds) do
        if v and typeof(v) == "EnumItem" then
            local es = tostring(v):match("Enum%.(.+)$")
            kb[k] = es or ""
        end
    end
    out._Keybinds = kb
    local ig = {}
    for uid, val in pairs(G.Set.IgnoredPlayers) do if val then ig[tostring(uid)] = true end end
    out._IgnoredPlayers = ig
    out._WaypointsPerGame = G.Set.WaypointsPerGame
    out._ThemeIndex = G.V.themeIdx
    return out
end

G.F.ApplyLoadedSettings = function(data)
    local wasFPS = G.Set.FPSBoostEnabled
    for k, v in pairs(data) do
        if k == "_Keybinds" then
            for kk, vv in pairs(v) do
                local eT, eN = vv:match("^(%w+)%.(%w+)$")
                if eT and eN then
                    local ok, res = pcall(function() return Enum[eT][eN] end)
                    if ok then G.Set.Keybinds[kk] = res end
                end
            end
        elseif k == "_IgnoredPlayers" then
            G.Set.IgnoredPlayers = {}
            for uid, val in pairs(v) do if val then G.Set.IgnoredPlayers[tonumber(uid)] = true end end
        elseif k == "_WaypointsPerGame" then
            G.Set.WaypointsPerGame = v or {}
        elseif k == "_ThemeIndex" then
            G.V.themeIdx = tonumber(v) or 1
            if G.V.themeIdx < 1 or G.V.themeIdx > #G.TH then G.V.themeIdx = 1 end
            G.F.UpdateAllThemedColors()
            G.UI.themeBtn.Text = "  🎨 Tema: " .. G.TH[G.V.themeIdx].name
        elseif k ~= "Keybinds" then
            if type(v) == "string" and v:sub(1,5) == "ENUM:" then
                local eT, eN = v:sub(6):match("^(%w+)%.(%w+)$")
                if eT and eN then
                    local ok, res = pcall(function() return Enum[eT][eN] end)
                    if ok then G.Set[k] = res end
                end
            elseif type(v) == "string" and v:sub(1,6) == "COLOR:" then
                local r, g, b = v:sub(7):match("^([%d%.]+),([%d%.]+),([%d%.]+)$")
                if r and g and b then G.Set[k] = Color3.new(tonumber(r), tonumber(g), tonumber(b)) end
            else G.Set[k] = v end
        end
    end
    for _, e in ipairs(G.V.tgRefs) do
        local val = G.Set[e.key]
        if type(val) ~= "boolean" then G.Set[e.key] = (val == true) end
        e.setter(G.Set[e.key], true)
    end
    for _, e in ipairs(G.V.sliders) do pcall(function() e.updateFn() end) end
    for _, e in ipairs(G.V.inputs) do e.textBox.Text = tostring(e.getValue()) end
    G.D.FOV.Radius = G.Set.FOV
    G.D.FOV.Color = G.Set.FOVColor
    G.D.FOVInner.Radius = G.Set.FOVInner
    G.D.FOVInner.Color = G.Set.FOVInnerColor
    if G.Set.FullbrightEnabled then
        G.Svc.L.Ambient = Color3.fromRGB(150,150,150)
        G.Svc.L.OutdoorAmbient = Color3.fromRGB(150,150,150)
        G.Svc.L.Brightness = G.Set.FullbrightBrightness
        G.Svc.L.ClockTime = 12
    else
        G.Svc.L.Ambient = G.origL.Ambient
        G.Svc.L.Brightness = G.origL.Brightness
        G.Svc.L.OutdoorAmbient = G.origL.OutdoorAmbient
        G.Svc.L.ClockTime = G.origL.ClockTime
    end
    if wasFPS ~= G.Set.FPSBoostEnabled then G.F.ApplyFPSBoost(G.Set.FPSBoostEnabled) end
    G.UI.plFrame.Visible = G.Set.PlayerListEnabled and not G.V.hidden or false
    G.UI.fps.Visible = G.Set.FpsCounterEnabled and not G.V.hidden or false
    G.UI.ping.Visible = G.Set.PingCounterEnabled and not G.V.hidden or false
    G.UI.radar.Visible = G.Set.RadarEnabled and not G.V.hidden or false
    G.UI.console.Visible = G.Set.ConsoleEnabled and not G.V.hidden or false
end

G.UI.saveBtn = G.F.CreateButtonItem(G.UI.p4, "Salvar Configurações", 114, function()
    if writefile then
        local ok, err = pcall(function() writefile(G.CFG_FILE, G.Svc.H:JSONEncode(G.F.SerializeSettings())) end)
        if ok then G.F.Notify("💾 Config salva!", Color3.fromRGB(60,220,60))
        else G.F.Notify("❌ Erro: " .. tostring(err), Color3.fromRGB(255,60,60)) end
    else G.F.Notify("❌ Sem writefile", Color3.fromRGB(255,60,60)) end
end)
G.UI.saveBtn.BackgroundColor3 = Color3.fromRGB(50,90,50)

G.UI.loadBtn = G.F.CreateButtonItem(G.UI.p4, "Carregar Configurações", 152, function()
    if isfile and readfile then
        if isfile(G.CFG_FILE) then
            local ok, data = pcall(function() return G.Svc.H:JSONDecode(readfile(G.CFG_FILE)) end)
            if ok and data then
                G.F.ApplyLoadedSettings(data)
                G.F.Notify("📂 Config carregada!", Color3.fromRGB(60,220,60))
            else G.F.Notify("❌ Config inválida", Color3.fromRGB(255,60,60)) end
        else G.F.Notify("⚠️ Nenhuma config salva", Color3.fromRGB(255,200,60)) end
    else G.F.Notify("❌ Sem readfile", Color3.fromRGB(255,60,60)) end
end)
G.UI.loadBtn.BackgroundColor3 = Color3.fromRGB(50,50,90)

G.UI.resetBtn = G.F.CreateButtonItem(G.UI.p4, "Resetar Tudo", 190, function()
    for _, e in ipairs(G.V.toggles) do e.setter(e.default, true) end
    G.Set.AimbotKey = Enum.KeyCode.Q
    G.Set.TriggerBotKey = Enum.KeyCode.E
    G.Set.AimPart = "Head"
    G.Set.FOV = 120
    G.Set.FOVInner = 40
    G.Set.MaxDistance = 10000
    G.Set.Smoothness = 0
    G.Set.FOVColor = Color3.fromRGB(255,255,255)
    G.Set.FOVInnerColor = Color3.fromRGB(255,100,100)
    G.Set.Prediction = 20
    G.Set.ESPLineColor = Color3.fromRGB(255,255,255)
    G.Set.ESPNameColor = Color3.fromRGB(255,255,255)
    G.Set.ESPHealthColor = Color3.fromRGB(80,255,80)
    G.Set.ESPSkeletonColor = Color3.fromRGB(255,255,255)
    G.Set.ESPBoxColor = Color3.fromRGB(255,80,80)
    G.Set.ESPMaxDistance = 10000
    G.Set.FlySpeed = 50
    G.Set.WalkspeedValue = 16
    G.Set.FullbrightBrightness = 2
    G.Set.AntiVoidHeight = -50
    G.Set.TPSmoothSpeed = 0.3
    G.Set.TPSmooth = false
    G.Set.CrosshairSize = 10
    G.Set.CrosshairColor = Color3.fromRGB(0,255,0)
    G.Set.RadarRange = 500
    G.Set.RadarSize = 130
    G.Set.ConsoleSize = 200
    G.Set.CustomSoundId = ""
    G.Set.HideMenuKey = Enum.KeyCode.Insert
    G.Set.MenuKey = Enum.KeyCode.P
    G.V.tKey = Enum.KeyCode.P
    G.Set.IgnoredPlayers = {}
    G.Set.WaypointsPerGame = {}
    for k, _ in pairs(G.Set.Keybinds) do G.Set.Keybinds[k] = nil end
    G.Svc.L.Ambient = G.origL.Ambient
    G.Svc.L.Brightness = G.origL.Brightness
    G.Svc.L.OutdoorAmbient = G.origL.OutdoorAmbient
    G.Svc.L.ClockTime = G.origL.ClockTime
    G.F.ApplyFPSBoost(false)
    G.V.themeIdx = 1
    G.F.UpdateAllThemedColors()
    for _, e in ipairs(G.V.sliders) do pcall(function() e.updateFn() end) end
    for _, e in ipairs(G.V.inputs) do e.textBox.Text = tostring(e.getValue()) end
    if G.UI.aimKeyBtn then G.UI.aimKeyBtn.Text = "  🎯 Tecla Aimbot: " .. G.Set.AimbotKey.Name end
    if G.UI.trigKeyBtn then G.UI.trigKeyBtn.Text = "  🔫 Tecla Trigger: " .. G.Set.TriggerBotKey.Name end
    if G.UI.menuKeyBtn then G.UI.menuKeyBtn.Text = "  ⌨️ Tecla Menu: " .. G.Set.MenuKey.Name end
    if G.UI.hideKeyBtn then G.UI.hideKeyBtn.Text = "  ⌨️ Tecla Esconder: " .. G.Set.HideMenuKey.Name end
    G.F.UpdateKeybindButtonsUI()
    G.F.Notify("🔄 Tudo resetado!", Color3.fromRGB(60,220,60))
end)
G.UI.resetBtn.BackgroundColor3 = Color3.fromRGB(90,40,40)

-- =========================================================
-- PÁGINA 4: RGB PICKER (Tema Customizado)
-- =========================================================
local sec4 = Instance.new("TextLabel")
sec4.Size = UDim2.new(1,-10,0,22)
sec4.Position = UDim2.new(0,4,0,234)
sec4.BackgroundTransparency = 1
sec4.Text = "  🎨 TEMA CUSTOMIZADO (RGB)"
sec4.TextColor3 = G.TH[G.V.themeIdx].accent
sec4.Font = Enum.Font.GothamBold
sec4.TextSize = 12
sec4.TextXAlignment = Enum.TextXAlignment.Left
sec4.Parent = G.UI.p4

-- Botão para ativar o tema custom
G.UI.customThemeBtn = G.F.CreateButtonItem(G.UI.p4, "Ativar Tema Customizado", 262, function()
    for i, t in ipairs(G.TH) do
        if t.custom then
            G.V.themeIdx = i
            G.F.UpdateAllThemedColors()
            G.UI.themeBtn.Text = "  🎨 Tema: " .. t.name
            G.F.Notify("🎨 Tema Customizado ativado", G.TH[i].accent)
            break
        end
    end
end)

G.F.CreateRGBPicker(G.UI.p4, 300, 
    function() return G.Set.CustomBg end,
    function(c) G.Set.CustomBg = c; G.F.UpdateAllThemedColors() end,
    "Cor de Fundo")

G.F.CreateRGBPicker(G.UI.p4, 438,
    function() return G.Set.CustomTop end,
    function(c) G.Set.CustomTop = c; G.F.UpdateAllThemedColors() end,
    "Cor da TopBar")

G.F.CreateRGBPicker(G.UI.p4, 576,
    function() return G.Set.CustomAccent end,
    function(c) G.Set.CustomAccent = c; G.F.UpdateAllThemedColors() end,
    "Cor de Destaque")

-- =========================================================
-- PÁGINA 4: TECLAS RÁPIDAS (Keybinds)
-- =========================================================
local secKB = Instance.new("TextLabel")
secKB.Size = UDim2.new(1,-10,0,22)
secKB.Position = UDim2.new(0,4,0,714)
secKB.BackgroundTransparency = 1
secKB.Text = "  ⚡ TECLAS RÁPIDAS"
secKB.TextColor3 = G.TH[G.V.themeIdx].accent
secKB.Font = Enum.Font.GothamBold
secKB.TextSize = 12
secKB.TextXAlignment = Enum.TextXAlignment.Left
secKB.Parent = G.UI.p4

G.V.keybindRows = {}

local kbList = {
    {"Fly", "✈️ Tecla Fly"},
    {"Noclip", "👻 Tecla Noclip"},
    {"Walkspeed", "⚡ Tecla Walkspeed"},
    {"ESP", "👁️ Tecla ESP"},
    {"TriggerBot", "🔫 Tecla Trigger Bot"},
}

for i, kb in ipairs(kbList) do
    local name = kb[1]
    local label = kb[2]
    local btn
    btn = G.F.CreateButtonItem(G.UI.p4, label .. ": " .. (G.Set.Keybinds[name] and G.Set.Keybinds[name].Name or "NENHUMA"), 742 + (i-1)*38, function()
        G.V.waitingBind = name
        btn.Text = "  Pressione uma tecla..."
    end)
    G.V.keybindRows[name] = {btn=btn, label=label}
end

G.F.UpdateKeybindButtonsUI = function()
    if G.UI.clickTPKeyBtn then G.UI.clickTPKeyBtn.Text = "  📍 Tecla Click TP: " .. (G.Set.Keybinds.ClickTP and G.Set.Keybinds.ClickTP.Name or "NENHUMA") end
    if G.UI.tpPlayerKeyBtn then G.UI.tpPlayerKeyBtn.Text = "  👤 Tecla TP Player: " .. (G.Set.Keybinds.TPPlayer and G.Set.Keybinds.TPPlayer.Name or "NENHUMA") end
    for k, e in pairs(G.V.keybindRows) do
        e.btn.Text = "  " .. e.label .. ": " .. (G.Set.Keybinds[k] and G.Set.Keybinds[k].Name or "NENHUMA")
    end
end

-- =========================================================
-- PÁGINA 4: HUD / EXTRAS
-- =========================================================
local sec5 = Instance.new("TextLabel")
sec5.Size = UDim2.new(1,-10,0,22)
sec5.Position = UDim2.new(0,4,0,946)
sec5.BackgroundTransparency = 1
sec5.Text = "  🖥️ HUD / EXTRAS"
sec5.TextColor3 = G.TH[G.V.themeIdx].accent
sec5.Font = Enum.Font.GothamBold
sec5.TextSize = 12
sec5.TextXAlignment = Enum.TextXAlignment.Left
sec5.Parent = G.UI.p4

G.F.CreateToggleItem(G.UI.p4, "Anti-AFK", 974, function(s) G.Set.AntiAFKEnabled = s end, false, true, "AntiAFKEnabled")

G.F.CreateToggleItem(G.UI.p4, "Auto-Clicker", 1012, function(state)
    G.Set.AutoClickerEnabled = state
    G.V.autoClickerActive = state
end, false, true, "AutoClickerEnabled")

G.F.CreateSlider(G.UI.p4, "Intervalo Auto-Clicker", 1050, 0.05, 1,
    function() return G.Set.AutoClickerInterval end,
    function(v) G.Set.AutoClickerInterval = v end, "s", "AutoClickerInterval")

G.F.CreateToggleItem(G.UI.p4, "FPS Counter", 1104, function(s)
    G.Set.FpsCounterEnabled = s
    G.UI.fps.Visible = s and not G.V.hidden or false
end, false, true, "FpsCounterEnabled")

G.F.CreateToggleItem(G.UI.p4, "FPS Avançado", 1142, function(s) G.Set.FpsAdvanced = s end, false, true, "FpsAdvanced")

G.F.CreateToggleItem(G.UI.p4, "Ping Counter", 1180, function(s)
    G.Set.PingCounterEnabled = s
    G.UI.ping.Visible = s and not G.V.hidden or false
end, false, true, "PingCounterEnabled")

G.F.CreateToggleItem(G.UI.p4, "Radar 2D", 1218, function(s)
    G.Set.RadarEnabled = s
    G.UI.radar.Visible = s and not G.V.hidden or false
end, false, true, "RadarEnabled")

G.F.CreateSlider(G.UI.p4, "Alcance Radar", 1256, 100, 2000,
    function() return G.Set.RadarRange end,
    function(v) G.Set.RadarRange = v end, " studs", "RadarRange")

G.F.CreateSlider(G.UI.p4, "Tamanho Radar", 1310, 80, 300,
    function() return G.Set.RadarSize end,
    function(v) G.Set.RadarSize = v; G.UI.radar.Size = UDim2.new(0,v,0,v) end, "", "RadarSize")

G.F.CreateToggleItem(G.UI.p4, "Console Log", 1364, function(s)
    G.Set.ConsoleEnabled = s
    G.UI.console.Visible = s and not G.V.hidden or false
end, false, true, "ConsoleEnabled")

G.F.CreateSlider(G.UI.p4, "Altura Console", 1402, 100, 500,
    function() return G.Set.ConsoleSize end,
    function(v) G.Set.ConsoleSize = v; G.UI.console.Size = UDim2.new(0,300,0,v) end, "", "ConsoleSize")

G.F.CreateToggleItem(G.UI.p4, "Custom Crosshair", 1456, function(s) G.Set.CrosshairEnabled = s end, false, true, "CrosshairEnabled")

G.F.CreateSlider(G.UI.p4, "Tamanho Crosshair", 1494, 3, 30,
    function() return G.Set.CrosshairSize end,
    function(v) G.Set.CrosshairSize = v end, "", "CrosshairSize")

G.F.CreateColorPalette(G.UI.p4, 1548, function() return G.Set.CrosshairColor end, function(c)
    G.Set.CrosshairColor = c
    for _, l in ipairs(G.D.Cross) do l.Color = c end
end, "Cor do Crosshair", "CrosshairColor")

-- =========================================================
-- PÁGINA 4: NOTIFICAÇÕES EXTRAS + SOM
-- =========================================================
local sec6 = Instance.new("TextLabel")
sec6.Size = UDim2.new(1,-10,0,22)
sec6.Position = UDim2.new(0,4,0,1616)
sec6.BackgroundTransparency = 1
sec6.Text = "  🔔 NOTIFICAÇÕES + SOM"
sec6.TextColor3 = G.TH[G.V.themeIdx].accent
sec6.Font = Enum.Font.GothamBold
sec6.TextSize = 12
sec6.TextXAlignment = Enum.TextXAlignment.Left
sec6.Parent = G.UI.p4

G.F.CreateToggleItem(G.UI.p4, "Notificações com Som", 1644, function(s) G.Set.SoundNotificationsEnabled = s end, false, true, "SoundNotificationsEnabled")

G.F.CreateInputItem(G.UI.p4, "ID do Som de Notificação", 1682,
    function() return G.Set.CustomSoundId end,
    function(v) G.Set.CustomSoundId = v end, nil, nil, "CustomSoundId", true)

G.F.CreateToggleItem(G.UI.p4, "Kill Notifier", 1720, function(s) G.Set.KillNotifierEnabled = s end, false, true, "KillNotifierEnabled")
G.F.CreateToggleItem(G.UI.p4, "Join/Leave Notifier", 1758, function(s) G.Set.JoinLeaveNotifierEnabled = s end, false, true, "JoinLeaveNotifierEnabled")

-- =========================================================
-- PÁGINA 4: SEGURANÇA
-- =========================================================
local sec7 = Instance.new("TextLabel")
sec7.Size = UDim2.new(1,-10,0,22)
sec7.Position = UDim2.new(0,4,0,1796)
sec7.BackgroundTransparency = 1
sec7.Text = "  🔒 SEGURANÇA"
sec7.TextColor3 = G.TH[G.V.themeIdx].accent
sec7.Font = Enum.Font.GothamBold
sec7.TextSize = 12
sec7.TextXAlignment = Enum.TextXAlignment.Left
sec7.Parent = G.UI.p4

G.F.CreateToggleItem(G.UI.p4, "Anti-Ban", 1824, function(s) G.Set.AntiBanEnabled = s end, false, true, "AntiBanEnabled")
G.F.CreateToggleItem(G.UI.p4, "Anti-Teleport Detect", 1862, function(s) G.Set.AntiTeleportDetectEnabled = s end, false, true, "AntiTeleportDetectEnabled")

G.F.CreateToggleItem(G.UI.p4, "Confirmação ao Fechar", 1900, function(s) G.Set.ConfirmCloseEnabled = s end, true, false, "ConfirmCloseEnabled")
G.F.CreateToggleItem(G.UI.p4, "Animações da GUI", 1938, function(s) G.Set.GuiAnimationsEnabled = s end, true, false, "GuiAnimationsEnabled")

-- Botão fechar total
G.UI.destroyBtn = G.F.CreateButtonItem(G.UI.p4, "❌ Fechar Totalmente o Script", 1976, function()
    G.F.ConfirmClose()
end)
G.UI.destroyBtn.BackgroundTransparency = 1
G.UI.destroyBtn.TextColor3 = Color3.fromRGB(255,60,60)
G.UI.destroyBtn.Font = Enum.Font.GothamBold

G.UI.p4.CanvasSize = UDim2.new(0,0,0,2020)

-- =========================================================
-- PÁGINA 5: PRESETS NOMEADOS
-- =========================================================
local presSec = Instance.new("TextLabel")
presSec.Size = UDim2.new(1,-10,0,22)
presSec.Position = UDim2.new(0,4,0,0)
presSec.BackgroundTransparency = 1
presSec.Text = "  📋 PRESETS (5 slots)"
presSec.TextColor3 = G.TH[G.V.themeIdx].accent
presSec.Font = Enum.Font.GothamBold
presSec.TextSize = 12
presSec.TextXAlignment = Enum.TextXAlignment.Left
presSec.Parent = G.UI.p5

local presInfo = Instance.new("TextLabel")
presInfo.Size = UDim2.new(1,-10,0,40)
presInfo.Position = UDim2.new(0,4,0,26)
presInfo.BackgroundTransparency = 1
presInfo.Text = "  Salva até 5 combos com nomes personalizados.\n  Clica em SALVAR pra guardar, ou no preset pra carregar."
presInfo.TextColor3 = Color3.fromRGB(180,180,180)
presInfo.Font = Enum.Font.Gotham
presInfo.TextSize = 11
presInfo.TextXAlignment = Enum.TextXAlignment.Left
presInfo.TextYAlignment = Enum.TextYAlignment.Top
presInfo.TextWrapped = true
presInfo.Parent = G.UI.p5

G.V.presets = {}

G.F.LoadPresets = function()
    if isfile and readfile then
        if isfile("GuastiPresets.json") then
            local ok, data = pcall(function() return G.Svc.H:JSONDecode(readfile("GuastiPresets.json")) end)
            if ok and data then G.V.presets = data end
        end
    end
    if not G.V.presets or #G.V.presets < 5 then
        for i = 1, 5 do
            if not G.V.presets[i] then
                G.V.presets[i] = {name="", data=nil}
            end
        end
    end
end

G.F.SavePresetsFile = function()
    if writefile then
        pcall(function() writefile("GuastiPresets.json", G.Svc.H:JSONEncode(G.V.presets)) end)
    end
end

G.F.RefreshPresetUI = function()
    for i = 1, 5 do
        local p = G.V.presets[i]
        if p and p.data then
            G.V.presetBtns[i].btn.Text = "  📁 " .. (p.name ~= "" and p.name or ("Preset " .. i))
        else
            G.V.presetBtns[i].btn.Text = "  📁 Slot " .. i .. " — vazio"
        end
    end
end

G.V.presetBtns = {}

for i = 1, 5 do
    local btn = G.F.CreateButtonItem(G.UI.p5, "Slot " .. i .. " — vazio", 76 + (i-1)*38, function()
        local p = G.V.presets[i]
        if p and p.data then
            G.F.ApplyLoadedSettings(p.data)
            G.F.Notify("📂 Preset '" .. (p.name ~= "" and p.name or ("Slot " .. i)) .. "' carregado!", Color3.fromRGB(60,220,60))
        else
            G.F.Notify("⚠️ Preset vazio", Color3.fromRGB(255,200,60))
        end
    end)
    G.V.presetBtns[i] = {btn=btn}
end

-- Input de nome + botão salvar
local nameCont = Instance.new("Frame")
nameCont.Size = UDim2.new(1,-10,0,34)
nameCont.Position = UDim2.new(0,0,0,270)
nameCont.BackgroundColor3 = Color3.fromRGB(35,35,40)
nameCont.BorderSizePixel = 0
nameCont.Parent = G.UI.p5
local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0,6); nc.Parent = nameCont

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(0,80,1,0)
nameLbl.Position = UDim2.new(0,10,0,0)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "Nome do slot:"
nameLbl.TextColor3 = Color3.fromRGB(220,220,220)
nameLbl.Font = Enum.Font.GothamMedium
nameLbl.TextSize = 11
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.Parent = nameCont

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1,-100,0,24)
nameBox.Position = UDim2.new(0,90,0.5,-12)
nameBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
nameBox.Text = "Meu Preset"
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.Font = Enum.Font.GothamMedium
nameBox.TextSize = 12
nameBox.ClearTextOnFocus = false
nameBox.Parent = nameCont
local nbc = Instance.new("UICorner"); nbc.CornerRadius = UDim.new(0,4); nbc.Parent = nameBox

G.UI.presetSlotPicker = 1
local slotPicker = G.F.CreateButtonItem(G.UI.p5, "Slot: 1", 312, function()
    G.UI.presetSlotPicker = G.UI.presetSlotPicker + 1
    if G.UI.presetSlotPicker > 5 then G.UI.presetSlotPicker = 1 end
    slotPicker.Text = "  Slot: " .. G.UI.presetSlotPicker
end)

local savePresBtn = G.F.CreateButtonItem(G.UI.p5, "💾 Salvar Config Atual no Slot", 350, function()
    local data = G.F.SerializeSettings()
    local name = nameBox.Text
    if name == "" then name = "Preset " .. G.UI.presetSlotPicker end
    G.V.presets[G.UI.presetSlotPicker] = {name=name, data=data}
    G.F.SavePresetsFile()
    G.F.RefreshPresetUI()
    G.F.Notify("💾 Salvo: " .. name, Color3.fromRGB(60,220,60))
end)
savePresBtn.BackgroundColor3 = Color3.fromRGB(50,90,50)

local clearPresBtn = G.F.CreateButtonItem(G.UI.p5, "🗑️ Limpar Slot Atual", 388, function()
    G.V.presets[G.UI.presetSlotPicker] = {name="", data=nil}
    G.F.SavePresetsFile()
    G.F.RefreshPresetUI()
    G.F.Notify("🗑️ Slot " .. G.UI.presetSlotPicker .. " limpo", Color3.fromRGB(255,200,60))
end)
clearPresBtn.BackgroundColor3 = Color3.fromRGB(90,40,40)

local clearAllBtn = G.F.CreateButtonItem(G.UI.p5, "🗑️ Limpar Todos os Slots", 426, function()
    for i = 1, 5 do
        G.V.presets[i] = {name="", data=nil}
    end
    G.F.SavePresetsFile()
    G.F.RefreshPresetUI()
    G.F.Notify("🗑️ Todos os presets limpos", Color3.fromRGB(255,200,60))
end)
clearAllBtn.BackgroundColor3 = Color3.fromRGB(90,40,40)

G.F.LoadPresets()
G.F.RefreshPresetUI()

-- =========================================================
-- PÁGINA 5: INFO
-- =========================================================
local infoSec = Instance.new("TextLabel")
infoSec.Size = UDim2.new(1,-10,0,22)
infoSec.Position = UDim2.new(0,4,0,480)
infoSec.BackgroundTransparency = 1
infoSec.Text = "  ℹ️ INFO"
infoSec.TextColor3 = G.TH[G.V.themeIdx].accent
infoSec.Font = Enum.Font.GothamBold
infoSec.TextSize = 12
infoSec.TextXAlignment = Enum.TextXAlignment.Left
infoSec.Parent = G.UI.p5

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1,-10,0,80)
infoLbl.Position = UDim2.new(0,4,0,506)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "  Guasti Scripts v31\n  Feito por indexcreator\n  Conversão G. — sem necessidade de patcher\n  Total de features: 42"
infoLbl.TextColor3 = Color3.fromRGB(180,180,180)
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 11
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.Parent = G.UI.p5

print("[Guasti] Parte 2c carregada.")
-- =========================================================
-- UTILITÁRIOS DE ESTADO
-- =========================================================
G.F.GetDistColor = function(dist)
    if dist < 100 then return Color3.fromRGB(255,50,50)
    elseif dist < 300 then return Color3.fromRGB(255,220,50)
    else return Color3.fromRGB(50,255,50) end
end

G.F.IsPlayerBlocked = function(p)
    return G.Set.IgnoredPlayers[p.UserId] == true
end

G.F.IsTeammate = function(p)
    if not G.Set.TeamCheck then return false end
    if G.pl.Team and p.Team then return G.pl.Team == p.Team end
    return false
end

G.F.IsESPTeammate = function(p)
    if G.Set.IgnoredPlayers[p.UserId] then return true end
    if not G.Set.ESPTeamCheck then return false end
    if G.pl.Team and p.Team then return G.pl.Team == p.Team end
    return false
end

G.F.CanSeePart = function(tp, part)
    if not G.Set.WallCheck then return true end
    local origin = G.cam.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {G.pl.Character}
    local r = G.Svc.WS:Raycast(origin, dir, params)
    if not r then return false end
    return r.Instance:IsDescendantOf(tp.Character)
end

G.F.GetAimPart = function(ch)
    if G.Set.AimPart == "Head" then return ch:FindFirstChild("Head")
    elseif G.Set.AimPart == "Torso" then
        return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart")
    end
    return ch:FindFirstChild("Head")
end

G.F.GetClosestTarget = function()
    local mp = G.Svc.UIS:GetMouseLocation()
    local innerBest, innerBD = nil, math.huge
    local outerBest, outerBD = nil, math.huge
    local useInner = G.Set.FOVDoubleEnabled
    for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
        if p ~= G.pl and p.Character then
            if not G.F.IsPlayerBlocked(p) and not G.F.IsTeammate(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local part = G.F.GetAimPart(p.Character)
                if hum and part and hum.Health > 0 then
                    local d = (G.cam.CFrame.Position - part.Position).Magnitude
                    if d <= G.Set.MaxDistance then
                        local sp, on = G.cam:WorldToViewportPoint(part.Position)
                        if on then
                            local sd = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                            if G.F.CanSeePart(p, part) then
                                if useInner and sd <= G.Set.FOVInner and sd < innerBD then
                                    innerBD = sd
                                    innerBest = part
                                end
                                if sd <= G.Set.FOV and sd < outerBD then
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

G.F.CreateESPObj = function(p)
    if p == G.pl or G.V.espObjects[p] then return end
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
    chams.Parent = G.espFolder
    d.Chams = chams
    G.V.espObjects[p] = d
end

G.F.RemoveESPObj = function(p)
    local d = G.V.espObjects[p]
    if not d then return end
    pcall(function()
        for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight"}) do
            if d[key] then d[key]:Remove() end
        end
        for _, i in ipairs(d.R15Lines) do i.Line:Remove() end
        for _, i in ipairs(d.R6Lines) do i.Line:Remove() end
        d.Chams:Destroy()
    end)
    G.V.espObjects[p] = nil
end

for _, p in ipairs(G.Svc.Pl:GetPlayers()) do G.F.CreateESPObj(p) end
G.Tr(G.Svc.Pl.PlayerAdded:Connect(function(p)
    G.F.CreateESPObj(p)
    if G.Set.JoinLeaveNotifierEnabled then
        G.F.Notify("🚪 + " .. p.Name .. " entrou", Color3.fromRGB(80,220,80))
    end
end))
G.Tr(G.Svc.Pl.PlayerRemoving:Connect(function(p)
    G.F.RemoveESPObj(p)
    if G.Set.JoinLeaveNotifierEnabled then
        G.F.Notify("🚪 - " .. p.Name .. " saiu", Color3.fromRGB(220,80,80))
    end
end))

G.F.HideESP = function(d)
    for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight"}) do
        if d[key] then d[key].Visible = false end
    end
    for _, i in ipairs(d.R15Lines) do i.Line.Visible = false end
    for _, i in ipairs(d.R6Lines) do i.Line.Visible = false end
    if d.Chams then d.Chams.Enabled = false end
end

-- =========================================================
-- RENDER STEPS
-- =========================================================
G.Svc.RS:BindToRenderStep("Guasti_FOV", Enum.RenderPriority.Camera.Value + 1, function()
    if G.V.cleaned then return end
    local mp = G.Svc.UIS:GetMouseLocation()
    local hasTarget = false
    if G.Set.AimbotEnabled then
        local t = G.F.GetClosestTarget()
        hasTarget = t ~= nil
    end

    local outerC = G.Set.FOVColor
    local innerC = G.Set.FOVInnerColor
    if G.Set.FOVStateColor and G.Set.AimbotEnabled then
        if hasTarget then
            outerC = Color3.fromRGB(60,220,60)
            innerC = Color3.fromRGB(60,220,60)
        else
            outerC = Color3.fromRGB(220,60,60)
            innerC = Color3.fromRGB(220,60,60)
        end
    end

    G.D.FOV.Position = mp
    G.D.FOV.Radius = G.Set.FOV
    G.D.FOV.Color = outerC
    G.D.FOV.Transparency = G.Set.FOVTransparency
    G.D.FOV.Visible = G.Set.AimbotEnabled and G.Set.FOVVisible

    G.D.FOVInner.Position = mp
    G.D.FOVInner.Radius = G.Set.FOVInner
    G.D.FOVInner.Color = innerC
    G.D.FOVInner.Visible = G.Set.AimbotEnabled and G.Set.FOVVisible and G.Set.FOVDoubleEnabled

    if G.Set.CrosshairEnabled and not G.V.hidden then
        local vp = G.cam.ViewportSize
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz = G.Set.CrosshairSize
        G.D.Cross[1].From = Vector2.new(cx - sz, cy)
        G.D.Cross[1].To = Vector2.new(cx + sz, cy)
        G.D.Cross[2].From = Vector2.new(cx, cy - sz)
        G.D.Cross[2].To = Vector2.new(cx, cy + sz)
        for _, l in ipairs(G.D.Cross) do
            l.Color = G.Set.CrosshairColor
            l.Visible = true
        end
    else
        for _, l in ipairs(G.D.Cross) do l.Visible = false end
    end
end)

G.Svc.RS:BindToRenderStep("Guasti_Aimbot", Enum.RenderPriority.Camera.Value + 2, function()
    if G.V.cleaned then return end
    if not G.Set.AimbotEnabled then
        G.D.PredDot.Visible = false
        G.D.TargetLine.Visible = false
        return
    end
    local tp = G.F.GetClosestTarget()
    if not tp then
        G.D.PredDot.Visible = false
        G.D.TargetLine.Visible = false
        return
    end
    local tPos = tp.Position
    if G.Set.PredictionEnabled then
        local v = tp.AssemblyLinearVelocity
        if v and v.Magnitude > 0.1 then
            tPos = tPos + v * (G.Set.Prediction / 100)
        end
    end
    if G.Set.PredictVisual then
        local sp, on = G.cam:WorldToViewportPoint(tPos)
        if on then
            G.D.PredDot.Position = Vector2.new(sp.X, sp.Y)
            G.D.PredDot.Visible = true
        else G.D.PredDot.Visible = false end
    else G.D.PredDot.Visible = false end

    if G.Set.AimbotTargetLine then
        local sp, on = G.cam:WorldToViewportPoint(tPos)
        if on then
            G.D.TargetLine.From = G.Svc.UIS:GetMouseLocation()
            G.D.TargetLine.To = Vector2.new(sp.X, sp.Y)
            G.D.TargetLine.Visible = true
        else G.D.TargetLine.Visible = false end
    else G.D.TargetLine.Visible = false end

    if G.Set.SilentAimEnabled then return end

    local tc = CFrame.new(G.cam.CFrame.Position, tPos)
    if G.Set.Smoothness <= 0 then
        G.cam.CFrame = tc
    else
        local a = math.clamp(1 - (G.Set.Smoothness / 100), 0.001, 1)
        G.cam.CFrame = G.cam.CFrame:Lerp(tc, a)
    end
end)

G.Svc.RS:BindToRenderStep("Guasti_ESP", Enum.RenderPriority.Camera.Value + 3, function()
    if G.V.cleaned then return end
    local vp = G.cam.ViewportSize
    G.V.animPhase = (G.V.animPhase + 0.03) % 1

    for tp, d in pairs(G.V.espObjects) do
        local ch = tp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not G.Set.ESPEnabled or not ch or not hum or hum.Health <= 0 or G.F.IsESPTeammate(tp) then
            G.F.HideESP(d)
        else
            local root = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
            if not root then G.F.HideESP(d)
            else
                local head = ch:FindFirstChild("Head")
                local sp, on = G.cam:WorldToViewportPoint(root.Position)
                if not on then G.F.HideESP(d)
                else
                    local dist = (G.cam.CFrame.Position - root.Position).Magnitude
                    if dist > G.Set.ESPMaxDistance then G.F.HideESP(d)
                    else
                        local lineC = G.Set.ESPLineColor
                        local nameC = G.Set.ESPNameColor
                        local hpC = G.Set.ESPHealthColor
                        local skC = G.Set.ESPSkeletonColor
                        local bxC = G.Set.ESPBoxColor
                        if G.Set.ESPRainbow then
                            local rb = G.F.Rainbow()
                            lineC = rb; nameC = rb; hpC = rb; skC = rb; bxC = rb
                        end
                        if G.Set.ESPDistanceColor then lineC = G.F.GetDistColor(dist) end

                        if G.Set.ESPLine then
                            d.Line.From = Vector2.new(vp.X/2, 0)
                            d.Line.To = Vector2.new(sp.X, sp.Y)
                            d.Line.Color = lineC
                            d.Line.Visible = true
                        else d.Line.Visible = false end

                        if G.Set.ESPHealth then
                            d.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                            d.Health.Position = Vector2.new(sp.X, sp.Y - 32)
                            d.Health.Color = hpC
                            d.Health.Visible = true
                        else d.Health.Visible = false end

                        if G.Set.ESPDistance and not G.Set.ESPDistanceInName then
                            d.Distance.Text = math.floor(dist) .. "m"
                            d.Distance.Position = Vector2.new(sp.X, sp.Y + 24)
                            d.Distance.Color = lineC
                            d.Distance.Visible = true
                        else d.Distance.Visible = false end

                        if G.Set.ESPName and head then
                            local hp, ho = G.cam:WorldToViewportPoint(head.Position + Vector3.new(0,1.8,0))
                            if ho then
                                local txt = tp.Name
                                if G.Set.ESPDistanceInName then
                                    txt = txt .. " [" .. math.floor(dist) .. "m]"
                                end
                                d.NameTag.Text = txt
                                d.NameTag.Position = Vector2.new(hp.X, hp.Y)
                                d.NameTag.Color = nameC
                                d.NameTag.Visible = true
                            else d.NameTag.Visible = false end
                        else d.NameTag.Visible = false end

                        if G.Set.ESPWeapon and head then
                            local tool = ch:FindFirstChildOfClass("Tool")
                            if tool then
                                local hp, ho = G.cam:WorldToViewportPoint(head.Position + Vector3.new(0,2.6,0))
                                if ho then
                                    d.Weapon.Text = tool.Name
                                    d.Weapon.Position = Vector2.new(hp.X, hp.Y)
                                    d.Weapon.Color = Color3.fromRGB(255,255,100)
                                    d.Weapon.Visible = true
                                else d.Weapon.Visible = false end
                            else d.Weapon.Visible = false end
                        else d.Weapon.Visible = false end

                        if G.Set.ESPBox and head then
                            local hpos, hon = G.cam:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
                            local fpos, fon = G.cam:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
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

                        if G.Set.ESPChams then
                            d.Chams.Adornee = ch
                            d.Chams.Enabled = true
                            d.Chams.FillColor = lineC
                            d.Chams.OutlineColor = lineC
                        else d.Chams.Enabled = false end

                        local isR15 = ch:FindFirstChild("UpperTorso") ~= nil
                        local active = isR15 and d.R15Lines or d.R6Lines
                        local inactive = isR15 and d.R6Lines or d.R15Lines
                        if G.Set.ESPSkeleton then
                            for _, i in ipairs(inactive) do i.Line.Visible = false end
                            for _, i in ipairs(active) do
                                local pa = ch:FindFirstChild(i.A)
                                local pb = ch:FindFirstChild(i.B)
                                if pa and pb then
                                    local posA, vA = G.cam:WorldToViewportPoint(pa.Position)
                                    local posB, vB = G.cam:WorldToViewportPoint(pb.Position)
                                    if vA and vB then
                                        i.Line.From = Vector2.new(posA.X, posA.Y)
                                        i.Line.To = Vector2.new(posB.X, posB.Y)
                                        i.Line.Color = skC
                                        i.Line.Thickness = G.Set.ESPSkeleton3D and 2 or 1
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
G.Svc.RS:BindToRenderStep("Guasti_Fly", Enum.RenderPriority.Camera.Value + 4, function(dt)
    if G.V.cleaned then return end
    if not G.Set.FlyEnabled then return end
    local ch = G.pl.Character
    if not ch then return end
    local rt = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not rt or not hum then return end
    hum.PlatformStand = true
    hum.AutoRotate = false
    local cam = G.cam.CFrame
    rt.CFrame = CFrame.new(rt.Position, rt.Position + cam.LookVector)
    rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
    rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
    local move = Vector3.new(0,0,0)
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if G.Svc.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
    if move.Magnitude > 0 then
        move = move.Unit
        rt.CFrame = rt.CFrame + move * G.Set.FlySpeed * dt
    end
    rt.AssemblyAngularVelocity = Vector3.new(0,0,0)
    rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
end)

-- =========================================================
-- HEARTBEAT PRINCIPAL
-- =========================================================
local fpsAcc = 0
local fpsFrames = 0
G.Tr(G.Svc.RS.Heartbeat:Connect(function(dt)
    if G.V.cleaned then return end

    -- Fullbright loop
    if G.Set.FullbrightEnabled then
        G.Svc.L.Ambient = Color3.fromRGB(150,150,150)
        G.Svc.L.OutdoorAmbient = Color3.fromRGB(150,150,150)
        G.Svc.L.Brightness = G.Set.FullbrightBrightness
        G.Svc.L.ClockTime = 12
    end

    -- FPS / Ping
    fpsAcc = fpsAcc + dt
    fpsFrames = fpsFrames + 1
    if fpsAcc >= 0.5 then
        local fps = math.floor(fpsFrames / fpsAcc)
        fpsAcc = 0; fpsFrames = 0
        if G.Set.FpsCounterEnabled then
            if G.Set.FpsAdvanced then
                if fps < G.V.sessionFpsMin then G.V.sessionFpsMin = fps end
                if fps > G.V.sessionFpsMax then G.V.sessionFpsMax = fps end
                G.V.sessionFpsSum = G.V.sessionFpsSum + fps
                G.V.sessionFpsCount = G.V.sessionFpsCount + 1
                local avg = math.floor(G.V.sessionFpsSum / math.max(1, G.V.sessionFpsCount))
                G.UI.fps.Size = UDim2.new(0, 210, 0, 24)
                G.UI.fps.Text = "FPS: " .. fps .. " | min " .. G.V.sessionFpsMin .. " | max " .. G.V.sessionFpsMax .. " | avg " .. avg
            else
                G.UI.fps.Text = "FPS: " .. fps
            end
            if fps >= 50 then G.UI.fps.TextColor3 = Color3.fromRGB(60,220,60)
            elseif fps >= 30 then G.UI.fps.TextColor3 = Color3.fromRGB(255,200,60)
            else G.UI.fps.TextColor3 = Color3.fromRGB(255,60,60) end
        end
        if G.Set.PingCounterEnabled then
            local ping = 0
            pcall(function()
                local item = G.Svc.Stats.Network.ServerStatsItem["Data Ping"]
                ping = math.floor(item:GetValue())
            end)
            if ping == 0 then
                pcall(function() ping = math.floor(G.Svc.Pl:GetNetworkPing() * 1000) end)
            end
            if ping > 0 then
                G.UI.ping.Text = "Ping: " .. ping .. "ms"
                if ping <= 80 then G.UI.ping.TextColor3 = Color3.fromRGB(60,220,60)
                elseif ping <= 150 then G.UI.ping.TextColor3 = Color3.fromRGB(255,200,60)
                else G.UI.ping.TextColor3 = Color3.fromRGB(255,60,60) end
            end
        end
    end

    -- Walkspeed
    if G.Set.WalkspeedEnabled then
        local ch = G.pl.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= G.Set.WalkspeedValue then
                hum.WalkSpeed = G.Set.WalkspeedValue
            end
        end
    end

    -- Anti-Fling
    if G.Set.AntiFlingEnabled then
        local ch = G.pl.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            if rt then
                local v = rt.AssemblyLinearVelocity
                if v.Magnitude > 150 then rt.AssemblyLinearVelocity = v.Unit * 100 end
            end
        end
    end

    -- Anti-Stun
    if G.Set.AntiStunEnabled then
        local ch = G.pl.Character
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

    -- Infinite Jump
    if G.Set.InfiniteJumpEnabled then
        local ch = G.pl.Character
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and G.Svc.UIS:IsKeyDown(Enum.KeyCode.Space) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    -- Infinite Ammo
    if G.Set.InfiniteAmmoEnabled then
        local ch = G.pl.Character
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
    if G.Set.AntiVoidEnabled then
        local ch = G.pl.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if rt and hum and hum.Health > 0 and rt.Position.Y < G.Set.AntiVoidHeight then
                rt.CFrame = CFrame.new(rt.Position.X, 100, rt.Position.Z)
                rt.AssemblyLinearVelocity = Vector3.new(0,0,0)
                G.F.Notify("🛡️ Anti-Void: resgatado!", Color3.fromRGB(60,220,60))
            end
        end
    end

    -- Anti-Teleport Detect
    if G.Set.AntiTeleportDetectEnabled then
        local ch = G.pl.Character
        if ch then
            local rt = ch:FindFirstChild("HumanoidRootPart")
            if rt then
                local last = G.V.lastPositions[G.pl.UserId]
                if last then
                    local diff = (rt.Position - last).Magnitude
                    if diff > 500 then
                        G.F.Notify("⚠️ Teleporte detectado (" .. math.floor(diff) .. "m)", Color3.fromRGB(255,200,60))
                    end
                end
                G.V.lastPositions[G.pl.UserId] = rt.Position
            end
        end
    end

    -- Trigger Bot (auto-fire quando está com a tecla pressionada)
    if G.Set.TriggerBotEnabled then
        local tgKey = G.Set.TriggerBotKey
        local pressed = false
        if typeof(tgKey) == "EnumItem" and tgKey.EnumType == Enum.KeyCode then
            pressed = G.Svc.UIS:IsKeyDown(tgKey)
        end
        if pressed or G.Set.TriggerBotAutoFire then
            local target = G.F.GetClosestTarget()
            if target then
                pcall(function()
                    if mouse1click then mouse1click()
                    else
                        G.Svc.VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.02)
                        G.Svc.VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end)
            end
        end
    end

    -- Kill Notifier
    if G.Set.KillNotifierEnabled then
        for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
            if p ~= G.pl and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local prev = G.V.lastHealth[p.UserId] or hum.MaxHealth
                    if prev > 0 and hum.Health <= 0 then
                        G.F.Notify("💀 " .. p.Name .. " morreu", Color3.fromRGB(255,80,80))
                    end
                    G.V.lastHealth[p.UserId] = hum.Health
                end
            end
        end
    end

    -- Anti-Ban
    if G.Set.AntiBanEnabled then
        for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
            if p ~= G.pl then
                local n = p.Name:lower()
                local dn = p.DisplayName:lower()
                if n:find("mod") or n:find("admin") or dn:find("moderador") or dn:find("admin") then
                    if G.Set.AimbotEnabled and G.V.tgRefs.Aimbot then
                        G.V.tgRefs.Aimbot(false, true)
                    end
                    if G.Set.ESPEnabled and G.V.tgRefs.ESP then
                        G.V.tgRefs.ESP(false, true)
                    end
                end
            end
        end
    end
end))

-- Noclip
G.Tr(G.Svc.RS.Stepped:Connect(function()
    if G.V.cleaned or not G.Set.NoclipEnabled then return end
    local ch = G.pl.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

-- Anti-AFK
G.Tr(G.pl.Idled:Connect(function()
    if G.Set.AntiAFKEnabled then
        pcall(function()
            G.Svc.VU:CaptureController()
            G.Svc.VU:ClickButton2(Vector2.new())
        end)
    end
end))

-- Auto-Clicker
G.Tr(task.spawn(function()
    while not G.V.cleaned do
        if G.Set.AutoClickerEnabled then
            pcall(function()
                if mouse1click then mouse1click()
                else
                    G.Svc.VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    G.Svc.VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
            task.wait(G.Set.AutoClickerInterval)
        else
            task.wait(0.3)
        end
    end
end))

-- =========================================================
-- RADAR LOOP
-- =========================================================
G.Tr(task.spawn(function()
    while not G.V.cleaned do
        task.wait(0.12)
        if G.Set.RadarEnabled and G.UI.radar.Visible then
            G.UI.radar.Size = UDim2.new(0, G.Set.RadarSize, 0, G.Set.RadarSize)
            for _, d in pairs(G.V.radarDots) do
                if d and d.Parent then d:Destroy() end
            end
            G.V.radarDots = {}
            local myRt = G.pl.Character and G.pl.Character:FindFirstChild("HumanoidRootPart")
            if myRt then
                local myPos = myRt.Position
                local camDir = G.cam.CFrame.LookVector
                local camRight = G.cam.CFrame.RightVector
                local range = G.Set.RadarRange
                local r = G.Set.RadarSize / 2 - 6
                for _, p in ipairs(G.Svc.Pl:GetPlayers()) do
                    if p ~= G.pl and p.Character then
                        local pr = p.Character:FindFirstChild("HumanoidRootPart")
                        local ph = p.Character:FindFirstChildOfClass("Humanoid")
                        if pr and ph and ph.Health > 0 then
                            local rel = pr.Position - myPos
                            local dist = rel.Magnitude
                            if dist <= range then
                                local dot = Instance.new("Frame")
                                dot.Size = UDim2.new(0,8,0,8)
                                dot.BackgroundColor3 = G.Set.IgnoredPlayers[p.UserId] and Color3.fromRGB(100,100,100) or Color3.fromRGB(255,80,80)
                                dot.BorderSizePixel = 0
                                dot.ZIndex = 102
                                dot.Parent = G.UI.radar
                                local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
                                local relX = rel:Dot(camRight)
                                local relZ = rel:Dot(camDir)
                                local angle = math.atan2(relX, relZ)
                                local px = math.sin(angle) * (dist / range) * r
                                local py = -math.cos(angle) * (dist / range) * r
                                dot.Position = UDim2.new(0.5, px - 4, 0.5, py - 4)
                                table.insert(G.V.radarDots, dot)
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

-- =========================================================
-- PLAYER LIST LOOP
-- =========================================================
G.Tr(task.spawn(function()
    while not G.V.cleaned do
        task.wait(0.4)
        if G.Set.PlayerListEnabled and G.UI.plFrame.Visible and not G.V.hidden then
            for _, c in ipairs(G.UI.plList:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            local sorted = {}
            for _, p in ipairs(G.Svc.Pl:GetPlayers()) do table.insert(sorted, p) end
            table.sort(sorted, function(a,b) return a.Name:lower() < b.Name:lower() end)
            local y = 0
            for _, p in ipairs(sorted) do
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local rt = ch and ch:FindFirstChild("HumanoidRootPart")
                local mrt = G.pl.Character and G.pl.Character:FindFirstChild("HumanoidRootPart")
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.floor(hum.MaxHealth) or 100
                local dist = 0
                if rt and mrt then dist = math.floor((mrt.Position - rt.Position).Magnitude) end
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1,-3,0,20)
                row.Position = UDim2.new(0,0,0,y)
                row.BackgroundTransparency = 1
                row.ZIndex = 302
                row.Parent = G.UI.plList

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.55,0,1,0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = (p == G.pl and "★ " or "  ") .. p.Name
                nameLbl.TextColor3 = (p == G.pl) and Color3.fromRGB(255,220,60) or Color3.fromRGB(255,255,255)
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
            G.UI.plList.CanvasSize = UDim2.new(0,0,0,y+3)
        end
    end
end))

-- Theme RGB loop
G.Tr(task.spawn(function()
    while not G.V.cleaned do
        task.wait(0.1)
        local t = G.TH[G.V.themeIdx]
        if t and t.rgb then
            local rb = Color3.fromHSV((tick() * 0.05) % 1, 1, 1)
            G.UI.mainStroke.Color = rb
            G.UI.tab1.BackgroundColor3 = rb
        end
    end
end))

-- =========================================================
-- CLEANUP
-- =========================================================
G.F.ConfirmClose = function()
    if not G.Set.ConfirmCloseEnabled then
        if G.Cleanup then G.Cleanup() end
        return
    end
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0,300,0,140)
    confirmFrame.Position = UDim2.new(0.5,-150,0.5,-70)
    confirmFrame.BackgroundColor3 = G.TH[G.V.themeIdx].bg
    confirmFrame.ZIndex = 600
    confirmFrame.Parent = G.UI.gui
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
        if G.Cleanup then G.Cleanup() end
    end)
end

G.Cleanup = function()
    if G.V.cleaned then return end
    G.V.cleaned = true
    for _, c in ipairs(G.Conns) do
        pcall(function() c:Disconnect() end)
    end
    G.Conns = {}
    pcall(function() G.Svc.RS:UnbindFromRenderStep("Guasti_FOV") end)
    pcall(function() G.Svc.RS:UnbindFromRenderStep("Guasti_Aimbot") end)
    pcall(function() G.Svc.RS:UnbindFromRenderStep("Guasti_ESP") end)
    pcall(function() G.Svc.RS:UnbindFromRenderStep("Guasti_Fly") end)
    pcall(function() G.D.FOV:Remove() end)
    pcall(function() G.D.FOVInner:Remove() end)
    pcall(function() G.D.PredDot:Remove() end)
    pcall(function() G.D.TargetLine:Remove() end)
    for _, l in ipairs(G.D.Cross) do
        pcall(function() l:Remove() end)
    end
    for p, d in pairs(G.V.espObjects) do
        pcall(function()
            for _, key in ipairs({"Line","Health","Distance","NameTag","Weapon","BoxTop","BoxBottom","BoxLeft","BoxRight"}) do
                if d[key] then d[key]:Remove() end
            end
            for _, i in ipairs(d.R15Lines) do i.Line:Remove() end
            for _, i in ipairs(d.R6Lines) do i.Line:Remove() end
            if d.Chams then d.Chams:Destroy() end
        end)
    end
    G.V.espObjects = {}
    pcall(function()
        G.Svc.L.Ambient = G.origL.Ambient
        G.Svc.L.Brightness = G.origL.Brightness
        G.Svc.L.OutdoorAmbient = G.origL.OutdoorAmbient
        G.Svc.L.ClockTime = G.origL.ClockTime
        G.Svc.L.GlobalShadows = G.origL.GlobalShadows
        G.Svc.L.FogEnd = G.origL.FogEnd
    end)
    pcall(function()
        for _, e in ipairs(G.Svc.L:GetChildren()) do
            if e:IsA("PostEffect") then
                for _, o in ipairs(G.origEff) do
                    if o.effect == e then e.Enabled = o.enabled; break end
                end
            end
        end
    end)
    for _, icon in ipairs(G.wpIcons) do
        pcall(function() icon.attach:Destroy() end)
    end
    pcall(function() G.espFolder:Destroy() end)
    pcall(function() G.UI.gui:Destroy() end)
    pcall(function()
        G.Svc.UIS.MouseBehavior = Enum.MouseBehavior.Default
        G.Svc.UIS.MouseIconEnabled = true
    end)
    pcall(function()
        local ch = G.pl.Character
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
    end)
    _G.GuastiCleanup = nil
end

_G.GuastiCleanup = G.Cleanup

-- =========================================================
-- INPUT HANDLERS
-- =========================================================
local function IsAimbotKeyInput(input)
    local k = G.Set.AimbotKey
    if typeof(k) == "EnumItem" then
        if k.EnumType == Enum.KeyCode then
            return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == k
        elseif k.EnumType == Enum.UserInputType then
            return input.UserInputType == k
        end
    end
    return false
end

G.Tr(G.Svc.UIS.InputBegan:Connect(function(input, gp)
    if G.V.cleaned then return end

    -- Esperando tecla Menu
    if G.V.waitingMenuKey and input.UserInputType == Enum.UserInputType.Keyboard then
        G.Set.MenuKey = input.KeyCode
        G.V.tKey = input.KeyCode
        G.V.waitingMenuKey = false
        G.UI.menuKeyBtn.Text = "  ⌨️ Tecla Menu: " .. input.KeyCode.Name
        return
    end
    -- Esperando tecla Esconder
    if G.V.waitingHideKey and input.UserInputType == Enum.UserInputType.Keyboard then
        G.Set.HideMenuKey = input.KeyCode
        G.V.waitingHideKey = false
        G.UI.hideKeyBtn.Text = "  ⌨️ Tecla Esconder: " .. input.KeyCode.Name
        return
    end
    -- Esperando tecla Aimbot
    if G.V.waitingAimbotKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            G.Set.AimbotKey = input.KeyCode
            G.V.waitingAimbotKey = false
            G.UI.aimKeyBtn.Text = "  🎯 Tecla Aimbot: " .. input.KeyCode.Name
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            G.Set.AimbotKey = Enum.UserInputType.MouseButton1
            G.V.waitingAimbotKey = false
            G.UI.aimKeyBtn.Text = "  🎯 Tecla Aimbot: Mouse1"
            return
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            G.Set.AimbotKey = Enum.UserInputType.MouseButton2
            G.V.waitingAimbotKey = false
            G.UI.aimKeyBtn.Text = "  🎯 Tecla Aimbot: Mouse2"
            return
        end
    end
    -- Esperando tecla Trigger
    if G.V.waitingTriggerKey and input.UserInputType == Enum.UserInputType.Keyboard then
        G.Set.TriggerBotKey = input.KeyCode
        G.V.waitingTriggerKey = false
        G.UI.trigKeyBtn.Text = "  🔫 Tecla Trigger: " .. input.KeyCode.Name
        return
    end
    -- Esperando keybind genérica
    if G.V.waitingBind and input.UserInputType == Enum.UserInputType.Keyboard then
        G.Set.Keybinds[G.V.waitingBind] = input.KeyCode
        G.F.UpdateKeybindButtonsUI()
        G.V.waitingBind = nil
        return
    end

    local fb = G.Svc.UIS:GetFocusedTextBox()
    if fb then return end

    -- Aimbot toggle
    if IsAimbotKeyInput(input) and G.V.tgRefs.Aimbot then
        G.V.tgRefs.Aimbot()
    end

    if not gp then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == G.Set.MenuKey then
                G.F.ToggleMenu()
                return
            end
            if input.KeyCode == G.Set.HideMenuKey then
                G.F.ToggleHiddenMode()
                return
            end
            for name, key in pairs(G.Set.Keybinds) do
                if key and input.KeyCode == key then
                    if name == "Fly" and G.V.tgRefs.Fly then G.V.tgRefs.Fly()
                    elseif name == "Noclip" and G.V.tgRefs.Noclip then G.V.tgRefs.Noclip()
                    elseif name == "Walkspeed" and G.V.tgRefs.Walkspeed then G.V.tgRefs.Walkspeed()
                    elseif name == "ESP" and G.V.tgRefs.ESP then G.V.tgRefs.ESP()
                    elseif name == "TriggerBot" and G.V.tgRefs.TriggerBot then G.V.tgRefs.TriggerBot()
                    elseif name == "TPPlayer" then G.F.OpenTPPopup() end
                    return
                end
            end
        end
    end
end))

-- Click TP
G.Tr(G.Svc.UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if G.Set.ClickTPEnabled and G.Set.Keybinds.ClickTP
        and input.UserInputType == Enum.UserInputType.MouseButton1
        and G.Svc.UIS:IsKeyDown(G.Set.Keybinds.ClickTP) then
        local rt = G.pl.Character and G.pl.Character:FindFirstChild("HumanoidRootPart")
        if rt and G.mouse and G.mouse.Hit then
            G.F.SmoothTP(CFrame.new(G.mouse.Hit.Position + Vector3.new(0,3,0)))
        end
    end
end))

-- Chat commands
G.Tr(G.pl.Chatted:Connect(function(msg)
    local cmd = msg:match("^/(%w+)")
    if not cmd then return end
    cmd = cmd:lower()
    if cmd == "fly" and G.V.tgRefs.Fly then G.V.tgRefs.Fly()
    elseif cmd == "noclip" and G.V.tgRefs.Noclip then G.V.tgRefs.Noclip()
    elseif cmd == "aimbot" and G.V.tgRefs.Aimbot then G.V.tgRefs.Aimbot()
    elseif cmd == "esp" and G.V.tgRefs.ESP then G.V.tgRefs.ESP()
    elseif cmd == "ws" and G.V.tgRefs.Walkspeed then G.V.tgRefs.Walkspeed()
    elseif cmd == "cmds" then
        G.F.Notify("📖 /fly /noclip /aimbot /esp /ws", G.TH[G.V.themeIdx].accent)
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
resizeHandle.Parent = G.UI.main

local dragging, dragStart, startPos
G.UI.topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = G.UI.main.Position
    end
end)
G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        G.UI.main.Position = newPos
        G.UI.shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 4, newPos.Y.Scale, newPos.Y.Offset + 4)
    end
end))
G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

local resizing, rsP, rsS
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not G.V.minimized then
        resizing = true; rsP = input.Position; rsS = G.UI.main.AbsoluteSize
    end
end)
G.Tr(G.Svc.UIS.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - rsP
        local nw = math.clamp(rsS.X + d.X, 400, 900)
        local nh = math.clamp(rsS.Y + d.Y, 300, 700)
        G.UI.main.Size = UDim2.new(0,nw,0,nh)
        G.UI.shadow.Size = UDim2.new(0,nw,0,nh)
        G.V.nSize = G.UI.main.Size
    end
end))
G.Tr(G.Svc.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end))

G.F.UpdateMouseLock = function()
    if G.V.open and not G.V.hidden then
        G.Svc.UIS.MouseBehavior = Enum.MouseBehavior.Default
        G.Svc.UIS.MouseIconEnabled = true
    else
        if G.pl.CameraMode == Enum.CameraMode.LockFirstPerson then
            G.Svc.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            G.Svc.UIS.MouseIconEnabled = false
        else
            G.Svc.UIS.MouseBehavior = Enum.MouseBehavior.Default
            G.Svc.UIS.MouseIconEnabled = true
        end
    end
end

G.F.ToggleMenu = function()
    if G.V.hidden then return end
    G.V.open = not G.V.open
    if G.V.open then
        G.UI.main.Visible = true
        G.UI.shadow.Visible = true
        G.UI.main.Size = UDim2.new(0,0,0,0)
        G.Svc.Tw:Create(G.UI.main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=G.V.nSize}):Play()
        G.Svc.Tw:Create(G.UI.shadow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=G.V.nSize}):Play()
    else
        local t = G.Svc.Tw:Create(G.UI.main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size=UDim2.new(0,0,0,0)})
        G.Svc.Tw:Create(G.UI.shadow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size=UDim2.new(0,0,0,0)}):Play()
        t:Play()
        t.Completed:Connect(function()
            if not G.V.open then
                G.UI.main.Visible = false
                G.UI.shadow.Visible = false
                G.UI.main.Size = G.V.nSize
                G.UI.shadow.Size = G.V.nSize
            end
        end)
        G.UI.tpPopup.Visible = false
        G.UI.igPopup.Visible = false
        G.UI.wpPopup.Visible = false
    end
    G.F.UpdateMouseLock()
end

G.F.ToggleHiddenMode = function()
    G.V.hidden = not G.V.hidden
    if G.V.hidden then
        G.UI.main.Visible = false
        G.UI.shadow.Visible = false
        G.UI.tpPopup.Visible = false
        G.UI.igPopup.Visible = false
        G.UI.wpPopup.Visible = false
        G.UI.plFrame.Visible = false
        G.UI.fps.Visible = false
        G.UI.ping.Visible = false
        G.UI.radar.Visible = false
        G.UI.console.Visible = false
        for _, l in ipairs(G.D.Cross) do l.Visible = false end
        G.F.Notify("📸 Modo screenshot: ON", G.TH[G.V.themeIdx].accent)
    else
        G.UI.main.Visible = G.V.open
        G.UI.shadow.Visible = G.V.open
        if G.Set.PlayerListEnabled then G.UI.plFrame.Visible = true end
        if G.Set.FpsCounterEnabled then G.UI.fps.Visible = true end
        if G.Set.PingCounterEnabled then G.UI.ping.Visible = true end
        if G.Set.RadarEnabled then G.UI.radar.Visible = true end
        if G.Set.ConsoleEnabled then G.UI.console.Visible = true end
        G.F.Notify("📸 Modo screenshot: OFF", G.TH[G.V.themeIdx].accent)
    end
    G.F.UpdateMouseLock()
end

G.UI.closeBtn.MouseButton1Click:Connect(function() if G.V.open then G.F.ToggleMenu() end end)

G.UI.minBtn.MouseButton1Click:Connect(function()
    G.V.minimized = not G.V.minimized
    G.UI.content.Visible = not G.V.minimized
    if G.V.minimized then
        G.UI.main:TweenSize(UDim2.new(0, G.V.nSize.X.Offset, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        G.UI.shadow:TweenSize(UDim2.new(0, G.V.nSize.X.Offset, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = false
    else
        G.UI.main:TweenSize(G.V.nSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        G.UI.shadow:TweenSize(G.V.nSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        resizeHandle.Visible = true
    end
end)

-- =========================================================
-- SPLASH (nome branco, menor, fundo transparente, 1s + 4s + 1s)
-- =========================================================
local splashBg = Instance.new("Frame")
splashBg.Size = UDim2.new(1,0,1,0)
splashBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
splashBg.BackgroundTransparency = 1  -- transparente
splashBg.BorderSizePixel = 0
splashBg.ZIndex = 700
splashBg.Parent = G.UI.gui

local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(1,0,0,50)
splashTitle.Position = UDim2.new(0,0,0.5,-40)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "Guasti Scripts"
splashTitle.TextColor3 = Color3.fromRGB(255,255,255)  -- BRANCO
splashTitle.TextSize = 36  -- MENOR
splashTitle.Font = Enum.Font.GothamBlack
splashTitle.TextTransparency = 1
splashTitle.ZIndex = 701
splashTitle.Parent = splashBg

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(1,0,0,20)
splashSub.Position = UDim2.new(0,0,0.5,10)
splashSub.BackgroundTransparency = 1
splashSub.Text = "Carregando"
splashSub.TextColor3 = Color3.fromRGB(220,220,220)
splashSub.TextSize = 15
splashSub.Font = Enum.Font.GothamMedium
splashSub.TextTransparency = 1
splashSub.ZIndex = 701
splashSub.Parent = splashBg

-- Fase 1: 1s (fade in do título)
G.Svc.Tw:Create(splashTitle, TweenInfo.new(1), {TextTransparency = 0}):Play()
task.wait(1)

-- Fase 2: 4s (mostra com "Carregando..." animando)
G.Svc.Tw:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
local dotsActive = true
task.spawn(function()
    local fr = {".", "..", "..."}
    local i = 1
    while dotsActive do
        splashSub.Text = "Carregando" .. fr[i]
        i = i + 1
        if i > #fr then i = 1 end
        task.wait(0.4)
    end
end)
task.wait(4)
dotsActive = false

-- Fase 3: 1s (fade out)
G.Svc.Tw:Create(splashTitle, TweenInfo.new(1), {TextTransparency = 1}):Play()
G.Svc.Tw:Create(splashSub, TweenInfo.new(1), {TextTransparency = 1}):Play()
task.wait(1)
splashBg:Destroy()

-- Mostra a GUI depois do splash
G.UI.main.Visible = true
G.UI.shadow.Visible = true
G.UI.main.Size = UDim2.new(0,0,0,0)
G.UI.shadow.Size = UDim2.new(0,0,0,0)
G.Svc.Tw:Create(G.UI.main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=G.V.nSize}):Play()
G.Svc.Tw:Create(G.UI.shadow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=G.V.nSize}):Play()
G.V.open = true
G.F.UpdateMouseLock()

-- =========================================================
-- AUTO-UPDATER (opcional)
-- =========================================================
task.spawn(function()
    local ok, version = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/indexcreator/guasti/main/version.txt")
    end)
    if ok and version and version:find("v32") then
        G.F.Notify("⬆️ Atualização disponível! v32", Color3.fromRGB(80,220,80))
    end
end)

-- =========================================================
-- FINAL
-- =========================================================
G.F.Notify("✅ Guasti v31 carregado!", G.TH[G.V.themeIdx].accent)
print("[Guasti] v31 (G. conversion) carregado com sucesso!")
print("[Guasti] Total de features: 42 | Sem patcher | Roda direto no Xeno")
