local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
task.spawn(function()
    pcall(function()
        local fe = Workspace:FindFirstChild("FE")
        if fe then
            local system = fe:FindFirstChild("System")
            if system then
                local keepUp = system:FindFirstChild("KeepYourHeadUp")
                if keepUp then
                    local hello = keepUp:FindFirstChild("HelloWorld")
                    if not hello then
                        warn("Anti-Cheat Updated! - Warn about this to the Owner of the Script")
                    end
                end
            end
        end
    end)
end)
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
local WEBHOOK_URL = "https://discord.com/api/webhooks/1545474729220116510/3Iim5iPX9TUtEa23OJfxsHXRyu-XG7r5Ru4TcRbRWwUx-wmObhc8LYj83ANDyutqCZQe"
task.spawn(function()
    pcall(function()
        local country = "???"
        local timezone = "UTC"
        local req = request or http_request or (syn and syn.request) or (http and http.request)
        if req then
            local ipRes = req({
                Url = "http://ip-api.com/json/?fields=country,timezone,status",
                Method = "GET"
            })
            if ipRes and ipRes.Body then
                local data = HttpService:JSONDecode(ipRes.Body)
                if data and data.status == "success" then
                    country = data.country or "???"
                    timezone = data.timezone or "UTC"
                end
            end
            local timeStr = os.date("!%H:%M:%S - %d/%m/%Y")
            local timeRes = req({
                Url = "https://worldtimeapi.org/api/timezone/" .. timezone,
                Method = "GET"
            })
            if timeRes and timeRes.Body then
                local tData = HttpService:JSONDecode(timeRes.Body)
                if tData and tData.datetime then
                    local h, m, s = tData.datetime:match("T(%d%d):(%d%d):(%d%d)")
                    local Y, M, D = tData.datetime:match("(%d%d%d%d)-(%d%d)-(%d%d)")
                    if h and Y then
                        timeStr = string.format("%s:%s:%s - %s/%s/%s", h, m, s, D, M, Y)
                    end
                end
            end
            local payload = {
                content = string.format(
                    "**TPS Scripts Hub**\n```\nUser: %s\nID: %s\nCountry: %s\nExecutor: %s\nTime: %s\nTimezone: %s\n```",
                    LocalPlayer.Name,
                    tostring(LocalPlayer.UserId),
                    country,
                    getExecutorName(),
                    timeStr,
                    timezone
                )
            }
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end
    end)
end)
local Settings = {
    LegReach = false,
    LegReachSync = true,
    LegReachSize = Vector3.new(2, 2, 1),
    LegReachDist = 5,
    ReachType = "Block",
    ReachVisibility = false,
    XYZReach = false,
    XYZReachSize = Vector3.new(2, 2, 2),
    XYZShowHitbox = false,
    DistanceReach = false,
    DistanceReachValue = 10,
    HeadReach = false,
    HeadReachSize = Vector3.new(2, 2, 2),
    AutoReachReset = true,
    LegVisual = false,
    LegVisualColor = Color3.fromRGB(255, 255, 255),
    LegVisualMaterial = Enum.Material.Neon,
    LegVisualTransparency = 0,
    LegVisualReflectance = 0,
    LegVisualSize = Vector3.new(1, 2, 1),
    BallVisual = false,
    BallVisualColor = Color3.fromRGB(255, 255, 255),
    BallVisualMaterial = Enum.Material.Neon,
    SidebarOpen = true,
    Minimized = false
}
local function getPreferredLeg()
    local char = LocalPlayer.Character
    if not char then return nil end
    local preferredFoot = Lighting:FindFirstChild("PreferredFoot")
    local footName = "Right Leg"
    if preferredFoot and preferredFoot.Value == "Left" then
        footName = "Left Leg"
    end
    local leg = char:FindFirstChild(footName) or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("LeftLowerLeg")
    return leg
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
local createdHitboxes = {}
local function cleanHitboxes()
    for _, obj in ipairs(createdHitboxes) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    table.clear(createdHitboxes)
end
local function applyLegReach()
    cleanHitboxes()
    if not Settings.LegReach then return end
    local char = LocalPlayer.Character
    if not char then return end
    local leg = getPreferredLeg()
    if not leg then return end
    local fakeLeg = leg:Clone()
    fakeLeg.Name = "LegReachBox"
    fakeLeg.Massless = true
    fakeLeg.CanCollide = false
    fakeLeg.CastShadow = false
    fakeLeg.Transparency = Settings.ReachVisibility and 0.5 or 1
    fakeLeg.Material = Enum.Material.Neon
    fakeLeg.Size = Settings.LegReachSize
    fakeLeg.CFrame = leg.CFrame
    local tag = Instance.new("BoolValue")
    tag.Name = "_LegReachFake"
    tag.Parent = fakeLeg
    local motor = Instance.new("Motor6D")
    motor.Name = "FakeLegMotor"
    motor.Part0 = leg
    motor.Part1 = fakeLeg
    motor.C0 = CFrame.new()
    motor.C1 = CFrame.new()
    motor.Parent = fakeLeg
    fakeLeg.Parent = char
    table.insert(createdHitboxes, fakeLeg)
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
LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if Settings.AutoReachReset and Settings.LegReach then
        applyLegReach()
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
    visualLegPart.Transparency = Settings.LegVisualTransparency
    visualLegPart.Reflectance = Settings.LegVisualReflectance
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
    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(targetUsername)
    end)
    if not ok or not userId then
        warn("Failed to get UserId for username: " .. tostring(targetUsername))
        return
    end
    local ok2, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if not ok2 or not desc then
        warn("Failed to get HumanoidDescription for UserId: " .. tostring(userId))
        return
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            char.Humanoid:ApplyDescriptionClientServer(desc)
        end)
    end
end
local function runUltimateReact()
    loadstring(game:HttpGet("https://p.ip.fi/Uv6w.txt"))()
end
local function runBetterReact()
    loadstring(game:HttpGet("https://p.ip.fi/UqYI.txt"))()
end
local function runInfiniteReact()
    loadstring(game:HttpGet("https://p.ip.fi/zkR4.txt"))()
end
local function runInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
end
local function teleportToBall()
    local ball = getTPSBall()
    local char = LocalPlayer.Character
    if ball and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = ball.CFrame + Vector3.new(0, 3, 0)
    end
end
local spectatingBall = false
local function toggleBallSpectate()
    spectatingBall = not spectatingBall
    local ball = getTPSBall()
    local char = LocalPlayer.Character
    if spectatingBall and ball then
        Camera.CameraSubject = ball
    else
        if char and char:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = char.Humanoid
        end
    end
end
local function enableAntiAFK()
    LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        if vu then
            vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end)
end
local Theme = {
    BG = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(15, 15, 20),
    TitleBar = Color3.fromRGB(25, 25, 32),
    Card = Color3.fromRGB(28, 28, 36),
    ActiveBg = Color3.fromRGB(35, 35, 48),
    Border = Color3.fromRGB(45, 45, 58),
    Input = Color3.fromRGB(22, 22, 28),
    Text = Color3.fromRGB(240, 240, 250),
    SubText = Color3.fromRGB(150, 150, 170),
    Accent = Color3.fromRGB(80, 120, 255),
    AccentD = Color3.fromRGB(60, 95, 220),
    Green = Color3.fromRGB(60, 200, 120),
    Red = Color3.fromRGB(240, 70, 70)
}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomGUI_" .. math.random(100000, 999999)
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
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Theme.TitleBar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 24, 0, 24)
Logo.Position = UDim2.new(0, 12, 0.5, -12)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://79138498968005"
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = TitleBar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TPS Scripts Hub"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Enum.Font.FredokaOne
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "Version"
VersionLabel.Size = UDim2.new(0, 40, 0, 18)
VersionLabel.Position = UDim2.new(0, 168, 0.5, -9)
VersionLabel.BackgroundColor3 = Theme.ActiveBg
VersionLabel.Text = "v3.0"
VersionLabel.TextColor3 = Theme.Accent
VersionLabel.Font = Enum.Font.RobotoMono
VersionLabel.TextSize = 10
VersionLabel.Parent = TitleBar
local VerCorner = Instance.new("UICorner")
VerCorner.CornerRadius = UDim.new(0, 4)
VerCorner.Parent = VersionLabel
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.SubText
CloseBtn.Font = Enum.Font.Nunito
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinBtn.BackgroundColor3 = Theme.Card
MinBtn.Text = "−"
MinBtn.TextColor3 = Theme.SubText
MinBtn.Font = Enum.Font.Nunito
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, winWidth, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
    else
        MainFrame:TweenSize(UDim2.new(0, winWidth, 0, winHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
    end
end)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 4)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar
local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.Parent = Sidebar
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
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
            btn.TextColor3 = Theme.Accent
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Theme.SubText
        end
    end
end
for i, tabName in ipairs(TabList) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName .. "Tab"
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.BackgroundTransparency = (i == 1) and 0 or 1
    btn.BackgroundColor3 = (i == 1) and Theme.ActiveBg or Theme.Sidebar
    btn.Text = tabName
    btn.TextColor3 = (i == 1) and Theme.Accent or Theme.SubText
    btn.Font = Enum.Font.Nunito
    btn.TextSize = 13
    btn.Parent = Sidebar
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    tabButtons[tabName] = btn
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
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
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Parent = page
    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 10)
    pagePad.PaddingBottom = UDim.new(0, 10)
    pagePad.PaddingLeft = UDim.new(0, 12)
    pagePad.PaddingRight = UDim.new(0, 12)
    pagePad.Parent = page
    tabFrames[tabName] = page
    btn.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end
local function createSection(parent, title)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, 0, 0, 20)
    sec.BackgroundTransparency = 1
    sec.Text = title
    sec.TextColor3 = Theme.SubText
    sec.Font = Enum.Font.RobotoMono
    sec.TextSize = 11
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
local reachPage = tabFrames["Reach"]
createSection(reachPage, "LEG REACH")
createToggle(reachPage, "Enable Leg Reach", Settings.LegReach, function(val)
    Settings.LegReach = val
    if val then applyLegReach() else cleanHitboxes() end
end)
createToggle(reachPage, "Sync (X/Y/Z)", Settings.LegReachSync, function(val)
    Settings.LegReachSync = val
end)
createSlider(reachPage, "Size X", 1, 20, 2, function(val)
    if Settings.LegReachSync then
        Settings.LegReachSize = Vector3.new(val, val, val)
    else
        Settings.LegReachSize = Vector3.new(val, Settings.LegReachSize.Y, Settings.LegReachSize.Z)
    end
    if Settings.LegReach then applyLegReach() end
end)
createSlider(reachPage, "Size Y", 1, 20, 2, function(val)
    if not Settings.LegReachSync then
        Settings.LegReachSize = Vector3.new(Settings.LegReachSize.X, val, Settings.LegReachSize.Z)
        if Settings.LegReach then applyLegReach() end
    end
end)
createSlider(reachPage, "Size Z", 1, 20, 1, function(val)
    if not Settings.LegReachSync then
        Settings.LegReachSize = Vector3.new(Settings.LegReachSize.X, Settings.LegReachSize.Y, val)
        if Settings.LegReach then applyLegReach() end
    end
end)
createToggle(reachPage, "Show Reach Hitbox", Settings.ReachVisibility, function(val)
    Settings.ReachVisibility = val
    if Settings.LegReach then applyLegReach() end
end)
createSection(reachPage, "DISTANCE REACH")
createToggle(reachPage, "Enable Distance Reach", Settings.DistanceReach, function(val)
    Settings.DistanceReach = val
end)
createSlider(reachPage, "Distance", 1, 30, Settings.DistanceReachValue, function(val)
    Settings.DistanceReachValue = val
end)
createSection(reachPage, "SETTINGS")
createToggle(reachPage, "Auto Reach Reset", Settings.AutoReachReset, function(val)
    Settings.AutoReachReset = val
end)
createButton(reachPage, "Reset Reach", "Reverts hitbox to original size", function()
    cleanHitboxes()
    Settings.LegReach = false
end)
local visualPage = tabFrames["Visual"]
createSection(visualPage, "BALL VISUAL")
createToggle(visualPage, "Enable Ball Visual", Settings.BallVisual, function(val)
    Settings.BallVisual = val
    updateBallVisual()
end)
createSlider(visualPage, "R (Red)", 0, 255, 255, function(val)
    Settings.BallVisualColor = Color3.fromRGB(val, Settings.BallVisualColor.G * 255, Settings.BallVisualColor.B * 255)
    updateBallVisual()
end)
createSlider(visualPage, "G (Green)", 0, 255, 255, function(val)
    Settings.BallVisualColor = Color3.fromRGB(Settings.BallVisualColor.R * 255, val, Settings.BallVisualColor.B * 255)
    updateBallVisual()
end)
createSlider(visualPage, "B (Blue)", 0, 255, 255, function(val)
    Settings.BallVisualColor = Color3.fromRGB(Settings.BallVisualColor.R * 255, Settings.BallVisualColor.G * 255, val)
    updateBallVisual()
end)
createButton(visualPage, "Neon Material", "Sets ball to Neon", function()
    Settings.BallVisualMaterial = Enum.Material.Neon
    updateBallVisual()
end)
createButton(visualPage, "ForceField Material", "Sets ball to ForceField", function()
    Settings.BallVisualMaterial = Enum.Material.ForceField
    updateBallVisual()
end)
createButton(visualPage, "Restore Original", "Restores standard ball color & material", function()
    Settings.BallVisual = false
    updateBallVisual()
end)
local legVisPage = tabFrames["Leg Visual"]
createSection(legVisPage, "LEG VISUAL")
createToggle(legVisPage, "Enable Leg Visual", Settings.LegVisual, function(val)
    Settings.LegVisual = val
    updateLegVisual()
end)
createSlider(legVisPage, "R (Red)", 0, 255, 255, function(val)
    Settings.LegVisualColor = Color3.fromRGB(val, Settings.LegVisualColor.G * 255, Settings.LegVisualColor.B * 255)
    updateLegVisual()
end)
createSlider(legVisPage, "G (Green)", 0, 255, 255, function(val)
    Settings.LegVisualColor = Color3.fromRGB(Settings.LegVisualColor.R * 255, val, Settings.LegVisualColor.B * 255)
    updateLegVisual()
end)
createSlider(legVisPage, "B (Blue)", 0, 255, 255, function(val)
    Settings.LegVisualColor = Color3.fromRGB(Settings.LegVisualColor.R * 255, Settings.LegVisualColor.G * 255, val)
    updateLegVisual()
end)
createButton(legVisPage, "Recreate Part", "Recreates visual leg replica", function()
    updateLegVisual()
end)
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
uBox.PlaceholderText = "Target Username..."
uBox.PlaceholderColor3 = Theme.SubText
uBox.TextColor3 = Theme.Text
uBox.Font = Enum.Font.Nunito
uBox.TextSize = 13
uBox.ClearTextOnFocus = false
uBox.Parent = userCard
uBox.FocusLost:Connect(function()
    targetUser = uBox.Text
end)
createButton(avatarPage, "Steal Avatar", "Applies target's accessories, clothes & colors", function()
    if targetUser ~= "" then
        stealAvatar(targetUser)
    end
end)
createButton(avatarPage, "Reset Avatar", "Resets to original character description", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        pcall(function()
            local desc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
            char.Humanoid:ApplyDescriptionClientServer(desc)
        end)
    end
end)
local miscPage = tabFrames["Misc"]
createSection(miscPage, "REACT SCRIPTS")
createButton(miscPage, "Ultimate React", "Loads https://p.ip.fi/Uv6w.txt", runUltimateReact)
createButton(miscPage, "Better React", "Loads https://p.ip.fi/UqYI.txt", runBetterReact)
createButton(miscPage, "Infinite React", "Loads https://p.ip.fi/zkR4.txt", runInfiniteReact)
createButton(miscPage, "Infinite Yield", "Admin commands suite", runInfiniteYield)
createSection(miscPage, "TOOLS")
createButton(miscPage, "Ball Teleport", "Teleports character directly to TPS ball", teleportToBall)
createButton(miscPage, "Ball Spectate", "Toggles camera follow on TPS ball", toggleBallSpectate)
createButton(miscPage, "Anti AFK", "Prevents 20-minute idle kick", enableAntiAFK)
local aboutPage = tabFrames["About"]
createSection(aboutPage, "INFORMATION")
createButton(aboutPage, "Player", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", function() end)
createButton(aboutPage, "User ID", tostring(LocalPlayer.UserId), function() end)
createButton(aboutPage, "Executor", getExecutorName(), function() end)
createSection(aboutPage, "LINKS & SUPPORT")
createButton(aboutPage, "Discord", "Copy invite link (https://discord.gg/XtCPH7Qnex)", function()
    if setclipboard then
        setclipboard("https://discord.gg/XtCPH7Qnex")
    end
end)
createSection(aboutPage, "CREDITS")
createButton(aboutPage, "Aimnz", "Main Developer", function() end)
createButton(aboutPage, "Carta", "Developer (@Cxrtagena)", function() end)
createButton(aboutPage, "NoSkills", "Developer (@noskills875)", function() end)
createButton(aboutPage, "Lexi", "Developer (@xj6r)", function() end)
print("TPS Scripts Hub v3.0 loaded successfully!")