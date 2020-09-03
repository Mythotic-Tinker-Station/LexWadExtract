






-- lua cant create folders, which is kind of annoying

function love.load(arg)

-------------------------------------------------

    class = require("mod30log")
    --xlat = require("xlat")
    wad = require("clsWad")
    love.graphics.setDefaultFilter("nearest", "nearest", 0)

    -- some stuff
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath:sub(1, -16) .. "pk3"
    local toolspath = apppath .. "/tools"
    local doom2 = wad(apppath .. "/doom2_lex.wad")

    ---------- edit these!-----------
    local acronym = "WORM"
    local pwad = apppath .. "/chnworm_lex.wad"

    ------------------------------------------------------------------------------------------
	-- love2d doesnt allow us to read outside it's save and root dirs, lets bypass that
	local ffi = require('ffi')
	local l = ffi.os == 'Windows' and ffi.load('love') or ffi.C

	ffi.cdef [[int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);]]
	l.PHYSFS_mount(string.format("%s/maps", pk3path), 'maps', 1)
	-----------------------------------------

    -- do all the things
    mapset = wad(pwad,     acronym,     false,      doom2,      pk3path,    toolspath)

end


function love.update(dt)

end

function love.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
end














