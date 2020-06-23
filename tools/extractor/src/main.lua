






-- lua cant create folders, which is kind of annoying

function love.load(arg)
    class = require("mod30log")
    wad = require("clsWad")
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath:sub(1, -16) .. "pk3"

    -- gather base wad
    doom2 = wad(apppath .. "/doom2_lex.wad")

    -- Filepath and acronym should be self explanitory
    -- Change patches to true to extract patches
    -- You shouldnt need to ever change base or pk3path


    --       wad(filepath                           acronym     patches      base       pk3path)
    mapset = wad(apppath .. "/chnworm_lex.wad",     "WORM",     false,      doom2,      pk3path)

end


function love.update(dt)

end

function love.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
end














