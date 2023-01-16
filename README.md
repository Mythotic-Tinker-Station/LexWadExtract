# Lexicon Wad Extractor Thing


**Prerequisite: Add the doom2.wad to the \tools\extractor\ folder**


    Note: Repeat all steps for each mapset
#### All OSes
1) Copy the wad you want to convert to root (where you cloned the repo)

### Windows
2) Edit the run.bat to and add the wad name you want to convert and the 4 letter ALL CAPS acronym for the mapset should look something like this: start Love2D/love.exe "src" "mayhem17.wad" "MAYH"
3) Click Run.Bat

### Mac/Linux
2) Run Run.sh or Run-Mac.sh, whichever is applicable to you
3) Arguments are:
        Run.sh <WadToConvert> <NewWadName4Chars> [DebugLevel]

#### All OSes
4) Watch it do the thing.
5) Once its done, the \pk3\ folder should have all the mapset assets set and ready along with the rest
6) Just copy all that stuff to your pack pk3 folder, then setup the MAPINFO, LANGUAGE, and ACS Script