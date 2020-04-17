-- Lexicon Wad Organizer
-- woo boy this script eats up a lot of memory...
-- the code was changed to minimize memory usage
-- the script is super heavy, and causes Slade to freeze up, making the splash screen freeze as well :(
-- slade doesnt seem to have any sort of pause script and let slade recover ability it seems
-- this font is nice, but why does l and 1 look the same?!
-- this lexer doesnt highlight --[[ multiline comments :(
-- when slade freezes due to this script it steals focus and hides the splash screen behind it


local acronym = "EPC2"
local archive = false
local callcount = 0
local texturenumber = 0
local renamelist = {}

-- idk if doom even reads up to nine, or if any wad uses these in the first place, but just incase
local ignorelist = {"P1_START", "P2_START", "P3_START", "P4_START", "P5_START", "P6_START", "P7_START", "P8_START", "P9_START", "F1_START", "F2_START", "F3_START", "F4_START", "F5_START", "F6_START", "F7_START", "F8_START", "F9_START",
					"P1_END", "P2_END", "P3_END", "P4_END", "P5_END", "P6_END", "P7_END", "P8_END", "P9_END", "F1_END", "F2_END", "F3_END", "F4_END", "F5_END", "F6_END", "F7_END", "F8_END", "F9_END"}

-- all graphics here are found and then formatted as such:
-- 	<acronyum><newname>
-- 	ex: if acronym = DOOM
--	CWILV00 will become DOOMLV01
local graphicslist =
{
	{"CWILV00", "LV00"},
	{"CWILV01", "LV01"},
	{"CWILV02", "LV02"},
	{"CWILV03", "LV03"},
	{"CWILV04", "LV04"},
	{"CWILV05", "LV05"},
	{"CWILV06", "LV06"},
	{"CWILV07", "LV07"},
	{"CWILV08", "LV08"},
	{"CWILV09", "LV09"},
	{"CWILV10", "LV10"},
	{"CWILV11", "LV11"},
	{"CWILV12", "LV12"},
	{"CWILV13", "LV13"},
	{"CWILV14", "LV14"},
	{"CWILV15", "LV15"},
	{"CWILV16", "LV16"},
	{"CWILV17", "LV17"},
	{"CWILV18", "LV18"},
	{"CWILV19", "LV19"},
	{"CWILV20", "LV20"},
	{"CWILV21", "LV21"},
	{"CWILV22", "LV22"},
	{"CWILV23", "LV23"},
	{"CWILV24", "LV24"},
	{"CWILV25", "LV25"},
	{"CWILV26", "LV26"},
	{"CWILV27", "LV27"},
	{"CWILV28", "LV28"},
	{"CWILV29", "LV29"},
	{"CWILV30", "LV30"},
	{"CWILV31", "LV31"},
	{"CWILV32", "LV32"},
	{"INTERPIC", "INTR"},
	{"TITLEPIC", "TITL"},
	{"HELP", "HELP"},
	{"CREDIT", "CRED"},
	{"BOSSBACK", "BOSS"},
}

local namespaces =
{
	specials =
	{
		ids = {"SP"},
		-- this namespace was a late idea, so i retrofitted the code
		-- to check for * to look for names instead of types
		types =
		{
			"*ALTHUDCF",
			"*ANIMATED",
			"*ANIMDEFS",
			"*COLORMAP",
			"*CVARINFO",
			"*DECALDEF",
			"*DECORATE",
			"*DEFBINDS",
			"*DEFCVARS",
			"*DEHACKED",
			"*DEHSUPP",
			"*DEMO1",
			"*DEMO2",
			"*DEMO3",
			"*DMXGUS",
			"*_DEUTEX_",
			"*ENDOOM",
			"*FONTDEFS",
			"*FSGLOBAL",
			"*GAMINFO",
			"*GENMIDI",
			"*GLDEFS",
			"*IWADINFO",
			"*LANGUAGE",
			"*LOADACS",
			"*LOCKDEFS",
			"*MAPINFO",
			"*MENUDEF",
			"*MODELDEF",
			"*MUSINFO",
			"*PALVARS",
			"*PLAYPAL",
			"*PNAMES",
			"*REVERB",
			"*SBARINFO",
			"*SECRETS",
			"*SNDCURVE",
			"*SNDINFO",
			"*SNDSEQ",
			"*SWITCHES",
			"*TEAMINFO",
			"*TERRAIN",
			"*TEXTCOLO",
			"*TEXTURE1",
			"*TEXTURE2",
			"*TEXTURES",
			"*TRNSLATE",
			"*VOXELDEF",
			"*X11R6RGB",
			"*XHAIRS",
			"*XLAT",
			"*ZMAPINFO",

		},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 1, -- for shits and giggles, lets organize the namespaces in specific order
		rename = 0
	},

	sounds =
	{
		ids = {"DS"},
		types = {"snd_"},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 2,
		rename = 0
	},

	music =
	{
		ids = {"MS"},
		types = {"midi"},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 3,
		rename = 0
	},

	graphics =
	{
		ids = {"GG"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 4,
		rename = 2 -- each lump is renamed specificly
	},

	textures =
	{
		ids = {"TX"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 5,
		rename = 0
	},

	flats =
	{
		ids = {"F", "FF"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 6,
		rename = 0
	},

	patches =
	{
		ids = {"P", "PP"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 7,
		rename = 0
	},

	sprites =
	{
		ids = {"S", "SS"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 8,
		rename = 0
	},

	maps =
	{
		ids = {"MM"},
		types = {""},
		pos = {-1,-1},
		found = false,
		count = 0,
		lumps = {},
		order = 9, -- ignored
		rename = 0 -- ignored
	},
}

function execute(arch)

	App.logMessage("Start") -- since we have no os time functions, lets use the consoles timestamps to measure how long this takes

	acronym = App.promptString("Acronym", "Please provide a 4 letter acronym for this mapset.", "DOOM"):sub(1, 4)

	SplashWindow.show("Slade will freeze, DONT PANIC!", true)

	archive = arch

	-- build up data table
	findNamespaces()
	verifyNamespaces()
	gatherNamespaceLumps()
	gatherMaps()
	gatherSpecialLumps()

	-- build wad
	buildWad()

	SplashWindow.hide()

	App.logMessage("End")
end

function findNamespaces()

	-- for each lump
	for i = 1, #archive.entries do

		splashbarHelper(i, 0, #archive.entries, "Finding existing namespaces...")

		-- if it's size 0 then it must be a marker right?
		if(archive.entries[i].size == 0) then

			-- look for _
			local stripIDpos = archive.entries[i].name:find("_")

			-- if the lump name has _
			if(stripIDpos) then

				-- use it as a delimiter and split the name with it
				local id = archive.entries[i].name:sub(1, stripIDpos-1)
				local what = archive.entries[i].name:sub(stripIDpos+1)

				-- for each namespace
				for k, v in pairs(namespaces) do

					-- for each id in each namespace
					for _, v2 in ipairs(v.ids) do

						-- if the id matches
						if(v2 == id) then

							if(not namespaces[k].found) then
								-- if its a start marker
								if(what == "START") then
									namespaces[k].pos[1] = i
								end

								-- if its an end marker
								if(what == "END") then
									namespaces[k].pos[2] = i

									-- if start marker was found
									if(namespaces[k].pos[1] > -1) then
										namespaces[k].count = (namespaces[k].pos[2]-namespaces[k].pos[1])-1
										namespaces[k].found = true
										App.logMessage(string.format("Found namespace '%s' at {%d, %d} with %d lumps", k, namespaces[k].pos[1], namespaces[k].pos[2], namespaces[k].count))
									end
								end
							else
								error("Found multiple " .. k .. " namespaces.")
							end
						end
						countcall()
					end
					countcall()
				end
			end
		end
		countcall()
	end
	collectgarbage()
end

function verifyNamespaces()
	local count = 1
	for k, v in pairs(namespaces) do
		splashbarHelper(count, 0, 9, "Verifying namespaces...")
		count=count+1
		if(namespaces[k].pos[1] == -1 and namespaces[k].pos[2] > -1) then
			error(string.format("Namespace '%s' is missing it's start marker.", k))
		end
		if(namespaces[k].pos[1] > -1 and namespaces[k].pos[2] == -1) then
			error(string.format("Namespace '%s' is missing it's end marker.", k))
		end
		countcall()
	end
	collectgarbage()
end

-- gather all items already in namespaces
function gatherNamespaceLumps()
	local count = 1
	for k, v in pairs(namespaces) do
		for i = v.pos[1]+1, v.pos[2]-1 do
			v.lumps[#v.lumps+1] = archive.entries[i]
			splashbarHelper(count, 0, v.count, "Gathering file '%s' in namespace '%s'", v.lumps[#v.lumps].name, k)
			count=count+1
			countcall()
		end
		countcall()
	end
	collectgarbage()
end

-- gather all the maps
function gatherMaps()
	local index = 1
	local lumpcount = #archive.entries

	-- for each entry
	while(index <= lumpcount) do
		splashbarHelper(index, 0, lumpcount, "Gathering maps...(Found: %d)", namespaces.maps.count)

		-- if we are not under any namespaces
		if(countNamespaceLevel(index) == 0) then

			-- doom/hexen
			if(archive.entries[index].name == "THINGS") then
				local found_things 		= index
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
				for i = 1, 11 do
					if(index+i <= lumpcount) then
						if(archive.entries[index+i].name == "THINGS")		then break end
						if(archive.entries[index+i].name == "LINEDEFS") 	then found_lines 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SIDEDEFS") 	then found_sides 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "VERTEXES") 	then found_vertexes 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SEGS") 		then found_segs 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SSECTORS") 	then found_ssectors 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "NODES") 		then found_nodes	 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SECTORS")		then found_sectors 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "REJECT") 		then found_reject	 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "BLOCKMAP") 	then found_blockmap 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "BEHAVIOR") 	then found_behavior 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SCRIPTS")		then found_scripts 		= index+i; 	map_lumpcount = map_lumpcount+1 end
					end
					countcall()
				end

				if(found_lines and found_sides and found_vertexes and found_sectors) then
					local mapindex = #namespaces.maps.lumps+1
					namespaces.maps.found = true
					namespaces.maps.count = namespaces.maps.count + 1
					namespaces.maps.lumps[mapindex] = {}
					namespaces.maps.lumps[mapindex].name = archive.entries[found_things-1]
					namespaces.maps.lumps[mapindex].things = archive.entries[found_things]
					namespaces.maps.lumps[mapindex].lines = archive.entries[found_lines]
					namespaces.maps.lumps[mapindex].sides = archive.entries[found_sides]
					namespaces.maps.lumps[mapindex].vertexes = archive.entries[found_vertexes]
					namespaces.maps.lumps[mapindex].segs = archive.entries[found_segs]
					namespaces.maps.lumps[mapindex].ssectors = archive.entries[found_ssectors]
					namespaces.maps.lumps[mapindex].nodes = archive.entries[found_nodes]
					namespaces.maps.lumps[mapindex].sectors = archive.entries[found_sectors]
					namespaces.maps.lumps[mapindex].reject = archive.entries[found_reject]
					namespaces.maps.lumps[mapindex].blockmap = archive.entries[found_blockmap]
					namespaces.maps.lumps[mapindex].behavior = archive.entries[found_behavior]
					namespaces.maps.lumps[mapindex].scripts = archive.entries[found_scripts]
					namespaces.maps.lumps[mapindex].format = "DM"

					if(found_behavior) then
						namespace.maps.lumps[mapindex].format = "HM"
					end

					App.logMessage(string.format("Found map: '%s'; format: %s; at %d", namespaces.maps.lumps[mapindex].name.name, namespaces.maps.lumps[mapindex].format, found_things-1))

					index = index + map_lumpcount + 1
				else
					local mlumps = ""

					if(found_lines == false) then 	mlumps = mlumps .. "-LINEDEFS-" end
					if(found_sides == false) then 	mlumps = mlumps .. "-SIDEDEFS-" end
					if(found_vertexes == false) then  mlumps = mlumps .. "-VERTEXES-" end
					if(found_sectors == false) then   mlumps = mlumps .. "-SECTORS-" end

					error(string.format("Map %s(entry number %d) is missing the following required lumps '%s'", archive.entries[found_things-1].name, found_things-2, mlumps), 1)
				end

			-- udmf
			elseif(archive.entries[index].name == "TEXTMAP") then
				local found_textmap 	= index
				local found_znodes	 	= false
				local found_reject	 	= false
				local found_dialogue	= false
				local found_behavior	= false
				local found_scripts 	= false
				local found_endmap		= false
				local map_lumpcount 	= 1

				for i = 1, 5 do
					if(index+i <= lumpcount) then
						if(archive.entries[index+i].name == "TEXTMAP") 	then break end
						if(archive.entries[index+i].name == "ZNODES") 	then found_znodes 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "REJECT") 	then found_reject 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "DIALOGUE") then found_dialogue 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "BEHAVIOR") then found_behavior 	= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "SCRIPTS") 	then found_scripts 		= index+i; 	map_lumpcount = map_lumpcount+1 end
						if(archive.entries[index+i].name == "ENDMAP") 	then found_endmap	 	= index+i; 	map_lumpcount = map_lumpcount+1 end
					end
					countcall()
				end

				if(found_endmap) then
					local mapindex = #namespaces.maps.lumps+1
					namespaces.maps.found = true
					namespaces.maps.count = namespaces.maps.count + 1
					namespaces.maps.lumps[mapindex] = {}
					namespaces.maps.lumps[mapindex].name = archive.entries[found_textmap-1]
					namespaces.maps.lumps[mapindex].textmap = archive.entries[found_textmap]
					namespaces.maps.lumps[mapindex].znodes = archive.entries[found_znodes]
					namespaces.maps.lumps[mapindex].reject = archive.entries[found_reject]
					namespaces.maps.lumps[mapindex].dialogue = archive.entries[found_dialogue]
					namespaces.maps.lumps[mapindex].behavior = archive.entries[found_behavior]
					namespaces.maps.lumps[mapindex].scripts = archive.entries[found_scripts]
					namespaces.maps.lumps[mapindex].endmap = archive.entries[found_endmap]
					namespaces.maps.lumps[mapindex].format = "UM"

					App.logMessage(string.format("Found map: '%s'; format: %s; at %d", namespaces.maps.lumps[mapindex].name.name, namespaces.maps.lumps[mapindex].format, found_textmap-1))

					index = index + map_lumpcount + 1
				else
					error(string.format("Map %s has no ENDMAP.", archive.entries[found_textmap-1].name), 0)
				end
			else
				index = index + 1
			end
		else
			index = index + 1
		end
		countcall()
	end
	collectgarbage()
end

-- gather all items already not in a namespace
function gatherSpecialLumps()

	-- for each lump
	for i = 1, #archive.entries do
		splashbarHelper(i, 0, #archive.entries, "Moving unmarked lumps to new namespaces...")

		-- check if we are not inside any namespaces
		if(countNamespaceLevel(i) <= 0) then

			-- for each type
			for k, v in ipairs(namespaces.specials.types) do
				if(archive.entries[i].name == v:sub(2)) then
					namespaces.specials.count = namespaces.specials.count + 1
					namespaces.specials.lumps[namespaces.specials.count] = archive.entries[i]
					break
				end
				countcall()
			end
		end
		countcall()
	end
	collectgarbage()
end


-- build the new wad
function buildWad()

	-- create new wad
	newwad = Archives.create("wad")

	-- create a table so we can order our namespaces, because why not
	local order = {}
	for k, v in pairs(namespaces) do
		order[v.order] = {k, v}
	end

	for i, _ in ipairs(order) do

		local k = order[i][1]
		local v = order[i][2]

		-- ignore maps, maps require special treatment
		if(k ~= "maps") then

			-- dont bother making a namespace if there is nothing in it
			if(v.count > 0) then

				-- create start marker
				if(v.ids[2]) then
					newwad:createEntry(string.format("%s_START", v.ids[2]), -1)
				else
					newwad:createEntry(string.format("%s_START", v.ids[1]), -1)
				end
				-- for each lump in namespace
				for ii = 1, #v.lumps do

					splashbarHelper(ii, 0, #v.lumps, "Building new wad... Current namespace: %s", k)

					-- if lump exist?(i feel like there is a bug here if i need this check...)
					if(v.lumps[ii]) then

						local ignore = false

						-- ignore unnecessary lumps
						for d = 1, #ignorelist do
							if(v.lumps[ii].name == ignorelist[d]) then
								ignore = true
								break
							end
						end

						if(not ignore) then

							-- if set to rename as a texture with a number
							if(v.rename == 1) then
								local newname = string.format("%s%04d", acronym, texturenumber)
								renamelist[#renamelist+1] = {v.ids[1], v.lumps[ii].name, newname}
								newwad:createEntry(newname, -1):importData(v.lumps[ii].data)
								texturenumber=texturenumber+1

							-- if set to rename specific lumps
							elseif(v.rename == 2) then
								local found = false
								for g = 1, #graphicslist do

									-- if lump is in our graphics list
									if(v.lumps[ii].name == graphicslist[g][1]) then
										found = true
										local newname = string.format("%s%s", acronym, graphicslist[g][2])
										renamelist[#renamelist+1] = {v.ids[1], v.lumps[ii].name, newname}
										newwad:createEntry(newname, -1):importData(v.lumps[ii].data)
										break
									end
								end

								if(not found) then
									newwad:createEntry(v.lumps[ii].name, -1):importData(v.lumps[ii].data)
								end

							-- otherwise, copy original name
							else
								newwad:createEntry(v.lumps[ii].name, -1):importData(v.lumps[ii].data)
							end
						end
					end
				end

				-- create end marker
				if(v.ids[2]) then
					newwad:createEntry(string.format("%s_END", v.ids[2]), -1)
				else
					newwad:createEntry(string.format("%s_END", v.ids[1]), -1)
				end
			end
		end
	end

	-- maps

	newwad:createEntry(string.format("%s_START", namespaces.maps.ids[1]), -1)
	for l = 1, #namespaces.maps.lumps do
		splashbarHelper(l, 0, #namespaces.maps.lumps, "Building new wad... Current namespace: maps")
		newwad:createEntry(string.format("%s_START", namespaces.maps.lumps[l].format), -1)
		newwad:createEntry(namespaces.maps.lumps[l].name.name, -1):importData(namespaces.maps.lumps[l].name.data)

		-- doom/hexen
		if(namespaces.maps.lumps[l].format == "DM" or namespaces.maps.lumps[l].format == "HM") then
			newwad:createEntry("THINGS", -1):importData(namespaces.maps.lumps[l].things.data)
			newwad:createEntry("LINEDEFS", -1):importData(namespaces.maps.lumps[l].lines.data)
			newwad:createEntry("SIDEDEFS", -1):importData(namespaces.maps.lumps[l].sides.data)
			newwad:createEntry("VERTEXES", -1):importData(namespaces.maps.lumps[l].vertexes.data)
			if(namespaces.maps.lumps[l].segs) 		then newwad:createEntry("SEGS", -1):importData(namespaces.maps.lumps[l].segs.data) end
			if(namespaces.maps.lumps[l].ssectors) 	then newwad:createEntry("SSECTORS", -1):importData(namespaces.maps.lumps[l].ssectors.data) end
			if(namespaces.maps.lumps[l].nodes) 		then newwad:createEntry("NODES", -1):importData(namespaces.maps.lumps[l].nodes.data) end
			newwad:createEntry("SECTORS", -1):importData(namespaces.maps.lumps[l].sectors.data)
			if(namespaces.maps.lumps[l].reject) 	then newwad:createEntry("REJECT", -1):importData(namespaces.maps.lumps[l].reject.data) end
			if(namespaces.maps.lumps[l].blockmap) 	then newwad:createEntry("BLOCKMAP", -1):importData(namespaces.maps.lumps[l].blockmap.data) end
			if(namespaces.maps.lumps[l].behavior) 	then newwad:createEntry("BEHAVIOR", -1):importData(namespaces.maps.lumps[l].behavior.data) end
			if(namespaces.maps.lumps[l].scripts) 	then newwad:createEntry("SCRIPTS", -1):importData(namespaces.maps.lumps[l].scripts.data) end
		end

		-- udmf
		if(namespaces.maps.lumps[l].format == "UM") then
			newwad:createEntry("TEXTMAP", -1):importData(namespaces.maps.lumps[l].textmap.data)
			if(namespaces.maps.lumps[l].znodes) 	then newwad:createEntry("ZNODES", -1):importData(namespaces.maps.lumps[l].znodes.data) end
			if(namespaces.maps.lumps[l].reject) 	then newwad:createEntry("REJECT", -1):importData(namespaces.maps.lumps[l].reject.data) end
			if(namespaces.maps.lumps[l].dialogue) 	then newwad:createEntry("DIALOGUE", -1):importData(namespaces.maps.lumps[l].dialogue.data) end
			if(namespaces.maps.lumps[l].behavior) 	then newwad:createEntry("BEHAVIOR", -1):importData(namespaces.maps.lumps[l].behavior.data) end
			if(namespaces.maps.lumps[l].scripts) 	then newwad:createEntry("SCRIPTS", -1):importData(namespaces.maps.lumps[l].scripts.data) end
			newwad:createEntry("ENDMAP", -1):importData(namespaces.maps.lumps[l].endmap.data)
		end

		newwad:createEntry(string.format("%s_END", namespaces.maps.lumps[l].format), -1)
	end
	newwad:createEntry(string.format("%s_END", namespaces.maps.ids[1]), -1)

	-- RNAMEDEF
	splashbarHelper(0, 0, 0, "Building RNAMEDEF...")
	local entry = newwad:createEntry("RNAMEDEF", 1)

	for index = 1, #renamelist do
		-- slade seems to change this to a \, so let use that and hope no wads used this in a name
		renamelist[index] = table.concat(renamelist[index], "^")
	end
	entry:importData(table.concat(renamelist, "\n"))

	splashbarHelper(0, 0, 0, "Saving wad...")
	newwad:save(archive.filename:sub(1, -5) .. "_lex.wad")

	collectgarbage()
end


------------------------------------------------
-- Helpers
------------------------------------------------
local namespace_level = 0
function countNamespaceLevel(i)
	if(archive.entries[i].name:sub(-6) == "_START") then namespace_level = namespace_level + 1 end
	if(archive.entries[i].name:sub(-4) == "_END") then namespace_level = namespace_level - 1 end
	return namespace_level
end

function printTable(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if(type(v) == "table") then
			App.logMessage(formatting)
			printTable(v, indent+1)
		elseif(type(v) == 'boolean') then
			App.logMessage(formatting .. tostring(v))
		elseif(type(v) == 'userdata') then
			App.logMessage(formatting .. v.name)
		else
			App.logMessage(formatting .. v)
		end
	end
end

-- helper function for displaying more accurate progress bar info
function splashbarHelper(val, min, max, text, ...)
	SplashWindow.setProgressMessage(string.format(text, ...))
	SplashWindow.setProgress((val-min) / (max-min))
end

function countcall()
	callcount=callcount+1
	if(callcount > 300000) then error("Runaway detected.") end
end
