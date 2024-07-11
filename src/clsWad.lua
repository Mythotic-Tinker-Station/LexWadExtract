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

-- cross platform code
function getOS()
	-- ask LuaJIT first
	if jit then
		return jit.os
	end
	-- Unix, Linux variants
	local fh,err = assert(io.popen("uname -o 2>/dev/null","r"))
	if fh then
		osname = fh:read()
	end
	return osname or "Windows"
end

osname = getOS()
print("OS: "..osname)
mac = osname=="OSX"

local deleteCommand, runScriptCommand, moveCommand, scriptName, mkDirCommand

if(mac) then
	deleteCommand="rm -rf"
	runScriptCommand="bash"
	moveCommand="mv"
	scriptName="LexiconWadConverter"
	mkDirCommand="mkdir -p"
else
	deleteCommand="del /q"
	runScriptCommand="cmd /c"
	moveCommand="move /Y"
	scriptName="zwadconv.bat"
	mkDirCommand="mkdir"
end

-- wad object
animdefsIgnore = {}
local wad = class("wad",
{
	-- class variables
	verbose = 0,
	texturecount = 0,
    texturecount2 = 0,
	soundcount = 0,
    songcount = 0,
	things = "N",
	acronym = "DOOM",
    acronym_sprite = "XX",
	base = false,
	extractpatches = false;

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
    sprites = {},
	doomsounds = {},
	oggsounds = {},
	wavesounds = {},
	flacsounds = {},
	songs = {},
	maps = {},
	dups = {},
	doomdups = {},
	animdefs = {},

    debugcanvas = love.graphics.newCanvas(1024, 1024),

    maplumps =
    {
        "THINGS", 
        "LINEDEFS", 
        "SIDEDEFS", 
        "VERTEXES", 
        "SEGS", 
        "SSECTORS", 
        "NODES", 
        "SECTORS", 
        "REJECT", 
        "BLOCKMAP",
        "BEHAVIOR",
        "SCRIPTS",
        "TEXTMAP",
        "ZNODES",
        "DIALOGUE",
        "ENDMAP",
    },

    specialslist =
    {
		"ALTHUDCF",
		"ANIMATED",
		"ANIMDEFS",
		"COLORMAP",
		"CVARINFO",
		"DECALDEF",
		"DECORATE",
		"DEFBINDS",
		"DEFCVARS",
		"DEHACKED",
		"DEHSUPP",
		"DEMO1",
		"DEMO2",
		"DEMO3",
		"DMXGUS",
		"_DEUTEX_",
		"ENDOOM",
		"FONTDEFS",
		"FSGLOBAL",
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

    graphicslist =
    {
        {"CWILV00", "V00"},
        {"CWILV01", "V01"},
        {"CWILV02", "V02"},
        {"CWILV03", "V03"},
        {"CWILV04", "V04"},
        {"CWILV05", "V05"},
        {"CWILV06", "V06"},
        {"CWILV07", "V07"},
        {"CWILV08", "V08"},
        {"CWILV09", "V09"},
        {"CWILV10", "V10"},
        {"CWILV11", "V11"},
        {"CWILV12", "V12"},
        {"CWILV13", "V13"},
        {"CWILV14", "V14"},
        {"CWILV15", "V15"},
        {"CWILV16", "V16"},
        {"CWILV17", "V17"},
        {"CWILV18", "V18"},
        {"CWILV19", "V19"},
        {"CWILV20", "V20"},
        {"CWILV21", "V21"},
        {"CWILV22", "V22"},
        {"CWILV23", "V23"},
        {"CWILV24", "V24"},
        {"CWILV25", "V25"},
        {"CWILV26", "V26"},
        {"CWILV27", "V27"},
        {"CWILV28", "V28"},
        {"CWILV29", "V29"},
        {"CWILV30", "V30"},
        {"CWILV31", "V31"},
        {"CWILV32", "V32"},
        {"WILV00", "UV00"},
        {"WILV01", "UV01"},
        {"WILV02", "UV02"},
        {"WILV03", "UV03"},
        {"WILV04", "UV04"},
        {"WILV05", "UV05"},
        {"WILV06", "UV06"},
        {"WILV07", "UV07"},
        {"WILV08", "UV08"},
        {"WILV09", "UV09"},
        {"WILV10", "UV10"},
        {"WILV11", "UV11"},
        {"WILV12", "UV12"},
        {"WILV13", "UV13"},
        {"WILV14", "UV14"},
        {"WILV15", "UV15"},
        {"WILV16", "UV16"},
        {"WILV17", "UV17"},
        {"WILV18", "UV18"},
        {"WILV19", "UV19"},
        {"WILV20", "UV20"},
        {"WILV21", "UV21"},
        {"WILV22", "UV22"},
        {"WILV23", "UV23"},
        {"WILV24", "UV24"},
        {"WILV25", "UV25"},
        {"WILV26", "UV26"},
        {"WILV27", "UV27"},
        {"WILV28", "UV28"},
        {"WILV29", "UV29"},
        {"WILV30", "UV30"},
        {"WILV31", "UV31"},
        {"WILV32", "UV32"},
        {"WILV33", "UV33"},
        {"WILV34", "UV34"},
        {"WILV35", "UV35"},
        {"WILV36", "UV36"},
        {"WILV37", "UV37"},
        {"WILV38", "UV38"},
        {"INTERPIC", "INT"},
        {"TITLEPIC", "TITL"},
        {"HELP", "HELP"},
        {"CREDIT", "CRED"},
        {"BOSSBACK", "BOSS"},
    },

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

    music_list =
    {
        -- order matters
        "D_RUNNIN",     -- map01
        "D_STALKS",
        "D_COUNTD",
        "D_BETWEE",
        "D_DOOM",
        "D_THE_DA",
        "D_SHAWN",
        "D_DDTBLU",
        "D_IN_CIT",
        "D_DEAD",
        "D_STLKS2",
        "D_THEDA2",
        "D_DOOM2",
        "D_DDTBL2",
        "D_RUNNI2",
        "D_DEAD2",
        "D_STLKS3",
        "D_ROMERO",
        "D_SHAWN2",
        "D_MESSAG",
        "D_COUNT2",
        "D_DDTBL3",
        "D_AMPIE",
        "D_THEDA3",
        "D_ADRIAN",
        "D_MESSG2",
        "D_ROMER2",
        "D_TENSE",
        "D_SHAWN3",
        "D_OPENIN",
        "D_EVIL",
        "D_ULTIMA",
        "D_DM2INT",     -- map32
    },

	linedef_flags =
	{
		[0x0001] = "blocking",
		[0x0002] = "blockmonsters",
		[0x0004] = "twosided",
		[0x0008] = "sontpegtop",
		[0x0010] = "dontpegbottom",
		[0x0020] = "secret",
		[0x0040] = "blocksound",
		[0x0080] = "dontdraw",
		[0x0100] = "mapped",
		[0x0200] = "repeatspecial",
		[0x0400] = "playeruse",
		[0x0800] = "monstercross",
		[0x0C00] = "impact",
		[0x1000] = "playerpush",
		[0x1400] = "missilecross",
		[0x1800] = "blocking",
		[0x2000] = "monsteractivate",
		[0x4000] = "blockplayers",
		[0x8000] = "blockeverything",
	},

	thing_filter =
	{
		5,
		6,
		7,
		8,
		9,
		10,
		12,
		13,
		15,
		16,
		17,
		18,
		19,
		20,
		21,
		22,
		23,
		24,
		25,
		26,
		27,
		28,
		29,
		30,
		31,
		32,
		33,
		34,
		35,
		36,
		37,
		38,
		39,
		40,
		41,
		42,
		43,
		44,
		45,
		46,
		47,
		48,
		49,
		50,
		51,
		52,
		53,
		54,
		55,
		56,
		57,
		58,
		59,
		60,
		61,
		62,
		63,
		64,
		65,
		66,
		67,
		68,
		69,
		70,
		71,
		72,
		73,
		74,
		75,
		76,
		77,
		78,
		79,
		80,
		81,
		82,
		83,
		84,
		85,
		86,
		87,
		88,
		89,
		888,
		2001,
		2002,
		2003,
		2004,
		2005,
		2006,
		2007,
		2008,
		2010,
		2011,
		2012,
		2013,
		2014,
		2015,
		2018,
		2019,
		2022,
		2023,
		2024,
		2025,
		2026,
		2028,
		2035,
		2045,
		2046,
		2047,
		2048,
		2049,
		3001,
		3002,
		3003,
		3004,
		3005,
		3006,
		5003,
		5004,
		5005,
		5006,
		5007,
		5008,
		5010,
		5011,
		5012,
		5013,
		5014,
		5015,
		9037,
		9050,
		9051,
		9052,
		9053,
		9054,
		9055,
		9056,
		9057,
		9058,
		9059,
		9060,
		9061,
	},

	thing_ignore =
	{
		32000,
	},

	door_actions =
	{
		10,
		11,
		12,
		13,
		14,
		202,
		249,
	},

	platform_actions =
	{
		29,
		30,
		94,
		60,
		61,
		62,
		63,
		64,
		65,
		172,
		203,
		206,
		207,
		228,
		230,
		231,
	},

	floor_actions =
	{
		20,
		21,
		22,
		23,
		24,
		25,
		28,
		35,
		36,
		37,
		46,
		66,
		67,
		68,
		95,
		96,
		138,
		200,
		235,
		236,
		238,
		239,
		240,
		241,
		242,
		250,
		251,
	},

	ceiling_actions =
	{
		38,
		40,
		41,
		42,
		43,
		44,
		45,
		47,
		69,
		97,
		104,
		169,
		192,
		193,
		194,
		195,
		196,
		197,
		198,
		199,
		201,
		205,
		252,
		253,
		254,
		255,
	},

    ctf_filter =
    {
        {5, 5130},  -- blue key to zandronum blue flag
        {13, 5131}, -- red key to zandronum red flag
    },

	door_sounds =
	{
		"DSDOROPN",
		"DSDORCLS",
		"DSBDOPN",
		"DSBDCLS",
	},

	platform_sounds =
	{
		"DSPSTART",
		"DSPSTOP",
		"DSSTNMOV",
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
			name = "doomsounds",
			lumps = {},
		},
		["WS"] =
		{
			name = "wavesounds",
			lumps = {},
		},
		["OS"] =
		{
			name = "oggsounds",
			lumps = {},
		},
		["CS"] =
		{
			name = "flacsounds",
			lumps = {},
		},
		["MS"] =
		{
			name = "songs",
			lumps = {},
		},
		["GG"] =
		{
			name = "graphics",
			lumps = {},
		},
		["TX"] =
		{
			name = "patches",
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


--[[
--------------------------------------------------------------
-- Main Functions
-- if you're wondering why this is a class
-- its because we need to load doom2.wad and wad of choice
    @param verbose
    @return string
-------------------------------------------------------------
]]
function wad:init(path, palette, acronym, patches, base, pk3path, toolspath, sprites, acronym_sprite, things)
	self.base = base or self

    if(acronym ~= nil) then 
        if(#acronym < 4) then
            error("Error: Acronym must be 4 letters.")
        end
        self.acronym = string.upper(acronym:sub(1, 4))
    end
    
    if(acronym_sprite ~= nil) then 
        if(#acronym_sprite < 2) then
            error("Error: Sprite acronym must be 2 letters.")
         end
        self.acronym_sprite = string.upper(acronym_sprite:sub(1, 2))
    end

    if(things ~= nil) then
        self.things = string.upper(things:sub(1, 1))
    end

    if patches ~= nil then
        self.extractpatches = string.upper(patches)
    end

	self.pk3path = pk3path
	self.toolspath = toolspath
	self.spritesname = sprites
	self.apppath = love.filesystem.getSourceBaseDirectory():gsub("/", "\\")
    self.palette = palette
    self.nodelete = nodelete

    -- we are loading the raw wad data in to memory
	utils:printf(0, "------------------------------------------------------------------------------------------")
	utils:printf(0, "Loading Wad '%s'...", path)
	self:open(path)

    -- read and save the wad header
	utils:printf(0, "Gathering Header...")
	self:gatherHeader()

    -- Run through the in memory wad data and add extra markers to help ID certain file types
    -- it does the following:
    -- read through all the lumps, ignoring markers
    -- add markers for everything, place lumps accordingly, makes old and new markers such as MM_START MM_END which all maps are placed in
    -- rebuilds the header and directory of the in memory wad
	utils:printf(0, "Adding Extra Namespace Markers...")
	self:addExtraMarkers()

    -- run through the in memory wad data
    -- find the markers
    -- put all lump data within each _START _END into their own namespace table
    -- so texture lumps for example, which are between TX_START and TX_END
    -- would be in self.namespace[textures].lumps[#] = { name=name, size=size, pos=filepos, data=filedata }
	utils:printf(0, "Building Namespaces...")
	self:buildNamespaces()

    -- all of these organizers run through a specific namespace
    -- it sets certain lumps to be ignored
    -- and puts all the data into their own table outside the self.namespace table
    -- so you get self.textures, self.patches, self.flats, ect
	utils:printf(0, "Organizing Graphics...")
	self:organizeNamespace("GG")

	utils:printf(0, "Organizing Flats...")
	self:organizeNamespace("FF")

	utils:printf(0, "Organizing Patches...")
	self:organizeNamespace("PP")

	utils:printf(0, "Organizing Sprites...")
	self:organizeNamespace("SS")

	utils:printf(0, "Organizing Zdoom Textures...")
	self:organizeNamespace("TX")

	utils:printf(0, "Organizing LMP Sounds...")
	self:organizeNamespace("DS")

	utils:printf(0, "Organizing WAV Sounds...")
	self:organizeNamespace("WS")

	utils:printf(0, "Organizing OGG Sounds...")
	self:organizeNamespace("OS")

	utils:printf(0, "Organizing FLAC Sounds...")
	self:organizeNamespace("CS")

	utils:printf(0, "Organizing Music...")
	self:organizeNamespace("MS")

    -- maps needed special organization code
	utils:printf(0, "Organizing Maps...")
	self:organizeMaps()

    -- read the palette, save each color into a table
    -- self.palette[entry] = { r, g, b }
	
    if(palette == nil) then
        utils:printf(0, "Processing Palette...")
	    self:processPalette()
    else
        utils:printf(0, "Skipping Palette...")
    end

    -- process the boom ANIMATED binary lump
    -- which stores all the texture animation definitions
	utils:printf(0, "Processing Boom Animations...")
	self:processAnimated()

    -- process the boom SWITCHES binary lump
    -- which stores all the switch animation definitions
	utils:printf(0, "Processing Boom Switches...")
	self:processSwitches()

    -- read doom's patch image format, with the loaded palette
    -- turn graphics into pngs
	utils:printf(0, "Processing Graphics...")
	self:buildImages(self.graphics, "Graphic")

    -- read doom's patch image format, with the loaded palette
    -- turn patches into pngs
	utils:printf(0, "Processing Patches...")
	self:buildImages(self.patches, "Patch")

    -- read doom's patch image format, with the loaded palette
    -- turn flats into pngs
	utils:printf(0, "Processing Flats...")
	self:buildFlats()

    -- read doom's patch image format, with the loaded palette
    -- turn sprites into pngs
	utils:printf(0, "Processing Sprites...")
	self:buildImages(self.sprites, "Sprite")

    -- read doom's PNAMES definition lump
	utils:printf(0, "Processing PNAMES...")
	self:processPnames()

    -- read through doom's TEXTUREx lump
    -- this lump makes new images in memory by stacking patches on top of each other
    -- we do the same, but then extract the result as a png
	utils:printf(0, "Processing TEXTUREx...")
	self:processTexturesX(1)
	self:processTexturesX(2)
	utils:printf(1, "\tDone.\n")

    -- simply just extract png files
    -- we no longer use this as zdoom textures namespace is now merged with patches
    --utils:printf(0, "Processing Zdoom Textures...")
	--self:moveZDoomTextures()

    -- find and remove duplicate files by md5 hash
	utils:printf(0, "Processing Duplicates...")
	self:filterDuplicates()

    -- rename all flats in this wad with a number system
	utils:printf(0, "Rename Flats...")
	self:renameFlats()

    -- rename all flats in this wad with a number system
	utils:printf(0, "Rename Sprites...")
	self:renameSprites()
   
    -- rename all composites in TEXTUREx with a number system
	utils:printf(0, "Rename Composites...")
	self:renameTextures()

    -- rename all patches in this wad with a number system
	utils:printf(0, "Rename Patches...")
	self:renamePatches()

    -- rename all sounds in this wad with a number system
	utils:printf(0, "Rename Sounds...")
	self:renameSounds()

    -- rename all songs in this wad with a number system
    utils:printf(0, "Rename Songs...")
    self:renameSongs()

    -- check of otex textures and mark them as to not rename them in maps
    --utils:printf(0, "Filtering OTEX Assets...")
    --self:filterOTexAssets()

    -- read zdoom's textures.txt (there is no code for this yet)
	utils:printf(0, "Processing TEXTURES...")
	self.textures.original = self:processTextLump("TEXTURES")

    -- read zdoom's animdefs.txt file
	utils:printf(0, "Processing ANIMDEFS...")
	self.animdefs.original = self:processTextLump("ANIMDEFS")

    -- this reads raw doom and hexen map data into tables
	utils:printf(0, "Processing Maps...")
	self:processMaps()

    -- this modifies maps in a number of ways
    -- renames all textures on the map with the newly renamed ones
    -- rebuilds sidedefs and sectors back into their binary form
    -- does this for doom hexen and udmf formats
	utils:printf(0, "Modifying Maps...")
	self:ModifyMaps()

    -- builds an animdefs.txt files for boom's ANIMATED and SWITCHES definitions
	utils:printf(0, "Processing ANIMDEFS for Doom/Boom...")
	self:buildAnimdefs()

    -- all the extracting ones should be self explanatory
    utils:printf(0, "Extracting Graphics...")
    self:extractGraphics()

	utils:printf(0, "Extracting Patches...")
	self:extractPatches()

	utils:printf(0, "Extracting Flats...")
	self:extractFlats()

	utils:printf(0, "Extracting Composites...")
	self:extractTextures()

	utils:printf(0, "Extracting Sprites...")
	self:extractSprites()

	utils:printf(0, "Extracting Maps...")
	self:extractMaps()

	utils:printf(0, "Extracting Sounds...")
	self:extractSounds()

    utils:printf(0, "Extracting Songs...")
    self:extractSongs()

	utils:printf(0, "Extracting ANIMDEFS...")
	self:extractAnimdefs()

	utils:printf(0, "Extracting TEXTURES...")
	self:extractTexturesLump()

	utils:printf(0, "Extracting SNDINFO...")
	self:extractSNDINFO()

    -- removed any unused textures found
	utils:printf(0, "Removing Unused Textures")
	self:removeUnusedTextures()

    -- we're done!
	utils:printf(0, "Complete.\n")
    
    -- free up memory
	collectgarbage()
end

function wad:initPalette(verbose, path)
	self.base = base or self
	self.pk3path = pk3path
	self.toolspath = toolspath
	self.extractpatches = patches or false
	self.spritesname = sprites
	self.apppath = love.filesystem.getSourceBaseDirectory():gsub("/", "\\")

    -- we are loading the raw wad data in to memory
	utils:printf(0, "Loading palette from mapset...", path)

    if(self.palette ~= nil) then
        return self.palette
    end
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
	utils:printf(1, "\tType: %s\n\tLumps: %d\n\tDirectory Position: 0x%X.\n\tBase: %s", self.header.magic, self.header.lumpcount, self.header.dirpos, isbase)
	utils:printf(1, "\tDone.\n")
end

function wad:addExtraMarkers()

    local lumplist = {}
    local lumplist_new = {}

    -- save all lumps into a table
    for lump = 0, self.header.lumpcount do
        lumpindex = #lumplist+1
        lumplist[lumpindex] = {}
		local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(lump*16))
        lumplist[lumpindex].filepos = filepos
        lumplist[lumpindex].size = size
        lumplist[lumpindex].name = utils:removePadding(name)
        lumplist[lumpindex].data = love.data.unpack(string.format("<c%d", size), self.raw, filepos+1)
    end
    ------------------
    -- specials 
    ------------------
    utils:printf(1, "\tCreating Specials Namespace...", name)

    -- make the SP_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "SP_START", data = ""}

    -- copy all the special lumps below the SP_START marker
    for l, lump in ipairs(lumplist) do
        for s, special in ipairs(self.specialslist) do
            if lump.name == special then
                utils:printf(2, "\t\tFound %s", special)
                lumplist_new[#lumplist_new+1] = lump
            end
        end
    end

    -- make the SP_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "SP_END", data = ""}

    ------------------
    -- graphics
    ------------------
    utils:printf(1, "\tCreating Graphics Namespace...", name)

    -- make the GG_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "GG_START", data = ""}

    -- copy all the graphics lumps below the GG_START marker
    for l, lump in ipairs(lumplist) do
        for g, graphic in ipairs(self.graphicslist) do
            if lump.name == graphic[1] then
                local newname = self.acronym .. graphic[2]
                utils:printf(2, "\t\tFound %s; renaming to %s", graphic[1], newname)
                lump.name = newname
                lumplist_new[#lumplist_new+1] = lump
            end
        end
    end

    -- make the GG_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "GG_END", data = ""}

    ------------------
    -- maps
    ------------------
    utils:printf(1, "\tCreating Maps Namespace...", name)

    -- make the MM_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "MM_START", data = ""}

    -- copy all the map lumps below the MM_START marker
    local maplist = {}

    -- go through all the lumps
    for l, lump in ipairs(lumplist) do

        -- find markers
        --if(lump.size == 0) then

            -- make sure we wont hit the end of the list
            if l+10 <= #lumplist then
                local t = "Doom"
                local function continue()
                    if lumplist[l+1].name ~= "THINGS" then return false end
                    if lumplist[l+2].name ~= "LINEDEFS" then return false end
                    if lumplist[l+3].name ~= "SIDEDEFS" then return false end
                    if lumplist[l+4].name ~= "VERTEXES" then return false end
                    if lumplist[l+5].name ~= "SEGS" then return  false end
                    if lumplist[l+6].name ~= "SSECTORS" then return  false end
                    if lumplist[l+7].name ~= "NODES" then return false end
                    if lumplist[l+8].name ~= "SECTORS" then return false end
                    if lumplist[l+9].name ~= "REJECT" then return false end
                    if lumplist[l+10].name ~= "BLOCKMAP" then return false end
                    return true
                end
                if continue() then
                    if l+11 <= #lumplist then
                        if lumplist[l+11].name == "BEHAVIOR" then 
                            t = "Hexen"
                        end
                    end

                    if t == "Doom" then
                        lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "DM_START", data = ""}
                        for ll = l, l+10 do
                            lumplist_new[#lumplist_new+1] = lumplist[ll]
                        end
                        lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "DM_END", data = ""}

                    elseif t == "Hexen" then
                        lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "HM_START", data = ""}
                        for ll = l, l+10 do
                            lumplist_new[#lumplist_new+1] = lumplist[ll]
                        end
                        lumplist_new[#lumplist_new+1] = lumplist[l+11]
                        if l+12 <= #lumplist then
                            if lumplist[l+12].name == "SCRIPTS" then 
                                lumplist_new[#lumplist_new+1] = lumplist[l+12]
                            end
                        end
                        lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "HM_END", data = ""}
                    end

                    utils:printf(2, "\t\tFound %s Format Map: %s", t, lumplist[l].name)
                end
            end

            if l+1 < #lumplist then
                if lumplist[l+1].name == "TEXTMAP" then
                    for ll = l, #lumplist do
                        if lumplist[ll].name == "ENDMAP" then 
                            lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "UM_START", data = ""}
                            for lll = l, ll do
                                lumplist_new[#lumplist_new+1] = lumplist[lll]
                            end
                            utils:printf(5)
                            lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "UM_END", data = ""}
                            t = "UDMF"
                            break;
                        end
                    end
                    utils:printf(2, "\t\tFound %s Format Map: %s", t, lumplist[l].name)
                end
            end
        --end
    end
    -- make the MM_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "MM_END", data = ""} 

    ------------------
    -- doom sounds
    ------------------
    utils:printf(1, "\tCreating Doom Sounds Namespace...", name)

    -- make the DS_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "DS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name:sub(1, 2) == "DS" then
            utils:printf(2, "\t\tFound Doom Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the DS_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "DS_END", data = ""}

    ------------------
    -- wave sounds
    ------------------
    utils:printf(1, "\tCreating Wave Sounds Namespace...", name)

    -- make the WS_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "WS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name:sub(1, 4) == "RIFF" then
            utils:printf(2, "\t\tFound Wave Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the WS_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "WS_END", data = ""}

    ------------------
    -- ogg sounds
    ------------------
    utils:printf(1, "\tCreating Ogg Sounds Namespace...", name)

    -- make the OS_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "OS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.data:sub(1, 3) == "Ogg" then
            utils:printf(2, "\t\tFound OGG Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the OS_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "OS_END", data = ""}  

    ------------------
    -- flac sounds
    ------------------
    utils:printf(1, "\tCreating Flac Sounds Namespace...", name)

    -- make the CS_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "CS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.data:sub(1, 4) == "fLaC" then
            utils:printf(2, "\t\tFound FLAC Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the CS_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "CS_END", data = ""}    

    ------------------
    -- music
    ------------------
    utils:printf(1, "\tCreating Music Namespace...", name)

    -- make the MS_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "MS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.data:sub(1, 3) == "MUS" then
            utils:printf(2, "\t\tFound MUS song: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
        if lump.data:sub(1, 4) == "MThd" then
            utils:printf(2, "\t\tFound MIDI song: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the MS_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "MS_END", data = ""}

    ------------------
    -- texture
    ------------------
    utils:printf(1, "\tCreating Textures Namespace...", name)

    -- make the TX_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "TX_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name == "TX_START" then
            for ll = l, #lumplist do
                if lumplist[ll].name == "TX_END" then
                    for lll = l, ll do
                        utils:printf(2, "\t\tFound Texture: %s", lumplist[lll].name)
                        lumplist_new[#lumplist_new+1] = lumplist[lll]
                    end
                    break
                end
            end
        end
    end

    -- make the TX_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "TX_END", data = ""}

    ------------------
    -- sprites
    ------------------
    utils:printf(1, "\tCreating Sprites Namespace...", name)

    -- make the S_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "SS_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name == "S_START" or lump.name == "SS_START" then
            for ll = l, #lumplist do
                if lumplist[ll].name == "S_END" or lumplist[ll].name == "SS_END" then
                    for lll = l+1, ll-1 do
                        utils:printf(2, "\t\tFound Sprite: %s", lumplist[lll].name)
                        lumplist_new[#lumplist_new+1] = lumplist[lll]
                    end
                    break
                end
            end
        end
    end

    -- make the S_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "SS_END", data = ""}

    ------------------
    -- flats
    ------------------
    utils:printf(1, "\tCreating Flats Namespace...", name)

    -- make the F_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "FF_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name == "F_START" or lump.name == "FF_START" then
            for ll = l, #lumplist do
                if lumplist[ll].name == "F_END" or lumplist[ll].name == "FF_END" then
                    for lll = l+1, ll-1 do
                        if lumplist[lll].name:sub(1,8) ~= "F1_START" and lumplist[lll].name:sub(1,8) ~= "F2_START" and lumplist[lll].name:sub(1,8) ~= "F3_START" then
                            if lumplist[lll].name:sub(1,6) ~= "F1_END" and lumplist[lll].name:sub(1,6) ~= "F2_END" and lumplist[lll].name:sub(1,6) ~= "F3_END" then
                                utils:printf(2, "\t\tFound Flat: %s", lumplist[lll].name)
                                lumplist_new[#lumplist_new+1] = lumplist[lll]
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    -- make the F_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "FF_END", data = ""}

    ------------------
    -- patches
    ------------------
    utils:printf(1, "\tCreating Patches Namespace...", name)

    -- make the P_START marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "PP_START", data = ""}

    for l, lump in ipairs(lumplist) do
        if lump.name == "P_START" or lump.name == "PP_START" then
            for ll = l, #lumplist do
                if lumplist[ll].name == "P_END" or lumplist[ll].name == "PP_END" then
                    for lll = l+1, ll-1 do
                        if lumplist[lll].name:sub(1,8) ~= "P1_START" and lumplist[lll].name:sub(1,8) ~= "P2_START" and lumplist[lll].name:sub(1,8) ~= "P3_START" then
                            if lumplist[lll].name:sub(1,6) ~= "P1_END" and lumplist[lll].name:sub(1,6) ~= "P2_END" and lumplist[lll].name:sub(1,6) ~= "P3_END" then
                                utils:printf(2, "\t\tFound Patch: %s", lumplist[lll].name)
                                lumplist_new[#lumplist_new+1] = lumplist[lll]
                            end
                        end
                    end
                    break
                end
            end
        end
    end

    -- make the P_END marker
    lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = "PP_END", data = ""}

    -- lump data
    local pos = {}
    local lumpchunk = ""

    utils:printf(1, "\tConcatenating lump data...")


    local datatable = {}
    local size = 0
    for lump = 1, #lumplist_new do
        pos[lump] = size
        datatable[lump] = lumplist_new[lump].data
        size = size + lumplist_new[lump].size
    end
    lumpchunk = table.concat(datatable)

	-- header
	local header = love.data.pack("string", "<c4i4i4", self.header.magic, #lumplist_new, 12+#lumpchunk)

    -- dir
    local dir = ""

    for lump = 1, #lumplist_new do
        dir = dir .. love.data.pack("string", "<i4i4c8", pos[lump]+12, #lumplist_new[lump].data, lumplist_new[lump].name)
    end

    collectgarbage()
    self.raw = header .. lumpchunk .. dir
    self:gatherHeader()
end

function wad:buildNamespaces()
	local found = false
	local namespace = ""
    local foundend = false

	for l = 0, self.header.lumpcount do

		-- get file meta data
		local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(l*16))
		name = string.upper(utils:removePadding(name))
		filepos = filepos+1
        
		-- get file data
		local filedata = love.data.unpack(string.format("<c%d", size), self.raw, filepos)

		-- end namespace
		if(name == string.format("%s_END", namespace)) then
			found = false
			utils:printf(1, "\tFound End of Namespace %s.", name)
            foundend = true
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
			utils:printf(1, "\tFound Start of Namespace %s.", name)
		end
	end
    if(not foundend) then
        utils:printf(0, "\tCould not find the end marker of namespace %s", name)
        error()
    end
	utils:printf(1, "\tDone.\n")
	collectgarbage()
end

function wad:organizeNamespace(name)
	-- are there any lumps?
	if(#self.namespaces[name].lumps > 0) then

		-- for each lump in the namespace
		for l = 1, #self.namespaces[name].lumps do
			if(self.namespaces[name].lumps[l].size > 0) then
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
		end
		utils:printf(1, "\tFound '%d' %s.", #self[self.namespaces[name].name], self.namespaces[name].name)
	else
		utils:printf(1, "\tNo '%s' found.", self.namespaces[name].name)
	end
	collectgarbage()
	utils:printf(1, "\tDone.\n")
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
                utils:printf(2, "\tFound %s", self.maps[m].name)
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

			utils:printf(1, "\tDoom Maps: '%d' \n\tHexen Maps: '%d' \n\tUDMF Maps: '%d'", count_dm, count_hm, count_um)
		end
		collectgarbage()
	else
		utils:printf(1, "\tNot organizing base wad maps.")
	end
	collectgarbage()
	utils:printf(1, "\tDone.\n")
end

function wad:processPalette()
	-- find PLAYPAL
	local paldata = self:findLump("SP", "PLAYPAL")

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
		utils:printf(1, "\tNo PLAYPAL found. using base wad PLAYPAL.")
	end
	collectgarbage()
	utils:printf(1, "\tDone.\n")
end

function wad:buildFlats()
	for f = 1, #self.flats do
		local flat = self.flats[f]
		local t = "Flat"

		if (not utils:checkFormat(flat.data, "PNG", 2, true)) then
			utils:printfNoNewLine(2, "\tBuilding Flat: %s; Type: %s ", flat.name, t)
			flat.image = love.image.newImageData(64, 64)
			flat.rows = {}

			local pcount = 0
			for y = 1, 64 do
				for x = 1, 64 do
					pcount = pcount + 1
					self:setPixelForPalette(flat.image, x, y, flat.data, pcount)
				end
			end

			flat.png = flat.image:encode("png"):getString()
			flat.md5 = love.data.hash("md5", flat.png)
			utils:printf(2, "Checksum: %s;", love.data.encode("string", "hex", flat.md5))
		else
			t = "PNG"
			utils:printfNoNewLine(2, "\tBuilding Flat: %s; Type: %s ", flat.name, t)
			flat.png = flat.data
			flat.image = love.graphics.newImage(love.image.newImageData(love.data.newByteData(flat.png)))
			flat.md5 = love.data.hash("md5", flat.png)
			utils:printf(2, "Checksum: %s;", love.data.encode("string", "hex", flat.md5))
			flat.notdoomflat = true
		end
		self.flats[flat.name] = flat
	end

	collectgarbage()
	utils:printf(1, "\tDone.\n")
end

function wad:buildImages(images, imagetype)
	for i = 1, #images do
		local image = images[i]

		if (not utils:checkFormat(image.data, "PNG", 2, true)) then
			utils:printfNoNewLine(2, "\tBuilding %s: %s; Type: %s; ", imagetype, image.name, imagetype)
			image.width = love.data.unpack("<H", image.data)
			image.height = love.data.unpack("<H", image.data, 3)
			image.xoffset = love.data.unpack("<h", image.data, 5)
			image.yoffset = love.data.unpack("<h", image.data, 7)
			image.imagedata = love.image.newImageData(image.width, image.height)
			utils:printfNoNewLine(2, "Width: %d; Height: %d; Xoff: %d; Yoff: %d; ", image.width, image.height, image.xoffset, image.yoffset)
			image.columns = {}

			for c = 1, image.width do
				image.columns[c] = love.data.unpack("<i4", image.data, 9+((c-1)*4))
			end

			local pleiadeshack = false
			if image.height == 256 then
				pleiadeshack = true
				for c = 2, image.width do
					if image.columns[c] - image.columns[c-1] ~= 261 then
						pleiadeshack = false
						break;
					end
				end
				if #image.data - image.columns[image.width] ~= 261 then
					pleiadeshack = false;
				end
			end

			for c = 1, image.width do
				local row = 0
				local post = image.columns[c]+1

				while (row ~= 0xFF) do
					local top = row

					row = love.data.unpack("<B", image.data, post)
					if (row == 0xFF) then break end

					-- tall images
					if (row <= top) then
						row = row+top
					end

					local length = love.data.unpack("<B", image.data, post+1)

					-- 256 height fix
					if pleiadeshack then
						length = 255
					end

					local data = image.data:sub(post+3, post+3+length)

					for pixel = 1, length do
						self:setPixelForPalette(image.imagedata, c, row+pixel, data, pixel)
					end

					post = post+4+length
				end
			end

			image.image = love.graphics.newImage(image.imagedata)
			image.png = image.imagedata:encode("png"):getString()
            image.png = utils:insertGRAB(image.png, image.xoffset, image.yoffset)
			image.md5 = love.data.hash("md5", image.png)
			utils:printf(2, "Checksum: %s;", love.data.encode("string", "hex", image.md5))
		else
			utils:printfNoNewLine(2, "\tBuilding %s: %s; Type: PNG; ", imagetype, image.name)
			filedata = love.filesystem.newFileData(image.data, "-")
			image.imagedata = love.image.newImageData(filedata)

			image.width = image.imagedata:getWidth()
			image.height = image.imagedata:getHeight()
			local offx, offy = utils:readGRAB(image.data)
			image.xoffset = offx or 0
			image.yoffset = offy or 0
			utils:printfNoNewLine(2, "Width: %d; Height: %d; Xoff: %d; Yoff: %d; ", image.width, image.height, image.xoffset, image.yoffset)

			image.image = love.graphics.newImage(image.imagedata)
			image.png = image.imagedata:encode("png"):getString()
			image.md5 = love.data.hash("md5", image.png)
			utils:printf(2, "Checksum: %s;", love.data.encode("string", "hex", image.md5))
			image.notdoompatch = true
		end
		images[image.name] = image
	end
	collectgarbage()
	utils:printf(1, "\tDone.\n")
end

function wad:setPixelForPalette(image, x, y, colordata, colorindex)
	local color = love.data.unpack("<B", colordata, colorindex) + 1
	local palettergb = self.palette[color]

	image:setPixel(x-1, y-1, palettergb[1], palettergb[2], palettergb[3], 1.0)
end

function wad:processPnames()

	-- find PNAMES
	local pndata = self:findLump("SP", "PNAMES")

	-- if PNAMES found
	if(pndata ~= "") then
		local count = love.data.unpack("<i4", pndata)
		for p = 5, count*8, 8 do
			local index = #self.pnames+1
			self.pnames[index] = utils:removePadding(love.data.unpack("<c8", pndata, p)):upper()
            utils:printf(2, "\tFound PNAMES Patch: %s", self.pnames[index])
		end
		utils:printf(1, "\tFound '%d' PNAMES patches.", #self.pnames)
	else
		self.pnames = self.base.pnames
		utils:printf(1, "\tNo PNAMES found. Using base wad PNAMES.")
	end
	collectgarbage()
	utils:printf(1, "\tDone.\n")
end

function wad:processTexturesX(num)
	-- find TEXTUREx
    local data = self:findLump("SP", string.format("TEXTURE%d", num))

	-- if TEXTUREx found
	if(data ~= "") then
		-- header
		local numtextures = love.data.unpack("<i4", data)
		local offsets = {}
		for i = 5, (numtextures*4)+4, 4 do
			offsets[#offsets+1] = love.data.unpack("<i4", data, i)+1
		end

		-- maptexture_t
		for i = 1, #offsets do
			local c = #self.composites+1

			self.composites[c] = {}

			local composite = self.composites[c]

			composite.name = utils:removePadding(love.data.unpack("<c8", data, offsets[i]))
			composite.flags = love.data.unpack("<H", data, offsets[i]+8)
			composite.scalex = love.data.unpack("<B", data, offsets[i]+0x0A)
			composite.scaley = love.data.unpack("<B", data, offsets[i]+0x0B)
			composite.width = love.data.unpack("<h", data, offsets[i]+0x0C)
			composite.height = love.data.unpack("<H", data, offsets[i]+0x0E)
			composite.unused1 = love.data.unpack("<B", data, offsets[i]+0x10)
			composite.unused2 = love.data.unpack("<B", data, offsets[i]+0x11)
			composite.unused3 = love.data.unpack("<B", data, offsets[i]+0x12)
			composite.unused4 = love.data.unpack("<B", data, offsets[i]+0x13)
			composite.patchcount = love.data.unpack("<h", data, offsets[i]+0x14)
			composite.patches = {}
			composite.canvas = love.graphics.newCanvas(composite.width, composite.height)
			composite.dups = {}
			composite.isdoomdup = false

			local istexturepatch = composite.patchcount == 1

			-- mappatch_t
			love.graphics.setCanvas(composite.canvas)
			for p = 1, composite.patchcount do
				composite.patches[p] = {}

				local compositepatch = composite.patches[p]

				compositepatch.x = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10))
				compositepatch.y = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+2)
				compositepatch.patch = self.pnames[love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+4)+1]
				compositepatch.stepdir = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+6)
				compositepatch.colormap = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+8)

				local patchdata = self.patches[compositepatch.patch]

				-- patches
				if (patchdata == nil) then
					local notfound = true
					patchdata = self.base.patches[compositepatch.patch]

					if (patchdata ~= nil) then
						if (istexturepatch and patchdata.composite == nil) then
							patchdata.composite = composite
						end

						love.graphics.draw(patchdata.image, compositepatch.x, compositepatch.y)
						notfound = false
					end

					-- flats
					if (notfound) then
						--love.graphics.draw(self.flats[compositepatch.patch].image, compositepatch.x, compositepatch.y)
					end
				else
					if (istexturepatch and patchdata.composite == nil) then
						patchdata.composite = composite
					end

					love.graphics.draw(patchdata.image, compositepatch.x, compositepatch.y)
				end

			end
			love.graphics.setCanvas()

			composite.png = composite.canvas:newImageData():encode("png"):getString()
			composite.md5 = love.data.hash("md5", composite.png)

            utils:printf(2, "\tBuilding Composite Texture: %s, Checksum: %s", composite.name, love.data.encode("string", "hex", composite.md5))
		end
	utils:printf(1, "\tFound '%d' composite textures.", numtextures)
	else
		--self.composites = self.base.composites
		--utils:printf(1, "\tNo %s found. using base wad %s", lumpname, lumpname)
	end
	collectgarbage()
end

function wad:processAnimated()

	-- find ANIMATED
	local data = self:findLump("SP", "ANIMATED")

	-- if ANIMATED found
	if(data ~= "") then

		local t = love.data.unpack("<B", data)
		local count = 0
		while(t ~= 255) do

			local last = utils:removePadding(love.data.unpack("<c8", data, 2+count)):upper()
			local first = utils:removePadding(love.data.unpack("<c8", data, 11+count)):upper()
			local speed = love.data.unpack("<i4", data, 20+count)

			local isdup = false
			for d = 1, #self.animlist do
				if(self.animlist[d][2] == first) then
					if(self.animlist[d][3] == last) then
                        utils:printf(2, "\tFound Duplicate ANIMATED define: %s %s to %s with speed %s", t, first, last, speed)
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
                utils:printf(2, "\tFound ANIMATED define: %s to %s with speed %s", first, last, speed)
			end

			count = count + 23
			t = love.data.unpack("<B", data, 1+count)
		end
        utils:printf(1, "\tFound '%d' ANIMATED defines.", #self.animlist)
	end
end

function wad:processSwitches()

	-- find SWITCHES
	local data = self:findLump("SP", "SWITCHES")

	-- if SWITCHES found
	if(data ~= "") then

		local t = 1
		local count = 0
		while(t ~= 0) do

			local off = utils:removePadding(love.data.unpack("<c8", data, 1+count)):upper()
			local on = utils:removePadding(love.data.unpack("<c8", data, 10+count)):upper()
			t = love.data.unpack("<H", data, 19+count)

			local isdup = false
			for d = 1, #self.switchlist do
				if(self.switchlist[d][1] == off) then
					if(self.switchlist[d][2] == on) then
						isdup = true
					end
				end
			end
            utils:printf(2, "\tFound SWITCH define: %s, %s, %s", off, on, t)
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
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot moving base wad zdoom textures.\n")
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

	utils:printf(1, "\tFound '%d' duplicates", count)
	count = 0
	-- filter dups from base wad
	if(self.base ~= self) then
		-- composites
		count = count + self:flagDuplicateAssets(self.composites, self.base.composites)

		-- flats
		count = count + self:flagDuplicateAssets(self.flats, self.base.flats)

		-- patches
		count = count + self:flagDuplicateAssets(self.patches, self.base.patches)

		-- sprites
		count = count + self:flagDuplicateAssets(self.sprites, self.base.sprites)

	end

	utils:printf(1, "\tFound '%d' doom duplicates", count)
	utils:printf(1, "\tDone.\n")
    collectgarbage()
end

function wad:flagDuplicateAssets(pwadassets, baseassets)
	local totalduplicates = 0

	for a = 1, #pwadassets do
		local pwadasset = pwadassets[a]

		for a2 = 1, #baseassets do
			local baseasset = baseassets[a2]

			if (pwadasset.md5 == baseasset.md5) then
				totalduplicates = totalduplicates + 1
				pwadasset.isdoomdup = true
				pwadasset.doomdup = baseasset.name
				utils:printf(2, "\tFound pwad:'%s' and base:'%s' duplicates.", pwadasset.name, baseasset.name)
			end
		end
	end
	
	return totalduplicates
end

function wad:renamePatches()
	if(self.base ~= self) then
		local patchcount = self:renameAssets(self.patches)
		utils:printf(1, "\tDone. Found %d patches.\n", patchcount)
	else
		utils:printf(1, "\tNot renaming base wad patches.\n")
	end
    collectgarbage()
end

function wad:renameTextures()
	if(self.base ~= self) then
		local texturecount = self:renameAssets(self.composites)
		utils:printf(1, "\tDone. Found %d composites.\n", texturecount)
	else
		utils:printf(1, "\tNot renaming base wad textures.\n")
	end
    collectgarbage()
end

function wad:renameFlats()
	if(self.base ~= self) then
		local flatcount = self:renameAssets(self.flats)
		utils:printf(1, "\tDone. Found %d flats.\n", flatcount)
	else
		utils:printf(1, "\tNot renaming base wad flats.\n")
	end
    collectgarbage()
end

function wad:renameAssets(assets)
	local assetcount = #assets

	for a = 1, assetcount do
		local asset = assets[a]

		self.texturecount = self.texturecount + 1
        local newname = string.format("%s%.4d", self.acronym, self.texturecount)

        if self.texturecount > 9999 then
            self.texturecount2 = self.texturecount2 + 1
            newname = string.format("%s%.4d", "ZZZZ", self.texturecount2)
        end
       
		utils:printf(2, "\tRenaming %s to %s", asset.name, newname)
		asset.newname = newname
	end

	return assetcount
end

function wad:renameSprites()
	if(self.base ~= self) then

        local spritesets = {}
        local setcount = 0
        for s = 1, #self.sprites do
            local set = self.sprites[s].name:sub(1, 4)
            if(spritesets[set] == nil) then 
                spritesets[set] = {} 
                setcount = setcount + 1
                utils:printf(1, "\tFound Sprite Set: %s", set)
            end
            self.sprites[s].newname = string.format("%s%02d%s", self.acronym_sprite, setcount, self.sprites[s].name:sub(5))
            utils:printf(2, "\tRenamed %s to %s", self.sprites[s].name, self.sprites[s].newname)
        end

        utils:printf(1, "\tFound %d Sprite Sets.", setcount)
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot renaming base wad patches.\n")
	end
    collectgarbage()
end

function wad:renameSounds()
	if(self.base ~= self) then

		--LMP
		for s = 1, #self.doomsounds do
			self.soundcount = self.soundcount + 1
			self.doomsounds[s].newname = string.format("%s%.4d", self.acronym, self.soundcount)
            utils:printf(2, "\tRenamed %s to %s", self.doomsounds[s].name, self.doomsounds[s].newname)
		end

		--WAV
		for s = 1, #self.wavesounds do
			self.soundcount = self.soundcount + 1
			self.wavesounds[s].newname = string.format("%s%.4d", self.acronym, self.soundcount)
            utils:printf(2, "\tRenamed %s to %s", self.wavesounds[s].name, self.wavesounds[s].newname)
		end

		--OGG
		for s = 1, #self.oggsounds do
			self.soundcount = self.soundcount + 1
			self.oggsounds[s].newname = string.format("%s%.4d", self.acronym, self.soundcount)
            utils:printf(2, "\tRenamed %s to %s", self.oggsounds[s].name, self.oggsounds[s].newname)
		end

		--FLAC
		for s = 1, #self.flacsounds do
			self.soundcount = self.soundcount + 1
			self.flacsounds[s].newname = string.format("%s%.4d", self.acronym, self.soundcount)
            utils:printf(2, "\tRenamed %s to %s", self.flacsounds[s].name, self.flacsounds[s].newname)
		end
		utils:printf(1, "\tDone.\n")
	end
	collectgarbage()
end

function wad:renameSongs()
    if self.base ~= self then
        for l = 1, #self.music_list do
            local lump = self:findLump("MS", self.music_list[l])
            if lump ~= "" then
                for s = 1, #self.songs do
                    if self.songs[s].data == lump then
                        self.songs[s].newname = string.format("%s%.2d", self.acronym, l)
						if l == 33 then
							self.songs[s].newname = string.format("%sIN", self.acronym)
						end
                        utils:printf(2, "\tRenamed %s to %s", self.songs[s].name, self.songs[s].newname)
                        break
                    end
                end
            end
        end
        utils:printf(1, "\tDone.\n")
    end
    collectgarbage()
end

function wad:filterOTexAssets()
    local count = 0
    for a = 1, #self.flats do
        local flat = self.flats[a]
        if otex:checkImageExists(flat.name, flat.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Flat: %s", flat.name)
            flat.isotex = true
        end
    end
    for a = 1, #self.patches do
        local patch = self.patches[a]
        if otex:checkImageExists(patch.name, patch.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Patch: %s", patch.name)
            patch.isotex = true
        end
    end
    for a = 1, #self.composites do
        local composite = self.composites[a]
        if otex:checkImageExists(composite.name, composite.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Composite: %s", composite.name)
            composite.isotex = true
        end
    end
    utils:printf(1, "\tDone. Found %d OTex Assets.\n", count)
end

function wad:processTextLump(name)

	-- find ANIMDEFS
	local data = self:findLump("SP", name)

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
			--if(self.composites[c].used == true) then
				for al = 1, #self.animlist do
					if(not self.composites[c].isdoomdup) then
						if(self.composites[c].name == self.animlist[al][2]) then
							if(self.animlist[al][1] == "texture") then
                                utils:printf(2, "\tBuilding Animation: texture %s to %s", self.composites[c].name, self.animlist[al][3])
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
			--end
		end

		for f = 1, #self.flats do
			--if(self.flats[f].used) then
				for al = 1, #self.animlist do
					if(not self.flats[f].isdoomdup) then
						if(self.flats[f].name == self.animlist[al][2]) then
							if(self.animlist[al][1] == "flat") then
                                utils:printf(2, "\tBuilding Animation: flat %s to %s", self.flats[f].name, self.animlist[al][3])
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
			--end
		end

		-- switches
		self.animdefs.switches = {}

		for c = 1, #self.composites do
			--if(self.composites[c].used) then
				for sl = 1, #self.switchlist do
					if(self.composites[c].name == self.switchlist[sl][1]) then
                        utils:printf(2, "\tBuilding Switch: %s to %s", self.composites[c].name, self.switchlist[sl][2])
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
			--end
		end
		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot building animdefs for base wad.\n")
	end
end

function wad:processMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do
			utils:printf(2, "\tProcessing Map: %d, %s", m, self.maps[m].name)

			-- doom
			if(self.maps[m].format == "DM") then

				-- things
				self.maps[m].things = {}
				local count = 0
				for s = 1, #self.maps[m].raw.things, 10 do
					count = count + 1
					self.maps[m].things[count] = {}
					self.maps[m].things[count].x = love.data.unpack("<h", self.maps[m].raw.things, s)
					self.maps[m].things[count].y = love.data.unpack("<h", self.maps[m].raw.things, s+2)
					self.maps[m].things[count].angle = love.data.unpack("<H", self.maps[m].raw.things, s+4)
					self.maps[m].things[count].typ = love.data.unpack("<H", self.maps[m].raw.things, s+6)
					self.maps[m].things[count].flags = love.data.unpack("<H", self.maps[m].raw.things, s+8)
				end

				-- linedefs
				self.maps[m].linedefs = {}
				count = 0
				for s = 1, #self.maps[m].raw.linedefs, 14 do
					count = count + 1
					self.maps[m].linedefs[count] = {}
					self.maps[m].linedefs[count].vertex_start = love.data.unpack("<H", self.maps[m].raw.linedefs, s)
					self.maps[m].linedefs[count].vertex_end = love.data.unpack("<H", self.maps[m].raw.linedefs, s+2)
					self.maps[m].linedefs[count].flags = love.data.unpack("<H", self.maps[m].raw.linedefs, s+4)
					self.maps[m].linedefs[count].line_type = love.data.unpack("<H", self.maps[m].raw.linedefs, s+6)
					self.maps[m].linedefs[count].sector_tag = love.data.unpack("<H", self.maps[m].raw.linedefs, s+8)
					self.maps[m].linedefs[count].sidedef_right =love.data.unpack("<H", self.maps[m].raw.linedefs, s+10)
					self.maps[m].linedefs[count].sidedef_left = love.data.unpack("<H", self.maps[m].raw.linedefs, s+12)
				end

				-- sidedefs
				self.maps[m].sidedefs = {}
				count = 0
				for s = 1, #self.maps[m].raw.sidedefs, 30 do
					count = count + 1
					self.maps[m].sidedefs[count] = {}
					self.maps[m].sidedefs[count].xoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s)
					self.maps[m].sidedefs[count].yoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s+2)
					self.maps[m].sidedefs[count].upper_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+4)))
					self.maps[m].sidedefs[count].lower_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+12)))
					self.maps[m].sidedefs[count].middle_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+20)))
					self.maps[m].sidedefs[count].sector = love.data.unpack("<H", self.maps[m].raw.sidedefs, s+28)
				end

				-- vertexes
				self.maps[m].vertexes = {}
				count = 0
				for s = 1, #self.maps[m].raw.vertexes, 4 do
					count = count + 1
					self.maps[m].vertexes[count] = {}
					self.maps[m].vertexes[count].x = love.data.unpack("<h", self.maps[m].raw.vertexes, s)
					self.maps[m].vertexes[count].y = love.data.unpack("<h", self.maps[m].raw.vertexes, s+2)
				end

				-- sectors
				self.maps[m].sectors = {}
				count = 0
				for s = 1, #self.maps[m].raw.sectors, 26 do
					count = count + 1
					self.maps[m].sectors[count] = {}
					self.maps[m].sectors[count].floor_height = love.data.unpack("<h", self.maps[m].raw.sectors, s)
					self.maps[m].sectors[count].ceiling_height = love.data.unpack("<h", self.maps[m].raw.sectors, s+2)
					self.maps[m].sectors[count].floor_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+4)))
					self.maps[m].sectors[count].ceiling_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+12)))
					self.maps[m].sectors[count].light = love.data.unpack("<h", self.maps[m].raw.sectors, s+20)
					self.maps[m].sectors[count].special = love.data.unpack("<H", self.maps[m].raw.sectors, s+22)
					self.maps[m].sectors[count].tag = love.data.unpack("<H", self.maps[m].raw.sectors, s+24)
				end

			--hexen
			elseif(self.maps[m].format == "HM") then

				-- things
				self.maps[m].things = {}
				local count = 0
				for s = 1, #self.maps[m].raw.things, 20 do
					count = count + 1
					self.maps[m].things[count] = {}
					self.maps[m].things[count].id = love.data.unpack("<H", self.maps[m].raw.things, s)
					self.maps[m].things[count].x = love.data.unpack("<h", self.maps[m].raw.things, s+2)
					self.maps[m].things[count].y = love.data.unpack("<h", self.maps[m].raw.things, s+4)
					self.maps[m].things[count].z = love.data.unpack("<h", self.maps[m].raw.things, s+6)
					self.maps[m].things[count].angle = love.data.unpack("<H", self.maps[m].raw.things, s+8)
					self.maps[m].things[count].typ = love.data.unpack("<H", self.maps[m].raw.things, s+10)
					self.maps[m].things[count].flags = love.data.unpack("<H", self.maps[m].raw.things, s+12)
					self.maps[m].things[count].special = love.data.unpack("<B", self.maps[m].raw.things, s+14)
					self.maps[m].things[count].a1 = love.data.unpack("<B", self.maps[m].raw.things, s+15)
					self.maps[m].things[count].a2 = love.data.unpack("<B", self.maps[m].raw.things, s+16)
					self.maps[m].things[count].a3 = love.data.unpack("<B", self.maps[m].raw.things, s+17)
					self.maps[m].things[count].a4 = love.data.unpack("<B", self.maps[m].raw.things, s+18)
					self.maps[m].things[count].a5 = love.data.unpack("<B", self.maps[m].raw.things, s+19)
				end

				-- linedefs
				self.maps[m].linedefs = {}
				count = 0
				for s = 1, #self.maps[m].raw.linedefs, 16 do
					count = count + 1
					self.maps[m].linedefs[count] = {}
					self.maps[m].linedefs[count].vertex_start = love.data.unpack("<H", self.maps[m].raw.linedefs, s)
					self.maps[m].linedefs[count].vertex_end = love.data.unpack("<H", self.maps[m].raw.linedefs, s+2)
					self.maps[m].linedefs[count].flags = love.data.unpack("<H", self.maps[m].raw.linedefs, s+4)
					self.maps[m].linedefs[count].special = love.data.unpack("<B", self.maps[m].raw.linedefs, s+6)
					self.maps[m].linedefs[count].a1 = love.data.unpack("<B", self.maps[m].raw.linedefs, s+7)
					self.maps[m].linedefs[count].a2 = love.data.unpack("<B", self.maps[m].raw.linedefs, s+8)
					self.maps[m].linedefs[count].a3 = love.data.unpack("<B", self.maps[m].raw.linedefs, s+9)
					self.maps[m].linedefs[count].a4 = love.data.unpack("<B", self.maps[m].raw.linedefs, s+10)
					self.maps[m].linedefs[count].a5 = love.data.unpack("<B", self.maps[m].raw.linedefs, s+11)
					self.maps[m].linedefs[count].front_sidedef = love.data.unpack("<B", self.maps[m].raw.linedefs, s+12)
					self.maps[m].linedefs[count].back_sidedef = love.data.unpack("<B", self.maps[m].raw.linedefs, s+14)
				end

				-- sidedefs
				self.maps[m].sidedefs = {}
				count = 0
				for s = 1, #self.maps[m].raw.sidedefs, 30 do
					count = count + 1
					self.maps[m].sidedefs[count] = {}
					self.maps[m].sidedefs[count].xoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s)
					self.maps[m].sidedefs[count].yoffset = love.data.unpack("<h", self.maps[m].raw.sidedefs, s+2)
					self.maps[m].sidedefs[count].upper_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+4)))
					self.maps[m].sidedefs[count].lower_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+12)))
					self.maps[m].sidedefs[count].middle_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sidedefs, s+20)))
					self.maps[m].sidedefs[count].sector = love.data.unpack("<H", self.maps[m].raw.sidedefs, s+28)
				end

				-- vertexes
				self.maps[m].vertexes = {}
				count = 0
				for s = 1, #self.maps[m].raw.vertexes, 4 do
					count = count + 1
					self.maps[m].vertexes[count] = {}
					self.maps[m].vertexes[count].x = love.data.unpack("<h", self.maps[m].raw.vertexes, s)
					self.maps[m].vertexes[count].y = love.data.unpack("<h", self.maps[m].raw.vertexes, s+2)
				end

				-- sectors
				self.maps[m].sectors = {}
				count = 0
				for s = 1, #self.maps[m].raw.sectors, 26 do
					count = count + 1
					self.maps[m].sectors[count] = {}
					self.maps[m].sectors[count].floor_height = love.data.unpack("<h", self.maps[m].raw.sectors, s)
					self.maps[m].sectors[count].ceiling_height = love.data.unpack("<h", self.maps[m].raw.sectors, s+2)
					self.maps[m].sectors[count].floor_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+4)))
					self.maps[m].sectors[count].ceiling_texture = string.upper(utils:removePadding(love.data.unpack("<c8", self.maps[m].raw.sectors, s+12)))
					self.maps[m].sectors[count].light = love.data.unpack("<h", self.maps[m].raw.sectors, s+20)
					self.maps[m].sectors[count].special = love.data.unpack("<H", self.maps[m].raw.sectors, s+22)
					self.maps[m].sectors[count].tag = love.data.unpack("<H", self.maps[m].raw.sectors, s+24)
				end
			end

			collectgarbage()
		end
	else
		utils:printf(1, "\tNot processing base wad maps.")
	end

	utils:printf(1, "\tDone.\n")
end

function wad:ModifyMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do
			local map = self.maps[m]

			utils:printf(1, "\tModifying Map: %d", m)
			
			local actorlist = io.open(love.filesystem.getSourceBaseDirectory() .. "/actorlist.txt")
			actorlist:read("*line")
			actorlist:read("*line")
			actorlist:read("*line")
			local line = actorlist:read("*line")

			-- doom/hexen
			if(map.format == "DM" or map.format == "HM") then

				-- thing replacement
				if(self.things == "Y") then
                    utils:printf(2, "\t\tReplacing actors.")
					while line ~= nil do
                        
						-- actor replacement stuff
						local actornewspace = string.find(line, " ")
						local actor1 = string.sub(line, 1, actornewspace)
						local actor2 = string.sub(line, actornewspace+1)
						actor1 = actor1 + 0
						actor2 = actor2 + 0
						for t = 1, #map.things do
							if(map.things[t].typ == actor1) then
                                utils:printf(3, "\t\t\tReplace actor #%d: X: %d; Y: %d; Angle: %d; Flags: %d; Old Type: %d; New Type: %d", t, map.things[t].x, map.things[t].y, map.things[t].angle, map.things[t].flags, actor1, actor2)
                                map.things[t].typ = actor2
							end
						end

						line = actorlist:read("*line")
					end
					actorlist:close()
				end

				-- find textures and rename
                utils:printf(2, "\t\tReplacing textures.")
				for c = 1, #self.composites do
					local composite = self.composites[c]
					self:replaceMapTextures(map, composite, composite.newname)
				end

				-- find flats and rename
                utils:printf(2, "\t\tReplacing flats.")
				for f = 1, #self.flats do
					local flat = self.flats[f]
					self:replaceMapTextures(map, flat, flat.newname)
				end

				-- find patches and rename
                utils:printf(2, "\t\tReplacing patches.")
				for p = 1, #self.patches do
					local patch = self.patches[p]

					self:replaceMapTextures(map, patch, self:getPatchName(patch))
				end

				-- build raw things back
                utils:printf(2, "\t\tBuilding things lump...")
				count = 0
				map.raw.things = ""
				local t = {}
				for s = 1, #map.things do
					count = count + 1
					if(map.format == "DM") then
						t[s] = love.data.pack("string", "<hhHHH", map.things[s].x, map.things[s].y, map.things[s].angle, map.things[s].typ, map.things[s].flags)
					elseif(map.format == "HM") then
						t[s] = love.data.pack("string", "<HhhhHHHBBBBBB", map.things[s].id, map.things[s].x, map.things[s].y, map.things[s].z, map.things[s].angle, map.things[s].typ, map.things[s].flags, map.things[s].special, map.things[s].a1, map.things[s].a2, map.things[s].a3, map.things[s].a4, map.things[s].a5)
					end
				end
				map.raw.things = table.concat(t)

				-- build raw sidedefs back
                utils:printf(2, "\t\tBuilding sidedefs lump...")
				count = 0
				map.raw.sidedefs = ""
				t = {}
				for s = 1, #map.sidedefs do
					count = count + 1
					t[s] = love.data.pack("string", "<hhc8c8c8H", map.sidedefs[s].xoffset, map.sidedefs[s].yoffset, map.sidedefs[s].upper_texture, map.sidedefs[s].lower_texture, map.sidedefs[s].middle_texture, map.sidedefs[s].sector)
				end
				map.raw.sidedefs = table.concat(t)

				-- build raw sectors back
                utils:printf(2, "\t\tBuilding sectors lump...")
				count = 0
				map.raw.sectors = ""
				t = {}
				for s = 1, #map.sectors do
					count = count + 1
					t[s] = love.data.pack("string", "<hhc8c8hHH", map.sectors[s].floor_height, map.sectors[s].ceiling_height, map.sectors[s].floor_texture, map.sectors[s].ceiling_texture, map.sectors[s].light, map.sectors[s].special, map.sectors[s].tag)
				end
				map.raw.sectors = table.concat(t)

			--udmf
			elseif(map.format == "UM") then

				if(self.things == "Y") then
					while line ~= nil do

						-- actor replacement stuff
						local actornewspace = string.find(line, " ")
						local actor1 = string.sub(line, 1, actornewspace)
						local actor2 = string.sub(line, actornewspace+1)
						actor1 = actor1 + 0
						actor2 = actor2 + 0
						for t = 1, #self.things do
							map.raw.textmap = map.raw.textmap:gsub(actor1, actor2)
						end

						line = actorlist:read("*line")
					end
					actorlist:close()
				end

				for c = 1, #self.composites do
					map.raw.textmap = map.raw.textmap:gsub(self.composites[c].name, self.composites[c].newname)
				end
				for f = 1, #self.flats do
					map.raw.textmap = map.raw.textmap:gsub(self.flats[f].name, self.flats[f].newname)
				end
				for p = 1, #self.patches do
					map.raw.textmap = map.raw.textmap:gsub(self.patches[p].name, self:getPatchName(self.patches[p]))
				end
			end
		end
	else
		utils:printf(1, "\tNot modifying base wad maps.")
	end

	utils:printf(1, "\tDone.\n")
end

function wad:replaceMapTextures(map, texture, newtexturename)

	if (not texture.isdoomdup and not texture.isotex) then
		-- walls
		for s = 1, #map.sidedefs do
			local sidedef = map.sidedefs[s]
			if (sidedef.upper_texture == texture.name) then
				utils:printf(3, "\t\t\tReplacing sidedef #%d upper texture '%s' with '%s'", s, sidedef.upper_texture, texture.newname)
				sidedef.upper_texture = newtexturename
				texture.used = true
			end

			if (sidedef.lower_texture == texture.name) then
				utils:printf(3, "\t\t\tReplacing sidedef #%d lower texture '%s' with '%s'", s, sidedef.lower_texture, texture.newname)
				sidedef.lower_texture = newtexturename
				texture.used = true
			end

			if (sidedef.middle_texture == texture.name) then
				utils:printf(3, "\t\t\tReplacing sidedef #%d middle texture '%s' with '%s'", s, sidedef.middle_texture, texture.newname)
				sidedef.middle_texture = newtexturename
				texture.used = true
			end
		end

		-- floors
		for ss = 1, #map.sectors do
			local sector = map.sectors[ss]

			if (sector.floor_texture == texture.name) then
				utils:printf(3, "\t\t\tReplacing sector #%d floor texture '%s' with '%s'", ss, sector.floor_texture, texture.newname)
				sector.floor_texture = newtexturename
				texture.used = true
			end

			if (sector.ceiling_texture == texture.name) then
				utils:printf(3, "\t\t\tReplacing sector #%d ceiling texture '%s' with '%s'", ss, sector.ceiling_texture, texture.newname)
				sector.ceiling_texture = newtexturename
				texture.used = true
			end
		end
	else
		-- walls
		for s = 1, #map.sidedefs do
			local sidedef = map.sidedefs[s]

			if (sidedef.upper_texture == texture.name) then
				utils:printf(3, "\t\t\tKeeping sidedef #%d upper texture %s", s, texture.doomdup)
				sidedef.upper_texture = texture.doomdup
			end

			if (sidedef.lower_texture == texture.name) then
				utils:printf(3, "\t\t\tKeeping sidedef #%d lower texture %s", s, texture.doomdup)
				sidedef.lower_texture = texture.doomdup
			end

			if (sidedef.middle_texture == texture.name) then
				utils:printf(3, "\t\t\tKeeping sidedef #%d middle texture %s", s, texture.doomdup)
				sidedef.middle_texture = texture.doomdup
			end
		end

		-- floors
		for ss = 1, #map.sectors do
			local sector = map.sectors[ss]

			if (sector.floor_texture == texture.name) then
				utils:printf(3, "\t\t\tKeeping sector #%d floor texture %s", ss, texture.doomdup)
				sector.floor_texture = texture.doomdup
			end

			if (sector.ceiling_texture == texture.name) then
				utils:printf(3, "\t\t\tKeeping sector #%d ceiling texture %s", ss, texture.doomdup)
				sector.ceiling_texture = texture.doomdup
			end
		end
	end
end

function wad:extractTextures()
	if(self.base ~= self) then
		local texturesstr = ""
		local displaydone = false

		for c = 1, #self.composites do
			local composite = self.composites[c]

			if (not composite.iszdoom) then
				if (not composite.isdoomdup) then
					displaydone = true
					utils:printf(2, "\tExtracting Composite: %s", composite.newname)

					if (composite.patchcount > 1) then
						texturesstr = string.format("%s%s", texturesstr, self:createTextureDefinition(composite))
					else
						local png = utils:openFile(string.format("%s/textures/%s/%s.png", self.pk3path, self.acronym, string.lower(composite.newname)), "w+b")
						png:write(composite.png)
						png:close()
					end
				end
			else
				displaydone = true
				utils:printf(2, "\tExtracting Texture: %s", composite.newname)

				if (composite.patchcount > 1) then
					texturesstr = string.format("%s%s", texturesstr, self:createTextureDefinition(composite))
				else
					local png = utils:openFile(string.format("%s/textures/%s/%s.raw", self.pk3path, self.acronym, string.lower(composite.newname)), "w+b")
					png:write(composite.raw)
					png:close()
				end
			end
		end

		if #texturesstr > 0 then
			local file = utils:openFile(string.format("%s/textures.%s.txt", self.pk3path, self.acronym), "w")
			file:write(texturesstr)
			file:close()
		end

		collectgarbage()

		if (displaydone) then
			utils:printf(1, "\tDone.\n")
		end
	else
		utils:printf(1, "\tNot extracting base wad composites.\n")
	end
end

-- Creates a WallTexture definition for TEXTURES
function wad:createTextureDefinition(composite)
	local texturedef = string.format("WallTexture \"%s\", %d, %d\n{\n", composite.newname, composite.width, composite.height)

	for p = 1, composite.patchcount do
		local compositepatch = composite.patches[p]
		local patchdata = self.patches[compositepatch.patch]
		local basepatchdata = self.base.patches[compositepatch.patch]
		local patchname = self:getPatchName(patchdata, basepatchdata)

		if (#patchname > 0) then
            if(patchdata) then
                patchdata.used = true
                texturedef = string.format("%s	Patch \"%s\", %d, %d\n", texturedef, patchname, compositepatch.x, compositepatch.y)
            end
		end
	end

	return string.format("%s}\n\n", texturedef)
end


function wad:getPatchName(patch, basepatch)
	local patchname = ""

	if (patch) then
		-- If this patch is a standalone texture, then use the composite texture name instead
		patchname = patch.composite and patch.composite.newname or patch.newname
	end

	-- If patch was not defined or somehow did not have a name, then attempt to get name from basepatch (if it exists)
	if (basepatch and #patchname == 0) then
		patchname = basepatch.composite and (basepatch.composite.newname or basepatch.composite.name) or basepatch.name
	end

	return patchname
end

function wad:extractGraphics()
    if(self.base ~= self) then
		for g = 1, #self.graphics do
            utils:printf(2, "\tExtracting Graphic: %s", self.graphics[g].name)
			local png = utils:openFile(string.format("%s/graphics/%s/%s.png", self.pk3path, self.acronym, string.lower(self.graphics[g].name)), "w+b")
			png:write(self.graphics[g].png)
			png:close()
		end
		collectgarbage()
		utils:printf(1, "\tDone.\n")
    else
        utils:printf(1, "\tNot extracting base wad graphics.\n")
    end

end

function wad:extractFlats()
	if(self.base ~= self) then
		for f = 1, #self.flats do
			if(not self.flats[f].isdoomdup) then
                utils:printf(2, "\tExtracting Flat: %s", self.flats[f].newname)
				local png = utils:openFile(string.format("%s/flats/%s/%s.png", self.pk3path, self.acronym, string.lower(self.flats[f].newname)), "w+b")
				png:write(self.flats[f].png)
				png:close()
			end
		end
		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad flats.\n")
	end
end

function wad:extractPatches()
	if (self.base ~= self) then
		for p = 1, #self.patches do
			local patch = self.patches[p]

			if (not patch.isdoomdup and patch.composite == nil) then
                utils:printf(2, "\tExtracting Patch: %s", patch.newname)
				local png = utils:openFile(string.format("%s/patches/%s/%s.png", self.pk3path, self.acronym, string.lower(patch.newname)), "w+b")
				png:write(patch.png)
				png:close()
			end
		end

		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad patches.\n")
	end
end

function wad:extractSprites()
	if(self.base ~= self) then
		for s = 1, #self.sprites do
			if(not self.sprites[s].isdoomdup) then
                utils:printf(2, "\tExtracting Sprite: %s", self.sprites[s].name)
                self.sprites[s].newname = self.sprites[s].newname:gsub("\\", "^")
				local png = utils:openFile(string.format("%s/sprites/%s/%s.png", self.pk3path, self.acronym, string.lower(self.sprites[s].newname)), "w+b")
				png:write(self.sprites[s].png)
				png:close()
            else
                utils:printf(2, "\tNot Extracting Duplicate Sprite: %s", self.sprites[s].name) 
			end
		end

		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad sprites.\n")
	end
end

function wad:extractMaps()
	if(self.base ~= self) then
		for m = 1, #self.maps do
            
			-- doom/hexen
			if(self.maps[m].format == "DM" or self.maps[m].format == "HM") then
                utils:printf(2, "\tExtracting DM/HM Map: %d", m)
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
				local header = love.data.pack("string", "<c4i4i4", "PWAD", #order+1, 12+#lumpchunk)

				-- directory
				local dir = love.data.pack("string", "<i4i4c8", 0, 0, "MAP01")
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

				local wad = utils:openFile(string.format("%s/maps/%s.wad", self.pk3path, self.maps[m].name), "w+b")

				wad:write(header)
				wad:write(lumpchunk)
				wad:write(dir)
				wad:close()

			-- udmf
			elseif(self.maps[m].format == "UM") then
                utils:printf(2, "\tExtracting UM Map: %d", m)
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
				local header = love.data.pack("string", "<c4i4i4", "PWAD", #order+1, 12+#lumpchunk)

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

				local wad = utils:openFile(string.format("%s/maps/%s.wad", self.pk3path, string.lower(self.maps[m].name)), "w+b")
				wad:write(header)
				wad:write(lumpchunk)
				wad:write(dir)
				wad:close()
			end
		end
		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad maps.\n")
	end
end

function wad:extractAnimdefs()
	if(self.base ~= self) then

		local anim = ""
		for a = 1, #self.animdefs.anims do
            utils:printf(2, "\t\t%s %s range %s tics 8", self.animdefs.anims[a].typ, self.animdefs.anims[a].text1, self.animdefs.anims[a].text2)
			anim = string.format("%s%s %s range %s tics 8", anim, self.animdefs.anims[a].typ, self.animdefs.anims[a].text1, self.animdefs.anims[a].text2)
			texNumMin = string.sub(self.animdefs.anims[a].text1, 5, 8)
			texNumMax = string.sub(self.animdefs.anims[a].text2, 5, 8)

			for i = tonumber(texNumMin), tonumber(texNumMax) do
				local lumpName = self.acronym

				if i < 1000 then
					lumpName = lumpName .. "0"
				end

				if i < 100 then
					lumpName = lumpName .. "0"
				end

				if i < 10 then
					lumpName = lumpName .. "0"
				end

				animdefsIgnore[lumpName .. i] = "not nil";
				i = i + 1
			end

			if(self.animdefs.anims[a].decal) then
				anim = string.format("%s %s", anim, self.animdefs.anims[a].decal)
			end
            anim = string.format("%s\n", anim)
		end

		local switch = ""
		for s = 1, #self.animdefs.switches do
            utils:printf(2, "\t\tswitch %s on pic %s tics 0", self.animdefs.switches[s].text1, self.animdefs.switches[s].text2)
			switch = string.format("%sswitch %s on pic %s tics 0\n", switch, self.animdefs.switches[s].text1, self.animdefs.switches[s].text2)

			animdefsIgnore[self.animdefs.switches[s].text1] = "not nil";
			animdefsIgnore[self.animdefs.switches[s].text2] = "not nil";
		end

        if #anim > 0 or #switch > 0 or #self.animdefs.original > 0 then
			local file = utils:openFile(string.format("%s/animdefs.%s.txt", self.pk3path, self.acronym), "w")
            file:write(anim)
            file:write(switch)
            file:write(self.animdefs.original)
            file:close()
        else
            utils:printf(1, "\tNo animations/switchs to define.\n")
        end
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad animdefs.\n")
	end
end

function wad:extractSNDINFO()
	if(self.base ~= self) then

		local txt = ""
		self.snddefs = {}

		for s = 1, #self.doomsounds do
			txt = string.format("%s\n%s/%s\t\t\t\t%s", txt, self.acronym, self.doomsounds[s].name, self.doomsounds[s].newname)
			self.snddefs[#self.snddefs+1] = { string.format("%s/%s", self.acronym, self.doomsounds[s].name),  self.doomsounds[s].name }
		end

		for s = 1, #self.wavesounds do
			txt = string.format("%s\n%s/%s\t\t\t\t%s", txt, self.acronym, self.wavesounds[s].name, self.wavesounds[s].newname)
			self.snddefs[#self.snddefs+1] = { string.format("%s/%s", self.acronym, self.wavesounds[s].name),  self.wavesounds[s].name }
		end

		for s = 1, #self.oggsounds do
			txt = string.format("%s\n%s/%s\t\t\t\t%s", txt, self.acronym, self.oggsounds[s].name, self.oggsounds[s].newname)
			self.snddefs[#self.snddefs+1] = { string.format("%s/%s", self.acronym, self.oggsounds[s].name),  self.oggsounds[s].name }
		end

		for s = 1, #self.flacsounds do
			txt = string.format("%s\n%s/%s\t\t\t\t%s", txt, self.acronym, self.flacsounds[s].name, self.flacsounds[s].newname)
			self.snddefs[#self.snddefs+1] = { string.format("%s/%s", self.acronym, self.flacsounds[s].name),  self.flacsounds[s].name }
		end

        if #txt > 0 then
            local file = utils:openFile(string.format("%s/sndinfo.%s.txt", self.pk3path, self.acronym), "w")
            file:write(txt)
            file:close()
        else
            utils:printf(1, "\tNo sounds to define.\n")
        end
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad sndinfo.\n")
	end
end

function wad:extractSounds()
	if(self.base ~= self) then

		--LMP
		for s = 1, #self.doomsounds do
			local snd = utils:openFile(string.format("%s/sounds/%s/%s.lmp", self.pk3path, self.acronym, string.lower(self.doomsounds[s].newname)), "w+b")
			snd:write(self.doomsounds[s].data)
			snd:close()
		end

		--WAV
		for s = 1, #self.wavesounds do
			local snd = utils:openFile(string.format("%s/sounds/%s/%s.wav", self.pk3path, self.acronym, string.lower(self.wavesounds[s].newname)), "w+b")
			snd:write(self.wavesounds[s].data)
			snd:close()
		end

		--OGG
		for s = 1, #self.oggsounds do
			local snd = utils:openFile(string.format("%s/sounds/%s/%s.ogg", self.pk3path, self.acronym, string.lower(self.oggsounds[s].newname)), "w+b")
			snd:write(self.oggsounds[s].data)
			snd:close()
		end

		--FLAC
		for s = 1, #self.flacsounds do
			local snd = utils:openFile(string.format("%s/sounds/%s/%s.flac", self.pk3path, self.acronym, string.lower(self.flacsounds[s].newname)), "w+b")
			snd:write(self.flacsounds[s].data)
			snd:close()
		end

		collectgarbage()
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad sounds.\n")
	end
end

function wad:extractSongs()
    if(self.base ~= self) then

        for s = 1, #self.songs do
            if self.songs[s].newname ~= nil then
                local ext = "mus"
                if self.songs[s].data:sub(1, 4) == "MThd" then
                    ext = "mid"
                end
                
                local mus = utils:openFile(string.format("%s/music/%s/D_%s.%s", self.pk3path, self.acronym, self.songs[s].newname, ext), "w+b")
                mus:write(self.songs[s].data)
                mus:close()
            end
        end

        collectgarbage()
        utils:printf(1, "\tDone.\n")
    else
        utils:printf(1, "\tNot extracting base wad music.\n")
    end
end

function wad:extractTexturesLump()
	if(self.base ~= self) then

        if #self.textures.original > 0 then
            local file = utils:openFile(string.format("%s/textures.%s.txt", self.pk3path, self.acronym), "w")
            file:write(self.textures.original)
            file:close()
        else
            utils:printf(1, "\tNo textures.txt to define.\n")
        end
		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting base wad TextureX.\n")
	end
end

function wad:extractMapinfo()
	if(self.base ~= self) then

		local file = utils:openFile(string.format("%s/mapinfo/%s.txt", self.pk3path, self.acronym), "w")
		file:write(self.mapinfo)
		file:close()

		file = utils:openFile(string.format("%s/mapinfo.txt", self.pk3path), "r")
		local mapinfo = file:read("*all")
		file:close()

		mapinfo = string.format('%s\ninclude "mapinfo/%s.txt"', mapinfo, self.acronym)

		file = utils:openFile(string.format("%s/mapinfo.txt", self.pk3path), "w")
		file:write(mapinfo)
		file:close()

		utils:printf(1, "\tDone.\n")
	else
		utils:printf(1, "\tNot extracting mapinfo for base wad.\n")
	end
end

function wad:removeUnusedTextures()
	local tex = 0
	local flats = 0
	local patches = 0

	for c = 1, #self.composites do
		if(not self.composites[c].used and animdefsIgnore[self.composites[c].newname] == nil) then
			tex = tex + 1
			os.remove(string.format("%s/textures/%s.png", self.pk3path, self.composites[c].newname))
		end
	end

	for f = 1, #self.flats do
		if(not self.flats[f].used and animdefsIgnore[self.flats[f].newname] == nil) then
			flats = flats + 1
			os.remove(string.format("%s/flats/%s.png", self.pk3path, self.flats[f].newname))
		end
	end

	for p = 1, #self.patches do
		if(not self.patches[p].used and animdefsIgnore[self.patches[p].newname] == nil) then
			patches = patches + 1
			os.remove(string.format("%s/patches/%s.png", self.pk3path, self.patches[p].newname))
		end
	end

	utils:printf(1, "\tFound: %i Unused Textures.", tex)
	utils:printf(1, "\tFound: %i Unused Flats.", flats)
	utils:printf(1, "\tFound: %i Unused Patches.", patches)
end


---------------------------------------------------------
-- Helpers
---------------------------------------------------------

function wad:findLump(namespace, lumpname)
	for l = 1, #self.namespaces[namespace].lumps do
		if(self.namespaces[namespace].lumps[l].name == lumpname) then
			return self.namespaces[namespace].lumps[l].data
		end
	end
    return ""
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