--[[
    NEXUS UI
    Core / Tab.lua

    Original UI Framework
    Designed for Roblox Studio
]]

local Tab = {}
Tab.__index = Tab

local COLORS = {
    Active = Color3.fromRGB(65, 105, 180),
    Inactive = Color3.fromRGB(35, 39, 52),
    Hover = Color3.fromRGB(50, 57, 75),
    Text = Color3.fromRGB(240, 242, 255),
    MutedText = Color3.fromRGB(155, 162, 180),
    Page = Color3.fromRGB(24, 27, 36),
}

-- タブ選択
function Tab:Select()
    if self.Destroyed or self.Window.Destroyed then
        return
    end

    local window = self.Window

    window.ActiveTab = self

    for _, tab in ipairs(window.Tabs) do
        local selected = tab == self

        tab.Page.Visible = selected

        tab.Button.BackgroundColor3 =
            selected and COLORS.Active or COLORS.Inactive

        tab.Button.TextColor3 =
            selected and COLORS.Text or COLORS.MutedText
    end
end

-- タブ生成
function Tab.new(window, options)
    options = options or {}

    local self = setmetatable({}, Tab)

    self.Window = window
    self.Destroyed = false
    self.Name = options.Name or "New Tab"

    local mode = window.NavigationMode

    -- タブボタン
    local button = Instance.new("TextButton")
    button.Name = "TabButton"
    button.BackgroundColor3 = COLORS.Inactive
    button.BorderSizePixel = 0
    button.TextColor3 = COLORS.MutedText
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.Text = self.Name
    button.AutoButtonColor = false

    if mode == "Top" then
        button.Size = UDim2.fromOffset(110, 30)

    elseif mode == "Floating" then
        button.Size = UDim2.fromOffset(36, 36)
        button.Text = options.ShortName
            or string.sub(self.Name, 1, 1)

    else
        button.Size = UDim2.new(1, 0, 0, 34)
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Text = "  " .. self.Name
    end

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 7)
    buttonCorner.Parent = button

    -- ページ
    local page = Instance.new("Frame")
    page.Name = "TabPage"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundColor3 = COLORS.Page
    page.BorderSizePixel = 0
    page.Visible = false

    local pageCorner = Instance.new("UICorner")
    pageCorner.CornerRadius = UDim.new(0, 10)
    pageCorner.Parent = page

    -- 参照を保存
    self.Button = button
    self.Page = page

    button.Parent = window.Navigation
    page.Parent = window.TabContainer

    -- タブクリック
    window:_Connect(button.Activated, function()
        self:Select()
    end)

    table.insert(window.Tabs, self)

    -- 最初のタブを自動選択
    if #window.Tabs == 1 then
        self:Select()
    end

    return self
end

-- タブ削除
function Tab:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    local window = self.Window

    if self.Button then
        self.Button:Destroy()
        self.Button = nil
    end

    if self.Page then
        self.Page:Destroy()
        self.Page = nil
    end

    local index = table.find(window.Tabs, self)

    if index then
        table.remove(window.Tabs, index)
    end

    if window.ActiveTab == self then
        window.ActiveTab = nil

        local nextTab = window.Tabs[1]

        if nextTab then
            nextTab:Select()
        end
    end
end

return Tab
