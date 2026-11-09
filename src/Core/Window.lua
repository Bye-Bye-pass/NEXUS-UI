--[[
    NEXUS UI
    Core / Window.lua

    Original UI Framework
    Designed for Roblox Studio
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

local DEFAULT_SIZE = UDim2.fromOffset(650, 450)

local COLORS = {
    Background = Color3.fromRGB(20, 22, 30),
    Topbar = Color3.fromRGB(27, 30, 40),
    Border = Color3.fromRGB(65, 72, 90),
    Text = Color3.fromRGB(240, 242, 255),
    Close = Color3.fromRGB(235, 85, 100),
}

-- イベント接続を管理
function Window:_Connect(signal, callback)
    local connection = signal:Connect(callback)

    table.insert(self.Connections, connection)

    return connection
end

-- ウィンドウ生成
function Window.new(nexus, options)
    options = options or {}

    local self = setmetatable({}, Window)

    self.Nexus = nexus
    self.Destroyed = false
    self.Connections = {}

    local player = Players.LocalPlayer

    assert(
        player,
        "[NEXUS UI] Window must be created on the client."
    )

    local playerGui = player:WaitForChild("PlayerGui")

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NEXUS_UI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = options.Size or DEFAULT_SIZE
    main.Position = options.Position or UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COLORS.Background
    main.BorderSizePixel = 0
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Parent = main

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 42)
    topbar.BackgroundColor3 = COLORS.Topbar
    topbar.BorderSizePixel = 0
    topbar.Parent = main

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topbar

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -65, 1, 0)
    title.Position = UDim2.fromOffset(15, 0)
    title.BackgroundTransparency = 1
    title.Text = options.Title or nexus.Config.Title
    title.TextColor3 = COLORS.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.fromOffset(30, 30)
    closeButton.Position = UDim2.new(1, -36, 0, 6)
    closeButton.BackgroundColor3 = COLORS.Close
    closeButton.BackgroundTransparency = 0.15
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 22
    closeButton.Font = Enum.Font.Gotham
    closeButton.BorderSizePixel = 0
    closeButton.Parent = topbar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -55)
    content.Position = UDim2.fromOffset(10, 48)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Store References
    self.Gui = screenGui
    self.Main = main
    self.Topbar = topbar
    self.Title = title
    self.Content = content

    -- Drag System
    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    self:_Connect(topbar.InputBegan, function(input)
        if options.Draggable == false then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = main.Position

            self:_Connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self:_Connect(topbar.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    self:_Connect(UserInputService.InputChanged, function(input)
        if not dragging or input ~= dragInput then
            return
        end

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    -- Close Button
    self:_Connect(closeButton.Activated, function()
        self:Destroy()
    end)

    -- Parent GUI
    screenGui.Parent = playerGui

    return self
end

-- ウィンドウ破棄
function Window:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    -- イベント接続を解除
    for _, connection in ipairs(self.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(self.Connections)

    -- GUIを削除
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

return Window
