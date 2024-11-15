local UI = {inputTimer = 0.1, resetTimer = 0.1}

-- Global UI settings
UI.font = love.graphics.newFont(12)
UI.defaultColor = { r = 1, g = 1, b = 1, a = 1 }
UI.hoverColor = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
UI.clickColor = { r = 0.6, g = 0.6, b = 0.6, a = 1 }
UI.elements = {}

-- UI Event Manager
UI.events = {}
function UI.on(event, callback)
    UI.events[event] = UI.events[event] or {}
    table.insert(UI.events[event], callback)
end

function UI.trigger(event, ...)
    if UI.events[event] then
        for _, callback in ipairs(UI.events[event]) do
            callback(...)
        end
    end
end

-- Utility for setting color
function UI.setColor(color)
    love.graphics.setColor(color.r, color.g, color.b, color.a)
end

-- Debounce function
function UI:canInteract(dt)
    if self.inputTimer <= 0 then
        self.inputTimer = self.resetTimer
        return true
    else
        self.inputTimer = self.inputTimer - dt
        return false
    end
end

--#region Base UI Element
local Element = {}
Element.__index = Element

function Element:new(x, y, width, height)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        width = width or 100,
        height = height or 30,
        visible = true,
        hovered = false
    }, self)
end

function Element:draw() end

function Element:update() end

function Element:isHovered()
    local mx, my = love.mouse.getPosition()
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

-- Add Element to UI
function UI.addElement(element)
    table.insert(UI.elements, element)
end

--#endregion

--#region Button
local Button = setmetatable({}, { __index = Element })
Button.__index = Button

function Button:new(text, x, y, width, height, onClick)
    local btn = Element.new(self, x, y, width, height)
    btn.text = text or "Button"
    btn.onClick = onClick or function() end
    return btn
end

function Button:draw()
    local color = self.isClicked and UI.clickColor or (self.hovered and UI.hoverColor or UI.defaultColor)
    UI.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setFont(UI.font)
    UI.setColor({ r = 0, g = 0, b = 0, a = 1 })
    love.graphics.print(self.text, self.x + 5, self.y + 5)
end

function Button:update(dt)
    self.hovered = self:isHovered()
    if love.mouse.isDown(1) and self.hovered and UI:canInteract(dt) then
        self.onClick()
    end
end

UI.Button = Button
--#endregion

--#region Toggle
local Toggle = setmetatable({}, { __index = Element })
Toggle.__index = Toggle

function Toggle:new(x, y, width, height, initialState, onToggle)
    local toggle = Element.new(self, x, y, width, height)
    toggle.state = initialState or false
    toggle.onToggle = onToggle or function() end
    return toggle
end

function Toggle:draw()
    UI.setColor(self.state and UI.clickColor or UI.defaultColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    UI.setColor({ r = 0, g = 0, b = 0, a = 1 })
    love.graphics.print(self.state and "On" or "Off", self.x + 5, self.y + 5)
end

function Toggle:update(dt)
    if love.mouse.isDown(1) and self:isHovered() and UI:canInteract(dt) then
        self.state = not self.state
        self.onToggle(self.state)
    end
end

UI.Toggle = Toggle
--#endregion

--#region TextInput
local TextInput = setmetatable({}, { __index = Element })
TextInput.__index = TextInput

function TextInput:new(x, y, width, placeholder, onEnter)
    local txt = Element.new(self, x, y, width, 25)
    txt.text = ""
    txt.placeholder = placeholder or "Enter text..."
    txt.active = false
    txt.onEnter = onEnter or function() end
    return txt
end

function TextInput:draw()
    UI.setColor(self.active and UI.hoverColor or UI.defaultColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    UI.setColor({ r = 0, g = 0, b = 0, a = 1 })
    love.graphics.print(self.text == "" and self.placeholder or self.text, self.x + 5, self.y + 5)
end

function TextInput:update(dt)
    if love.mouse.isDown(1) and self:isHovered() and UI:canInteract(dt) then
        self.active = not self.active
    end
end

function TextInput:textinput(t)
    if self.active then
        self.text = self.text .. t
    end
end

function TextInput:keypressed(key)
    if self.active and key == "return" then
        self.onEnter(self.text)
    elseif self.active and key == "backspace" then
        self.text = self.text:sub(1, -2)
    end
end

UI.TextInput = TextInput
--#endregion

--#region Dropdown Menu
local Dropdown = setmetatable({}, { __index = Element })
Dropdown.__index = Dropdown

function Dropdown:new(x, y, width, options)
    local dropdown = Element.new(self, x, y, width, #options * 20)
    dropdown.options = options or {}
    dropdown.selected = nil
    dropdown.open = false
    return dropdown
end

function Dropdown:draw()
    UI.setColor(UI.defaultColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, 20)
    love.graphics.print(self.selected or "Select...", self.x + 5, self.y + 5)
    if self.open then
        for i, option in ipairs(self.options) do
            love.graphics.rectangle("fill", self.x, self.y + 20 * i, self.width, 20)
            love.graphics.print(option, self.x + 5, self.y + 20 * i + 5)
        end
    end
end

function Dropdown:update(dt)
    if love.mouse.isDown(1) and self:isHovered() and UI:canInteract(dt) then
        self.open = not self.open
    elseif love.mouse.isDown(1) and not self:isHovered() and UI:canInteract(dt) then
        self.open = false
    end
end

UI.Dropdown = Dropdown
--#endregion

--#region Tab Menu
local TabMenu = {}
TabMenu.__index = TabMenu

function TabMenu:new(tabs)
    local menu = setmetatable({ tabs = tabs, activeTab = 1 }, self)
    return menu
end

function TabMenu:draw()
    for i, tab in ipairs(self.tabs) do
        UI.setColor(i == self.activeTab and UI.hoverColor or UI.defaultColor)
        love.graphics.rectangle("fill", 100 * (i - 1), 0, 100, 30)
        love.graphics.print(tab.name, 100 * (i - 1) + 5, 5)
    end
end

function TabMenu:update()
    if love.mouse.isDown(1) then
        for i = 1, #self.tabs do
            if UI.elements[i]:isHovered() then
                self.activeTab = i
            end
        end
    end
end

UI.TabMenu = TabMenu
--#endregion

return UI
