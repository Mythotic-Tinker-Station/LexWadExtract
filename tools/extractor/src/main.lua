
log = {}

function love.load(arg)

-------------------------------------------------

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
    local acronym = "MAYH"
    local pwad = apppath .. "/mayhem_17_lex.wad"

    ------------------------------------------------------------------------------------------
	-- love2d doesnt allow us to read outside it's save and root dirs, lets bypass that
	local ffi = require('ffi')
	local l = ffi.os == 'Windows' and ffi.load('love') or ffi.C

	ffi.cdef [[int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);]]
	l.PHYSFS_mount(string.format("%s/maps", pk3path), 'maps', 1)
	-----------------------------------------

    -- do all the things
    mapset = wad(pwad, acronym, true, doom2, pk3path, toolspath, sprites)

end


function love.update(dt)
	log[#log+1] = love.thread.getChannel('info'):pop()
	local error = thread:getError()
    assert( not error, error )
end


function love.draw()
	local logcount = 0
	for i = #log, 32, -1 do
		if log[i] ~= nil then
			logcount = logcount + 1
			love.graphics.print(log[i], 10, 10-(logcount*12))
		end
	end

    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Complete", 10, 10)
end








