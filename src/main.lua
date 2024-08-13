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

local main = {}

function main:load(args)
    self.args = args
    self:setupArgs()
    self:setupPaths()
    self:setupLogging()
    self:logEverything()
    self:startExtration()
end

function main:setupArgs()
    self.iwad_filename = self.args[1]
    self.pwad_filename = self.args[2]
    self.acronym = self.args[3]
    self.verbose = self.args[4]
    self.acronym_sprites = self.args[5]
    self.things = self.args[6]
    self.patches = self.args[7]
    utils.verbose = tonumber(self.verbose)
end

function main:setupPaths()
    self.app_path = love.filesystem.getSourceBaseDirectory()
    self.pk3_path = self.app_path ..  "/pk3"
    self.tools_path = self.app_path .. "/tools"
    self.iwad_path = self.app_path .. "/" .. self.iwad_filename
    self.pwad_path = self.app_path .. "/" .. self.pwad_filename

    self.date = os.date("%c")
    self.date = self.date:gsub(" ", "_")
    self.date = self.date:gsub(":", "-")
    self.date = self.date:gsub("/", "-")
    self.log_path = self.app_path .. string.format("/logs/%s_%s.txt", self.pwad_filename, self.date)
end

function main:setupLogging()
	utils.log_file = utils:openFile(self.log_path, "w")
end

function main:logEverything()
    utils:printf(0, "Options: ")
    utils:printf(0, "\tIWAD Filename: %s", tostring(self.iwad_filename))
    utils:printf(0, "\tPWAD Filename: %s", tostring(self.pwad_filename))
    utils:printf(0, "\tAcronym: %s", tostring(self.acronym))
    utils:printf(0, "\tVerbose: %s", tostring(self.verbose))
    utils:printf(0, "\tAcronym Sprites: %s", tostring(self.acronym_sprites))
    utils:printf(0, "\tThings: %s", tostring(self.things))
    utils:printf(0, "\tPatches: %s", tostring(self.patches))
    utils:printf(0, "")
    utils:printf(0, "Paths: ")
    utils:printf(0, "\tApp Path: %s", tostring(self.app_path))
    utils:printf(0, "\tPK3 Path: %s", tostring(self.pk3_path))
    utils:printf(0, "\tTools Path: %s", tostring(self.tools_path))
    utils:printf(0, "\tIWAD Path: %s", tostring(self.iwad_path))
    utils:printf(0, "\tPWAD Path: %s", tostring(self.pwad_path))
    utils:printf(0, "\tLog Path: %s", tostring(self.log_path))
end

function main:getPWADPalette()
    local file = utils:openFile(self.pwad_path, "rb")
    local raw = file:read("*all")
    file:close()
    local magic, lumpcount, dirpos = love.data.unpack("<c4i4i4", raw, 1)

    lumpcount = lumpcount - 1
    dirpos = dirpos + 1

    if not utils:checkFormat(raw, "IWAD") and not utils:checkFormat(raw, "PWAD") then
        error("File is not a valid wad file, expected IWAD or PWAD, got: " .. magic)
    end

    local palette = nil
    for lump = 0, lumpcount do
        local filepos, size, name = love.data.unpack("<i4i4c8", raw, dirpos + (lump * 16))
        if utils:removePadding(name) == "PLAYPAL" then
            palette = {}
            local data = love.data.unpack(string.format("<c%d", size), raw, filepos + 1)
            for c = 1, 256 * 3, 3 do
                local r, g, b = love.data.unpack("<BBB", data, c)
                local index = #palette + 1
                local r2, g2, b2 = love.math.colorFromBytes(r, g, b, 255)
                palette[index] = {r2,g2,b2}
            end
        end
    end

    return palette
end

function main:startExtration()
    self.palette = self:getPWADPalette(self.pwad_path)
    self.mainiwad = wad(self.iwad_path, self.palette)
    self.mapset = wad(self.pwad_path, self.palette, self.acronym, self.patches, self.mainiwad, self.pk3_path, self.toolspath, self.sprites, self.acronym_sprites, self.things)
end

function love.load(args)
	love.graphics.setFont(love.graphics.newFont(50))
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

    ffi = require('ffi')
    class = require("mod30log")
    utils = require("utils")
    stringbuilder = require("stringbuilder")
    otex = require("otex")
    wad = require("clsWad")

    main:load(args)
end

function love.update(dt)

end

function love.draw()
    
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




