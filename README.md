# Lexicon Wad Extractor Thing


## Prerequisite:
    Add the doom2.wad to the root folder

## Notes:
        Zandronum still relies on the 8 char name limit,
        So to avoid conflicts we made use of an acronym system
        all mods must have a 4 letter arconym, this will be used to:
            - ID the mapset
            - Rename assets:
                - Textures, Flats, Patches, Sounds: xxxxyyyy (xxxx = acronym, yyyy = number)
                - Maps:                             xxxxyy (xxxx = acronum, yy = map number)
                - Sprites:                          xxyyzzzz (xx = 2 letter acronym, yy = number, zzzz = frame)
                - Text lumps:                       xxxxxxxx.yyyy.txt (xxxxxxxx = lump file name, yyyy = acronym)

    Notes:
        Zandronum still relies on the 8 char name limit,
        So to avoid conflicts we made use of an acronym system
        all mods must have a 4 letter arconym, this will be use to:
            - ID the mapset
            - Rename assets:
                - Textures, Flats, Patches, Sounds: xxxxyyyy (xxxx is the acronym, yyyy is a number)
                - Maps:                             xxxxyy (xxxx is the acronum, yy is the map number)
                - Sprites:                          xxyyzzzz (xx is a 2 letter acronym, yy is a number, zzzz is the frames letters)
                - Text lumps:                       xxxxxxxx.yyyy.txt (xxxxxxxx is the name of the lump file, for example animdefs, yyyy is the acronym)




### What Do
1) Copy the wad file you want to convert into the root folder.
2) Click Run.Bat.
3) Follow the prompts:

        Prompt 1: Provide a 4 letter acronym for the mapset.
                  Must be 4 letters
                  Less than 4 letters will error
                  More the 4 letters will be ignored
                  Acronym will automaticly be made caps

        Prompt 2: Provide a 2 letter acronym for the sprites.
                  Same rules as above
                  Can be left blank if mapset has no sprites

        Prompt 3: Provide the name of the wad file
                  Path does not need to be absolute, only the filename.wad is necessary

        Prompt 4: Provide the name of the iwad this file runs on
                  Like the previous step, only filename.wad is necessary

        Prompt 5: Verbosity
                  For debugging
                  0 = Basic.
                  1 = Detailed.
                  2 = Spam all the things.
                  3 = Same as 2, but includes logging of loading the doom2.wad.
                  Blank = Same as 0

4) If all goes well, the pk3 folder will have all your converted assets

        Copy the assets to the lexicon_base expansion pack pk3 folder

5) Next you will need to modify the lexicon_base acs main.c file

        Modify and add up "#define MODCOUNT", so if its 19, you'll change it to 20
        Add the acronym you decided on to the int acronym_list[MODCOUNT] list

6) Next is the language.txt file, this file is where all the data for the mapset lies

        To add a mapset, add the following information so lexicon can gather info for each mapset

        format: <acronym>_<key> = "string"

        General information
            ACRO_NAME               = "Woo Mapset";                 // The name of the mapset
            ACRO_DESCRIPTION        = "Woo Mapset doesnt exist";    // A description of the mapset
            ACRO_MAPCOUNT           = "32";                         // Number of maps this mapset has
            ACRO_STARTMAP           = "ACRO01";                     // The name of the first map of this mapset
            ACRO_THUMBNAIL          = "IMAGENAME";                  // An image to display for the voting UI
                                                                    // thumbnails are 192x108, with forced gl defaults

        Credits:
            ACRO_CREDITS0           = "Person1";                    // Who made the mapset
            ACRO_CREDITS1           = "Person2";                    // Who made the mapset
            ...

        Start Items:
            ACRO_STARTITEM1         = "AcroFist:1";                 // Players start with the 1 AcroFist
            ACRO_STARTITEM2         = "AcroPistol:1";               // Players start with the 1 AcroPistol
            ACRO_STARTITEM3         = "Soulsphere:1";               // Players start with a Soul Sphere
            ...

        Take Items:
            ACRO_TAKEITEM1          = "Fist":1;                        // Remove the Doom Fist from players as they spawn
            ACRO_TAKEITEM2          = "Pistol":1;                   // Remove the Doom Pistol from players as they spawn
            ...

        Actor Replacers:
            ACRO_REPLACER0          = "ZombieMan:Archvile";         // A replacement define, Archviles will spawn in the place of Zombiemen for all levels in this mapset.
            ACRO_REPLACER1          = "ShotgunGuy:CoolImp";         // CoolImp will spawn in the place of ShotgunGuy for all levels in this mapset.
            ...

6) Run zandronum.exe with the git lexicon pk3 folder listed first, and git lexicon_base pk3 folder second

        Zandronum.exe -file "lexicon\pk3" -file "lexicon-base\pk3"

# Disclaimer
This tool will allow one to extract full mapsets including most of their resources such as textures, sounds, sprites etc to be able to be placed in a mapset compliation easily. Please note that we are not resposible should you decide to use this tool in a way where you infringe on peoples permissions of a mapset. Some people may not give you permission to add their works into a compilation or to put it bluntly, to rip peoples work. Always get permission from the author before you extract their work!!!
