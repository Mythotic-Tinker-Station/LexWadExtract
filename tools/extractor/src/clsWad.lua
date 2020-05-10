
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
	animdefs = {},
	switchlist =
	{
		{"SW1BRCOM", 	"SW2BRCOM"},
		{"SW1BRN1",		"SW2BRN1"},
		{"SW1BRN2",		"SW2BRN2"},
		{"SW1BRNGN", 	"SW2BRNGN"},
		{"SW1BROWN", 	"SW2BROWN"},
		{"SW1COMM",		"SW2COMM"},
		{"SW1COMP",		"SW2COMP"},
		{"SW1DIRT",		"SW2DIRT"},
		{"SW1EXIT",		"SW2EXIT"},
		{"SW1GRAY",		"SW2GRAY"},
		{"SW1GRAY1", 	"SW2GRAY1"},
		{"SW1METAL", 	"SW2METAL"},
		{"SW1PIPE",		"SW2PIPE"},
		{"SW1SLAD",		"SW2SLAD"},
		{"SW1STARG", 	"SW2STARG"},
		{"SW1STON1", 	"SW2STON1"},
		{"SW1STON2", 	"SW2STON2"},
		{"SW1STONE", 	"SW2STONE"},
		{"SW1STRTN", 	"SW2STRTN"},
		{"SW1BLUE",		"SW2BLUE"},
		{"SW1CMT",		"SW2CMT"},
		{"SW1GARG",		"SW2GARG"},
		{"SW1GSTON", 	"SW2GSTON"},
		{"SW1HOT",		"SW2HOT"},
		{"SW1LION",		"SW2LION"},
		{"SW1SATYR", 	"SW2SATYR"},
		{"SW1SKIN",		"SW2SKIN"},
		{"SW1VINE",		"SW2VINE"},
		{"SW1WOOD",		"SW2WOOD"},
		{"SW1PANEL", 	"SW2PANEL"},
		{"SW1ROCK",		"SW2ROCK"},
		{"SW1MET2",		"SW2MET2"},
		{"SW1WDMET", 	"SW2WDMET"},
		{"SW1BRIK",		"SW2BRIK"},
		{"SW1MOD1",		"SW2MOD1"},
		{"SW1ZIM",		"SW2ZIM"},
		{"SW1STON6", 	"SW2STON6"},
		{"SW1TEK",		"SW2TEK"},
		{"SW1MARB",		"SW2MARB"},
		{"SW1SKULL", 	"SW2SKULL"},
	},
	animlist =
	{
		{"flat",	"BLOOD1",		"BLOOD3"},
		{"flat",	"FWATER1",		"FWATER4"},
		{"flat",	"LAVA1",		"LAVA4"},
		{"flat",	"NUKAGE1",		"NUKAGE3"},
		{"flat",	"RROCK05",		"RROCK08"},
		{"flat",	"SLIME01",		"SLIME04"},
		{"flat",	"SLIME05",		"SLIME08"},
		{"flat",	"SLIME09",		"SLIME12"},
		{"flat",	"SWATER1",		"SWATER4"},
		{"texture",	"BFALL1",		"BFALL4"},
		{"texture",	"BLODGR1",		"BLODGR4", 	"allowdecals"},
		{"texture",	"BLODRIP1",		"BLODRIP4", "allowdecals"},
		{"texture",	"DBRAIN1",		"DBRAIN4"},
		{"texture",	"FIREBLU1",		"FIREBLU2"},
		{"texture",	"FIRELAV3",		"FIRELAVA"},
		{"texture",	"FIREMAG1",		"FIREMAG3"},
		{"texture",	"FIREWALA",		"FIREWALL"},
		{"texture",	"GSTFONT1",		"GSTFONT3", "allowdecals"},
		{"texture",	"ROCKRED1",		"ROCKRED3", "allowdecals"},
		{"texture",	"SFALL1",		"SFALL4"},
		{"texture",	"SLADRIP1",		"SLADRIP3", "allowdecals"},
		{"texture",	"WFALL1",		"WFALL4"},
	},

	ignorelist =
	{
		"F_SKY1",
	},

	-- namespaces
	namespaces =
	{
		["SP"] =
		{
			name = "specials",
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
		["MM"] =
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
function wad:init(path, acronym, base, pk3path)

	self.base = base or self
	self.acronym = acronym
	self.pk3path = pk3path

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

	self:printf(0, "Processing Boom Animations...")
	self:processAnimated()

	self:printf(0, "Processing Boom Switches...")
	self:processSwitches()

	self:printf(0, "Processing Patches...")
	self:buildPatches()

	self:printf(0, "Processing Flats...")
	self:buildFlats()

	self:printf(0, "Processing PNAMES...")
	self:processPnames()

	self:printf(0, "Processing TEXTUREx...")
	self:processTexturesX(1)
	self:processTexturesX(2)
	self:printf(1, "\tDone.\n")

	self:printf(0, "Processing Zdoom Textures...")
	self:moveZDoomTextures()

	self:printf(0, "Processing Duplicates...")
	self:filterDuplicates()

	self:printf(0, "Rename Flats...")
	self:renameFlats()

	self:printf(0, "Rename Composites...")
	self:renameTextures()

	self:printf(0, "Rename Patches...")
	self:renamePatches()

	self:printf(0, "Processing ANIMDEFS...")
	self.animdefs.original = self:processTextLump("ANIMDEFS")

	self:printf(0, "Processing TEXTURES...")
	self.textures.original = self:processTextLump("TEXTURES")

	self:printf(0, "Processing ANIMDEFS for Doom/Boom...")
	self:buildAnimdefs()

	self:printf(0, "Processing Maps...")
	self:processMaps()

	self:printf(0, "Extracting Flats...")
	self:extractFlats()

	self:printf(0, "Extracting Composites...")
	self:extractTextures()

	self:printf(0, "Extracting Patches...")
	self:extractPatches()

	self:printf(0, "Extracting Maps...")
	self:extractMaps()

	self:printf(0, "Extracting ANIMDEFS...")
	self:extractAnimdefs()

	self:printf(0, "Extracting TEXTURES...")
	self:extractTexturesLump()

	--self:printf(0, "Extracting Mapinfo...")
	--self:extractMapinfo()
	self:printf(0, "Complete.\n")

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

	if(name ~= "RNAMEDEF") then
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
			self:printf(1, "\tFound End of Namespace %s.", name)
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
			self:printf(1, "\tFound Start of Namespace %s.", name)
		end
	end
	self:printf(1, "\tDone.\n")
	collectgarbage()
end

function wad:organizeNamespace(name)
	-- are there any lumps?
	if(#self.namespaces[name].lumps > 0) then

		-- for each lump in the namespace
		for l = 1, #self.namespaces[name].lumps do

			if(self.base ~= self) then
				local skip = false
				for ignore = 1, #self.ignorelist do
					if(self.namespaces[name].lumps[l].name == self.ignorelist[ignore]) then
						skip = true
					end
				end
			end
			if(not skip) then
				local v = self.namespaces[name].lumps[l]
				local index = #self[self.namespaces[name].name]+1
				self[self.namespaces[name].name][index] = v
			end
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
		if(#self.namespaces["MM"].lumps > 0) then

			-- for each lump in the maps namespace
			for l = 1, #self.namespaces["MM"].lumps do

				local v = self.namespaces["MM"].lumps[l]

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
					self.maps[index].name = self.acronym .. self.namespaces["MM"].lumps[l+1].name:sub(-2)
					self.maps[index].raw = {}
				end
			end

			-- structure map data
			for m = 1, #self.maps do
				for l = self.maps[m].pos[1], self.maps[m].pos[2] do
					if(self.namespaces["MM"].lumps[l].name == "THINGS") then 	self.maps[m].raw.things 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "LINEDEFS") then 	self.maps[m].raw.linedefs 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "SIDEDEFS") then 	self.maps[m].raw.sidedefs 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "VERTEXES") then 	self.maps[m].raw.vertexes 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "SEGS") then 		self.maps[m].raw.segs 			= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "SSECTORS") then 	self.maps[m].raw.ssectors 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "NODES") then 	self.maps[m].raw.nodes 			= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "SECTORS") then 	self.maps[m].raw.sectors 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "REJECT") then 	self.maps[m].raw.reject 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "BLOCKMAP") then 	self.maps[m].raw.blockmap 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "BEHAVIOR") then 	self.maps[m].raw.behavior		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "SCRIPTS") then 	self.maps[m].raw.scripts 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "TEXTMAP") then 	self.maps[m].raw.textmap 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "ZNODES") then 	self.maps[m].raw.znodes 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "DIALOGUE") then 	self.maps[m].raw.dialogue 		= self.namespaces["MM"].lumps[l].data end
					if(self.namespaces["MM"].lumps[l].name == "ENDMAP") then 	self.maps[m].raw.endmap 		= self.namespaces["MM"].lumps[l].data end
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
		self.patches[p].png = self.patches[p].imagedata:encode("png"):getString()
		self.patches[p].md5 = love.data.hash("md5", self.patches[p].png)

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

		self.flats[f].png = self.flats[f].image:encode("png"):getString()
		self.flats[f].md5 = love.data.hash("md5", self.flats[f].png)
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
		local numtextures = love.data.unpack("<l", tdata)
		local offsets = {}
		for i = 5, (numtextures*4)+4, 4 do
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
	self:printf(1, "\tFound '%d' textures.", numtextures)
	else
		--self.composites = self.base.composites
		self:printf(1, "\tNo %s found. using base wad %s", lumpname, lumpname)
	end
	collectgarbage()
end

function wad:processAnimated()

	-- find ANIMATED
	local tdata = ""
	local lumpname = "ANIMATED"
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == lumpname) then
			tdata = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if ANIMATED found
	if(tdata ~= "") then

		local t = love.data.unpack("<B", tdata)
		local count = 0
		while(t ~= 255) do

			local last = self:removePadding(love.data.unpack("<c8", tdata, 2+count)):upper()
			local first = self:removePadding(love.data.unpack("<c8", tdata, 11+count)):upper()
			local speed = love.data.unpack("<L", tdata, 20+count)

			local isdup = false
			for d = 1, #self.animlist do
				if(self.animlist[d][2] == first) then
					if(self.animlist[d][3] == last) then
						isdup = true
					end
				end
			end

			if(isdup == false) then
				local index = #self.animlist+1
				self.animlist[index] = {}
				if(t == 0) then self.animlist[index][1] = "flat" end
				if(t == 1) then self.animlist[index][1] = "texture" end

				self.animlist[index][2] = first
				self.animlist[index][3] = last

			end

			count = count + 23
			t = love.data.unpack("<B", tdata, 1+count)
		end
	end
end

function wad:processSwitches()

	-- find SWITCHES
	local tdata = ""
	local lumpname = "SWITCHES"
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == lumpname) then
			tdata = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if SWITCHES found
	if(tdata ~= "") then

		local t = 1
		local count = 0
		while(t ~= 0) do

			local off = self:removePadding(love.data.unpack("<c8", tdata, 1+count)):upper()
			local on = self:removePadding(love.data.unpack("<c8", tdata, 10+count)):upper()
			t = love.data.unpack("<H", tdata, 19+count)


			local isdup = false
			for d = 1, #self.switchlist do
				if(self.switchlist[d][1] == off) then
					if(self.switchlist[d][2] == on) then
						isdup = true
					end
				end
			end
			print(off, on, t, isdup)

			if(isdup == false) then
				local index = #self.switchlist+1
				self.switchlist[index] = {}
				self.switchlist[index][1] = off
				self.switchlist[index][2] = on

			end

			count = count + 20
		end
	end
end

function wad:moveZDoomTextures()
	if(self.base ~= self) then
		for t = 1, #self.textures do
			local c = #self.composites+1
			self.composites[c] = {}
			self.composites[c].name = self.textures[t].name
			self.composites[c].raw = self.textures[t].data
			self.composites[c].iszdoom = true
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot moving base wad zdoom textures.\n")
	end
	collectgarbage()
end

function wad:filterDuplicates()
	local count = 0

	-- filter dups from same wad
	for c = 1, #self.composites do
		for c2 = c, #self.composites do
			if(c ~= c2) then
				if(self.composites[c].md5 == self.composites[c2].md5) then
					count = count + 1
					if(self.composites[c].dups ~= nil) then
						if(self.composites[c].dups[self.composites[c].name] == nil) then self.composites[c].dups[self.composites[c].name] = {} end
						self.composites[c].dups[self.composites[c].name][#self.composites[c].dups[self.composites[c].name]+1] = self.composites[c2].name
					end
				end
			end
		end
	end

	self:printf(1, "\tFound '%d' duplicates", count)
	count = 0
	-- filter dups from base wad
	if(self.base ~= self) then

		-- composites
		for c = 1, #self.composites do
			for c2 = 1, #self.base.composites do
				if(self.composites[c].md5 == self.base.composites[c2].md5) then
					count = count + 1
					self.composites[c].isdoomdup = true
					self.composites[c].doomdup = self.base.composites[c2].name
				end
			end
		end

		-- flats
		for f = 1, #self.flats do
			for f2 = 1, #self.base.flats do
				if(self.flats[f].md5 == self.base.flats[f2].md5) then
					count = count + 1
					self.flats[f].isdoomdup = true
					self.flats[f].doomdup = self.base.flats[f2].name
				end
			end
		end

		-- patches
		for p = 1, #self.patches do
			for p2 = 1, #self.base.patches do
				if(self.patches[p].md5 == self.base.patches[p2].md5) then
					count = count + 1
					self.patches[p].isdoomdup = true
					self.patches[p].doomdup = self.base.patches[p2].name
				end
			end
		end
	end

	collectgarbage()
	self:printf(1, "\tFound '%d' doom duplicates", count)
	self:printf(1, "\tDone.\n")
end

function wad:renamePatches()
	if(self.base ~= self) then

		for p = 1, #self.patches do
			self.texturecount = self.texturecount + 1
			self.patches[p].newname = string.format("%s%.4d", self.acronym, self.texturecount)
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot renaming base wad patches.\n")
	end
end

function wad:renameTextures()
	if(self.base ~= self) then

		for c = 1, #self.composites do
			self.texturecount = self.texturecount + 1
			self.composites[c].newname = string.format("%s%.4d", self.acronym, self.texturecount)
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot renaming base wad textures.\n")
	end
end

function wad:renameFlats()
	if(self.base ~= self) then

		for f = 1, #self.flats do
			self.texturecount = self.texturecount + 1
			self.flats[f].newname = string.format("%s%.4d", self.acronym, self.texturecount)
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot renaming base wad flats.\n")
	end
end

function wad:processTextLump(name)

	-- find ANIMDEFS
	local data = ""
	local lumpname = name
	for l = 1, #self.namespaces["SP"].lumps do
		if(self.namespaces["SP"].lumps[l].name == lumpname) then
			data = self.namespaces["SP"].lumps[l].data
			break;
		end
	end

	-- if ANIMDEFS found
	if(data ~= "") then
		for p = 1, #self.patches do
			data = data:gsub(self.patches[p].name, self.patches[p].newname)
		end
		for c = 1, #self.composites do
			data = data:gsub(self.composites[c].name, self.composites[c].newname)
		end
		for f = 1, #self.flats do
			data = data:gsub(self.flats[f].name, self.flats[f].newname)
		end
	end

	return data
end


function wad:buildAnimdefs()
	if(self.base ~= self) then

		-- animations
		self.animdefs.anims = {}
		for c = 1, #self.composites do
			for al = 1, #self.animlist do
				if(not self.composites[c].isdoomdup) then
					if(self.composites[c].name == self.animlist[al][2]) then
						if(self.animlist[al][1] == "texture") then

							local a = #self.animdefs.anims+1
							self.animdefs.anims[a] = {}
							self.animdefs.anims[a].text1 = self.composites[c].newname
							self.animdefs.anims[a].typ = self.animlist[al][1]
							self.animdefs.anims[a].decal = self.animlist[al][4]

							for c2 = 1, #self.composites do
								if(self.composites[c2].name == self.animlist[al][3]) then
									self.animdefs.anims[a].text2 = self.composites[c2].newname
									break
								end
							end
							break
						end
					end
				end
			end
		end

		for f = 1, #self.flats do
			for al = 1, #self.animlist do
				if(not self.flats[f].isdoomdup) then
					if(self.flats[f].name == self.animlist[al][2]) then
						if(self.animlist[al][1] == "flat") then
							local a = #self.animdefs.anims+1
							self.animdefs.anims[a] = {}
							self.animdefs.anims[a].text1 = self.flats[f].newname
							self.animdefs.anims[a].typ = self.animlist[al][1]
							self.animdefs.anims[a].decal = self.animlist[al][4]

							for f2 = 1, #self.flats do
								if(self.flats[f2].name == self.animlist[al][3]) then
									self.animdefs.anims[a].text2 = self.flats[f2].newname
									break
								end
							end
							break
						end
					end
				end
			end
		end
		-- switches
		self.animdefs.switches = {}

		for c = 1, #self.composites do
			for sl = 1, #self.switchlist do
				if(self.composites[c].name == self.switchlist[sl][1]) then

					local s = #self.animdefs.switches+1
					self.animdefs.switches[s] = {}
					self.animdefs.switches[s].text1 = self.composites[c].newname

					for c2 = 1, #self.composites do
						if(self.composites[c2].name == self.switchlist[sl][2]) then
							self.animdefs.switches[s].text2 = self.composites[c2].newname
						end
					end
					break
				end
			end
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot building animdefs for base wad.\n")
	end
end

function wad:buildMapinfo()
	if(self.base ~= self) then

		for s = 1, #self.namespaces["SP"].lumps do
			if(self.namespaces["SP"].lumps[s].name == "MAPINFO" or self.namespaces["SP"].lumps[s].name == "ZMAPINFO") then
				local mapinfo = self.namespaces["SP"].lumps[s].data
				break
			end
		end

		if(mapinfo) then

		else

			for m = 1, #self.maps do
				if(m == 1) then
					self.mapinfo = string.format(
					[[
					Episode %s
					{
						name = %s
					}
					]], self.maps[1].name, self.acronym)
				end

				self.mapinfo = self.mapinfo .. string.format(
					[[
					Map %s
					{
						titlepatch = "%s"
						next = "%s"
						secretnext = "%s"
						sky1 = "SKY1"
						cluster = 0
						par = 0
						music = "$MUSIC_RUNNIN"
					}
					]], self.mapinfo, self.maps[m].name, self.acronym .. self.maps[m].name:sub(-2), self.acronym .. self.maps[m].name:sub(-2))
			end
		end

		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot building mapinfo for base wad\n")
	end
end

function wad:processMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do
			self:printf(2, "\tProcessing Map: %d", m)

			-- doom/hexen
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
					self.maps[m].sectors[count].floor_texture = self:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+4))
					self.maps[m].sectors[count].ceiling_texture = self:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+12))
					self.maps[m].sectors[count].light = love.data.unpack("<h", self.maps[m].raw.sectors, s+20)
					self.maps[m].sectors[count].special = love.data.unpack("<H", self.maps[m].raw.sectors, s+22)
					self.maps[m].sectors[count].tag = love.data.unpack("<H", self.maps[m].raw.sectors, s+24)
				end

				-- find textures and rename
				for c = 1, #self.composites do
					if not self.composites[c].isdoomdup then

						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.composites[c].name) then self.maps[m].sidedefs[s].upper_texture = self.composites[c].newname end
							if(self.maps[m].sidedefs[s].lower_texture == self.composites[c].name) then self.maps[m].sidedefs[s].lower_texture = self.composites[c].newname end
							if(self.maps[m].sidedefs[s].middle_texture == self.composites[c].name) then self.maps[m].sidedefs[s].middle_texture = self.composites[c].newname end
						end

						-- floors
						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[s].floor_texture == self.composites[c].name) then self.maps[m].sectors[ss].floor_texture = self.composites[c].newname end
							if(self.maps[m].sectors[s].ceiling_texture == self.composites[c].name) then self.maps[m].sectors[ss].ceiling_texture = self.composites[c].newname end
						end
					else
						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.composites[c].name) then self.maps[m].sidedefs[s].upper_texture = self.composites[c].doomdup end
							if(self.maps[m].sidedefs[s].lower_texture == self.composites[c].name) then self.maps[m].sidedefs[s].lower_texture = self.composites[c].doomdup end
							if(self.maps[m].sidedefs[s].middle_texture == self.composites[c].name) then self.maps[m].sidedefs[s].middle_texture = self.composites[c].doomdup end
						end

						-- floors
						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[s].floor_texture == self.composites[c].name) then self.maps[m].sectors[ss].floor_texture = self.composites[c].doomdup end
							if(self.maps[m].sectors[s].ceiling_texture == self.composites[c].name) then self.maps[m].sectors[ss].ceiling_texture = self.composites[c].doomdup end
						end
					end
				end

				for f = 1, #self.flats do
					if not self.flats[f].isdoomdup then

						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.flats[f].name) then self.maps[m].sidedefs[s].upper_texture = self.flats[f].newname end
							if(self.maps[m].sidedefs[s].lower_texture == self.flats[f].name) then self.maps[m].sidedefs[s].lower_texture = self.flats[f].newname end
							if(self.maps[m].sidedefs[s].middle_texture == self.flats[f].name) then self.maps[m].sidedefs[s].middle_texture = self.flats[f].newname end
						end

						-- floors
						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[ss].floor_texture == self.flats[f].name) then self.maps[m].sectors[ss].floor_texture = self.flats[f].newname end
							if(self.maps[m].sectors[ss].ceiling_texture == self.flats[f].name) then self.maps[m].sectors[ss].ceiling_texture = self.flats[f].newname end
						end
					else
						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.flats[f].name) then self.maps[m].sidedefs[s].upper_texture = self.flats[f].doomdup end
							if(self.maps[m].sidedefs[s].lower_texture == self.flats[f].name) then self.maps[m].sidedefs[s].lower_texture = self.flats[f].doomdup end
							if(self.maps[m].sidedefs[s].middle_texture == self.flats[f].name) then self.maps[m].sidedefs[s].middle_texture = self.flats[f].doomdup end
						end

						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[ss].floor_texture == self.flats[f].name) then self.maps[m].sectors[ss].floor_texture = self.flats[f].doomdup end
							if(self.maps[m].sectors[ss].ceiling_texture == self.flats[f].name) then self.maps[m].sectors[ss].ceiling_texture = self.flats[f].doomdup end
						end
					end
				end

				for p = 1, #self.patches do
					if not self.patches[p].isdoomdup then

						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.patches[p].name) then self.maps[m].sidedefs[s].upper_texture = self.patches[p].newname end
							if(self.maps[m].sidedefs[s].lower_texture == self.patches[p].name) then self.maps[m].sidedefs[s].lower_texture = self.patches[p].newname end
							if(self.maps[m].sidedefs[s].middle_texture == self.patches[p].name) then self.maps[m].sidedefs[s].middle_texture = self.patches[p].newname end
						end

						-- floors
						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[ss].floor_texture == self.patches[p].name) then self.maps[m].sectors[ss].floor_texture = self.patches[p].newname end
							if(self.maps[m].sectors[ss].ceiling_texture == self.patches[p].name) then self.maps[m].sectors[ss].ceiling_texture = self.patches[p].newname end
						end
					else
						-- walls
						for s = 1, #self.maps[m].sidedefs do
							if(self.maps[m].sidedefs[s].upper_texture == self.patches[p].name) then self.maps[m].sidedefs[s].upper_texture = self.patches[p].doomdup end
							if(self.maps[m].sidedefs[s].lower_texture == self.patches[p].name) then self.maps[m].sidedefs[s].lower_texture = self.patches[p].doomdup end
							if(self.maps[m].sidedefs[s].middle_texture == self.patches[p].name) then self.maps[m].sidedefs[s].middle_texture = self.patches[p].doomdup end
						end

						for ss = 1, #self.maps[m].sectors do
							if(self.maps[m].sectors[ss].floor_texture == self.patches[p].name) then self.maps[m].sectors[ss].floor_texture = self.patches[p].doomdup end
							if(self.maps[m].sectors[ss].ceiling_texture == self.patches[p].name) then self.maps[m].sectors[ss].ceiling_texture = self.patches[p].doomdup end
						end
					end
				end


				-- build raw sidedefs back
				count = 0
				self.maps[m].raw.sidedefs = ""
				local t = {}
				for s = 1, #self.maps[m].sidedefs do
					count = count + 1
					t[s] = love.data.pack("string", "<hhc8c8c8H", self.maps[m].sidedefs[s].xoffset, self.maps[m].sidedefs[s].yoffset, self.maps[m].sidedefs[s].upper_texture, self.maps[m].sidedefs[s].lower_texture, self.maps[m].sidedefs[s].middle_texture, self.maps[m].sidedefs[s].sector)
				end
				self.maps[m].raw.sidedefs = table.concat(t)

				-- build raw sectors back
				count = 0
				self.maps[m].raw.sectors = ""
				t = {}
				for s = 1, #self.maps[m].sectors do
					count = count + 1
					t[s] = love.data.pack("string", "<hhc8c8hHH", self.maps[m].sectors[s].floor_height, self.maps[m].sectors[s].ceiling_height, self.maps[m].sectors[s].floor_texture, self.maps[m].sectors[s].ceiling_texture, self.maps[m].sectors[s].light, self.maps[m].sectors[s].special, self.maps[m].sectors[s].tag)
				end
				self.maps[m].raw.sectors = table.concat(t)

			--udmf
			elseif(self.maps[m].format == "UM") then
				for c = 1, #self.composites do
					self.maps[m].raw.textmap = self.maps[m].raw.textmap:gsub(self.composites[c].name, self.composites[c].newname)
				end
				for f = 1, #self.flats do
					self.maps[m].raw.textmap = self.maps[m].raw.textmap:gsub(self.flats[f].name, self.flats[f].newname)
				end
				for p = 1, #self.patches do
					self.maps[m].raw.textmap = self.maps[m].raw.textmap:gsub(self.patches[p].name, self.patches[p].newname)
				end
			end

			collectgarbage()
		end
	else
		self:printf(1, "\tNot processing base wad maps.")
	end

	self:printf(1, "\tDone.\n")
end

function wad:extractTextures()
	if(self.base ~= self) then
		if(#self.composites > 0) then
			for c = 1, #self.composites do
				if(not self.composites[c].iszdoom) then
					if(not self.composites[c].isdoomdup) then
						local png, err = io.open(string.format("%s/TEXTURES/%s.PNG", self.pk3path, self.composites[c].newname), "w+b")
						if err then error("[ERROR] " .. err) end
						png:write(self.composites[c].png)
						png:close()
					end
				else
					local png, err = io.open(string.format("%s/TEXTURES/%s.raw", self.pk3path, self.composites[c].newname), "w+b")
					if err then error("[ERROR] " .. err) end
					png:write(self.composites[c].raw)
					png:close()
				end
			end
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting base wad composites.\n")
	end
end

function wad:extractFlats()
	if(self.base ~= self) then
		for f = 1, #self.flats do
			if(not self.flats[f].isdoomdup) then
				local png, err = io.open(string.format("%s/FLATS/%s.PNG", self.pk3path, self.flats[f].newname), "w+b")
				if err then error("[ERROR] " .. err) end
				png:write(self.flats[f].png)
				png:close()
			end
		end
		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting base wad flats.\n")
	end
end

function wad:extractPatches()
	if(self.base ~= self) then
		-- find TEXTURES
		local data = ""
		local lumpname = "TEXTURES"
		for l = 1, #self.namespaces["SP"].lumps do
			if(self.namespaces["SP"].lumps[l].name == lumpname) then
				data = self.namespaces["SP"].lumps[l].data
				break;
			end
		end

		if(data ~= "") then
			for p = 1, #self.patches do
				if(not self.patches[p].isdoomdup) then
					local png, err = io.open(string.format("%s/PATCHES/%s.PNG", self.pk3path, self.patches[p].newname), "w+b")
					if err then error("[ERROR] " .. err) end
					png:write(self.patches[p].png)
					png:close()
				end
			end
		end

		collectgarbage()
		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting base wad patches.\n")
	end
end


function wad:extractMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do

			-- doom/hexen
			if(self.maps[m].format == "DM" or self.maps[m].format == "HM") then

				-- lumps
				local order = {}
				order[#order+1] = self.maps[m].raw.things
				order[#order+1] = self.maps[m].raw.linedefs
				order[#order+1] = self.maps[m].raw.sidedefs
				order[#order+1] = self.maps[m].raw.vertexes
				order[#order+1] = self.maps[m].raw.segs
				order[#order+1] = self.maps[m].raw.ssectors
				order[#order+1] = self.maps[m].raw.nodes
				order[#order+1] = self.maps[m].raw.sectors
				order[#order+1] = self.maps[m].raw.reject
				order[#order+1] = self.maps[m].raw.blockmap
				if(self.maps[m].raw.behavior) then order[#order+1] = self.maps[m].raw.behavior end
				if(self.maps[m].raw.scripts) then order[#order+1] = self.maps[m].raw.scripts end

				local pos = {}
				local lumpchunk = ""
				for o = 1, #order do
					pos[o] = #lumpchunk
					lumpchunk = lumpchunk .. order[o]
				end

				-- header
				local header = love.data.pack("string", "<c4LL", "PWAD", #order+1, 12+#lumpchunk)

				-- directory
				local dir = love.data.pack("string", "<i4i4c8", 10, 10, "MAP01")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[1]+12, #order[1], "THINGS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[2]+12, #order[2], "LINEDEFS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[3]+12, #order[3], "SIDEDEFS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[4]+12, #order[4], "VERTEXES")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[5]+12, #order[5], "SEGS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[6]+12, #order[6], "SSECTORS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[7]+12, #order[7], "NODES")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[8]+12, #order[8], "SECTORS")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[9]+12, #order[9], "REJECT")
				dir = dir .. love.data.pack("string", "<i4i4c8", pos[10]+12, #order[10], "BLOCKMAP")
				if(self.maps[m].raw.behavior) then dir = dir .. love.data.pack("string", "<i4i4c8", pos[11]+12, #order[11], "BEHAVIOR") end
				if(self.maps[m].raw.scripts) then dir = dir .. love.data.pack("string", "<i4i4c8", pos[12]+12, #order[12], "SCRIPT") end

				local wad, err = io.open(string.format("%s/MAPS/%s.WAD", self.pk3path, self.maps[m].name), "w+b")
				if err then error("[ERROR] " .. err) end
				wad:write(header)
				wad:write(lumpchunk)
				wad:write(dir)
				wad:close()

			-- udmf
			elseif(self.maps[m].format == "UM") then

				-- lumps
				local order = {}
				order[#order+1] = self.maps[m].raw.textmap
				if(self.maps[m].raw.znodes) then order[#order+1] = self.maps[m].raw.znodes end
				if(self.maps[m].raw.reject) then order[#order+1] = self.maps[m].raw.reject end
				if(self.maps[m].raw.dialogue) then order[#order+1] = self.maps[m].raw.dialogue end
				if(self.maps[m].raw.behavior) then order[#order+1] = self.maps[m].raw.behavior end
				if(self.maps[m].raw.scripts) then order[#order+1] = self.maps[m].raw.scripts end
				order[#order+1] = self.maps[m].raw.endmap


				local pos = {}
				local lumpchunk = ""
				for o = 1, #order do
					pos[o] = #lumpchunk
					lumpchunk = lumpchunk .. order[o]
				end

				-- header
				local header = love.data.pack("string", "<c4LL", "PWAD", #order+1, 12+#lumpchunk)

				-- directory
				local dir = love.data.pack("string", "<i4i4c8", 10, 0, "MAP01")
				local count = 1

				dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "TEXTMAP")
				if(self.maps[m].raw.znodes) then count = count + 1; dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "ZNODES") end
				if(self.maps[m].raw.reject) then count = count + 1; dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "REJECT") end
				if(self.maps[m].raw.dialogue) then count = count + 1; dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "DIALOGUE") end
				if(self.maps[m].raw.behavior) then count = count + 1; dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "BEHAVIOR") end
				if(self.maps[m].raw.scripts) then count = count + 1; dir = dir .. love.data.pack("string", "<i4i4c8", pos[count]+12, #order[count], "SCRIPTS") end
				dir = dir .. love.data.pack("string", "<i4i4c8", 22, 0, "ENDMAP")

				local wad, err = io.open(string.format("%s/MAPS/%s.WAD", self.pk3path, self.maps[m].name), "w+b")
				if err then error("[ERROR] " .. err) end
				wad:write(header)
				wad:write(lumpchunk)
				wad:write(dir)
				wad:close()
			end
		end
	end
end

function wad:extractAnimdefs()
	if(self.base ~= self) then

		local anim = ""
		for a = 1, #self.animdefs.anims do
			anim = string.format("%s\n%s %s range %s tics 8", anim, self.animdefs.anims[a].typ, self.animdefs.anims[a].text1, self.animdefs.anims[a].text2)
			if(self.animdefs.anims[a].decal) then
				anim = string.format("%s %s", anim, self.animdefs.anims[a].decal)
			end
		end

		local switch = ""
		for s = 1, #self.animdefs.switches do
			switch = string.format("%s\nswitch %s on pic %s tics 0", switch, self.animdefs.switches[s].text1, self.animdefs.switches[s].text2)
		end
		local file, err = io.open(string.format("%s/ANIMDEFS.%s.TXT", self.pk3path, self.acronym), "w")
		if err then error("[ERROR] " .. err) end
		file:write(anim)
		file:write("\n")
		file:write(switch)
		file:write("\n\n")
		file:write(self.animdefs.original)
		file:close()

		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting base wad flats.\n")
	end
end

function wad:extractTexturesLump()
	if(self.base ~= self) then

		local file, err = io.open(string.format("%s/TEXTURES.%s.TXT", self.pk3path, self.acronym), "w")
		if err then error("[ERROR] " .. err) end
		file:write(self.textures.original)
		file:close()

		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting base wad flats.\n")
	end
end

function wad:extractMapinfo()
	if(self.base ~= self) then

		local file, err = io.open(string.format("%s/MAPINFO/%s.TXT", self.pk3path, self.acronym), "w")
		if err then error("[ERROR] " .. err) end
		file:write(self.mapinfo)
		file:close()

		file, err = io.open(string.format("%s/MAPINFO.TXT", self.pk3path), "r")
		if err then error("[ERROR] " .. err) end
		local mapinfo = file:read("*all")
		file:close()

		mapinfo = string.format('%s\ninclude "MAPINFO/%s.TXT"', mapinfo, self.acronym)
		file, err = io.open(string.format("%s/MAPINFO.TXT", self.pk3path), "w")
		if err then error("[ERROR] " .. err) end
		file:write(mapinfo)
		file:close()

		self:printf(1, "\tDone.\n")
	else
		self:printf(1, "\tNot extracting mapinfo for base wad.\n")
	end
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

function wad:insertGRAB(data, xoff, yoff)
	local grAb = love.data.pack("data", ">Lc4llL", 8, "grAb", xoff, yoff, self:crc(data))
	return data:sub(1, 37) .. grAb .. data:sub(38)
end

-- CRC code found: https://stackoverflow.com/questions/34120322/converting-a-c-checksum-function-to-lua
function wad:crc(data)
    sum = 65535
    local d
    for i = 1, #data do
        d = string.byte(data, i)    -- get i-th element, like data[i] in C
        sum = self:ByteCRC(sum, d)
    end
    return sum
end

function wad:ByteCRC(sum, data)
    sum = bit.bxor(sum, data)
    for i = 0, 7 do     -- lua for loop includes upper bound, so 7, not 8
        if (bit.band(sum, 1) == 0) then
            sum = bit.rshift(sum, 1)
        else
            sum = bit.bxor(bit.rshift(sum, 1),0xA001)  -- it is integer, no need for string func
        end
    end
    return sum
end


return wad











