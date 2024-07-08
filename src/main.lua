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

function love.load(arg)
    class = require("mod30log")
    utils = require("utils")
    wad = require("clsWad")

    -- path stuff
    local apppath = love.filesystem.getSourceBaseDirectory()
    local pk3path = apppath ..  "/pk3"
    local toolspath = apppath .. "/tools"
    
	-- start logging
    local date = os.date("%c")
    date = date:gsub(" ", "_")
    date = date:gsub(":", "-")
    date = date:gsub("/", "-")
	local logpath = apppath .. string.format("/logs/%s_%s.txt", arg[1], date)
    print("Log path: " .. logpath)
	logfile = io.open(logpath, "w+")
-------------------------------------------------
    local startTime = os.time()

	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

    -- these are global because apparently the class library i use only allows 10 args for a method

    -- get command line args
    local iwad = apppath .. "/" .. arg[1]
    local pwad = apppath .. "/" .. arg[2]
    local acronym = arg[3]
    local verbose = arg[4]
    local acronym_sprites = arg[5]
    local things = arg[6]
    local patches = arg[7]

    utils:printf(0, "Options: ")
    utils:printf(0, "\tiwad: %s", tostring(iwad))
    utils:printf(0, "\tpwad: %s", tostring(pwad))
    utils:printf(0, "\tacronym: %s", tostring(acronym))
    utils:printf(0, "\tverbose: %s", tostring(verbose))
    utils:printf(0, "\tacronym_sprites: %s", tostring(acronym_sprites))
    utils:printf(0, "\tthings: %s", tostring(things))
    utils:printf(0, "\tpatches: %s", tostring(patches))

    utils.verbose = tonumber(verbose)
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
        if(utils:removePadding(name) == "PLAYPAL") then
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

	-- read iwad
    local mainiwad = wad(iwad, palette)

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
    mapset = wad(pwad, palette, acronym, patches, mainiwad, pk3path, toolspath, sprites, acronym_sprites, things)

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

----------------------------------------------------------------------------------------
-- Error handling
-- this is love2d's default error handler, modified to write to a log file
----------------------------------------------------------------------------------------
local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

    logfile:write(p)
    logfile:close()
	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end




