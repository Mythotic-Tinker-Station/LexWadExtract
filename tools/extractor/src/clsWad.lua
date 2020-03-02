
local wad = class("wad",
{
	-- class variables
	verbose = 0,
	texturecount = 0,
	acronym = "DOOM",
	base = false,

	lumps = {},
	header = {},
	metadata = {},
	palette = {},
	pnames = {},
	composites = {},
	textures = {},
	flats = {},
	patches = {},
	graphics = {},
	sounds = {},
	songs = {},
	maps = {},
	dups = {},
	doomdups = {},

	-- namespaces
	namespaces =
	{
		["SP"] =
		{
			name = "spacials",
			lumps = {},
		},
		["DS"] =
		{
			name = "sounds",
			lumps = {},
		},
		["MS"] =
		{
			name = "songs",
			lumps = {},
		},
		["GF"] =
		{
			name = "graphics",
			lumps = {},
		},
		["TX"] =
		{
			name = "textures",
			lumps = {},
		},
		["PP"] =
		{
			name = "patches",
			lumps = {},
		},
		["FF"] =
		{
			name = "flats",
			lumps = {},
		},
		["SS"] =
		{
			name = "sprites",
			lumps = {},
		},
		["MP"] =
		{
			name = "maps",
			lumps = {},
			maps = {},
		},
	}
})



---------------------------------------------------------
-- Main Functions
---------------------------------------------------------
function wad:init(path, acronym, base)

	self.base = base or self
	self.acronym = acronym

	self:printf(0, "------------------------------------------------------------------------------------------\n")
	self:printf(0, "Loading Wad '%s'...", path)
	self:open(path)

	self:printf(0, "Gathering Header...")
	self:gatherHeader()

	self:printf(0, "Processing Lexinizer Data...")
	self:checkMetadata()

	self:printf(0, "Gathering Namespaces...")
	self:buildNamespaces()

	self:printf(0, "Organizing Zdoom Textures...")
	self:organizeNamespace("TX")

	self:printf(0, "Organizing Flats...")
	self:organizeNamespace("FF")

	self:printf(0, "Organizing Patches...")
	self:organizeNamespace("PP")

	self:printf(0, "Organizing Graphics...")
	self:organizeNamespace("GF")

	self:printf(0, "Organizing Sounds...")
	self:organizeNamespace("DS")

	self:printf(0, "Organizing Music...")
	self:organizeNamespace("MS")

	self:printf(0, "Organizing Maps...")
	self:organizeMaps()

	self:printf(0, "Processing Palette...")
	self:processPalette()

	self:printf(0, "Building Patches...")
	self:buildPatches()

	self:printf(0, "Building Flats...")
	self:buildFlats()

	self:printf(0, "Processing PNAMES...")
	self:processPnames()

	self:printf(0, "Processing TEXTUREx...")
	self:processTexturesX(1)
	self:processTexturesX(2)
	self:printf(1, "\tDone.\n")

	self:printf(0, "Filtering Duplicates...")
	self:filterDuplicates()

	self:printf(0, "Moving Flats to Textures...")
	self:moveFlats()

	self:printf(0, "Rename Textures...")
	self:renameTextures()

	self:printf(0, "Processing Maps...")
	self:processMaps()

	self:printf(0, "Complete.\n")
	--self:printTable(self.metadata)]]
	collectgarbage()
end

function wad:open(path)
	local file = assert(io.open(path, "rb"))
	self.raw = file:read("*all")
	file:close()
	collectgarbage()
end

function wad:gatherHeader()
	self.header.magic, self.header.lumpcount, self.header.dirpos = love.data.unpack("<c4i4i4", self.raw, 1)

	-- dammit lua
	self.header.lumpcount = self.header.lumpcount-1
	self.header.dirpos = self.header.dirpos+1

	if(self.header.magic ~= "IWAD" and self.header.magic ~= "PWAD") then error("File is not a valid wad file, expected IWAD or PWAD, got: " .. self.header.magic) end

	local isbase = (self.base == self) and "true" or "false"
	collectgarbage()
	self:printf(1, "\tType: %s\n\tLumps: %d\n\tDirectory Position: 0x%X.\n\tBase: %s", self.header.magic, self.header.lumpcount, self.header.dirpos, isbase)
	self:printf(1, "\tDone.\n")
end

function wad:checkMetadata()

	local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+16)
	name = self:removePadding(name)
	local filedata = love.data.unpack(string.format("<c%d", size), self.raw, filepos)

	if(name ~= "METADATA") then
		error("Wad has not been Lexinized...Please run this wad through the slade lexinizer before extraction.")
	else
		for line in string.gmatch(filedata, "[^\n]+") do
			local index = #self.metadata+1
			local count = 1
			self.metadata[index] = {}
			for param in string.gmatch(line, "[^%^]+") do
				if(count == 1) then self.metadata[index].namespace = param end
				if(count == 2) then self.metadata[index].oldname = param end
				if(count == 3) then self.metadata[index].newname = param end
				if(count == 4) then self.metadata[index].id = param end
				if(count == 5) then self.metadata[index].name = param end
				if(count == 6) then self.metadata[index].ext = param end
				if(count == 7) then self.metadata[index].format = param end
				if(count == 8) then self.metadata[index].editor = param end
				if(count == 9) then self.metadata[index].category = param end
				count = count + 1
			end
		end
		self:printf(1, "\tDone.\n")
	end
	collectgarbage()
end

function wad:buildNamespaces()
	local found = false
	local namespace = ""

	for l = 0, self.header.lumpcount do

		-- get file meta data
		local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(l*16))
		name = self:removePadding(name)
		filepos = filepos+1

		-- get file data
		local filedata = love.data.unpack(string.format("<c%d", size), self.raw, filepos)

		-- end namespace
		if(name == string.format("%s_END", namespace)) then
			found = false
		end

		-- in namespace
		if(found) then
			if(self.namespaces[namespace] ~= nil) then
				self.namespaces[namespace].lumps[#self.namespaces[namespace].lumps+1] = { name=name, size=size, pos=filepos, data=filedata }
			end
		end

		-- start namespace
		if(name:sub(-6) == "_START" and not found) then
			namespace = name:sub(1, 2)
			found = true
		end
	end
	self:printf(1, "\tDone.\n")
	collectgarbage()
end

function wad:organizeNamespace(name)
	-- are there any textures?
	if(#self.namespaces[name].lumps > 0) then

		-- for each lump in the textures namespace
		for l = 1, #self.namespaces[name].lumps do
			local v = self.namespaces[name].lumps[l]
			local index = #self[self.namespaces[name].name]+1
			self[self.namespaces[name].name][index] = v
		end
		self:printf(1, "\tFound '%d' %s.", #self[self.namespaces[name].name], self.namespaces[name].name)
	else
		self:printf(1, "\tNo '%s' found.", self.namespaces[name].name)
	end
	collectgarbage()
	self:printf(1, "\tDone.\n")
end

function wad:organizeMaps()
	if(self.base ~= self) then
		local found = false
		local namespace = ""
		local mapname = ""
		local count_dm = 0
		local count_hm = 0
		local count_um = 0
		local index = 0

		-- if any maps were found
		if(#self.namespaces["MP"].lumps > 0) then

			-- for each lump in the maps namespace
			for l = 1, #self.namespaces["MP"].lumps do

				local v = self.namespaces["MP"].lumps[l]

				-- end namespace
				if(v.name == string.format("%s_END", namespace)) then
					self.maps[index].pos[2] = l
					found = false
				end

				-- start namespace
				if(v.name:sub(-6) == "_START" and not found) then
					found = true
					namespace = v.name:sub(1, 2)
					index = #self.maps+1
					self.maps[index] = {}
					self.maps[index].pos = {l}
					self.maps[index].format = namespace
					self.maps[index].name = self.namespaces["MP"].lumps[l+1].name
					self.maps[index].raw = {}
				end
			end

			-- structure map data
			for m = 1, #self.maps do
				for l = self.maps[m].pos[1], self.maps[m].pos[2] do
					if(self.namespaces["MP"].lumps[l].name == "THINGS") then 	self.maps[m].raw.things 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "LINEDEFS") then 	self.maps[m].raw.linedefs 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "SIDEDEFS") then 	self.maps[m].raw.sidedefs 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "VERTEXES") then 	self.maps[m].raw.vertexes 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "SEGS") then 		self.maps[m].raw.segs 			= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "SSECTORS") then 	self.maps[m].raw.ssectors 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "NODES") then 	self.maps[m].raw.nodes 			= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "SECTORS") then 	self.maps[m].raw.sectors 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "REJECT") then 	self.maps[m].raw.reject 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "BLOCKMAP") then 	self.maps[m].raw.blockmap 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "BEHAVIOR") then 	self.maps[m].raw.behavior		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "SCRIPTS") then 	self.maps[m].raw.scripts 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "TEXTMAP") then 	self.maps[m].raw.textmap 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "ZNODES") then 	self.maps[m].raw.znodes 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "DIALOGUE") then 	self.maps[m].raw.dialogue 		= self.namespaces["MP"].lumps[l].data end
					if(self.namespaces["MP"].lumps[l].name == "ENDMAP") then 	self.maps[m].raw.endmap 		= self.namespaces["MP"].lumps[l].data end
				end

				-- log stuff
				if(self.maps[m].raw.behavior == nil and self.maps[m].raw.textmap == nil) then
					count_dm = count_dm + 1
				else
					count_hm = count_hm + 1
				end

				if(self.maps[m].raw.textmap ~= nil) then
					count_um = count_um + 1
				end
			end

			self:printf(1, "\tDoom Maps: '%d' \n\tHexen Maps: '%d' \n\tUDMF Maps: '%d'", count_dm, count_hm, count_um)
		end
		collectgarbage()
	else
		self:printf(1, "\tNot organizing base wad maps.")
	end
	collectgarbage()
	self:printf(1, "\tDone.\n")
end

function wad:processPalette()
	-- find PLAYPAL
	local paldata = ""
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == "PLAYPAL") then
			paldata = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if playpal found
	if(paldata ~= "") then
		for c = 1, 256*3, 3 do
			local r, g, b = love.data.unpack("<BBB", paldata, c)
			local index = #self.palette+1
			local r2, g2, b2 = love.math.colorFromBytes(r, g, b, 255)
			self.palette[index] =
			{
				r2,
				g2,
				b2,
			}
		end
	else
		self.palette = self.base.palette
		self:printf(1, "\tNo PLAYPAL found. using base wad PLAYPAL.")
	end
	collectgarbage()
	self:printf(1, "\tDone.\n")
end

function wad:processPnames()

	-- find PNAMES
	local pndata = ""
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == "PNAMES") then
			pndata = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if PNAMES found
	if(pndata ~= "") then

		local count = love.data.unpack("<L", pndata)
		for p = 5, count*8, 8 do
			local index = #self.pnames+1
			self.pnames[index] = self:removePadding(love.data.unpack("<c8", pndata, p)):upper()
		end
		self:printf(1, "\tFound '%d' patches.", #self.pnames)
	else
		self.pnames = self.base.pnames
		self:printf(1, "\tNo PNAMES found. Using base wad PNAMES.")
	end
	collectgarbage()
	self:printf(1, "\tDone.\n")
end

function wad:buildPatches()

	for p = 1, #self.patches do

		self.patches[p].width = love.data.unpack("<H", self.patches[p].data)
		self.patches[p].height = love.data.unpack("<H", self.patches[p].data, 3)
		self.patches[p].xoffset = love.data.unpack("<h", self.patches[p].data, 5)
		self.patches[p].yoffset = love.data.unpack("<h", self.patches[p].data, 7)
		self.patches[p].imagedata = love.image.newImageData(self.patches[p].width, self.patches[p].height)
		self.patches[p].columns = {}

		for c = 1, self.patches[p].width do

			self.patches[p].columns[c] = love.data.unpack("<L", self.patches[p].data, 9+((c-1)*4))

			local topdelta = 0
			local post = self.patches[p].columns[c]+1

			while(topdelta ~= 0xFF) do

				local topdelta_prev = topdelta

				topdelta = love.data.unpack("<B", self.patches[p].data, post)
				if(topdelta == 0xFF) then break end

				-- tall patches
				if(topdelta <= topdelta_prev) then
					topdelta = topdelta+topdelta_prev
				end

				local length = love.data.unpack("<B", self.patches[p].data, post+1)
				local data = self.patches[p].data:sub(post+3, post+3+length)

				for pixel = 1, length do
					local color = love.data.unpack("<B", data, pixel)+1
					self.patches[p].imagedata:setPixel(c-1, topdelta+pixel-1, self.palette[color][1], self.palette[color][2], self.palette[color][3], 1.0)
				end

				post = post+4+length
			end
		end

		self.patches[p].image = love.graphics.newImage(self.patches[p].imagedata)

		self.patches[self.patches[p].name] = self.patches[p]
	end
	collectgarbage()
	self:printf(1, "\tDone.\n")
end


function wad:buildFlats()

	for f = 1, #self.flats do
		self.flats[f].image = love.image.newImageData(64, 64)
		self.flats[f].rows = {}

		local pcount = 0
		for y = 1, 64 do
			for x = 1, 64 do
				pcount = pcount + 1
				local color = love.data.unpack("<B", self.flats[f].data, pcount)+1
				self.flats[f].image:setPixel(x-1, y-1, self.palette[color][1], self.palette[color][2], self.palette[color][3], 1.0)
			end
		end

		self.flats[f].image = love.graphics.newImage(self.flats[f].image)
	end

	collectgarbage()
	self:printf(1, "\tDone.\n")
end


function wad:processTexturesX(num)
	-- find TEXTUREx
	local tdata = ""
	local lumpname = string.format("TEXTURE%d", num)
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == lumpname) then
			tdata = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if TEXTUREx found
	if(tdata ~= "") then

		-- header
		local numtextures = love.data.unpack("<l", tdata)+#self.composites
		self:printf(1, "\tFound '%d' textures.", numtextures)
		local offsets = {}
		for i = 5, numtextures*4, 4 do
			offsets[#offsets+1] = love.data.unpack("<l", tdata, i)+1
		end

		-- maptexture_t
		for i = 1, #offsets do
			local c = #self.composites+1
			self.composites[c] = {}
			self.composites[c].name = self:removePadding(love.data.unpack("<c8", tdata, offsets[i]))
			self.composites[c].flags = love.data.unpack("<H", tdata, offsets[i]+8)
			self.composites[c].scalex = love.data.unpack("<B", tdata, offsets[i]+0x0A)
			self.composites[c].scaley = love.data.unpack("<B", tdata, offsets[i]+0x0B)
			self.composites[c].width = love.data.unpack("<h", tdata, offsets[i]+0x0C)
			self.composites[c].height = love.data.unpack("<H", tdata, offsets[i]+0x0E)
			self.composites[c].unused1 = love.data.unpack("<B", tdata, offsets[i]+0x10)
			self.composites[c].unused2 = love.data.unpack("<B", tdata, offsets[i]+0x11)
			self.composites[c].unused3 = love.data.unpack("<B", tdata, offsets[i]+0x12)
			self.composites[c].unused4 = love.data.unpack("<B", tdata, offsets[i]+0x13)
			self.composites[c].patchcount = love.data.unpack("<h", tdata, offsets[i]+0x14)
			self.composites[c].patches = {}
			self.composites[c].canvas = love.graphics.newCanvas(self.composites[c].width, self.composites[c].height)
			self.composites[c].dups = {}
			self.composites[c].isdoomdup = false

			-- mappatch_t
			love.graphics.setCanvas(self.composites[c].canvas)
				for p = 1, self.composites[c].patchcount do
					self.composites[c].patches[p] = {}
					self.composites[c].patches[p].x = love.data.unpack("<h", tdata, offsets[i]+0x16+((p-1)*10))
					self.composites[c].patches[p].y = love.data.unpack("<h", tdata, offsets[i]+0x16+((p-1)*10)+2)
					self.composites[c].patches[p].patch = self.pnames[love.data.unpack("<h", tdata, offsets[i]+0x16+((p-1)*10)+4)+1]
					self.composites[c].patches[p].stepdir = love.data.unpack("<h", tdata, offsets[i]+0x16+((p-1)*10)+6)
					self.composites[c].patches[p].colormap = love.data.unpack("<h", tdata, offsets[i]+0x16+((p-1)*10)+8)

					if(self.patches[self.composites[c].patches[p].patch] == nil) then
						love.graphics.draw(self.base.patches[self.composites[c].patches[p].patch].image, self.composites[c].patches[p].x, self.composites[c].patches[p].y)
					else
						love.graphics.draw(self.patches[self.composites[c].patches[p].patch].image, self.composites[c].patches[p].x, self.composites[c].patches[p].y)
					end
				end
			love.graphics.setCanvas()

			self.composites[c].png = self.composites[c].canvas:newImageData():encode("png"):getString()
			self.composites[c].md5 = love.data.hash("md5", self.composites[c].png)

		end
	else
		--self.composites = self.base.composites
		self:printf(1, "\tNo %s found. using base wad %s", lumpname, lumpname)
	end
	collectgarbage()
end

function wad:moveFlats()
	if(self.base ~= self) then
		for f = 1, #self.flats do
			self.composites[#self.composites+1] = self.flats[f]
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot moving base wad flats.\n")
	end
	collectgarbage()
end

function wad:renameTextures()
	if(self.base ~= self) then

		for c = 1, #self.composites do
			self.texturecount = self.texturecount + 1
			self.composites[c].newname = string.format("%s%.4X", self.acronym, self.texturecount)
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot renaming base wad textures.\n")
	end
end

function wad:filterDuplicates()
	local count = 0

	-- filter dups from same wad
	for c = 1, #self.composites do
		for c2 = c, #self.composites do
			if(c ~= c2) then
				if(self.composites[c].md5 == self.composites[c2].md5) then
					count = count + 1
					if(self.composites[c].dups[self.composites[c].name] == nil) then self.composites[c].dups[self.composites[c].name] = {} end
					self.composites[c].dups[self.composites[c].name][#self.composites[c].dups[self.composites[c].name]+1] = self.composites[c2].name
				end
			end
		end
	end

	self:printf(1, "\tFound '%d' duplicates", count)
	count = 0
	-- filter dups from base wad
	if(self.base ~= self) then
		for c = 1, #self.composites do
			for c2 = 1, #self.base.composites do
				if(self.composites[c].md5 == self.base.composites[c2].md5) then
					count = count + 1
					self.composites[c].isdoomdup = true
				end
			end
		end
	end

	collectgarbage()
	self:printf(1, "\tFound '%d' doom duplicates", count)
	self:printf(1, "\tDone.\n")
end


function wad:processMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do
			if(self.maps[m].format == "DM" or self.maps[m].format == "HM") then

				-- sidedefs
				self.maps[m].sidedefs = {}
				local count = 0
				for s = 1, #self.maps[m].raw.sidedefs, 30 do
					count = count + 1
					self.maps[m].sidedefs[count] = {}
					self.maps[m].sidedefs[count].xoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s)
					self.maps[m].sidedefs[count].yoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s+2)
					self.maps[m].sidedefs[count].upper_texture = self:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+4))
					self.maps[m].sidedefs[count].lower_texture = self:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+12))
					self.maps[m].sidedefs[count].middle_texture = self:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+20))
					self.maps[m].sidedefs[count].sector = love.data.unpack("<H", self.maps[m].raw.sidedefs, s+28)
				end

				-- sectors
				self.maps[m].sectors = {}
				count = 0
				for s = 1, #self.maps[m].raw.sectors, 26 do
					count = count + 1
					self.maps[m].sectors[count] = {}
					self.maps[m].sectors[count].floor_height = love.data.unpack("<h", self.maps[m].raw.sectors, s)
					self.maps[m].sectors[count].ceiling_height = love.data.unpack("<h", self.maps[m].raw.sectors, s+2)
					self.maps[m].sectors[count].floor_texture = love.data.unpack("<c8", self.maps[m].raw.sectors, s+4)
					self.maps[m].sectors[count].ceiling_texture = love.data.unpack("<c8", self.maps[m].raw.sectors, s+12)
					self.maps[m].sectors[count].light = love.data.unpack("<h", self.maps[m].raw.sectors, s+20)
					self.maps[m].sectors[count].special = love.data.unpack("<H", self.maps[m].raw.sectors, s+22)
					self.maps[m].sectors[count].tag = love.data.unpack("<H", self.maps[m].raw.sectors, s+24)
				end

				-- find textures and rename
				for c = 1, #self.composites do
					if not self.composites[c].isdoomdup then
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.composites[c].name) then self.maps[m].sidedefs[s].upper_texture = self.composites[c].newname end
							if(self.maps[m].sidedefs[s].lower_texture == self.composites[c].name) then self.maps[m].sidedefs[s].lower_texture = self.composites[c].newname end
							if(self.maps[m].sidedefs[s].middle_texture == self.composites[c].name) then self.maps[m].sidedefs[s].middle_texture = self.composites[c].newname end
						end

						for s = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[s].floor_texture == self.composites[c].name) then self.maps[m].sectors[s].floor_texture = self.composites[c].newname end
							if(self.maps[m].sectors[s].ceiling_texture == self.composites[c].name) then self.maps[m].sectors[s].ceiling_texture = self.composites[c].newname end
						end
					end
				end
			else

			end
			collectgarbage()
		end
	else
		self:printf(1, "\tNot processing base wad maps.")
	end

	self:printf(1, "\tDone.\n")
end
    function printEx(msg, num)
        msg = msg
        love.thread.getChannel('info'):push(msg)
    end

---------------------------------------------------------
-- Helpers
---------------------------------------------------------
function wad:printf(verbose, ...)
	if(verbose <= self.verbose) then
		print(string.format(...))
	end
end

function wad:printTable(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if(type(v) == "table") then
			print(formatting)
			self:printTable(v, indent+1)
		elseif(type(v) == 'boolean') then
			print(formatting .. tostring(v))
		elseif(type(v) == "string" and #v > 50) then
			print(formatting .. tostring(k))
		else
			print(formatting .. v)
		end
	end
end

function wad:removePadding(str)
	local newstr = ""
	for i = 1, #str do
		if str:sub(i,i) == "\0" then break end
		newstr = string.format("%s%s", newstr, str:sub(i,i))
	end
	return newstr
end

function wad:addPadding(str)
	if #str >= 8 then return str end
	local newstr = str

	for i = #str+1, 8 do
		newstr = string.format("%s%s", newstr, "\0")
	end
	return newstr
end

function wad:findTexture(data, texture, tbl, pos)
	pos = pos or 1
	local correct = 0
	while(pos < #data-8) do
		correct = 0
		for n = 1, 8 do
			if(n <= #texture) then
				if(data:sub(pos+n, pos+n) == texture:sub(n, n)) then
					correct = correct + 1
				end
			else
				if(data:sub(pos+n, pos+n) == "\0") then
					correct = correct + 1
				end
			end
		end
		if(correct == 8) then
			tbl[#tbl+1] = pos
			pos = pos + 8
		end
		pos = pos + 1
	end
	return tbl
end

return wad











