--[[
    Lexicon Wad Converter:
        MIT License:
            Copyright (c) 2024 The Mythotic Tinker Station

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.

    30log:
        https://github.com/Yonaba/30log
        Copyright (c) 2012-2016 Roland Yonaba
        See mod30log.lua for license information.

    Love2D:
        Website: https://love2d.org/
        License: zlib
        Copyright (c) 2006-2024 LOVE Development Team
        See https://love2d.org/wiki/License for license information.
--]]


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
    class = require("mod30log")
    wad = require("clsWad")

    -- path stuff
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath ..  "/pk3"
    local toolspath = apppath .. "/tools"
    
	-- start logging
	local logpath = apppath .. "/logs/extract.txt"
	logfile = io.open(logpath, "w+")
-------------------------------------------------
    local startTime = os.time()

	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

    -- these are global because apparently the class library i use only allows 10 args for a method

    -- get command line args
    local pwad = apppath .. "/" .. arg[1]
    local acronym = arg[2]
    local verbose = arg[3]
    local acronym_sprites = arg[4]
    local things = arg[5]
    local patches = arg[6]

    wad:printf(0, "Options: ")
    wad:printf(0, "\tpwad: %s", tostring(arg[i]))
    wad:printf(0, "\tacronym: %s", tostring(acronym))
    wad:printf(0, "\tverbose: %s", tostring(verbose))
    wad:printf(0, "\tacronym_sprites: %s", tostring(acronym_sprites))
    wad:printf(0, "\tthings: %s", tostring(things))
    wad:printf(0, "\tpatches: %s", tostring(patches))

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
    mapset = wad(verbose, pwad, palette, acronym, patches, doom2, pk3path, toolspath, sprites, acronym_sprites, things)

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






