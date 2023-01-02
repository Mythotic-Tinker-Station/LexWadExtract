
log = {}
timeTaken = ""

function love.load(arg)

    print(arg[1], arg[2])

-------------------------------------------------
    local startTime = os.time()

	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

    class = require("mod30log")
    wad = require("clsWad")

    -- some stuff
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath ..  "/pk3"
    local toolspath = apppath .. "/tools"

	-- start logging
	local logpath = apppath .. "/logs/extract.txt"
	logfile = io.open(logpath, "w+")

	-- read doom2.wad
    local doom2 = wad(apppath .. "/doom2.wad")

    -- get command line args
    local acronym = arg[2]
    local pwad = apppath .. "/" .. arg[1]

    ------------------------------------------------------------------------------------------
	-- love2d doesnt allow us to read outside it's save and root dirs, lets bypass that
	local ffi = require('ffi')
	local l = ffi.os == 'Windows' and ffi.load('love') or ffi.C

	ffi.cdef "int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);"
	l.PHYSFS_mount(string.format("%s/maps", pk3path), 'maps', 1)
	l.PHYSFS_mount(string.format("%s/textures", pk3path), 'textures', 1)
	l.PHYSFS_mount(string.format("%s/flats", pk3path), 'flats', 1)
	l.PHYSFS_mount(string.format("%s/patches", pk3path), 'patches', 1)
	-----------------------------------------

    -- do all the things
    mapset = wad(pwad, acronym, true, doom2, pk3path, toolspath, sprites)

    local endTime = os.time();

    local timeTaken_seconds = os.difftime(endTime, startTime)

    local minutes = 0
    if timeTaken_seconds >= 60 then
        minutes = math.floor(timeTaken_seconds / 60)
        local s = ternary(minutes ~= 1, "minutes", "minute")
        timeTaken = string.format("%d %s and ", minutes, s)
    end

    local seconds = timeTaken_seconds - (minutes * 60)
    local s = ternary(seconds ~= 1, "seconds", "second")
    timeTaken = timeTaken .. string.format("%d %s", seconds, s)

	logfile:close()

end


function love.update(dt)
end


function love.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Complete", 10, 10)
	love.graphics.print(string.format("Time taken:\n%s.", timeTaken), 10, 70)
end

function ternary(cond, T, F)
    if cond then return T else return F end
end






