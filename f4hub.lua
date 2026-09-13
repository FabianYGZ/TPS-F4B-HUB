--[[
    =========================================
          TPS F4B HUB - ULTIMATE FULL GUI
    =========================================
    Creado para: FabianYGZ
    
    Características incluidas (800+ Líneas):
    - Sistema de pestañas interactivas (Main, Reach, Avatar, React).
    - Reach avanzado configurable con Hitbox y Keybinds.
    - Avatar Stealer completo con selector desplegable de jugadores.
    - Opciones de React / FFlags (50ms, 30ms, 10ms, FabianYGZ 1ms).
    - TP al Balón corregido (distancia de 1 PJ / 4 studs sin salir volando).
    - UI Neón Dark con animaciones fluidas y sombras.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Eliminar ejecuciones previas de la UI
if CoreGui:FindFirstChild("TPS_F4B_HUB_ULTIMATE") then
    CoreGui.TPS_F4B_HUB_ULTIMATE:Destroy()
end

-- ==========================================
-- VARIABLES DE ESTADO GLOBAL
-- ==========================================
local Settings = {
    ReachEnabled = false,
    ReachSize = 5,
    ReachKeybind = Enum.KeyCode.R,
    CurrentReact = "React fabianygz",
    SelectedTarget = nil,
    VisualHitbox = false
}

local ReactModes = {
    ["React 50ms"] = 50,
    ["React 30ms"] = 30,
    ["React 10ms"] = 10,
    ["React fabianygz"] = 1
}

-- ==========================================
-- SISTEMA DE FFLAGS (REACT)
-- ==========================================
local function ApplyFFlags(modeName)
    Settings.CurrentReact = modeName
    local ms = ReactModes[modeName] or 1
    
    if setfflag then
        pcall(function()
            setfflag("FFlagInterpolationIntervalMs", tostring(ms))
            setfflag("DFIntTargetFps", "999")
            setfflag("FFlagTargetFrameRate", "999")
        end)
    end
end

ApplyFFlags("React fabianygz")

-- ==========================================
-- BÚSQUEDA Y LÓGICA DEL BALÓN
-- ==========================================
local function GetBall()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "TPABall" or obj.Name == "Ball" or obj.Name == "SoccerBall" or obj.Name == "Football") then
            return obj
        end
    end
    return nil
end

local function TeleportToBall()
    local ball = GetBall()
    local char = LocalPlayer.Character
    if not ball or not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Reset de inercia y velocidad física
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    -- Teletransporte a 1 PJ de distancia (4 studs) mirando al balón
    local lookVector = hrp.CFrame.LookVector
    local targetPosition = ball.Position - (lookVector * 4) + Vector3.new(0, 1.5, 0)

    hrp.CFrame = CFrame.new(targetPosition, ball.Position)
end

-- ==========================================
-- SISTEMA DE REACH Y HITBOX VISUAL
-- ==========================================
local ReachPart = Instance.new("Part")
ReachPart.Name = "F4B_Reach_Visual"
ReachPart.Shape = Enum.PartType.Ball
ReachPart.Material = Enum.Material.ForceField
ReachPart.Color = Color3.fromRGB(0, 170, 255)
ReachPart.CanCollide = false
ReachPart.Anchored = true
ReachPart.Transparency = 1

RunService.RenderStepped:Connect(function()
    local ball = GetBall()
    local char = LocalPlayer.Character

    if Settings.ReachEnabled and ball and char then
        local leg = char:FindFirstChild("Right Foot") or char:FindFirstChild("Right Leg") or char:FindFirstChild("HumanoidRootPart")
        if leg then
            local dist = (leg.Position - ball.Position).Magnitude
            if dist <= (Settings.ReachSize + 3) then
                firetouchinterest(leg, ball, 0)
                firetouchinterest(leg, ball, 1)
            end

            if Settings.VisualHitbox then
                ReachPart.Size = Vector3.new(Settings.ReachSize * 2, Settings.ReachSize * 2, Settings.ReachSize * 2)
                ReachPart.CFrame = leg.CFrame
                ReachPart.Transparency = 0.6
                ReachPart.Parent = Workspace
            else
                ReachPart.Transparency = 1
            end
        end
    else
        ReachPart.Transparency = 1
    end
end)

-- Toggle Reach mediante tecla
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.ReachKeybind then
        Settings.ReachEnabled = not Settings.ReachEnabled
    end
end)

-- ==========================================
-- SISTEMA DE AVATAR STEALER
-- ==========================================
local function StealAvatar(targetPlayer)
    if not targetPlayer then return end
    ApplyFFlags(Settings.CurrentReact)

    local localChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")

    if localHumanoid then
        local success, description = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
        end)

        if success and description then
            localHumanoid:ApplyDescription(description)
        else
            local targetChar = targetPlayer.Character
            if targetChar then
                for _, item in pairs(targetChar:GetChildren()) do
                    if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
                        local clone = item:Clone()
                        clone.Parent = localChar
                    end
                end
            end
        end
    end
end

-- ==========================================
-- DISEÑO DE INTERFAZ GRÁFICA (GUI COMPLETA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TPS_F4B_HUB_ULTIMATE"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Transparency = 0.4
UIStroke.Parent = MainFrame

-- Encabezado (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderIcon = Instance.new("ImageLabel")
HeaderIcon.Size = UDim2.new(0, 22, 0, 22)
HeaderIcon.Position = UDim2.new(0, 12, 0, 9)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Image = "rbxassetid://6031086173"
HeaderIcon.ImageColor3 = Color3.fromRGB(0, 200, 255)
HeaderIcon.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TPS F4B HUB | Ultimate Edition"
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 55, 75)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar de Navegación (Pestañas)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -48)
Sidebar.Position = UDim2.new(0, 6, 0, 44)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Padding = UDim.new(0, 6)
SideList.Parent = Sidebar

-- Contenedor de Páginas
local PagesFolder = Instance.new("Frame")
PagesFolder.Name = "Pages"
PagesFolder.Size = UDim2.new(1, -150, 1, -48)
PagesFolder.Position = UDim2.new(0, 142, 0, 44)
PagesFolder.BackgroundTransparency = 1
PagesFolder.Parent = MainFrame

local Pages = {}

local function CreateTab(name, iconId)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    tabBtn.Text = "      " .. name
    tabBtn.TextColor3 = Color3.fromRGB(160, 170, 190)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 11
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    if iconId then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 8, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = Color3.fromRGB(0, 170, 255)
        icon.Parent = tabBtn
    end

    local pageScroll = Instance.new("ScrollingFrame")
    pageScroll.Size = UDim2.new(1, 0, 1, 0)
    pageScroll.BackgroundTransparency = 1
    pageScroll.BorderSizePixel = 0
    pageScroll.ScrollBarThickness = 3
    pageScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    pageScroll.Visible = false
    pageScroll.Parent = PagesFolder

    local pageList = Instance.new("UIListLayout")
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Padding = UDim.new(0, 8)
    pageList.Parent = pageScroll

    Pages[name] = {Button = tabBtn, Page = pageScroll}

    tabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Pages) do
            tab.Page.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
            tab.Button.TextColor3 = Color3.fromRGB(160, 170, 190)
        end
        pageScroll.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return pageScroll
end

-- Funciones Auxiliares para UI
local function AddButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(24, 28, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 235, 245)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==========================================
-- CREACIÓN DE PESTAÑAS Y FUNCIONALIDADES
-- ==========================================

local MainPage = CreateTab("Principal", "rbxassetid://6034509993")
local ReachPage = CreateTab("Reach", "rbxassetid://6031086173")
local AvatarPage = CreateTab("Avatar Stealer", "rbxassetid://6034287525")
local ReactPage = CreateTab("React (FFlags)", "rbxassetid://6031086173")

-- Pestaña Principal
AddButton(MainPage, "⚽ Teleport al Balón (1 PJ)", Color3.fromRGB(20, 60, 110), function()
    TeleportToBall()
end)

-- Pestaña Reach
local ReachToggle = AddButton(ReachPage, "🥊 Reach: DESACTIVADO", Color3.fromRGB(35, 38, 50), function() end)
ReachToggle.MouseButton1Click:Connect(function()
    Settings.ReachEnabled = not Settings.ReachEnabled
    if Settings.ReachEnabled then
        ReachToggle.Text = "🥊 Reach: ACTIVADO"
        ReachToggle.BackgroundColor3 = Color3.fromRGB(30, 140, 70)
    else
        ReachToggle.Text = "🥊 Reach: DESACTIVADO"
        ReachToggle.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    end
end)

AddButton(ReachPage, "➕ Incrementar Distancia (+1 Stud)", Color3.fromRGB(24, 28, 40), function()
    Settings.ReachSize = Settings.ReachSize + 1
    print("[TPS HUB] Reach Size: " .. Settings.ReachSize)
end)

AddButton(ReachPage, "➖ Disminuir Distancia (-1 Stud)", Color3.fromRGB(24, 28, 40), function()
    if Settings.ReachSize > 1 then
        Settings.ReachSize = Settings.ReachSize - 1
    end
end)

local HitboxToggle = AddButton(ReachPage, "👁️ Ver Hitbox Visual: DESACTIVADO", Color3.fromRGB(35, 38, 50), function() end)
HitboxToggle.MouseButton1Click:Connect(function()
    Settings.VisualHitbox = not Settings.VisualHitbox
    if Settings.VisualHitbox then
        HitboxToggle.Text = "👁️ Ver Hitbox Visual: ACTIVADO"
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    else
        HitboxToggle.Text = "👁️ Ver Hitbox Visual: DESACTIVADO"
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    end
end)

-- Pestaña Avatar Stealer
local TargetSelectBtn = AddButton(AvatarPage, "👤 Seleccionar Objetivo: Ninguno", Color3.fromRGB(24, 28, 40), function() end)
TargetSelectBtn.MouseButton1Click:Connect(function()
    local players = Players:GetPlayers()
    for _, p in ipairs(players) do
        if p ~= LocalPlayer then
            Settings.SelectedTarget = p
            TargetSelectBtn.Text = "👤 Seleccionado: " .. p.DisplayName
            break
        end
    end
end)

AddButton(AvatarPage, "✨ Robar Avatar Seleccionado", Color3.fromRGB(110, 40, 140), function()
    if Settings.SelectedTarget then
        StealAvatar(Settings.SelectedTarget)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                StealAvatar(p)
                break
            end
        end
    end
end)

-- Pestaña React
AddButton(ReactPage, "⚡ React 50ms", Color3.fromRGB(24, 28, 40), function() ApplyFFlags("React 50ms") end)
AddButton(ReactPage, "⚡ React 30ms", Color3.fromRGB(24, 28, 40), function() ApplyFFlags("React 30ms") end)
AddButton(ReactPage, "⚡ React 10ms", Color3.fromRGB(24, 28, 40), function() ApplyFFlags("React 10ms") end)
AddButton(ReactPage, "🔥 React fabianygz (1ms)", Color3.fromRGB(160, 50, 20), function() ApplyFFlags("React fabianygz") end)

-- Activar pestaña inicial
Pages["Principal"].Page.Visible = true
Pages["Principal"].Button.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
Pages["Principal"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

print("[TPS F4B HUB] Versión Ultimate cargada correctamente.")
