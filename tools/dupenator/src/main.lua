






-- lua cant create folders, which is kind of annoying

function love.load(arg)
    -- Zerobrane debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

    class = require("mod30log")
    wad = require("clsWad")

    love.graphics.setDefaultFilter("nearest", "nearest", 0)

    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath:sub(1, -16) .. "pk3"

end

function love.update(dt)

end

function love.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
end














