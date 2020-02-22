
function love.load(arg)

    -- Zerobrane debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

    print(0/0)

    class               = require("mod30log")
    streamReader        = require("clsStreamReader")
    streamWriter        = require("clsStreamWriter")
    wad                 = require("modWad")

    local doom2 = wad("doom2.wad")

end

function love.update(dt)

end


