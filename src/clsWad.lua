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
    pnames = {},
    composites = {},
    textures = {},
    zdoomtextures = {},
    texturedefines = {},
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
        "ENDMAP"
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
        "ZMAPINFO"
    },

    graphicslist =
    {
        {lumpname = "CWILV00",  suffix = "V00"},
        {lumpname = "CWILV01",  suffix = "V01"},
        {lumpname = "CWILV02",  suffix = "V02"},
        {lumpname = "CWILV03",  suffix = "V03"},
        {lumpname = "CWILV04",  suffix = "V04"},
        {lumpname = "CWILV05",  suffix = "V05"},
        {lumpname = "CWILV06",  suffix = "V06"},
        {lumpname = "CWILV07",  suffix = "V07"},
        {lumpname = "CWILV08",  suffix = "V08"},
        {lumpname = "CWILV09",  suffix = "V09"},
        {lumpname = "CWILV10",  suffix = "V10"},
        {lumpname = "CWILV11",  suffix = "V11"},
        {lumpname = "CWILV12",  suffix = "V12"},
        {lumpname = "CWILV13",  suffix = "V13"},
        {lumpname = "CWILV14",  suffix = "V14"},
        {lumpname = "CWILV15",  suffix = "V15"},
        {lumpname = "CWILV16",  suffix = "V16"},
        {lumpname = "CWILV17",  suffix = "V17"},
        {lumpname = "CWILV18",  suffix = "V18"},
        {lumpname = "CWILV19",  suffix = "V19"},
        {lumpname = "CWILV20",  suffix = "V20"},
        {lumpname = "CWILV21",  suffix = "V21"},
        {lumpname = "CWILV22",  suffix = "V22"},
        {lumpname = "CWILV23",  suffix = "V23"},
        {lumpname = "CWILV24",  suffix = "V24"},
        {lumpname = "CWILV25",  suffix = "V25"},
        {lumpname = "CWILV26",  suffix = "V26"},
        {lumpname = "CWILV27",  suffix = "V27"},
        {lumpname = "CWILV28",  suffix = "V28"},
        {lumpname = "CWILV29",  suffix = "V29"},
        {lumpname = "CWILV30",  suffix = "V30"},
        {lumpname = "CWILV31",  suffix = "V31"},
        {lumpname = "CWILV32",  suffix = "V32"},
        {lumpname = "WILV00",   suffix = "UV00"},
        {lumpname = "WILV01",   suffix = "UV01"},
        {lumpname = "WILV02",   suffix = "UV02"},
        {lumpname = "WILV03",   suffix = "UV03"},
        {lumpname = "WILV04",   suffix = "UV04"},
        {lumpname = "WILV05",   suffix = "UV05"},
        {lumpname = "WILV06",   suffix = "UV06"},
        {lumpname = "WILV07",   suffix = "UV07"},
        {lumpname = "WILV08",   suffix = "UV08"},
        {lumpname = "WILV09",   suffix = "UV09"},
        {lumpname = "WILV10",   suffix = "UV10"},
        {lumpname = "WILV11",   suffix = "UV11"},
        {lumpname = "WILV12",   suffix = "UV12"},
        {lumpname = "WILV13",   suffix = "UV13"},
        {lumpname = "WILV14",   suffix = "UV14"},
        {lumpname = "WILV15",   suffix = "UV15"},
        {lumpname = "WILV16",   suffix = "UV16"},
        {lumpname = "WILV17",   suffix = "UV17"},
        {lumpname = "WILV18",   suffix = "UV18"},
        {lumpname = "WILV19",   suffix = "UV19"},
        {lumpname = "WILV20",   suffix = "UV20"},
        {lumpname = "WILV21",   suffix = "UV21"},
        {lumpname = "WILV22",   suffix = "UV22"},
        {lumpname = "WILV23",   suffix = "UV23"},
        {lumpname = "WILV24",   suffix = "UV24"},
        {lumpname = "WILV25",   suffix = "UV25"},
        {lumpname = "WILV26",   suffix = "UV26"},
        {lumpname = "WILV27",   suffix = "UV27"},
        {lumpname = "WILV28",   suffix = "UV28"},
        {lumpname = "WILV29",   suffix = "UV29"},
        {lumpname = "WILV30",   suffix = "UV30"},
        {lumpname = "WILV31",   suffix = "UV31"},
        {lumpname = "WILV32",   suffix = "UV32"},
        {lumpname = "WILV33",   suffix = "UV33"},
        {lumpname = "WILV34",   suffix = "UV34"},
        {lumpname = "WILV35",   suffix = "UV35"},
        {lumpname = "WILV36",   suffix = "UV36"},
        {lumpname = "WILV37",   suffix = "UV37"},
        {lumpname = "WILV38",   suffix = "UV38"},
        {lumpname = "INTERPIC", suffix = "INT"},
        {lumpname = "TITLEPIC", suffix = "TITL"},
        {lumpname = "HELP",     suffix = "HELP"},
        {lumpname = "CREDIT",   suffix = "CRED"},
        {lumpname = "BOSSBACK", suffix = "BOSS"}
    },

    switchlist =
    {
        {off = "SW1BRCOM", on = "SW2BRCOM"},
        {off = "SW1BRN1",  on = "SW2BRN1"},
        {off = "SW1BRN2",  on = "SW2BRN2"},
        {off = "SW1BRNGN", on = "SW2BRNGN"},
        {off = "SW1BROWN", on = "SW2BROWN"},
        {off = "SW1COMM",  on = "SW2COMM"},
        {off = "SW1COMP",  on = "SW2COMP"},
        {off = "SW1DIRT",  on = "SW2DIRT"},
        {off = "SW1EXIT",  on = "SW2EXIT"},
        {off = "SW1GRAY",  on = "SW2GRAY"},
        {off = "SW1GRAY1", on = "SW2GRAY1"},
        {off = "SW1METAL", on = "SW2METAL"},
        {off = "SW1PIPE",  on = "SW2PIPE"},
        {off = "SW1SLAD",  on = "SW2SLAD"},
        {off = "SW1STARG", on = "SW2STARG"},
        {off = "SW1STON1", on = "SW2STON1"},
        {off = "SW1STON2", on = "SW2STON2"},
        {off = "SW1STONE", on = "SW2STONE"},
        {off = "SW1STRTN", on = "SW2STRTN"},
        {off = "SW1BLUE",  on = "SW2BLUE"},
        {off = "SW1CMT",   on = "SW2CMT"},
        {off = "SW1GARG",  on = "SW2GARG"},
        {off = "SW1GSTON", on = "SW2GSTON"},
        {off = "SW1HOT",   on = "SW2HOT"},
        {off = "SW1LION",  on = "SW2LION"},
        {off = "SW1SATYR", on = "SW2SATYR"},
        {off = "SW1SKIN",  on = "SW2SKIN"},
        {off = "SW1VINE",  on = "SW2VINE"},
        {off = "SW1WOOD",  on = "SW2WOOD"},
        {off = "SW1PANEL", on = "SW2PANEL"},
        {off = "SW1ROCK",  on = "SW2ROCK"},
        {off = "SW1MET2",  on = "SW2MET2"},
        {off = "SW1WDMET", on = "SW2WDMET"},
        {off = "SW1BRIK",  on = "SW2BRIK"},
        {off = "SW1MOD1",  on = "SW2MOD1"},
        {off = "SW1ZIM",   on = "SW2ZIM"},
        {off = "SW1STON6", on = "SW2STON6"},
        {off = "SW1TEK",   on = "SW2TEK"},
        {off = "SW1MARB",  on = "SW2MARB"},
        {off = "SW1SKULL", on = "SW2SKULL"}
    },

    animlist =
    {
        {typ = "flat",    first = "BLOOD1",   last = "BLOOD3"},
        {typ = "flat",    first = "FWATER1",  last = "FWATER4"},
        {typ = "flat",    first = "LAVA1",    last = "LAVA4"},
        {typ = "flat",    first = "NUKAGE1",  last = "NUKAGE3"},
        {typ = "flat",    first = "RROCK05",  last = "RROCK08"},
        {typ = "flat",    first = "SLIME01",  last = "SLIME04"},
        {typ = "flat",    first = "SLIME05",  last = "SLIME08"},
        {typ = "flat",    first = "SLIME09",  last = "SLIME12"},
        {typ = "flat",    first = "SWATER1",  last = "SWATER4"},
        {typ = "texture", first = "BFALL1",   last = "BFALL4"},
        {typ = "texture", first = "BLODGR1",  last = "BLODGR4",  flags = "allowdecals"},
        {typ = "texture", first = "BLODRIP1", last = "BLODRIP4", flags = "allowdecals"},
        {typ = "texture", first = "DBRAIN1",  last = "DBRAIN4"},
        {typ = "texture", first = "FIREBLU1", last = "FIREBLU2"},
        {typ = "texture", first = "FIRELAV3", last = "FIRELAVA"},
        {typ = "texture", first = "FIREMAG1", last = "FIREMAG3"},
        {typ = "texture", first = "FIREWALA", last = "FIREWALL"},
        {typ = "texture", first = "GSTFONT1", last = "GSTFONT3", flags = "allowdecals"},
        {typ = "texture", first = "ROCKRED1", last = "ROCKRED3", flags = "allowdecals"},
        {typ = "texture", first = "SFALL1",   last = "SFALL4"},
        {typ = "texture", first = "SLADRIP1", last = "SLADRIP3", flags = "allowdecals"},
        {typ = "texture", first = "WFALL1",   last = "WFALL4"}
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
        "D_DM2INT"     -- map32
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
        [0x8000] = "blockeverything"
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
        9061
    },

    thing_ignore =
    {
        32000
    },

    door_actions =
    {
        10,
        11,
        12,
        13,
        14,
        202,
        249
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
        231
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
        251
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
        255
    },

    ctf_filter =
    {
        {5, 5130},  -- blue key to zandronum blue flag
        {13, 5131}  -- red key to zandronum red flag
    },

    door_sounds =
    {
        "DSDOROPN",
        "DSDORCLS",
        "DSBDOPN",
        "DSBDCLS"
    },

    platform_sounds =
    {
        "DSPSTART",
        "DSPSTOP",
        "DSSTNMOV"
    },

    ignorelist =
    {
        {"F_SKY1", 0}
    },

    ignorelist_dups =
    {
        "SW1BRCOM",
        "SW1BRN1",
        "SW1STARG",
        "SW1STON2",
        "SW1STONE",
        "SW2BRCOM",
        "SW2BRN1",
        "SW2STARG",
        "SW2STON2",
        "SW2STONE",
    },

    -- namespaces
    namespaces =
    {
        ["SP"] =
        {
            name = "specials",
            lumps = {}
        },
        ["DS"] =
        {
            name = "doomsounds",
            lumps = {}
        },
        ["WS"] =
        {
            name = "wavesounds",
            lumps = {}
        },
        ["OS"] =
        {
            name = "oggsounds",
            lumps = {}
        },
        ["CS"] =
        {
            name = "flacsounds",
            lumps = {}
        },
        ["MS"] =
        {
            name = "songs",
            lumps = {}
        },
        ["GG"] =
        {
            name = "graphics",
            lumps = {}
        },
        ["TX"] =
        {
            name = "zdoomtextures",
            lumps = {}
        },
        ["PP"] =
        {
            name = "patches",
            lumps = {}
        },
        ["FF"] =
        {
            name = "flats",
            lumps = {}
        },
        ["SS"] =
        {
            name = "sprites",
            lumps = {}
        },
        ["MM"] =
        {
            name = "maps",
            lumps = {},
            maps = {}
        }
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

    if (acronym ~= nil) then
        if (#acronym < 4) then
            error("Error: Acronym must be 4 letters.")
        end
        self.acronym = acronym:sub(1, 4):upper()
    end

    if (acronym_sprite ~= nil) then
        if (#acronym_sprite < 2) then
            error("Error: Sprite acronym must be 2 letters.")
        end
        self.acronym_sprite = acronym_sprite:sub(1, 2):upper()
    end

    if (things ~= nil) then
        self.things = things:sub(1, 1):upper()
    end

    if (patches ~= nil) then
        self.extractpatches = patches:upper()
    end

    self.pk3path = pk3path
    self.toolspath = toolspath
    self.spritesname = sprites
    self.apppath = love.filesystem.getSourceBaseDirectory():gsub("/", "\\")
    self.palette = palette
    self.nodelete = nodelete

    utils:printf(0, "------------------------------------------------------------------------------------------")
    utils:bench("Loading Wad...",                       self.open,                  self, path)
    utils:bench("Gathering Header...",                  self.gatherHeader,          self)
    utils:bench("Adding Extra Namespace Markers...",    self.addExtraMarkers,       self)
    utils:bench("Building Namespaces...",               self.buildNamespaces,       self)
    utils:bench("Organizing Graphics...",               self.organizeNamespace,     self, "GG")
    utils:bench("Organizing Flats...",                  self.organizeNamespace,     self, "FF")
    utils:bench("Organizing Patches...",                self.organizeNamespace,     self, "PP")
    utils:bench("Organizing Sprites...",                self.organizeNamespace,     self, "SS")
    utils:bench("Organizing Zdoom Textures...",         self.organizeNamespace,     self, "TX")
    utils:bench("Organizing LMP Sounds...",             self.organizeNamespace,     self, "DS")
    utils:bench("Organizing WAV Sounds...",             self.organizeNamespace,     self, "WS")
    utils:bench("Organizing OGG Sounds...",             self.organizeNamespace,     self, "OS")
    utils:bench("Organizing FLAC Sounds...",            self.organizeNamespace,     self, "CS")
    utils:bench("Organizing Music...",                  self.organizeNamespace,     self, "MS")
    utils:bench("Organizing Maps...",                   self.organizeMaps,          self)
    utils:bench("Processing Palette...",                self.processPalette,        self)
    utils:bench("Processing Boom Animations...",        self.processAnimated,       self)
    utils:bench("Processing Boom Switches...",          self.processSwitches,       self)
    utils:bench("Processing Flats...",                  self.buildFlats,            self)
    utils:bench("Processing Patches...",                self.buildImages,           self, self.patches, "Patch")
    utils:bench("Processing Graphics...",               self.buildImages,           self, self.graphics, "Graphic")
    utils:bench("Processing Sprites...",                self.buildImages,           self, self.sprites, "Sprite")
    utils:bench("Processing Zdoom Textures...",         self.buildImages,           self, self.zdoomtextures, "ZDoom Texture")
    utils:bench("Processing PNames...",                 self.processPnames,         self)
    utils:bench("Processing TEXTURE1...",               self.processTexturesX,      self, 1)
    utils:bench("Processing TEXTURE2...",               self.processTexturesX,      self, 2)
    utils:bench("Processing TEXTURES.TXT...",           self.processTexturesTXT,    self)
    utils:bench("Processing Duplicates...",             self.filterDuplicates,      self)
    utils:bench("Renaming Flats...",                    self.renameFlats,           self)
    utils:bench("Renaming Sprites...",                  self.renameSprites,         self)
    utils:bench("Renaming Composites...",               self.renameTextures,        self)
    utils:bench("Renaming Patches...",                  self.renamePatches,         self)
    utils:bench("Renaming Zdoom Textures...",           self.renameZDoomTextures,   self)
    utils:bench("Renaming Sounds...",                   self.renameSounds,          self)
    utils:bench("Renaming Songs...",                    self.renameSongs,           self)
    utils:bench("Filtering OTEX Assets...",             self.filterOTexAssets,      self)
    self:setLumpData("SP", "TEXTURES", utils:bench("Processing TEXTURES...",        self.processTextLump,   self, "TEXTURES"))
    self.animdefs.original = utils:bench("Processing ANIMDEFS...",                  self.processTextLump,   self, "ANIMDEFS")
    utils:bench("Processing Maps...",                   self.processMaps,           self)
    utils:bench("Modifying Maps...",                    self.ModifyMaps,            self)
    utils:bench("Building ANIMDEFS for Doom/Boom...",   self.buildAnimdefs,         self)
    utils:bench("Extracting Graphics...",               self.extractGraphics,       self)
    utils:bench("Extracting Patches...",                self.extractPatches,        self)
    utils:bench("Extracting Flats...",                  self.extractFlats,          self)
    utils:bench("Extracting Composites...",             self.extractComposites,     self)
    utils:bench("Extracting Sprites...",                self.extractSprites,        self)
    utils:bench("Extracting Zdoom Textures...",         self.extractZDoomTextures,  self)
    utils:bench("Extracting Maps...",                   self.extractMaps,           self)
    utils:bench("Extracting Sounds...",                 self.extractSounds,         self)
    utils:bench("Extracting Songs...",                  self.extractSongs,          self)
    utils:bench("Extracting ANIMDEFS...",               self.extractAnimdefs,       self)
    utils:bench("Extracting TEXTURES...",               self.extractTexturesLump,   self)
    utils:bench("Extracting SNDINFO...",                self.extractSNDINFO,        self)
    utils:bench("Removing Unused Textures...",          self.removeUnusedTextures,  self)
    utils:printf(0, "Complete.\n")
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

    local isbase = (self.base == self) and "true" or "false"
    utils:printf(1, "\tType: %s\n\tLumps: %d\n\tDirectory Position: 0x%X.\n\tBase: %s", self.header.magic, self.header.lumpcount, self.header.dirpos, isbase)
end

function wad:addExtraMarkers()
    local lumplist = {}
    local lumplist_new = {}

    local function addLumpListItem(name)
        lumplist_new[#lumplist_new+1] = {filepos = 0, size = 0, name = name, data = ""}
    end

    -- save all lumps into a table
    for lump = 0, self.header.lumpcount do
        local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(lump*16))

        lumplist[#lumplist+1] = {
            filepos = filepos,
            size = size,
            name = utils:removePadding(name),
            data = love.data.unpack(string.format("<c%d", size), self.raw, filepos+1)
        }
    end
    ------------------
    -- specials
    ------------------
    utils:printf(1, "\tCreating Specials Namespace...", name)

    -- make the SP_START marker
    addLumpListItem("SP_START")

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
    addLumpListItem("SP_END")

    ------------------
    -- graphics
    ------------------
    utils:printf(1, "\tCreating Graphics Namespace...", name)

    -- make the GG_START marker
    addLumpListItem("GG_START")

    -- copy all the graphics lumps below the GG_START marker
    for l, lump in ipairs(lumplist) do
        for g, graphic in ipairs(self.graphicslist) do
            if lump.name == graphic.lumpname then
                local newname = self.acronym .. graphic.suffix
                utils:printf(2, "\t\tFound %s; renaming to %s", graphic.lumpname, newname)
                lump.name = newname
                lumplist_new[#lumplist_new+1] = lump
            end
        end
    end

    -- make the GG_END marker
    addLumpListItem("GG_END")

    ------------------
    -- maps
    ------------------
    utils:printf(1, "\tCreating Maps Namespace...", name)

    -- make the MM_START marker
    addLumpListItem("MM_START")

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
                    if lumplist[l+1].name ~= "THINGS"    then return false end
                    if lumplist[l+2].name ~= "LINEDEFS"  then return false end
                    if lumplist[l+3].name ~= "SIDEDEFS"  then return false end
                    if lumplist[l+4].name ~= "VERTEXES"  then return false end
                    if lumplist[l+5].name ~= "SEGS"      then return false end
                    if lumplist[l+6].name ~= "SSECTORS"  then return false end
                    if lumplist[l+7].name ~= "NODES"     then return false end
                    if lumplist[l+8].name ~= "SECTORS"   then return false end
                    if lumplist[l+9].name ~= "REJECT"    then return false end
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
                        addLumpListItem("DM_START")
                        for ll = l, l+10 do
                            lumplist_new[#lumplist_new+1] = lumplist[ll]
                        end
                        addLumpListItem("DM_END")

                    elseif t == "Hexen" then
                        addLumpListItem("HM_START")
                        for ll = l, l+10 do
                            lumplist_new[#lumplist_new+1] = lumplist[ll]
                        end
                        lumplist_new[#lumplist_new+1] = lumplist[l+11]
                        if l+12 <= #lumplist then
                            if lumplist[l+12].name == "SCRIPTS" then
                                lumplist_new[#lumplist_new+1] = lumplist[l+12]
                            end
                        end
                        addLumpListItem("HM_END")
                    end

                    utils:printf(2, "\t\tFound %s Format Map: %s", t, lumplist[l].name)
                end
            end

            if l+1 < #lumplist then
                if lumplist[l+1].name == "TEXTMAP" then
                    for ll = l, #lumplist do
                        if lumplist[ll].name == "ENDMAP" then
                            addLumpListItem("UM_START")
                            for lll = l, ll do
                                lumplist_new[#lumplist_new+1] = lumplist[lll]
                            end
                            addLumpListItem("UM_END")
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
    addLumpListItem("MM_END")

    ------------------
    -- doom sounds
    ------------------
    utils:printf(1, "\tCreating Doom Sounds Namespace...", name)

    -- make the DS_START marker
    addLumpListItem("DS_START")

    for l, lump in ipairs(lumplist) do
        if lump.name:sub(1, 2) == "DS" then
            utils:printf(2, "\t\tFound Doom Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the DS_END marker
    addLumpListItem("DS_END")

    ------------------
    -- wave sounds
    ------------------
    utils:printf(1, "\tCreating Wave Sounds Namespace...", name)

    -- make the WS_START marker
    addLumpListItem("WS_START")

    for l, lump in ipairs(lumplist) do
        if utils:checkFormat(lump.data, "RIFF") then
            utils:printf(2, "\t\tFound Wave Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the WS_END marker
    addLumpListItem("WS_END")

    ------------------
    -- ogg sounds
    ------------------
    utils:printf(1, "\tCreating Ogg Sounds Namespace...", name)

    -- make the OS_START marker
    addLumpListItem("OS_START")

    for l, lump in ipairs(lumplist) do
        if utils:checkFormat(lump.data, "OggS") then
            utils:printf(2, "\t\tFound OGG Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the OS_END marker
    addLumpListItem("OS_END")

    ------------------
    -- flac sounds
    ------------------
    utils:printf(1, "\tCreating Flac Sounds Namespace...", name)

    -- make the CS_START marker
    addLumpListItem("CS_START")

    for l, lump in ipairs(lumplist) do
        if utils:checkFormat(lump.data, "fLaC") then
            utils:printf(2, "\t\tFound FLAC Sound: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
        end
    end

    -- make the CS_END marker
    addLumpListItem("CS_END")

    ------------------
    -- music
    ------------------
    utils:printf(1, "\tCreating Music Namespace...", name)

    -- make the MS_START marker
    addLumpListItem("MS_START")

    for l, lump in ipairs(lumplist) do
        if utils:checkFormat(lump.data, "MUS") then
            utils:printf(2, "\t\tFound MUS song: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
            goto continue
        end
        if utils:checkFormat(lump.data, "MThd") then
            utils:printf(2, "\t\tFound MIDI song: %s", lumplist[l].name)
            lumplist_new[#lumplist_new+1] = lump
            goto continue
        end
        for m, music in ipairs(self.music_list) do
            if lump.name == music then
                utils:printf(2, "\t\tFound song by name: %s", lumplist[l].name)
                lumplist_new[#lumplist_new+1] = lump
            end
        end
        ::continue::
    end

    -- make the MS_END marker
    addLumpListItem("MS_END")

    ------------------
    -- texture
    ------------------
    utils:printf(1, "\tCreating Textures Namespace...", name)

    -- make the TX_START marker
    addLumpListItem("TX_START")

    for l, lump in ipairs(lumplist) do
        if lump.name == "TX_START" then
            for ll = l, #lumplist do
                if lumplist[ll].name == "TX_END" then
                    for lll = l+1, ll-1 do
                        utils:printf(2, "\t\tFound Texture: %s", lumplist[lll].name)
                        lumplist_new[#lumplist_new+1] = lumplist[lll]
                    end
                    break
                end
            end
        end
    end

    -- make the TX_END marker
    addLumpListItem("TX_END")

    ------------------
    -- sprites
    ------------------
    utils:printf(1, "\tCreating Sprites Namespace...", name)

    -- make the S_START marker
    addLumpListItem("SS_START")

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
    addLumpListItem("SS_END")

    ------------------
    -- flats
    ------------------
    utils:printf(1, "\tCreating Flats Namespace...", name)

    -- make the F_START marker
    addLumpListItem("FF_START")

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
    addLumpListItem("FF_END")

    ------------------
    -- patches
    ------------------
    utils:printf(1, "\tCreating Patches Namespace...", name)

    -- make the P_START marker
    addLumpListItem("PP_START")

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
    addLumpListItem("PP_END")

    -- lump data
    local pos = {}
    local lumpchunk = ""

    utils:printf(1, "\tConcatenating lump data...")

    local datasb = stringbuilder()
    local size = 0
    for lump = 1, #lumplist_new do
        local lumplistitem = lumplist_new[lump]

        pos[lump] = size
        datasb:append(lumplistitem.data)
        size = size + lumplistitem.size
    end
    lumpchunk = datasb:toString()

    -- header
    local header = love.data.pack("string", "<c4i4i4", self.header.magic, #lumplist_new, 12+#lumpchunk)

    -- dir
    local dirsb = stringbuilder()

    for lump = 1, #lumplist_new do
        local lumplistitem = lumplist_new[lump]
        dirsb:append(love.data.pack("string", "<i4i4c8", pos[lump]+12, #lumplistitem.data, lumplistitem.name))
    end

    self.raw = header .. lumpchunk .. dirsb:toString()
    self:gatherHeader()
end

function wad:buildNamespaces()
    local found = false
    local namespace = ""
    local foundend = false

    for l = 0, self.header.lumpcount do

        -- get file meta data
        local filepos, size, name = love.data.unpack("<i4i4c8", self.raw, self.header.dirpos+(l*16))
        name = utils:removePadding(name):upper()
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
            local namespacedata = self.namespaces[namespace]
            if(namespacedata ~= nil) then
                namespacedata.lumps[#namespacedata.lumps+1] = { name=name, size=size, pos=filepos, data=filedata }
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
                        if(self.namespaces[name].lumps[l].name == self.ignorelist[ignore][1]) then
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
end

function wad:organizeMaps()
    if(self.base ~= self) then
        local namespacedata = self.namespaces["MM"]
        local found = false
        local namespace = ""
        local mapname = ""
        local count_dm = 0
        local count_hm = 0
        local count_um = 0
        local index = 0

        -- if any maps were found
        if(#namespacedata.lumps > 0) then

            -- for each lump in the maps namespace
            for l = 1, #namespacedata.lumps do

                local v = namespacedata.lumps[l]

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
                    self.maps[index].name = self.acronym .. namespacedata.lumps[l+1].name:sub(-2)
                    self.maps[index].raw = {}
                end
            end

            -- structure map data
            for m = 1, #self.maps do
                local map = self.maps[m]

                utils:printf(2, "\tFound %s", map.name)
                for l = map.pos[1], map.pos[2] do
                    local lump = namespacedata.lumps[l]

                    if(lump.name == "THINGS") then            map.raw.things        = lump.data
                    elseif(lump.name == "LINEDEFS") then     map.raw.linedefs     = lump.data
                    elseif(lump.name == "SIDEDEFS") then     map.raw.sidedefs     = lump.data
                    elseif(lump.name == "VERTEXES") then     map.raw.vertexes     = lump.data
                    elseif(lump.name == "SEGS") then        map.raw.segs        = lump.data
                    elseif(lump.name == "SSECTORS") then     map.raw.ssectors     = lump.data
                    elseif(lump.name == "NODES") then        map.raw.nodes        = lump.data
                    elseif(lump.name == "SECTORS") then     map.raw.sectors     = lump.data
                    elseif(lump.name == "REJECT") then        map.raw.reject         = lump.data
                    elseif(lump.name == "BLOCKMAP") then     map.raw.blockmap     = lump.data
                    elseif(lump.name == "BEHAVIOR") then     map.raw.behavior    = lump.data
                    elseif(lump.name == "SCRIPTS") then     map.raw.scripts     = lump.data
                    elseif(lump.name == "TEXTMAP") then     map.raw.textmap     = lump.data
                    elseif(lump.name == "ZNODES") then        map.raw.znodes         = lump.data
                    elseif(lump.name == "DIALOGUE") then     map.raw.dialogue     = lump.data
                    elseif(lump.name == "ENDMAP") then        map.raw.endmap         = lump.data
                    end
                end

                -- log stuff
                if(map.raw.behavior == nil and map.raw.textmap == nil) then
                    count_dm = count_dm + 1
                else
                    count_hm = count_hm + 1
                end

                if(map.raw.textmap ~= nil) then
                    count_um = count_um + 1
                end
            end

            utils:printf(1, "\tDoom Maps: '%d' \n\tHexen Maps: '%d' \n\tUDMF Maps: '%d'", count_dm, count_hm, count_um)
        end
    else
        utils:printf(1, "\tNot organizing base wad maps.")
    end
end

function wad:processPalette()
    if self.palette == nil then
        -- find PLAYPAL
        local paldata = self:findLump("SP", "PLAYPAL")

        -- if playpal found
        if (paldata ~= "") then
            self.palette = {}

            for c = 1, 256*3, 3 do
                local r, g, b = love.data.unpack("<BBB", paldata, c)
                local index = #self.palette+1
                local r2, g2, b2 = love.math.colorFromBytes(r, g, b, 255)
                self.palette[index] =
                {
                    r2,
                    g2,
                    b2
                }
            end
        else
            self.palette = self.base.palette
            utils:printf(1, "\tNo PLAYPAL found. using base wad PLAYPAL.")
        end
    else
        utils:printf(1, "\tUsing custom palette.")
    end
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
            image.png = utils:insertGRAB(image.png, image.xoffset, image.yoffset)
            image.md5 = love.data.hash("md5", image.png)
            utils:printf(2, "Checksum: %s;", love.data.encode("string", "hex", image.md5))
        end
        images[image.name] = image
    end
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

            local composite = {
                name = utils:removePadding(love.data.unpack("<c8", data, offsets[i])),
                flags = love.data.unpack("<H", data, offsets[i]+8),
                scalex = love.data.unpack("<B", data, offsets[i]+0x0A),
                scaley = love.data.unpack("<B", data, offsets[i]+0x0B),
                width = love.data.unpack("<h", data, offsets[i]+0x0C),
                height = love.data.unpack("<H", data, offsets[i]+0x0E),
                unused1 = love.data.unpack("<B", data, offsets[i]+0x10),
                unused2 = love.data.unpack("<B", data, offsets[i]+0x11),
                unused3 = love.data.unpack("<B", data, offsets[i]+0x12),
                unused4 = love.data.unpack("<B", data, offsets[i]+0x13),
                patchcount = love.data.unpack("<h", data, offsets[i]+0x14),
                patches = {},
                dups = {},
                ignore = false
            }
            self.composites[c] = composite

            composite.canvas = love.graphics.newCanvas(composite.width, composite.height)

            local hasonepatch = composite.patchcount == 1

            -- mappatch_t
            love.graphics.setCanvas(composite.canvas)
            for p = 1, composite.patchcount do
                local compositepatch = {
                    x = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)),
                    y = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+2),
                    patch = self.pnames[love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+4)+1],
                    stepdir = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+6),
                    colormap = love.data.unpack("<h", data, offsets[i]+0x16+((p-1)*10)+8)
                }
                composite.patches[p] = compositepatch

                local patchdata = self.patches[compositepatch.patch]

                -- patches
                if (patchdata == nil) then
                    local notfound = true
                    patchdata = self.base.patches[compositepatch.patch]

                    if (patchdata ~= nil) then
                        if (hasonepatch and patchdata.composite == nil and isCompositeSameAsPatch(composite, compositepatch, patchdata)) then
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
                    if (hasonepatch and patchdata.composite == nil and isCompositeSameAsPatch(composite, compositepatch, patchdata)) then
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
end

function isCompositeSameAsPatch(composite, compositepatch, patch)
    return compositepatch.x == 0 and compositepatch.y == 0 and composite.width == patch.width and composite.height == patch.height
end

function wad:processTexturesTXT()
    -- find TEXTURES
    local data = self:findLump("SP","TEXTURES")

    -- if TEXTURES found
    if data ~= "" then
        -- Split data into lines
        local lines = {}
        for line in data:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end

        -- Iterate through each line
        for i, line in ipairs(lines) do
            -- find any line that starts with texture
            if line:find("texture ") then
                -- Split the line into words
                local words = {}
                for word in line:gmatch("%S+") do
                    table.insert(words, word)
                end

                -- Get the texture name
                local textureName = words[2]:sub(1, -2)
                self.texturedefines[#self.texturedefines+1] = {}
                self.texturedefines[#self.texturedefines].name = textureName

                local newname = ""
                if self.texturecount <= 9999 then
                    self.texturecount = self.texturecount + 1
                    newname = string.format("%s%.4d", self.acronym, self.texturecount)
                else
                    self.texturecount2 = self.texturecount2 + 1
                    newname = string.format("%s%s%.4d", self.acronym:sub(1, 3), "Z", self.texturecount2)
                end

                self.texturedefines[#self.texturedefines].newname = newname
                words[2] = newname .. ","
                lines[i] = table.concat(words, " ")
                utils:printf(2, "\tFound TEXTURES.TXT texture: %s", textureName)
            end
        end
        data = table.concat(lines, "\n")
        self:setLumpData("SP", "TEXTURES", data)
    end
end

function wad:processAnimated()
    -- find ANIMATED
    local data = self:findLump("SP", "ANIMATED")

    -- if ANIMATED found
    if (data ~= "") then
        local t = love.data.unpack("<B", data)
        local count = 0

        while (t ~= 255) do
            local last = utils:removePadding(love.data.unpack("<c8", data, 2+count)):upper()
            local first = utils:removePadding(love.data.unpack("<c8", data, 11+count)):upper()
            local speed = love.data.unpack("<i4", data, 20+count)

            local isdup = false
            for d = 1, #self.animlist do
                local anim = self.animlist[d]

                if (anim.first == first and anim.last == last) then
                    utils:printf(2, "\tFound Duplicate ANIMATED define: %s %s to %s with speed %s", t, first, last, speed)
                    isdup = true
                    break
                end
            end

            if (isdup == false) then
                local newanim = {first = first, last = last}

                if (t == 0) then newanim.typ = "flat"
                elseif (t == 1) then newanim.typ = "texture" end

                self.animlist[#self.animlist+1] = newanim
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
    if (data ~= "") then
        local t = 1
        local count = 0

        while (t ~= 0) do
            local off = utils:removePadding(love.data.unpack("<c8", data, 1+count)):upper()
            local on = utils:removePadding(love.data.unpack("<c8", data, 10+count)):upper()
            t = love.data.unpack("<H", data, 19+count)

            local isdup = false
            for d = 1, #self.switchlist do
                local switch = self.switchlist[d]

                if (switch.off == off and switch.on == on) then
                    isdup = true
                    break
                end
            end

            utils:printf(2, "\tFound SWITCH define: %s, %s, %s", off, on, t)

            if (isdup == false) then
                self.switchlist[#self.switchlist+1] = {off = off, on = on}
            end

            count = count + 20
        end
    end
end

function wad:filterDuplicates()
    local count = 0
    local compositecount = #self.composites

    -- filter dups from same wad
    for c = 1, compositecount do
        local composite = self.composites[c]

        local ignore = false
        for i = 1, #self.ignorelist_dups do
            if (composite.name == self.ignorelist_dups[i]) then
                ignore = true
            end
        end
        if ignore == false then
            for c2 = c, compositecount do
                if (c ~= c2) then
                    local composite2 = self.composites[c2]

                    local ignore = false
                    for i = 1, #self.ignorelist_dups do
                        if (composite2.name == self.ignorelist_dups[i]) then
                            ignore = true
                        end
                    end
                    if ignore == false then
                        if (composite.md5 == composite2.md5) then
                            count = count + 1
                            if (composite.dups ~= nil) then
                                local dupcomposite = composite.dups[composite.name]
                                if (dupcomposite == nil) then dupcomposite = {} end
                                dupcomposite[#dupcomposite+1] = composite2.name
                            end
                        end
                    end
                end
            end
        end
    end

    utils:printf(1, "\tFound '%d' duplicates", count)
    count = 0
    -- filter dups from base wad
    if (self.base ~= self) then
        local function flagDuplicateAssets(pwadassets, baseassets)
            for a = 1, #pwadassets do
                local pwadasset = pwadassets[a]
                local ignore = false
                for i = 1, #self.ignorelist_dups do
                    if (pwadasset.name == self.ignorelist_dups[i]) then
                        ignore = true
                    end
                end
                if ignore == false then
                    for a2 = 1, #baseassets do
                        local baseasset = baseassets[a2]
                        local ignore = false
                        for i = 1, #self.ignorelist_dups do
                            if (baseasset.name == self.ignorelist_dups[i]) then
                                ignore = true
                            end
                        end

                        if ignore == false then
                            if (pwadasset.md5 == baseasset.md5) then
                                count = count + 1
                                pwadasset.ignore = true
                                pwadasset.doomdup = baseasset.name
                                utils:printf(2, "\tFound pwad '%s' and base '%s' duplicates.", pwadasset.name, baseasset.name)
                            end
                        end
                    end
                end
            end
        end

        -- composites
        flagDuplicateAssets(self.composites, self.base.composites)

        -- flats
        flagDuplicateAssets(self.flats, self.base.flats)

        -- patches
        flagDuplicateAssets(self.patches, self.base.patches)

        -- sprites
        flagDuplicateAssets(self.sprites, self.base.sprites)
    end

    utils:printf(1, "\tFound '%d' doom duplicates", count)
end


function wad:renamePatches()
    if(self.base ~= self) then
        local patchcount = self:renameAssets(self.patches)
        utils:printf(1, "\tFound %d patches.\n", patchcount)
    else
        utils:printf(1, "\tNot renaming base wad patches.\n")
    end
end

function wad:renameTextures()
    if(self.base ~= self) then
        local texturecount = self:renameAssets(self.composites)
        utils:printf(1, "\tFound %d composites.\n", texturecount)
    else
        utils:printf(1, "\tNot renaming base wad textures.\n")
    end
end

function wad:renameFlats()
    if(self.base ~= self) then
        local flatcount = self:renameAssets(self.flats)
        utils:printf(1, "\tFound %d flats.\n", flatcount)
    else
        utils:printf(1, "\tNot renaming base wad flats.\n")
    end
end

function wad:renameAssets(assets)
    local assetcount = #assets

    for a = 1, assetcount do
        local asset = assets[a]

        if (not asset.ignore) then
            local newname

            if self.texturecount <= 9999 then
                self.texturecount = self.texturecount + 1
                newname = string.format("%s%.4d", self.acronym, self.texturecount)
            else
                self.texturecount2 = self.texturecount2 + 1
                newname = string.format("%s%s%.4d", self.acronym:sub(1, 3), "Z", self.texturecount2)
            end

            utils:printf(2, "\tRenaming %s to %s", asset.name, newname)
            asset.newname = newname
        end
    end

    return assetcount
end

function wad:renameSprites()
    if (self.base ~= self) then
        local spritesets = {}
        local setcount = 0

        for s = 1, #self.sprites do
            local sprite = self.sprites[s]
            local set = sprite.name:sub(1, 4)

            if (spritesets[set] == nil) then
                spritesets[set] = {}
                setcount = setcount + 1
                utils:printf(1, "\tFound Sprite Set: %s", set)
            end

            sprite.newname = string.format("%s%02d%s", self.acronym_sprite, setcount, sprite.name:sub(5))
            utils:printf(2, "\tRenamed %s to %s", sprite.name, sprite.newname)
        end
        utils:printf(1, "\tFound %d Sprite Sets.", setcount)
    else
        utils:printf(1, "\tNot renaming base wad patches.\n")
    end
end

function wad:renameSounds()
    if (self.base ~= self) then
        local function renameSoundsForType(sounds)
            for s = 1, #sounds do
                local sound = sounds[s]
                self.soundcount = self.soundcount + 1
                sound.newname = string.format("%s%.4d", self.acronym, self.soundcount)
                utils:printf(2, "\tRenamed %s to %s", sound.name, sound.newname)
            end
        end

        --LMP
        renameSoundsForType(self.doomsounds)

        --WAV
        renameSoundsForType(self.wavesounds)

        --OGG
        renameSoundsForType(self.oggsounds)

        --FLAC
        renameSoundsForType(self.flacsounds)
    end
end

function wad:renameSongs()
    if self.base ~= self then
        for l = 1, #self.music_list do
            local lump = self:findLump("MS", self.music_list[l])

            if lump ~= "" then
                for s = 1, #self.songs do
                    local song = self.songs[s]

                    if song.data == lump then
                        song.newname = string.format("%s%.2d", self.acronym, l)

                        if l == 33 then
                            song.newname = string.format("%sIN", self.acronym)
                        end

                        utils:printf(2, "\tRenamed %s to %s", song.name, song.newname)
                        break
                    end
                end
            end
        end
    end
end

function wad:renameZDoomTextures()
    if(self.base ~= self) then
        local zdoomcount = self:renameAssets(self.zdoomtextures)
        utils:printf(1, "\tFound %d ZDoom textures.\n", zdoomcount)
    else
        utils:printf(1, "\tNot renaming base wad ZDoom textures.\n")
    end
end

function wad:filterOTexAssets()
    local count = 0
    for f = 1, #self.flats do
        local flat = self.flats[f]
        if otex:checkImageExists(flat.name, flat.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Flat: %s", flat.name)
            flat.ignore = true
        end
    end
    for p = 1, #self.patches do
        local patch = self.patches[p]
        if otex:checkImageExists(patch.name, patch.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Patch: %s", patch.name)
            patch.ignore = true
        end
    end
    for c = 1, #self.composites do
        local composite = self.composites[c]
        if otex:checkImageExists(composite.name, composite.md5) then
            count = count + 1
            utils:printf(2, "\tFound OTex Composite: %s", composite.name)
            composite.ignore = true
        end
    end
    utils:printf(1, "\tFound %d OTex Assets.\n", count)
end

function wad:processTextLump(name)
    -- find file with name
    local data = self:findLump("SP", name)

    -- if file exists
    if (data ~= "") then

        for p = 1, #self.patches do
            local patch = self.patches[p]
            data = data:gsub('%f[%w]'..patch.name..'%f[%W]', getPatchName(patch))
        end

        for c = 1, #self.composites do
            local composite = self.composites[c]
            data = data:gsub('%f[%w]'..composite.name..'%f[%W]', composite.newname)
        end

        for f = 1, #self.flats do
            local flat = self.flats[f]
            data = data:gsub('%f[%w]'..flat.name..'%f[%W]', flat.newname)
        end

        for z = 1, #self.zdoomtextures do
            local zdoomtexture = self.zdoomtextures[z]
            data = data:gsub('%f[%w]'..zdoomtexture.name..'%f[%W]', zdoomtexture.newname)
        end

        for t = 1, #self.texturedefines do
            local texture = self.texturedefines[t]
            data = data:gsub('%f[%w]'..texture.name..'%f[%W]', texture.newname)
        end
    end

    return data
end

function wad:buildAnimdefs()
    if (self.base ~= self) then
        -- animations
        self.animdefs.anims = {}

        self:buildAnimdefsForAssets(self.composites, "texture")
        self:buildAnimdefsForAssets(self.flats, "flat")

        -- switches
        self.animdefs.switches = {}

        self:buildSwitchesForAssets(self.composites, "Composites")
        self:buildSwitchesForAssets(self.flats, "Flats")
        self:buildSwitchesForAssets(self.patches, "Patches")
    else
        utils:printf(1, "\tNot building animdefs for base wad.\n")
    end
end

function wad:buildAnimdefsForAssets(assets, assettype)
    for ast = 1, #assets do
        local asset = assets[ast]

        for al = 1, #self.animlist do
            if (not asset.ignore) then
                local animlist = self.animlist[al]

                if (animlist.first == asset.name and animlist.typ == assettype) then
                    utils:printf(2, "\tBuilding Animation: %s %s to %s", assettype, asset.name, animlist.last)

                    local a = #self.animdefs.anims + 1
                    local anim = {
                        text1 = asset.newname,
                        typ = animlist.typ,
                        decal = animlist.flags
                    }

                    self.animdefs.anims[a] = anim

                    for ast2 = 1, #assets do
                        local asset2 = assets[ast2]

                        if (asset2.name == animlist.last) then
                            anim.text2 = asset2.newname
                        end
                    end
                    break
                end
            end
        end
    end
end

function wad:buildSwitchesForAssets(assets, assettype)
    for a = 1, #assets do
        local asset = assets[a]

        if (not asset.ignore) then
            for sl = 1, #self.switchlist do
                local switchlist = self.switchlist[sl]

                if (switchlist.off == asset.name) then
                    utils:printf(2, "\tBuilding Switch From %s: %s to %s", assettype, asset.name, switchlist.on)

                    local s = #self.animdefs.switches + 1
                    local switch = {text1 = asset.newname}

                    self.animdefs.switches[s] = switch

                    for a2 = 1, #assets do
                        local asset2 = assets[a2]

                        if (switchlist.on == asset2.name) then
                            switch.text2 = asset2.newname
                        end
                    end
                    break
                end
            end
        end
    end
end

function wad:processMaps()
    if (self.base ~= self) then
        for m = 1, #self.maps do
            local map = self.maps[m]

            utils:printf(2, "\tProcessing Map: %d, %s", m, map.name)

            -- doom
            if (map.format == "DM") then

                -- things
                map.things = {}
                local count = 0
                for s = 1, #map.raw.things, 10 do
                    count = count + 1

                    map.things[count] = {
                        x = love.data.unpack("<h", map.raw.things, s),
                        y = love.data.unpack("<h", map.raw.things, s+2),
                        angle = love.data.unpack("<H", map.raw.things, s+4),
                        typ = love.data.unpack("<H", map.raw.things, s+6),
                        flags = love.data.unpack("<H", map.raw.things, s+8)
                    }
                end

                -- linedefs
                map.linedefs = {}
                count = 0
                for s = 1, #map.raw.linedefs, 14 do
                    count = count + 1

                    map.linedefs[count] = {
                        vertex_start = love.data.unpack("<H", map.raw.linedefs, s),
                        vertex_end = love.data.unpack("<H", map.raw.linedefs, s+2),
                        flags = love.data.unpack("<H", map.raw.linedefs, s+4),
                        line_type = love.data.unpack("<H", map.raw.linedefs, s+6),
                        sector_tag = love.data.unpack("<H", map.raw.linedefs, s+8),
                        sidedef_right = love.data.unpack("<H", map.raw.linedefs, s+10),
                        sidedef_left = love.data.unpack("<H", map.raw.linedefs, s+12)
                    }
                end

                self:processCommonMapData(map)

            --hexen
            elseif(map.format == "HM") then

                -- things
                local count = 0
                for s = 1, #map.raw.things, 20 do
                    count = count + 1

                    map.things[count] = {
                        id = love.data.unpack("<H", map.raw.things, s),
                        x = love.data.unpack("<h", map.raw.things, s+2),
                        y = love.data.unpack("<h", map.raw.things, s+4),
                        z = love.data.unpack("<h", map.raw.things, s+6),
                        angle = love.data.unpack("<H", map.raw.things, s+8),
                        typ = love.data.unpack("<H", map.raw.things, s+10),
                        flags = love.data.unpack("<H", map.raw.things, s+12),
                        special = love.data.unpack("<B", map.raw.things, s+14),
                        a1 = love.data.unpack("<B", map.raw.things, s+15),
                        a2 = love.data.unpack("<B", map.raw.things, s+16),
                        a3 = love.data.unpack("<B", map.raw.things, s+17),
                        a4 = love.data.unpack("<B", map.raw.things, s+18),
                        a5 = love.data.unpack("<B", map.raw.things, s+19)
                    }
                end

                -- linedefs
                map.linedefs = {}
                count = 0
                for s = 1, #map.raw.linedefs, 16 do
                    count = count + 1

                    map.linedefs[count] = {
                        vertex_start = love.data.unpack("<H", map.raw.linedefs, s),
                        vertex_end = love.data.unpack("<H", map.raw.linedefs, s+2),
                        flags = love.data.unpack("<H", map.raw.linedefs, s+4),
                        special = love.data.unpack("<B", map.raw.linedefs, s+6),
                        a1 = love.data.unpack("<B", map.raw.linedefs, s+7),
                        a2 = love.data.unpack("<B", map.raw.linedefs, s+8),
                        a3 = love.data.unpack("<B", map.raw.linedefs, s+9),
                        a4 = love.data.unpack("<B", map.raw.linedefs, s+10),
                        a5 = love.data.unpack("<B", map.raw.linedefs, s+11),
                        front_sidedef = love.data.unpack("<B", map.raw.linedefs, s+12),
                        back_sidedef = love.data.unpack("<B", map.raw.linedefs, s+14)
                    }
                end

                self:processCommonMapData(map)
            end
        end
    else
        utils:printf(1, "\tNot processing base wad maps.")
    end
end

function wad:processCommonMapData(map)
    -- sidedefs
    map.sidedefs = {}
    local count = 0
    for s = 1, #map.raw.sidedefs, 30 do
        count = count + 1

        map.sidedefs[count] = {
            xoffset = love.data.unpack("<h", map.raw.sidedefs, s),
            yoffset = love.data.unpack("<h", map.raw.sidedefs, s+2),
            upper_texture = utils:removePadding(love.data.unpack("<c8", map.raw.sidedefs, s+4)):upper(),
            lower_texture = utils:removePadding(love.data.unpack("<c8", map.raw.sidedefs, s+12)):upper(),
            middle_texture = utils:removePadding(love.data.unpack("<c8", map.raw.sidedefs, s+20)):upper(),
            sector = love.data.unpack("<H", map.raw.sidedefs, s+28)
        }
    end

    -- vertexes
    map.vertexes = {}
    count = 0
    for s = 1, #map.raw.vertexes, 4 do
        count = count + 1

        map.vertexes[count] = {
            x = love.data.unpack("<h", map.raw.vertexes, s),
            y = love.data.unpack("<h", map.raw.vertexes, s+2)
        }
    end

    -- sectors
    map.sectors = {}
    count = 0
    for s = 1, #map.raw.sectors, 26 do
        count = count + 1

        map.sectors[count] = {
            floor_height = love.data.unpack("<h", map.raw.sectors, s),
            ceiling_height = love.data.unpack("<h", map.raw.sectors, s+2),
            floor_texture = utils:removePadding(love.data.unpack("<c8", map.raw.sectors, s+4)):upper(),
            ceiling_texture = utils:removePadding(love.data.unpack("<c8", map.raw.sectors, s+12)):upper(),
            light = love.data.unpack("<h", map.raw.sectors, s+20),
            special = love.data.unpack("<H", map.raw.sectors, s+22),
            tag = love.data.unpack("<H", map.raw.sectors, s+24)
        }
    end
end

function wad:ModifyMaps()
    if (self.base ~= self) then
        for m = 1, #self.maps do
            local map = self.maps[m]

            utils:printf(1, "\tModifying Map: %s", map.name)

            -- doom/hexen
            if (map.format == "DM" or map.format == "HM") then
                -- thing replacement
                if (self.things == "Y") then
                    local actorlist = utils:openFile(string.format("%s/actorlist.%s.txt", self.pk3path, self.acronym), "r")
                    actorlist:read("*line")
                    actorlist:read("*line")
                    actorlist:read("*line")
                    local line = actorlist:read("*line")

                    utils:printf(2, "\t\tReplacing actors....")
                    while line ~= nil do

                        -- actor replacement stuff
                        local actornewspace = line:find(" ")
                        local actor1 = line:sub(1, actornewspace)
                        local actor2 = line:sub(actornewspace+1)
                        actor1 = actor1 + 0
                        actor2 = actor2 + 0
                        for t = 1, #map.things do
                            local thing = map.things[t]
                            if (thing.typ == actor1) then
                                utils:printf(3, "\t\t\tReplace actor #%d: X: %d; Y: %d; Angle: %d; Flags: %d; Old Type: %d; New Type: %d", t, thing.x, thing.y, thing.angle, thing.flags, actor1, actor2)
                                thing.typ = actor2
                            end
                        end

                        line = actorlist:read("*line")
                    end
                    actorlist:close()
                end

                -- find textures and rename
                utils:printf(2, "\t\tReplacing composites...")
                for c = 1, #self.composites do
                    local composite = self.composites[c]
                    self:replaceMapTextures(map, composite, composite.newname)
                end

                -- find flats and rename
                utils:printf(2, "\t\tReplacing flats....")
                for f = 1, #self.flats do
                    local flat = self.flats[f]
                    self:replaceMapTextures(map, flat, flat.newname)
                end

                -- find patches and rename
                utils:printf(2, "\t\tReplacing patches....")
                for p = 1, #self.patches do
                    local patch = self.patches[p]
                    self:replaceMapTextures(map, patch, getPatchName(patch))
                end

                -- find zdoom textures and rename
                utils:printf(2, "\t\tReplacing zdoom textures....")
                for z = 1, #self.zdoomtextures do
                    local zdoomtexture = self.zdoomtextures[z]
                    self:replaceMapTextures(map, zdoomtexture, zdoomtexture.newname)
                end

                -- find textures.txt textures and rename
                utils:printf(2, "\t\tReplacing textures.txt textures....")
                for t = 1, #self.texturedefines do
                    local texture = self.texturedefines[t]
                    self:replaceMapTextures(map, texture, texture.newname)
                end

                -- build raw things back
                utils:printf(2, "\t\tBuilding things lump...")
                count = 0
                map.raw.things = ""
                local sb = stringbuilder()
                for s = 1, #map.things do
                    local thing = map.things[s]
                    count = count + 1
                    if(map.format == "DM") then
                        sb:append(love.data.pack("string", "<hhHHH", thing.x, thing.y, thing.angle, thing.typ, thing.flags))
                    elseif(map.format == "HM") then
                        sb:append(love.data.pack("string", "<HhhhHHHBBBBBB", thing.id, thing.x, thing.y, thing.z, thing.angle, thing.typ, thing.flags, thing.special, thing.a1, thing.a2, thing.a3, thing.a4, thing.a5))
                    end
                end
                map.raw.things = sb:toString()

                -- build raw sidedefs back
                utils:printf(2, "\t\tBuilding sidedefs lump...")
                count = 0
                map.raw.sidedefs = ""
                sb:clear()
                for s = 1, #map.sidedefs do
                    local sidedef = map.sidedefs[s]
                    count = count + 1
                    sb:append(love.data.pack("string", "<hhc8c8c8H", sidedef.xoffset, sidedef.yoffset, sidedef.upper_texture, sidedef.lower_texture, sidedef.middle_texture, sidedef.sector))
                end
                map.raw.sidedefs = sb:toString()

                -- build raw sectors back
                utils:printf(2, "\t\tBuilding sectors lump...")
                count = 0
                map.raw.sectors = ""
                sb:clear()
                for s = 1, #map.sectors do
                    local sector = map.sectors[s]
                    count = count + 1
                    sb:append(love.data.pack("string", "<hhc8c8hHH", sector.floor_height, sector.ceiling_height, sector.floor_texture, sector.ceiling_texture, sector.light, sector.special, sector.tag))
                end
                map.raw.sectors = sb:toString()

            --udmf
            elseif(map.format == "UM") then

                --[[
                if(self.things == "Y") then
                    local lines = {}
                    local inThing = false
                    for line in map.raw.textmap:gmatch("[^\r\n]+") do
                        if line:find("thing") then
                            inThing = true
                        elseif inThing then
                            if line:find("}") then
                                inThing = false
                            else
                                local thing = tonumber(line:match("id = (%d+)"))
                                for l = 1, #self.thinglist do
                                    local thinglist = self.thinglist[l]
                                    if thing == thinglist.old then
                                        line = line:gsub("id = %d+", "id = "..thinglist.new)
                                        utils:printf(3, "\t\t\tReplace thing #%d with #%d", thing, thinglist.new)
                                    end
                                end
                            end
                        end
                        table.insert(lines, line)
                    end
                end
                ]]

                utils:printf(2, "\t\tReplacing composites...")
                for c = 1, #self.composites do
                    local composite = self.composites[c]
                    utils:printf(3, "\t\t\tReplacing composite %s with %s", composite.name, composite.newname)
                    map.raw.textmap = map.raw.textmap:gsub('%f[%w]'..composite.name..'%f[%W]', composite.newname)
                end

                utils:printf(2, "\t\tReplacing flats...")
                for f = 1, #self.flats do
                    local flat = self.flats[f]
                    utils:printf(3, "\t\t\tReplacing flat %s with %s", flat.name, flat.newname)
                    map.raw.textmap = map.raw.textmap:gsub('%f[%w]'..flat.name..'%f[%W]', flat.newname)
                end

                utils:printf(2, "\t\tReplacing patches...")
                for p = 1, #self.patches do
                    local patch = self.patches[p]
                    utils:printf(3, "\t\t\tReplacing patch %s with %s", patch.name, getPatchName(patch))
                    map.raw.textmap = map.raw.textmap:gsub('%f[%w]'..patch.name..'%f[%W]', getPatchName(patch))
                end

                utils:printf(2, "\t\tReplacing zdoom textures...")
                for z = 1, #self.zdoomtextures do
                    local zdoomtexture = self.zdoomtextures[z]
                    utils:printf(3, "\t\t\tReplacing zdoom texture %s with %s", zdoomtexture.name, zdoomtexture.newname)
                    map.raw.textmap = map.raw.textmap:gsub('%f[%w]'..zdoomtexture.name..'%f[%W]', zdoomtexture.newname)
                end

                utils:printf(2, "\t\tReplacing textures.txt textures...")
                for t = 1, #self.texturedefines do
                    local texture = self.texturedefines[t]
                    utils:printf(3, "\t\t\tReplacing textures.txt texture %s with %s", texture.name, texture.newname)
                    map.raw.textmap = map.raw.textmap:gsub('%f[%w]'..texture.name..'%f[%W]', texture.newname)
                end

                -- This is specificly for fixing Dark Encounters maps.
                --[[
                local lines = {}
                local inLinedef = false
                local inSpecial = false
                local inArg1 = false
                local special = 0
                for line in map.raw.textmap:gmatch("[^\r\n]+") do
                    if line:find("linedef") or line:find("sector") then
                        inLinedef = true
                    elseif inLinedef then
                        if line:find("{") then
                            inSpecial = true
                        elseif inSpecial then
                            if  line:find("special = 80;") or
                                line:find("special = 81;") or
                                line:find("special = 82;") or
                                line:find("special = 83;") or
                                line:find("special = 84;") or
                                line:find("special = 85;") or
                                line:find("special = 226;") then
                                inArg1 = true
                                special = line:match("special = (%d+);")
                            elseif inArg1 then
                                if line:find("arg1") then
                                    utils:printf(3, "\t\t\t\tReplacing '" .. line .. "' with 0; special = " .. tostring(special))
                                    line = "arg1 = 0;"
                                    inArg1 = false
                                end
                            elseif line:find("}") then
                                inLinedef = false
                                inSpecial = false
                            end
                        end
                    end
                    table.insert(lines, line)
                end
                map.raw.textmap = table.concat(lines, "\n")
                ]]
            end
        end
    else
        utils:printf(1, "\tNot modifying base wad maps.")
    end
end

function wad:replaceMapTextures(map, texture, newtexturename)
    if (not texture.ignore) then
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
                local newname = texture.doomdup or texture.name
                utils:printf(3, "\t\t\tKeeping sidedef #%d upper texture %s", s, newname)
                sidedef.upper_texture = newname
            end

            if (sidedef.lower_texture == texture.name) then
                local newname = texture.doomdup or texture.name
                utils:printf(3, "\t\t\tKeeping sidedef #%d lower texture %s", s, newname)
                sidedef.lower_texture = newname
            end

            if (sidedef.middle_texture == texture.name) then
                local newname = texture.doomdup or texture.name
                utils:printf(3, "\t\t\tKeeping sidedef #%d middle texture %s", s, newname)
                sidedef.middle_texture = newname
            end
        end

        -- floors
        for ss = 1, #map.sectors do
            local sector = map.sectors[ss]

            if (sector.floor_texture == texture.name) then
                local newname = texture.doomdup or texture.name
                utils:printf(3, "\t\t\tKeeping sector #%d floor texture %s", ss, newname)
                sector.floor_texture = newname
            end

            if (sector.ceiling_texture == texture.name) then
                local newname = texture.doomdup or texture.name
                utils:printf(3, "\t\t\tKeeping sector #%d ceiling texture %s", ss, newname)
                sector.ceiling_texture = newname
            end
        end
    end
end

function wad:extractComposites()
    if (self.base ~= self) then
        local texturesb = stringbuilder()

        local function isCompositeDifferentFromPatches(composite)
            if (composite.patchcount > 1) then
                return true
            end

            local compositepatch = composite.patches[1]
            local patchdata = self.patches[compositepatch.patch] or self.base.patches[compositepatch.patch]

            return not isCompositeSameAsPatch(composite, compositepatch, patchdata)
        end

        for c = 1, #self.composites do
            local composite = self.composites[c]

            if (not composite.iszdoom) then
                if (not composite.ignore) then
                    utils:printf(2, "\tExtracting Composite: %s", composite.newname)

                    if (isCompositeDifferentFromPatches(composite)) then
                        texturesb:append(self:createTextureDefinition(composite))
                    else
                        self:extractAsset("textures", composite.newname, composite.png)
                    end
                end
            else
                utils:printf(2, "\tExtracting Texture: %s", composite.newname)

                if (isCompositeDifferentFromPatches(composite)) then
                    texturesb:append(self:createTextureDefinition(composite))
                else
                    local png = utils:openFile(string.format("%s/textures/%s/%s.raw", self.pk3path, self.acronym, composite.newname:lower()), "w+b")
                    png:write(composite.raw)
                    png:close()
                end
            end
        end

        if (not texturesb:empty()) then
            local file = utils:openFile(string.format("%s/textures.%s.txt", self.pk3path, self.acronym), "w")
            file:write(texturesb:toString())
            file:close()
        end
    else
        utils:printf(1, "\tNot extracting base wad composites.\n")
    end
end

-- Creates a Texture definition for TEXTURES
function wad:createTextureDefinition(composite)
    local texturedefsb = stringbuilder()
    texturedefsb:append(string.format("Texture \"%s\", %d, %d\n{\n", composite.newname, composite.width, composite.height))

    for p = 1, composite.patchcount do
        local compositepatch = composite.patches[p]
        local patchdata = self.patches[compositepatch.patch]
        local basepatchdata = self.base.patches[compositepatch.patch]
        local patchname = getPatchName(patchdata, basepatchdata)

        if (#patchname > 0) then
            if (patchdata or basepatchdata) then
                if (patchdata) then
                    patchdata.used = true
                end
                texturedefsb:append(string.format("\tPatch \"%s\", %d, %d\n", patchname, compositepatch.x, compositepatch.y))
            end
        end
    end

    texturedefsb:append("}\n")
    return texturedefsb:toString()
end

function getPatchName(patch, basepatch)
    local patchname

    if (patch and not patch.ignore) then
        -- If this patch is a standalone texture, then use the composite texture name instead
        if (patch.composite) then
            patchname = patch.composite.newname
        else
            patchname = patch.newname
        end
    end

    -- If patch was not defined or somehow did not have a name, then attempt to get name from basepatch (if it exists)
    if (basepatch and patchname == nil) then
        patchname = basepatch.name or (basepatch.composite and basepatch.composite.name)
    end

    return patchname or ""
end

function wad:extractGraphics()
    if (self.base ~= self) then
        for g = 1, #self.graphics do
            local graphic = self.graphics[g]

            utils:printf(2, "\tExtracting Graphic: %s", graphic.name)
            self:extractAsset("graphics", graphic.name, graphic.png)
        end
    else
        utils:printf(1, "\tNot extracting base wad graphics.\n")
    end
end

function wad:extractFlats()
    if (self.base ~= self) then
        for f = 1, #self.flats do
            local flat = self.flats[f]

            if (not flat.ignore and flat.newname) then
                utils:printf(2, "\tExtracting Flat: %s", flat.newname)
                self:extractAsset("flats", flat.newname, flat.png)
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad flats.\n")
    end
end

function wad:extractPatches()
    if (self.base ~= self) then
        for p = 1, #self.patches do
            local patch = self.patches[p]

            if (not patch.ignore and patch.composite == nil and patch.newname) then
                utils:printf(2, "\tExtracting Patch: %s", patch.newname)
                self:extractAsset("patches", patch.newname, patch.png)
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad patches.\n")
    end
end

function wad:extractSprites()
    if (self.base ~= self) then
        for s = 1, #self.sprites do
            local sprite = self.sprites[s]

            if (not sprite.ignore) then
                utils:printf(2, "\tExtracting Sprite: %s", sprite.name)
                sprite.newname = sprite.newname:gsub("\\", "^")
                self:extractAsset("sprites", sprite.newname, sprite.png)
            else
                utils:printf(2, "\tNot Extracting Duplicate Sprite: %s", sprite.name)
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad sprites.\n")
    end
end

function wad:extractZDoomTextures()
    if (self.base ~= self) then
        for z = 1, #self.zdoomtextures do
            local zdoomtexture = self.zdoomtextures[z]

            if (not zdoomtexture.ignore and zdoomtexture.composite == nil and zdoomtexture.newname) then
                utils:printf(2, "\tExtracting ZDoom Texture: %s", zdoomtexture.newname)
                self:extractAsset("textures", zdoomtexture.newname, zdoomtexture.png)
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad patches.\n")
    end
end

function wad:extractAsset(dirname, assetname, assetimagedata)
    local png = utils:openFile(string.format("%s/%s/%s/%s.png", self.pk3path, dirname, self.acronym, assetname:lower()), "w+b")
    png:write(assetimagedata)
    png:close()
end

function wad:extractMaps()
    if (self.base ~= self) then
        local function getLumpChunkAndPositions(order)
            local pos = {}
            local pos2 = 0
            local lumpchunksb = stringbuilder()
            for o = 1, #order do
                local lump = order[o]

                pos[o] = pos2
                pos2 = pos2 + #lump
                lumpchunksb:append(lump)
            end

            return lumpchunksb:toString(), pos
        end

        for m = 1, #self.maps do
            local map = self.maps[m]

            -- doom/hexen
            if(map.format == "DM" or map.format == "HM") then
                utils:printf(2, "\tExtracting DM/HM Map: %d", m)
                -- lumps
                local order = {}
                order[#order+1] = map.raw.things
                order[#order+1] = map.raw.linedefs
                order[#order+1] = map.raw.sidedefs
                order[#order+1] = map.raw.vertexes
                order[#order+1] = map.raw.segs
                order[#order+1] = map.raw.ssectors
                order[#order+1] = map.raw.nodes
                order[#order+1] = map.raw.sectors
                order[#order+1] = map.raw.reject
                order[#order+1] = map.raw.blockmap
                if(map.raw.behavior) then order[#order+1] = map.raw.behavior end
                if(map.raw.scripts) then order[#order+1] = map.raw.scripts end

                -- header
                local lumpchunk, pos = getLumpChunkAndPositions(order)
                local header = love.data.pack("string", "<c4i4i4", "PWAD", #order+1, 12+#lumpchunk)

                -- directory
                local dirsb = stringbuilder()
                dirsb:append(love.data.pack("string", "<i4i4c8", 0, 0, "MAP01"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[1]+12, #order[1], "THINGS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[2]+12, #order[2], "LINEDEFS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[3]+12, #order[3], "SIDEDEFS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[4]+12, #order[4], "VERTEXES"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[5]+12, #order[5], "SEGS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[6]+12, #order[6], "SSECTORS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[7]+12, #order[7], "NODES"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[8]+12, #order[8], "SECTORS"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[9]+12, #order[9], "REJECT"))
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[10]+12, #order[10], "BLOCKMAP"))
                if(map.raw.behavior) then dirsb:append(love.data.pack("string", "<i4i4c8", pos[11]+12, #order[11], "BEHAVIOR")) end
                if(map.raw.scripts) then dirsb:append(love.data.pack("string", "<i4i4c8", pos[12]+12, #order[12], "SCRIPTS")) end

                local wad = utils:openFile(string.format("%s/maps/%s.wad", self.pk3path, map.name), "w+b")

                wad:write(header)
                wad:write(lumpchunk)
                wad:write(dirsb:toString())
                wad:close()

            -- udmf
            elseif(map.format == "UM") then
                utils:printf(2, "\tExtracting UM Map: %d", m)
                -- lumps
                local order = {}
                order[#order+1] = map.raw.textmap
                if(map.raw.znodes) then order[#order+1] = map.raw.znodes end
                if(map.raw.reject) then order[#order+1] = map.raw.reject end
                if(map.raw.dialogue) then order[#order+1] = map.raw.dialogue end
                if(map.raw.behavior) then order[#order+1] = map.raw.behavior end
                if(map.raw.scripts) then order[#order+1] = map.raw.scripts end
                order[#order+1] = map.raw.endmap

                -- header
                local lumpchunk, pos = getLumpChunkAndPositions(order)
                local header = love.data.pack("string", "<c4i4i4", "PWAD", #order+1, 12+#lumpchunk)

                -- directory
                local dirsb = stringbuilder()
                dirsb:append(love.data.pack("string", "<i4i4c8", 0, 0, "MAP01"))
                local index = 1
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "TEXTMAP"))
                index = index + 1
                if(map.raw.znodes)      then dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "ZNODES"))      index = index + 1 end
                if(map.raw.reject)      then dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "REJECT"))      index = index + 1 end
                if(map.raw.dialogue)    then dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "DIALOGUE"))    index = index + 1 end
                if(map.raw.behavior)    then dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "BEHAVIOR"))    index = index + 1 end
                if(map.raw.scripts)     then dirsb:append(love.data.pack("string", "<i4i4c8", pos[index]+12, #order[index], "SCRIPTS"))      index = index + 1 end
                dirsb:append(love.data.pack("string", "<i4i4c8", pos[#order]+12, 0, "ENDMAP"))

                local wad = utils:openFile(string.format("%s/maps/%s.wad", self.pk3path, map.name:lower()), "w+b")
                wad:write(header)
                wad:write(lumpchunk)
                wad:write(dirsb:toString())
                wad:close()
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad maps.\n")
    end
end

function wad:extractAnimdefs()
    if(self.base ~= self) then
        local animsb = stringbuilder()
        local lumpNameSb = stringbuilder()

        for a = 1, #self.animdefs.anims do
            local anim = self.animdefs.anims[a]

            utils:printf(2, "\t\t%s %s range %s tics 8", anim.typ, anim.text1, anim.text2)
            animsb:append(string.format("%s %s range %s tics 8", anim.typ, anim.text1, anim.text2))

            texNumMin = anim.text1:sub(5, 8)
            texNumMax = anim.text2:sub(5, 8)

            for i = tonumber(texNumMin), tonumber(texNumMax) do
                lumpNameSb:append(self.acronym)

                if i < 1000 then
                    lumpNameSb:append("0")
                end

                if i < 100 then
                    lumpNameSb:append("0")
                end

                if i < 10 then
                    lumpNameSb:append("0")
                end

                animdefsIgnore[lumpNameSb:toString() .. i] = "not nil";
                i = i + 1
                lumpNameSb:clear()
            end

            if(anim.decal) then
                animsb:append(" "..anim.decal)
            end
            animsb:append("\n")
        end

        local switchsb = stringbuilder()
        for s = 1, #self.animdefs.switches do
            local switch = self.animdefs.switches[s]

            utils:printf(2, "\t\tswitch %s on pic %s tics 0", switch.text1, switch.text2)
            switchsb:append(string.format("switch %s on pic %s tics 0\n", switch.text1, switch.text2))

            animdefsIgnore[switch.text1] = "not nil";
            animdefsIgnore[switch.text2] = "not nil";
        end

        if (not animsb:empty() or not switchsb:empty() or #self.animdefs.original > 0) then
            local file = utils:openFile(string.format("%s/animdefs.%s.txt", self.pk3path, self.acronym), "w")
            file:write(animsb:toString())
            file:write(switchsb:toString())
            file:write(self.animdefs.original)
            file:close()
        else
            utils:printf(1, "\tNo animations/switches to define.\n")
        end
    else
        utils:printf(1, "\tNot extracting base wad animdefs.\n")
    end
end

function wad:extractSNDINFO()
    if (self.base ~= self) then
        local txtsb = stringbuilder()
        self.snddefs = {}

        local function createSNDINFODefs(sounditems)
            for s = 1, #sounditems do
                local sounditem = sounditems[s]

                txtsb:append(string.format("%s/%s\t\t\t\t%s\n", self.acronym, sounditem.name, sounditem.newname))
                self.snddefs[#self.snddefs+1] = { string.format("%s/%s", self.acronym, sounditem.name),  sounditem.name }
            end
        end

        createSNDINFODefs(self.doomsounds)
        createSNDINFODefs(self.wavesounds)
        createSNDINFODefs(self.oggsounds)
        createSNDINFODefs(self.flacsounds)

        if (not txtsb:empty()) then
            local file = utils:openFile(string.format("%s/sndinfo.%s.txt", self.pk3path, self.acronym), "w")
            file:write(txtsb:toString())
            file:close()
        else
            utils:printf(1, "\tNo sounds to define.\n")
        end
    else
        utils:printf(1, "\tNot extracting base wad sndinfo.\n")
    end
end

function wad:extractSounds()
    if (self.base ~= self) then
        local function createSoundFiles(sounditems, fileextension)
            for s = 1, #sounditems do
                local sounditem = sounditems[s]

                local snd = utils:openFile(string.format("%s/sounds/%s/%s.%s", self.pk3path, self.acronym, sounditem.newname:lower(), fileextension), "w+b")
                snd:write(sounditem.data)
                snd:close()
            end
        end

        --LMP
        createSoundFiles(self.doomsounds, "lmp")

        --WAV
        createSoundFiles(self.wavesounds, "wav")

        --OGG
        createSoundFiles(self.oggsounds, "ogg")

        --FLAC
        createSoundFiles(self.flacsounds, "flac")
    else
        utils:printf(1, "\tNot extracting base wad sounds.\n")
    end
end

function wad:extractSongs()
    if(self.base ~= self) then
        for s = 1, #self.songs do
            if self.songs[s].newname ~= nil then
                local ext = "ukn"
                if utils:checkFormat(self.songs[s].data, "MUS") then
                    ext = "mus"
                end
                if utils:checkFormat(self.songs[s].data, "OggS") then
                    ext = "ogg"
                end
                if utils:checkFormat(self.songs[s].data, "MThd") then
                    ext = "mid"
                end
                if utils:checkFormat(self.songs[s].data, "mp3") then
                    ext = "mp3"
                end

                local mus = utils:openFile(string.format("%s/music/%s/D_%s.%s", self.pk3path, self.acronym, self.songs[s].newname, ext), "w+b")
                mus:write(self.songs[s].data)
                mus:close()
            end
        end
    else
        utils:printf(1, "\tNot extracting base wad music.\n")
    end
end

function wad:extractTexturesLump()
    if(self.base ~= self) then

        if #self.texturedefines > 0 then
            local file = utils:openFile(string.format("%s/textures.%s.txt", self.pk3path, self.acronym), "w+")
            file:write(self:findLump("SP", "TEXTURES"))
            file:close()
        else
            utils:printf(1, "\tNo textures.txt to define.\n")
        end
    else
        utils:printf(1, "\tNot extracting base wad TextureX.\n")
    end
end

function wad:extractMapinfo()
    if (self.base ~= self) then
        local file = utils:openFile(string.format("%s/mapinfo/%s.txt", self.pk3path, self.acronym), "w")
        file:write(self.mapinfo)
        file:close()

        local mapinfopath = string.format("%s/mapinfo.txt", self.pk3path)
        file = utils:openFile(mapinfopath, "r")
        local mapinfo = file:read("*all")
        file:close()

        mapinfo = string.format('%s\ninclude "mapinfo/%s.txt"', mapinfo, self.acronym)

        file = utils:openFile(mapinfopath, "w")
        file:write(mapinfo)
        file:close()
    else
        utils:printf(1, "\tNot extracting mapinfo for base wad.\n")
    end
end

function wad:removeUnusedTextures()
    local function removeUnused(assets, dirname)
        local count = 0

        for a = 1, #assets do
            local asset = assets[a]

            if (not asset.used and animdefsIgnore[asset.newname] == nil) then
                count = count + 1
                os.remove(string.format("%s/%s/%s.png", self.pk3path, dirname, asset.newname))
            end
        end

        return count
    end

    local tex = removeUnused(self.composites, "textures")
    local flats = removeUnused(self.flats, "flats")
    local patches = removeUnused(self.patches, "patches")

    utils:printf(1, "\tFound: %i Unused Textures.", tex)
    utils:printf(1, "\tFound: %i Unused Flats.", flats)
    utils:printf(1, "\tFound: %i Unused Patches.", patches)
end


---------------------------------------------------------
-- Helpers
---------------------------------------------------------

function wad:findLump(namespace, lumpname)
    local namespacedata = self.namespaces[namespace]

    for l = 1, #namespacedata.lumps do
        local namespacelump = namespacedata.lumps[l]

        if (namespacelump.name == lumpname) then
            return namespacelump.data
        end
    end

    return ""
end

function wad:setLumpData(namespace, lumpname, data)
    local namespacedata = self.namespaces[namespace]

    for l = 1, #namespacedata.lumps do
        local namespacelump = namespacedata.lumps[l]

        if (namespacelump.name == lumpname) then
            namespacelump.data = data
            return
        end
    end
end

function wad:findTexture(data, texture, tbl, pos)
    pos = pos or 1
    local correct = 0
    while (pos < #data-8) do
        correct = 0
        for n = 1, 8 do
            local texturedata = data:sub(pos+n, pos+n)

            if (n <= #texture) then
                if (texturedata == texture:sub(n, n)) then
                    correct = correct + 1
                end
            elseif (texturedata == "\0") then
                correct = correct + 1
            end
        end
        if (correct == 8) then
            tbl[#tbl+1] = pos
            pos = pos + 8
        end
        pos = pos + 1
    end
    return tbl
end

return wad