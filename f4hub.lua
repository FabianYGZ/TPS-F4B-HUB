local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function getExecutorName()
    if identifyexecutor then
        return identifyexecutor()
    elseif getgenv then
        local env = getgenv()
        if env.SYNZ_LOADED then return "Synapse Z" end
        if env.DELTA_LOADED then return "Delta" end
        if env.CODEX_LOADED then return "Codex" end
        if env.hydrogen then return "Hydrogen" end
        if env.is_sirhurt_closure then return "SirHurt" end
        if env.EVON_LOADED then return "Evon" end
        if env.celery then return "Celery" end
        if env.KRNL_LOADED then return "KRNL" end
        if env.syn then return "Synapse X" end
        if env.ScriptWare then return "Script-Ware" end
        if env.fluxus then return "Fluxus" end
        if env.AWP then return "AWP.GG" end
    end
    return "Unknown"
end

local Settings = {
    DistanceReach = false,
    DistanceReachValue = 10,
    LegVisual = false,
    LegVisualColor = Color3.fromRGB(0, 255, 200),
    LegVisualMaterial = Enum.Material.Neon,
    BallVisual = false,
    BallVisualColor = Color3.fromRGB(255, 0, 128),
    BallVisualMaterial = Enum.Material.Neon
}

local function getPreferredLeg()
    local char = LocalPlayer.Character
    if not char then return nil end
    local preferredFoot = Lighting:FindFirstChild("PreferredFoot")
    local footName = "Right Leg"
    if preferredFoot and preferredFoot.Value == "Left" then
        footName = "Left Leg"
    end
    return char:FindFirstChild(footName) or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("LeftLowerLeg")
end

local function getTPSBall()
    local tpsSystem = Workspace:FindFirstChild("TPSSystem")
    if tpsSystem and tpsSystem:FindFirstChild("TPS") then
        return tpsSystem.TPS
    end
    local fe = Workspace:FindFirstChild("FE")
    if fe and fe:FindFirstChild("System") and fe.System:FindFirstChild("Ball") then
        return fe.System.Ball
    end
    return Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("TPS")
end

RunService.PreSimulation:Connect(function()
    if Settings.DistanceReach and firetouchinterest then
        local char = LocalPlayer.Character
        if not char then return end
        local leg = getPreferredLeg()
        local ball = getTPSBall()
        if leg and ball then
            local dist = (leg.Position - ball.Position).Magnitude
            if dist <= Settings.DistanceReachValue then
                pcall(function()
                    firetouchinterest(leg, ball, 0)
                    firetouchinterest(leg, ball, 1)
                end)
            end
        end
    end
end)

local visualLegPart = nil
local function updateLegVisual()
    if visualLegPart and visualLegPart.Parent then
        visualLegPart:Destroy()
        visualLegPart = nil
    end
    if not Settings.LegVisual then return end
    local char = LocalPlayer.Character
    if not char then return end
    local leg = getPreferredLeg()
    if not leg then return end

    visualLegPart = Instance.new("Part")
    visualLegPart.Name = "LegReachVisual"
    visualLegPart.Massless = true
    visualLegPart.CanCollide = false
    visualLegPart.CastShadow = false
    visualLegPart.Material = Settings.LegVisualMaterial
    visualLegPart.Color = Settings.LegVisualColor
    visualLegPart.Size = leg.Size
    visualLegPart.CFrame = leg.CFrame

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = leg
    weld.Part1 = visualLegPart
    weld.Parent = visualLegPart
    visualLegPart.Parent = char
end

local originalBallProps = { Color = nil, Material = nil }
local function updateBallVisual()
    local ball = getTPSBall()
    if not ball then return end
    if not originalBallProps.Color then
        originalBallProps.Color = ball.Color
        originalBallProps.Material = ball.Material
    end
    if Settings.BallVisual then
        ball.Color = Settings.BallVisualColor
        ball.Material = Settings.BallVisualMaterial
    else
        if originalBallProps.Color then
            ball.Color = originalBallProps.Color
            ball.Material = originalBallProps.Material
        end
    end
end

local function stealAvatar(targetUsername)
    local ok, userId = pcall(function() return Players:GetUserIdFromNameAsync(targetUsername) end)
    if not ok or not userId then return end
    local ok2, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
    if not ok2 or not desc then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        pcall(function() char.Humanoid:ApplyDescriptionClientServer(desc) end)
    end
end

-- Colores más llamativos y vívidos
local Theme = {
    BG = Color3.fromRGB(15, 12, 28),
    Sidebar = Color3.fromRGB(24, 18, 45),
    TitleBar = Color3.fromRGB(32, 22, 60),
    Card = Color3.fromRGB(35, 28, 65),
    ActiveBg = Color3.fromRGB(120, 40, 255),
    Border = Color3.fromRGB(160, 50, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 180, 245),
    Accent = Color3.fromRGB(0, 230, 255),
    Green = Color3.fromRGB(0, 255, 140)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "F4Hub_" .. math.random(100000, 999999)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local isMobile = UserInputService.TouchEnabled
local winWidth = isMobile and math.min(Camera.ViewportSize.X - 40, 480) or 540
local winHeight = isMobile and math.min(Camera.ViewportSize.Y - 60, 360) or 380

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
MainFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Theme.TitleBar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "F4 HUB"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.FredokaOne
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.Nunito
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 4)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -130, 1, -42)
Pages.Position = UDim2.new(0, 130, 0, 42)
Pages.BackgroundTransparency = 1
Pages.Parent = MainFrame

local tabFrames = {}
local tabButtons = {}
local TabList = {"Reach", "Visual", "Leg Visual", "Avatar", "Misc", "About"}

local function switchTab(tabName)
    for name, frame in pairs(tabFrames) do
        frame.Visible = (name == tabName)
    end
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Theme.ActiveBg
            btn.TextColor3 = Theme.Text
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Theme.SubText
        end
    end
end

for i, tabName in ipairs(TabList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.BackgroundTransparency = (i == 1) and 0 or 1
    btn.BackgroundColor3 = (i == 1) and Theme.ActiveBg or Theme.Sidebar
    btn.Text = tabName
    btn.TextColor3 = (i == 1) and Theme.Text or Theme.SubText
    btn.Font = Enum.Font.Nunito
    btn.TextSize = 13
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    tabButtons[tabName] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Border
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = (i == 1)
    page.Parent = Pages

    local pageList = Instance.new("UIListLayout")
    pageList.Padding = UDim.new(0, 8)
    pageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageList.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 10)
    pagePad.PaddingBottom = UDim.new(0, 10)
    pagePad.PaddingLeft = UDim.new(0, 12)
    pagePad.PaddingRight = UDim.new(0, 12)
    pagePad.Parent = page

    tabFrames[tabName] = page

    btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
end

local function createSection(parent, title)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, 0, 0, 20)
    sec.BackgroundTransparency = 1
    sec.Text = title
    sec.TextColor3 = Theme.Accent
    sec.Font = Enum.Font.FredokaOne
    sec.TextSize = 12
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Parent = parent
    return sec
end

local function createToggle(parent, title, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 38)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Nunito
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(0, 36, 0, 20)
    tBtn.Position = UDim2.new(1, -48, 0.5, -10)
    tBtn.BackgroundColor3 = default and Theme.Green or Theme.Border
    tBtn.Text = ""
    tBtn.Parent = card

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = tBtn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = tBtn

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(1, 0)
    dCorner.Parent = dot

    local state = default
    tBtn.MouseButton1Click:Connect(function()
        state = not state
        tBtn.BackgroundColor3 = state and Theme.Green or Theme.Border
        dot.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
    return card
end

local function createSlider(parent, title, min, max, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Nunito
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -72, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Theme.Accent
    valLbl.Font = Enum.Font.RobotoMono
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 32)
    bar.BackgroundColor3 = Theme.Border
    bar.BorderSizePixel = 0
    bar.Parent = card

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(1, 0)
    bCorner.Parent = bar

    local fill = Instance.new("Frame")
    local pct = math.clamp((default - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local active = false
    local function updateSlider(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        local val = math.floor(min + (max - min) * rel)
        valLbl.Text = tostring(val)
        callback(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    return card
end

local function createButton(parent, title, subtitle, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Theme.Card
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Nunito
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -24, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 20)
    sub.BackgroundTransparency = 1
    sub.Text = subtitle or ""
    sub.TextColor3 = Theme.SubText
    sub.Font = Enum.Font.Nunito
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- TAB REACH
local reachPage = tabFrames["Reach"]
createSection(reachPage, "REACH (X,Y,Z)")
createToggle(reachPage, "Activar Reach", Settings.DistanceReach, function(val)
    Settings.DistanceReach = val
end)
createSlider(reachPage, "Distancia", 1, 30, Settings.DistanceReachValue, function(val)
    Settings.DistanceReachValue = val
end)

-- TAB VISUAL
local visualPage = tabFrames["Visual"]
createSection(visualPage, "BALL VISUAL")
createToggle(visualPage, "Activar Ball Visual", Settings.BallVisual, function(val)
    Settings.BallVisual = val
    updateBallVisual()
end)

-- TAB LEG VISUAL
local legVisPage = tabFrames["Leg Visual"]
createSection(legVisPage, "LEG VISUAL")
createToggle(legVisPage, "Activar Leg Visual", Settings.LegVisual, function(val)
    Settings.LegVisual = val
    updateLegVisual()
end)

-- TAB AVATAR
local avatarPage = tabFrames["Avatar"]
createSection(avatarPage, "AVATAR STEALER")
local targetUser = ""
local userCard = Instance.new("Frame")
userCard.Size = UDim2.new(1, 0, 0, 40)
userCard.BackgroundColor3 = Theme.Card
userCard.BorderSizePixel = 0
userCard.Parent = avatarPage

local uCorner = Instance.new("UICorner")
uCorner.CornerRadius = UDim.new(0, 6)
uCorner.Parent = userCard

local uBox = Instance.new("TextBox")
uBox.Size = UDim2.new(1, -24, 1, 0)
uBox.Position = UDim2.new(0, 12, 0, 0)
uBox.BackgroundTransparency = 1
uBox.PlaceholderText = "Nombre de usuario..."
uBox.PlaceholderColor3 = Theme.SubText
uBox.TextColor3 = Theme.Text
uBox.Font = Enum.Font.Nunito
uBox.TextSize = 13
uBox.ClearTextOnFocus = false
uBox.Parent = userCard

uBox.FocusLost:Connect(function() targetUser = uBox.Text end)
createButton(avatarPage, "Copiar Avatar", "Aplica el avatar del usuario", function()
    if targetUser ~= "" then stealAvatar(targetUser) end
end)

-- TAB MISC
local miscPage = tabFrames["Misc"]
createSection(miscPage, "SCRIPTS SECUNDARIOS")
createButton(miscPage, "Infinite Yield", "Panel de comandos Admin", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
end)

-- TAB ABOUT
local aboutPage = tabFrames["About"]
createSection(aboutPage, "INFORMACIÓN")
createButton(aboutPage, "Jugador", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", function() end)
createButton(aboutPage, "Ejecutor", getExecutorName(), function() end)

createSection(aboutPage, "LINKS & SUPPORT")
createButton(aboutPage, "Discord", "Copiar invitación (https://discord.gg/4yYZ6Uykde)", function()
    if setclipboard then
        setclipboard("https://discord.gg/4yYZ6Uykde")
    end
end)

createSection(aboutPage, "CRÉDITOS")
createButton(aboutPage, "fabianygz", "Creador Principal", function() end)

print("F4 HUB cargado correctamente.")
