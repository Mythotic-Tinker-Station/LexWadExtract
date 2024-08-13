

local ui = {}

function ui:init()


end

function ui:draw()
    self:button(10, 10, 100, 50, function() print("Button clicked!") end)
end

function ui:update(dt)
    
end

function ui:button(x, y, w, h, func, ...)
    local mx, my = love.mouse.getPosition()
    local clicked = love.mouse.isDown(1)
    if mx > x and mx < x + w and my > y and my < y + h then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 1, 1)
        if clicked then
            func(...)
        end
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 1, 1)
    end
end

return ui