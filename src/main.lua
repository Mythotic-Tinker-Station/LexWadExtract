
log = {}
timeTaken = ""

function removePadding(str)
	local newstr = ""
	for i = 1, #str do
		if str:sub(i,i) == "\0" then break end
		newstr = string.format("%s%s", newstr, str:sub(i,i))
	end
	return newstr
end

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

    -- get command line args
    local acronym = arg[2]
    local pwad = apppath .. "/" .. arg[1]
    local verbose = arg[3]
    local acronym_sprites = arg[4]
    local palette = nil

    -- get pawd palette
    local file = assert(io.open(pwad, "rb"))
	local raw = file:read("*all")
	file:close()
    local magic, lumpcount, dirpos = love.data.unpack("<c4i4i4", raw, 1)

	lumpcount = lumpcount-1
	dirpos = dirpos+1

	if(magic ~= "IWAD" and magic ~= "PWAD") then error("File is not a valid wad file, expected IWAD or PWAD, got: " .. magic) end

    for lump = 0, lumpcount do
        local filepos, size, name = love.data.unpack("<i4i4c8", raw, dirpos+(lump*16))
        if(removePadding(name) == "PLAYPAL") then
            palette = {}
            local data = love.data.unpack(string.format("<c%d", size), raw, filepos+1)
            for c = 1, 256*3, 3 do
                local r, g, b = love.data.unpack("<BBB", data, c)
                local index = #palette+1
                local r2, g2, b2 = love.math.colorFromBytes(r, g, b, 255)
                palette[index] =
                {
                    r2,
                    g2,
                    b2,
                }
            end
        end
    end


	-- read doom2.wad
    local doom2 = wad(verbose, apppath .. "/doom2.wad", palette)

    ------------------------------------------------------------------------------------------
	-- love2d doesnt allow us to read outside it's save and root dirs, lets bypass that
	local ffi = require('ffi')
	local l = ffi.os == 'Windows' and ffi.load('love') or ffi.C

	ffi.cdef "int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);"
	l.PHYSFS_mount(string.format("%s/maps", pk3path), 'maps', 1)
	l.PHYSFS_mount(string.format("%s/textures", pk3path), 'textures', 1)
	l.PHYSFS_mount(string.format("%s/flats", pk3path), 'flats', 1)
	l.PHYSFS_mount(string.format("%s/patches", pk3path), 'patches', 1)
    l.PHYSFS_mount(string.format("%s/sprites", pk3path), 'sprites', 1)
	-----------------------------------------

    -- do all the things
    mapset = wad(verbose, pwad, palette, acronym, true, doom2, pk3path, toolspath, sprites, acronym_sprites, arg[5])

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
    love.window.close()
    love.event.quit()
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






