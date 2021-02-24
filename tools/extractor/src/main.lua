
log = {}
startTime = 0;
endTime = 0;

function love.load(arg)

-------------------------------------------------
    startTime = os.time()

	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

	console = require("console")
    class = require("mod30log")
    wad = require("clsWad")

    -- some stuff
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath:sub(1, -16) .. "pk3"
    local toolspath = apppath .. "/tools"
    local doom2 = wad(apppath .. "/doom2_lex.wad")

    ---------- edit these!-----------
    local acronym = "D2RL"
    local pwad = apppath .. "/d2reload_lex.wad"

    ------------------------------------------------------------------------------------------
	-- love2d doesnt allow us to read outside it's save and root dirs, lets bypass that
	local ffi = require('ffi')
	local l = ffi.os == 'Windows' and ffi.load('love') or ffi.C

	ffi.cdef [[int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);]]
	l.PHYSFS_mount(string.format("%s/maps", pk3path), 'maps', 1)
	l.PHYSFS_mount(string.format("%s/textures", pk3path), 'textures', 1)
	l.PHYSFS_mount(string.format("%s/flats", pk3path), 'flats', 1)
	l.PHYSFS_mount(string.format("%s/patches", pk3path), 'patches', 1)
	-----------------------------------------

    -- do all the things
    mapset = wad(pwad, acronym, true, doom2, pk3path, toolspath, sprites)

    endTime = os.time();
end


function love.update(dt)
end


function love.draw()
    local timeTaken = os.difftime(endTime, startTime)

    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Complete", 10, 10)
	love.graphics.print(string.format("Time taken: %d seconds.", timeTaken), 10, 60)
end








