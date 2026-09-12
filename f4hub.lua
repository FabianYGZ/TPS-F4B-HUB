--[[
    =========================================
            TPS F4B HUB - FULL SCRIPT
    =========================================
    Creado para: FabianYGZ
    
    Características incluidas:
    - Interfaz gráfica (UI) completa y draggable.
    - Avatar Stealer funcional con selector de objetivo.
    - Opciones de React / FFlags (50ms, 30ms, 10ms, FabianYGZ 1ms).
    - TP al Balón corregido (distancia exacta de 1 personaje / 4 studs sin salir volando).
    - Resets de velocidad e inercia física.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Eliminar UI previa si existe
if CoreGui:FindFirstChild("TPS_F4B_HUB_FULL") then
    CoreGui.TPS_F4B_HUB_FULL:Destroy()
end

-- ==========================================
-- SISTEMA DE FFLAGS E INTERPOLACIÓN (REACT)
-- ==========================================
local ReactModes = {
    ["React 50ms"] = 50,
    ["React 30ms"] = 30,
    ["React 10ms"] = 10,
    ["React fabianygz"] = 1
}

local CurrentReact = "React fabianygz"
local SelectedPlayerToSteal = nil

local function ApplyFFlags(modeName)
    CurrentReact = modeName
    local interpolationMS = ReactModes[modeName] or 1
    
    if setfflag then
        pcall(function()
            setfflag("FFlagInterpolationIntervalMs", tostring(interpolationMS))
            setfflag("DFIntTargetFps", "999")
            setfflag("FFlagTargetFrameRate", "999")
        end)
    end
    print("[TPS F4B HUB] React activo: " .. modeName .. " (" .. interpolationMS .. "ms)")
end

-- Aplicar React por defecto
ApplyFFlags("React fabianygz")

-- ==========================================
-- SISTEMA DE AVATAR STEALER
-- ==========================================
local function StealAvatar(targetPlayer)
    if not targetPlayer then return end
    
    -- Aplicar FFlag configurada al robar
    ApplyFFlags(CurrentReact)

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
-- SISTEMA DE TELETRANSPORTE AL BALÓN (TP)
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

    -- Detener velocidad física acumulada para no salir volando
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    -- Calcular posición a 1 personaje de distancia (4 studs) mirando directo al balón
    local lookVector = hrp.CFrame.LookVector
    local targetPosition = ball.Position - (lookVector * 4) + Vector3.new(0, 1.5, 0)

    hrp.CFrame = CFrame.new(targetPosition, ball.Position)
end

-- ==========================================
-- CONSTRUCCIÓN DE LA INTERFAZ COMPLETA (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TPS_F4B_HUB_FULL"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Top Bar / Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TPS F4B HUB | FabianYGZ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
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

-- Scroll Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -55)
Scroll.Position = UDim2.new(0, 10, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Scroll

-- Creador de Secciones
local function CreateSectionTitle(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "-- " .. string.upper(text) .. " --"
    label.TextColor3 = Color3.fromRGB(120, 120, 140)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = Scroll
end

-- Creador de Botones
local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(38, 38, 48)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==========================================
-- ELEMENTOS DE LA UI
-- ==========================================

CreateSectionTitle("Teleport & Física")
CreateButton("⚽ TP al Balón (1 PJ Distancia)", Color3.fromRGB(45, 90, 180), function()
    TeleportToBall()
end)

CreateSectionTitle("Avatar Stealer")

-- Selector de Jugador
local PlayerDropdown = Instance.new("TextButton")
PlayerDropdown.Size = UDim2.new(1, 0, 0, 32)
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
PlayerDropdown.Text = "Seleccionar Jugador: Ninguno"
PlayerDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerDropdown.Font = Enum.Font.Gotham
PlayerDropdown.TextSize = 12
PlayerDropdown.Parent = Scroll

local DropCorner = Instance.new("UICorner")
DropCorner.CornerRadius = UDim.new(0, 6)
DropCorner.Parent = PlayerDropdown

PlayerDropdown.MouseButton1Click:Connect(function()
    local allPlayers = Players:GetPlayers()
    for i, p in ipairs(allPlayers) do
        if p ~= LocalPlayer then
            SelectedPlayerToSteal = p
            PlayerDropdown.Text = "Seleccionado: " .. p.DisplayName
            break
        end
    end
end)

CreateButton("👤 Robar Avatar Seleccionado", Color3.fromRGB(140, 45, 180), function()
    if SelectedPlayerToSteal then
        StealAvatar(SelectedPlayerToSteal)
    else
        -- Roba a un jugador cualquiera si no se ha seleccionado ninguno
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                StealAvatar(p)
                break
            end
        end
    end
end)

CreateSectionTitle("Ajustes de React (FFlags)")

CreateButton("⚡ React 50ms (50 Interpolation)", Color3.fromRGB(38, 38, 48), function()
    ApplyFFlags("React 50ms")
end)

CreateButton("⚡ React 30ms (30 Interpolation)", Color3.fromRGB(38, 38, 48), function()
    ApplyFFlags("React 30ms")
end)

CreateButton("⚡ React 10ms (10 Interpolation)", Color3.fromRGB(38, 38, 48), function()
    ApplyFFlags("React 10ms")
end)

CreateButton("🔥 React fabianygz (1 Interpolation)", Color3.fromRGB(180, 80, 40), function()
    ApplyFFlags("React fabianygz")
end)

print("[TPS F4B HUB] Script completo cargado con éxito.")
