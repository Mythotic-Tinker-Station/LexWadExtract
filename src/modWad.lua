
local wad = class("wad",
{
	-- class variables
	verbose = 2,
	raw = "",
	lumps = {},
	specials =
	{
		"PLAYPAL",
		"ALTHUDCF",
		"ANIMATED",
		"ANIMDEFS",
		"CVARINFO",
		"COLORMAP",
		"DECALDEF",
		"DECORATE",
		"DEFBINDS",
		"DEFCVARS",
		"DEHACKED",
		"DEHSUPP",
		"DMXGUS",
		"DEMO1",
		"DEMO2",
		"DEMO3",
		"ENDOOM",
		"FSGLOBAL",
		"FONTDEFS",
		"DEHSUPP",
		"GAMINFO",
		"GENMIDI",
		"GLDEFS",
		"IWADINFO",
		"LANGUAGE",
		"LOADACS",
		"LOCKDEFS",
		"MAPINFO",
		"MENUDEF",
		"MODELDEF",
		"MUSINFO",
		"PALVARS",
		"PLAYPAL",
		"PNAMES",
		"REVERB",
		"SBARINFO",
		"SECRETS",
		"SNDCURVE",
		"SNDINFO",
		"SNDSEQ",
		"SWITCHES",
		"TEAMINFO",
		"TERRAIN",
		"TEXTCOLO",
		"TEXTURE1",
		"TEXTURE2",
		"TEXTURES",
		"TRNSLATE",
		"VOXELDEF",
		"X11R6RGB",
		"XHAIRS",
		"XLAT",
		"ZMAPINFO",
	},



	-- namespaces
	root = {},
	palette = {},
	header = {},
	maps = {},
	textures = {},
	sprites = {},
	colormaps = {},
	voice = {},
	voxels = {},
	acs = {},
})



---------------------------------------------------------
-- Main Functions
---------------------------------------------------------
function wad:init(path)
	self:open(path)

	self:printf(0, "Gathering Header...")
	self:gatherHeader()

	self:printf(0, "Gathering Lumps...")
	self:gatherLumps()

	self:printf(0, "Organizing Maps Namespace...")
	self:organizeMaps()

	self:printf(0, "Organizing Flats Namespace...")
	self:organizeNamespace("F1_START", "F1_END", "textures", "Flat")
	self:organizeNamespace("F2_START", "F2_END", "textures", "Flat")
	self:organizeNamespace("F3_START", "F3_END", "textures", "Flat")
	self:organizeNamespace("F_START", "F_END", "textures", "Flat")
	self:organizeNamespace("FF_START", "FF_END", "textures", "Flat")

	self:printf(0, "Organizing Patches Namespace...")
	self:organizeNamespace("P1_START", "P1_END", "textures", "Patch")
	self:organizeNamespace("P2_START", "P2_END", "textures", "Patch")
	self:organizeNamespace("P3_START", "P3_END", "textures", "Patch")
	self:organizeNamespace("P_START", "P_END", "textures", "Patch")
	self:organizeNamespace("PP_START", "PP_END", "textures", "Patch")

	self:printf(0, "Organizing Textures Namespace...")
	self:organizeNamespace("TX_START", "TX_END", "textures", "Texture")

	self:printf(0, "Organizing HR Textures Namespace...")
	self:organizeNamespace("HI_START", "HI_END", "textures", "Texture")

	self:printf(0, "Organizing Sprites Namespace...")
	self:organizeNamespace("S_START", "S_END", "sprites", "Texture")
	self:organizeNamespace("SS_START", "SS_END", "sprites", "Sprite")

	self:printf(0, "Organizing Colormaps Namespace...")
	self:organizeNamespace("C_START", "C_END", "colormaps", "Colormap")

	self:printf(0, "Organizing Voices Namespace...")
	self:organizeNamespace("V_START", "V_END", "voice", "Voice")

	self:printf(0, "Organizing Voxels Namespace...")
	self:organizeNamespace("VX_START", "VX_END", "voxels", "Voxel")

	self:printf(0, "Organizing ACS Scripts Namespace...")
	self:organizeNamespace("A_START", "A_END", "acs", "ACS")


	self:printf(0, "Organizing Specials...")
	self:organizeSpecials()

	for k, v in pairs(self.lumps) do
		print(k,v.name)
	end

end

function wad:open(path)
	local file = assert(io.open(path, "rb"))
	self.raw = file:read("*all")
	file:close()
end

function wad:gatherHeader()
	self.header.magic, self.header.lumpcount, self.header.dirpos = love.data.unpack("<c4i4i4", self.raw, 1)

	-- dammit lua
	self.header.lumpcount = self.header.lumpcount-1
	self.header.dirpos = self.header.dirpos+1

	if(self.header.magic ~= "IWAD" and self.header.magic ~= "PWAD") then error("File is not a valid wad file, expected IWAD or PWAD, got: " .. self.header.magic) end
	self:printf(1, "Type: %s\nLumps: %d\nDirectory Position: 0x%X\n", self.header.magic, self.header.lumpcount, self.header.dirpos)

end

function wad:gatherLumps()
	for l = 0, self.header.lumpcount do

		-- get file meta data
		local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(l*16))
		name = self:removePadding(name)
		filepos = filepos+1

		-- get file data
		local filedata = love.data.unpack(string.format("<c%d", size), self.raw, filepos)

		-- save file
		self.lumps[l+1] = { name=name, size=size, pos=filepos, data=filedata }
	end
end

function wad:organizeSpecials()
	local name = ""
	local l = 1
	local lumpcount = #self.lumps
	while(l <= lumpcount) do

		for i = 1, #self.specials do
			if(self.lumps[l].name == self.specials[i]) then
				name = self.specials[i]
			end
		end

		if(name ~= "") then
			self.root[name] = self.lumps[l]
			table.remove(self.lumps, l)
			self:printf(1, "Found %s", name)
			name = ""
			lumpcount = #self.lumps
		else
			l = l + 1
		end
	end
end

function wad:organizeMaps()
	local l = 1
	local lumpcount = #self.lumps
	while(l <= lumpcount) do

		if(not self:checkDoomMapData(l) and not self:checkUDMFData(l)) then
			l = l + 1
		end
		lumpcount = #self.lumps
	end

end

function wad:organizeNamespace(marker1, marker2, namespace, typename)
	local found_start = false
	local found_end = false
	local count = #self[namespace]

	-- for each lump
	local l = 1
	local lumpcount = #self.lumps

	while(l <= lumpcount) do

		-- if we have found the section
		if(found_start) then
			if(self.lumps[l].name == marker2) then found_end = l end
			count = count + 1
			self[namespace][count] = self.lumps[l]
			table.remove(self.lumps, l)
			if(found_end) then return end
			self:printf(2, "Found %s: %s", typename, self[namespace][count].name)

		-- looking for section
		elseif(not found_start) then
			if(self.lumps[l].name == marker1) then
				found_start = l
				table.remove(self.lumps, l)
				lumpcount = #self.lumps
			else
				l = l + 1
			end
		end
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

function wad:removePadding(str)
	local newstr = ""
	for i = 1, #str do
		if str:sub(i,i) == "\0" then break end
		newstr = string.format("%s%s", newstr, str:sub(i,i))
	end
	return newstr
end


function wad:checkDoomMapData(l)
	-- doom/hexen maps always starts with the "THINGS" lump
	if self.lumps[l].name == "THINGS" then

		local found_things 		= l
		local found_lines 		= false
		local found_sides 		= false
		local found_vertexes 	= false
		local found_segs 		= false
		local found_ssectors 	= false
		local found_nodes 		= false
		local found_sectors 	= false
		local found_reject  	= false
		local found_blockmap 	= false
		local found_behavior 	= false
		local found_scripts 	= false
		local map_lumpcount 	= 1

		-- there are 12 possible lumps that can be included with a doom/hexen map
		for i = 1, 11 do

			-- maker sure we arent at the end of the wad
			if(l+i <= #self.lumps) then
				if(self.lumps[l+i].name == "LINEDEFS") 	then found_lines 		= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SIDEDEFS") 	then found_sides 		= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "VERTEXES") 	then found_vertexes 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SEGS") 		then found_segs 		= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SSECTORS") 	then found_ssectors 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "NODES") 	then found_nodes	 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SECTORS")	then found_sectors 		= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "REJECT") 	then found_reject	 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "BLOCKMAP") 	then found_blockmap 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "BEHAVIOR") 	then found_behavior 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SCRIPTS")	then found_scripts 		= l+i; 	map_lumpcount = map_lumpcount+1 end
			end
		end

		-- check if valid map
		if(found_things and found_lines and found_sides and found_vertexes and found_sectors) then
			local mapindex = #self.maps+1
			self.maps[mapindex] = {}
			self.maps[mapindex].name		= self.lumps[l-1].name
			self.maps[mapindex].things 		= self.lumps[found_things]
			self.maps[mapindex].linedefs 	= self.lumps[found_lines]
			self.maps[mapindex].sidedefs 	= self.lumps[found_sides]
			self.maps[mapindex].vertexes 	= self.lumps[found_vertexes]
			self.maps[mapindex].segs 		= self.lumps[found_segs]
			self.maps[mapindex].ssectors 	= self.lumps[found_ssectors]
			self.maps[mapindex].nodes 		= self.lumps[found_nodes]
			self.maps[mapindex].sectors 	= self.lumps[found_sectors]
			self.maps[mapindex].reject 		= self.lumps[found_reject]
			self.maps[mapindex].blockmap 	= self.lumps[found_blockmap]
			self.maps[mapindex].behavior 	= self.lumps[found_behavior]
			self.maps[mapindex].scripts 	= self.lumps[found_scripts]
			self.maps[mapindex].mapformat	= "doom"
			if(found_behavior) then
				self.maps[mapindex].mapformat = "hexen"
			end

			for i = 0, map_lumpcount do
				table.remove(self.lumps, l-1)
			end

			self:printf(2, "Found Map: %s; Type: %s", self.maps[mapindex].name, self.maps[mapindex].mapformat)

			return true
		end
	end
	return false
end

function wad:checkUDMFData(l)
	if self.lumps[l].name == "TEXTMAP" then

		local found_textmap 	= l
		local found_znodes	 	= false
		local found_reject	 	= false
		local found_dialogue	= false
		local found_behavior	= false
		local found_scripts 	= false
		local found_endmap		= false
		local map_lumpcount 	= 1

		-- there are 7 possible lumps that can be included with a udmf map
		for i = 1, 5 do
			-- maker sure we arent at the end of the wad
			if(l+i <= #self.lumps) then
				if(self.lumps[l+i].name == "ZNODES") 	then found_znodes 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "REJECT") 	then found_reject 	= l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "DIALOGUE") 	then found_dialogue = l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "BEHAVIOR") 	then found_behavior = l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "SCRIPTS") 	then found_scripts  = l+i; 	map_lumpcount = map_lumpcount+1 end
				if(self.lumps[l+i].name == "ENDMAP") 	then found_endmap 	= l+i; 	map_lumpcount = map_lumpcount+1 end
			end
		end

		if(found_endmap) then
			local mapindex = #self.maps+1
			self.maps[mapindex] = {}
			self.maps[mapindex].name = self.lumps[l-1].name
			self.maps[mapindex].textmap = self.lumps[found_textmap]
			self.maps[mapindex].znodes = self.lumps[found_znodes]
			self.maps[mapindex].reject = self.lumps[found_reject]
			self.maps[mapindex].dialogue = self.lumps[found_dialogue]
			self.maps[mapindex].behavior = self.lumps[found_behavior]
			self.maps[mapindex].scripts = self.lumps[found_scripts]
			self.maps[mapindex].endmap = self.lumps[found_endmap]
			self.maps[mapindex].mapformat = "udmf"

			for i = 0, map_lumpcount do
				table.remove(self.lumps, l-1)
			end

			self:printf(2, "Found Map: %s; Type: %s", self.maps[mapindex].name, self.maps[mapindex].mapformat)

			return true
		end
	end
	return false
end

return wad











