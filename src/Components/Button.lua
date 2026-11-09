--[[
    NEXUS UI
    Components / Button.lua

    Original UI Framework
    Designed for Roblox Studio
]]

local Button = {}
Button.__index = Button

local COLORS = {
    Background = Color3.fromRGB(39, 44, 58),
    Hover = Color3.fromRGB(55, 63, 82),
    Border = Color3.fromRGB(75, 85, 110),
    Text = Color3.fromRGB(240, 242, 255),
    Description = Color3.fromRGB(155, 162, 180),
}

-- Button生成
function Button.new(section, options)
    options = options or {}

    assert(
        type(options) == "table",
        "[NEXUS UI] Button options must be a table."
    )

    assert(
        not section.Destroyed,
        "[NEXUS UI] Cannot create a button inside a destroyed section."
    )

    if options.Callback ~= nil then
        assert(
            type(options.Callback) == "function",
            "[NEXUS UI] Button Callback must be a function."
        )
    end

    local self = setmetatable({}, Button)

    self.Section = section
    self.Destroyed = false

    -- 設定
    local name = options.Name or "Button"
    local description = options.Description

    -- ボタン本体
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(
        1,
        0,
        0,
        description and 56 or 40
    )
    button.BackgroundColor3 = COLORS.Background
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = options.LayoutOrder or 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button

    -- ボタン名
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -24, 0, 20)
    title.Position = UDim2.fromOffset(
        12,
        description and 7 or 10
    )
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = COLORS.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = button

    -- 説明文
    if description then
        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Name = "Description"
        descriptionLabel.Size = UDim2.new(1, -24, 0, 17)
        descriptionLabel.Position = UDim2.fromOffset(12, 29)
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Text = description
        descriptionLabel.TextColor3 = COLORS.Description
        descriptionLabel.TextSize = 11
        descriptionLabel.Font = Enum.Font.Gotham
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        descriptionLabel.Parent = button

        self.Description = descriptionLabel
    end

    -- ホバー演出
    self.HoverConnection = button.MouseEnter:Connect(function()
        if not self.Destroyed then
            button.BackgroundColor3 = COLORS.Hover
        end
    end)

    self.LeaveConnection = button.MouseLeave:Connect(function()
        if not self.Destroyed then
            button.BackgroundColor3 = COLORS.Background
        end
    end)

    -- クリック処理
    self.ActivatedConnection = button.Activated:Connect(function()
        if self.Destroyed then
            return
        end

        if options.Callback then
            local success, err = pcall(options.Callback)

            if not success then
                warn("[NEXUS UI] Button callback error:", err)
            end
        end
    end)

    self.Instance = button
    self.Title = title

    button.Parent = section.Content

    return self
end

-- Button削除
function Button:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.HoverConnection then
        self.HoverConnection:Disconnect()
        self.HoverConnection = nil
    end

    if self.LeaveConnection then
        self.LeaveConnection:Disconnect()
        self.LeaveConnection = nil
    end

    if self.ActivatedConnection then
        self.ActivatedConnection:Disconnect()
        self.ActivatedConnection = nil
    end

    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
end

return Button
