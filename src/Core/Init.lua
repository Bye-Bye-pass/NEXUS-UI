--[[
    NEXUS UI
    Core / Init.lua

    Original UI Framework
    Designed for Roblox Studio
]]

local Window = require(script.Parent.Window)

local Nexus = {}
Nexus.__index = Nexus

local DEFAULT_CONFIG = {
    Title = "NEXUS UI",
    Theme = "Glass",
    Navigation = "Sidebar",
}

-- 初期化
function Nexus.new(config)
    config = config or {}

    assert(
        type(config) == "table",
        "[NEXUS UI] Config must be a table."
    )

    local self = setmetatable({}, Nexus)

    self.Config = table.clone(DEFAULT_CONFIG)

    -- ユーザー設定を反映
    for key, value in pairs(config) do
        self.Config[key] = value
    end

    self.Windows = {}
    self.Destroyed = false

    return self
end

-- ウィンドウを作成
function Nexus:CreateWindow(options)
    assert(
        not self.Destroyed,
        "[NEXUS UI] Cannot create a window after destruction."
    )

    options = options or {}

    assert(
        type(options) == "table",
        "[NEXUS UI] Window options must be a table."
    )

    local window = Window.new(self, options)

    table.insert(self.Windows, window)

    return window
end

-- 現在のウィンドウ一覧を取得
function Nexus:GetWindows()
    return table.clone(self.Windows)
end

-- テーマを変更
function Nexus:SetTheme(theme)
    assert(
        type(theme) == "string",
        "[NEXUS UI] Theme must be a string."
    )

    self.Config.Theme = theme
end

-- ライブラリを破棄
function Nexus:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    for _, window in ipairs(self.Windows) do
        if window.Destroy then
            window:Destroy()
        end
    end

    table.clear(self.Windows)
end

return Nexus
