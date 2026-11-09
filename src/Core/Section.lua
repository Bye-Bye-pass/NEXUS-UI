--[[
    NEXUS UI
    Core / Section.lua

    Original UI Framework
    Designed for Roblox Studio
]]

local Button = require(script.Parent.Parent.Components.Button)

local Section = {}
Section.__index = Section

local COLORS = {
    Background = Color3.fromRGB(29, 32, 43),
    Border = Color3.fromRGB(65, 72, 90),
    Title = Color3.fromRGB(240, 242, 255),
    Muted = Color3.fromRGB(155, 162, 180),
}

-- Section生成
function Section.new(tab, options)
    options = options or {}

    local self = setmetatable({}, Section)

    self.Tab = tab
    self.Destroyed = false
    self.Name = options.Name or "New Section"

    -- Section本体
    local container = Instance.new("Frame")
    container.Name = "Section"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = COLORS.Background
    container.BorderSizePixel = 0
    container.LayoutOrder = #tab.Sections + 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = container

    -- Section内部レイアウト
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = container

    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = self.Name
    title.TextColor3 = COLORS.Title
    title.TextSize = 14
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.Parent = container

    -- コンポーネント配置領域
    local content = Instance.new("Frame")
    content.Name = "Components"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.LayoutOrder = 2
    content.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = content

    -- 参照を保存
    self.Container = container
    self.Title = title
    self.Content = content

    container.Parent = tab.Page

    table.insert(tab.Sections, self)

    return self
end

-- Button生成
function Section:CreateButton(options)
    assert(
        not self.Destroyed,
        "[NEXUS UI] Cannot create a button inside a destroyed section."
    )

    options = options or {}

    assert(
        type(options) == "table",
        "[NEXUS UI] Button options must be a table."
    )

    self.Components = self.Components or {}

    -- 表示順を設定
    if options.LayoutOrder == nil then
        options.LayoutOrder = #self.Components + 1
    end

    local button = Button.new(self, options)

    table.insert(self.Components, button)

    return button
end

-- Section削除
function Section:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    local tab = self.Tab

    local index = table.find(tab.Sections, self)

if index then
    table.remove(tab.Sections, index)

    -- Sectionの表示順を再整理
    for order, section in ipairs(tab.Sections) do
        if section.Container then
            section.Container.LayoutOrder = order
        end
    end
end

    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Section
