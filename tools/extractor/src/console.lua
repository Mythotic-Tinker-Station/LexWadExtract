local console =
{
	width = 0,
	height = 0,
	codes =
	{
		-- more information about these can be found at https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences

		cursor_up 					= {"\27[%iA", 						1},		-- Move the cursor up.
		cursor_down 				= {"\27[%iB", 						1},		-- Move the cursor down.
		cursor_right 				= {"\27[%iC", 						1},		-- Move the cursor right.
		cursor_left 				= {"\27[%iD", 						1},		-- Move the cursor left.
		cursor_next					= {"\27[%iE", 						1},		-- Move the cursor to the next line.
		cursor_prev					= {"\27[%iF", 						1},		-- Move the cursor to the previous line.
		cursor_horiz				= {"\27[%iG", 						1},		-- Move the cursor to an speciifc position on the current line.
		cursor_vert					= {"\27[%id", 						1},		-- Move the cursor to a specific line.
		cursor_xy					= {"\27[%i;%iH", 					2},		-- Move the cursor to a specific x, y location.
		cursor_hv					= {"\27[%i;%if", 					2},		-- Move the cursor to a specific horiz, vert location.
		cursor_save					= {"\27[s", 						0},		-- Save the cursor position.
		cursor_restore				= {"\27[u",							0},		-- Restores the cursor to the saved position.
		cursor_blink				= {"\27[?12h", 						0},		-- Enables cursor blinking.
		cursor_solid				= {"\27[?12l", 						0},		-- Enables cursor blinking.
		cursor_show					= {"\27[?25h", 						0},		-- Show the cursor.
		cursor_hide					= {"\27[?25l", 						0},		-- Hide the cursor.

		char_insert					= {"\27[%i@",						1},		-- Inserts a char at position(moving all text after it to the right, and deleting anything that goes off screen).
		char_delete					= {"\27[%iP",						1},		-- Deletes a char at position(moving all text after it to the left).
		char_erase					= {"\27[%iX",						1},		-- Erases a char at position(replacing it with a space).

		line_insert					= {"\27[%iL",						1},		-- Inserts a line into the buffer at the cursor position. The line the cursor is on, and lines below it, will be shifted downwards.
		line_delete					= {"\27[%iM",						1},		-- Deletes a line from the buffer, starting with the row the cursor is on.
		line_erase					= {"\27[%iJ",						1},		-- Replace all text on the line with the cursor specified by <n> with space characters.

		display_erase				= {"\27[%iJ",						1},		-- Replace all text in the current viewport/screen specified by <n> with space characters.
		display_palette				= {"\27]4;%i;rgb:%i/%i/%i\27", 		4},		-- Modify the internal palette.

		keypad_app					= {"\27=",							0},		-- Keypad keys will emit their application mode sequences.
		keypad_num					= {"\27>",							0},		-- Keypad keys will emit their numeric mode sequences.
		keypad_cursor_app			= {"\27[?1h",						0},		-- Cursor keys will emit their application mode sequences.
		keypad_cursor_num			= {"\27[?1h",						0},		-- Cursor keys will emit their numeric mode sequences.

		state_cursor				= {"\27[6n",						0},		-- Show cursor position as: ESC [ <r> ; <c> R Where <r> = cursor row and <c> = cursor column
		state_device				= {"\27[0c",						0},		-- Report the terminal identity. will emit “\x1b[?1;0c”, indicating "VT101 with No Options".

		tab_horiz					= {"\27H",							0},		-- Sets a tab stop in the current column the cursor is in.
		tab_horiz_cursor			= {"\27[%iI",						1},		-- Advance the cursor to the next column (in the same row) with a tab stop.
		tab_horiz_cursor_back		= {"\27[%iI",						1},		-- Move the cursor to the previous column (in the same row) with a tab stop.
		tab_clear					= {"\27[0g",						0},		-- Clears the tab stop in the current column, if there is one. Otherwise does nothing.
		tab_erase					= {"\27[3g",						0},		-- Clears all currently set tab stops.

		charset_dec					= {"\27(0",							0},		-- Enables DEC Line Drawing Mode. See http://vt100.net/docs/vt220-rm/table2-4.html
		charset_ascii				= {"\27(B",							0},		-- Enables ASCII Mode (Default)

		scroll_region				= {"\27[%i;%ir",					2},		-- Sets the VT scrolling margins of the viewport.

		window_title				= {"\27]2;%s\07",					1},		-- Sets the console window’s title.
		window_title2				= {"\27]0;%s\07",					1},		-- Sets the console window’s title. Supposedly this sets the icon as well?
		window_width132				= {"\27[?3h",						0},		-- Sets the console width to 132 columns wide.
		window_width80				= {"\27[?3l",						0},		-- Sets the console width to 80 columns wide.

		screen_alt					= {"\27[?1049h",					0},		-- Switches to a alternate screen buffer.
		screen_main					= {"\27[?1049l",					0},		-- Switches to a main screen buffer.

		soft_reset					= {"\27[!p",						0},		-- Resets some properties to defaults.

		text_up						= {"\27[%iS",						1},		-- Moves all the text up(only the text below the cursor).
		text_down					= {"\27[%iT",						1},		-- Moves all the text down(only the text below the cursor).
		text_reset					= {"\27[0m",						0},		-- Resets text formatting.
		text_bright					= {"\27[1m",						0},		-- Sets text to bright.
		text_underline				= {"\27[4m",						0},		-- Sets text to underline.
		text_no_underline			= {"\27[24m",						0},		-- Sets text to no underline.
		text_negative				= {"\27[7m",						0},		-- Swaps fore/back color.
		text_positive				= {"\27[27m",						0},		-- Swaps fore/back color back to normal.

		text_black					= {"\27[30m",						0},		-- Set text foreground to black.
		text_red					= {"\27[31m",						0},		-- Set text foreground to red.
		text_green					= {"\27[32m",						0},		-- Set text foreground to green.
		text_yellow					= {"\27[33m",						0},		-- Set text foreground to yellow.
		text_blue					= {"\27[34m",						0},		-- Set text foreground to blue.
		text_magenta				= {"\27[35m",						0},		-- Set text foreground to magenta.
		text_cyan					= {"\27[36m",						0},		-- Set text foreground to cyan.
		text_white					= {"\27[37m",						0},		-- Set text foreground to white.
		text_rgb					= {"\27[38;2;%i;%i;%im",			3},		-- Set text foreground to any RGB color.
		text_palette				= {"\27[38;5;%im",					0},		-- Set text foreground to palette index.
		text_default				= {"\27[39m",						0},		-- Set text foreground to default.

		text_back_black				= {"\27[40m",						0},		-- Set text background to black.
		text_back_red				= {"\27[41m",						0},		-- Set text background to red.
		text_back_green				= {"\27[42m",						0},		-- Set text background to green.
		text_back_yellow			= {"\27[43m",						0},		-- Set text background to yellow.
		text_back_blue				= {"\27[44m",						0},		-- Set text background to blue.
		text_back_magenta			= {"\27[45m",						0},		-- Set text background to magenta.
		text_back_cyan				= {"\27[46m",						0},		-- Set text background to cyan.
		text_back_white				= {"\27[47m",						0},		-- Set text background to white.
		text_back_rgb				= {"\27[48;2;%i;%i;%im",			3},		-- Set text background to any RGB color.
		text_back_palette			= {"\27[48;5;%im",					0},		-- Set text background to palette index.
		text_back_default			= {"\27[49m",						0},		-- Set text background to default.

		text_bright_black			= {"\27[90m",						0},		-- Set text foreground to bright black.
		text_bright_red				= {"\27[91m",						0},		-- Set text foreground to bright red.
		text_bright_green			= {"\27[92m",						0},		-- Set text foreground to bright green.
		text_bright_yellow			= {"\27[93m",						0},		-- Set text foreground to bright yellow.
		text_bright_blue			= {"\27[94m",						0},		-- Set text foreground to bright blue.
		text_bright_magenta			= {"\27[95m",						0},		-- Set text foreground to bright magenta.
		text_bright_cyan			= {"\27[96m",						0},		-- Set text foreground to bright cyan.
		text_bright_white			= {"\27[97m",						0},		-- Set text foreground to bright white.

		text_bright_back_black		= {"\27[100m",						0},		-- Set text background to bright black.
		text_bright_back_red		= {"\27[101m",						0},		-- Set text background to bright red.
		text_bright_back_green		= {"\27[102m",						0},		-- Set text background to bright green.
		text_bright_back_yellow		= {"\27[103m",						0},		-- Set text background to bright yellow.
		text_bright_back_blue		= {"\27[104m",						0},		-- Set text background to bright blue.
		text_bright_back_magenta	= {"\27[105m",						0},		-- Set text background to bright magenta.
		text_bright_back_cyan		= {"\27[106m",						0},		-- Set text background to bright cyan.
		text_bright_back_white		= {"\27[107m",						0},		-- Set text background to bright white.
	}
}

function console:init()

	-- allow console manipulation
	-- barrowed from: https://github.com/MikuAuahDark/livesim2/blob/master/logging.lua#L82
	ffi = require("ffi")
	ffi.cdef([[
				// coord structure
				typedef struct logging_Coord
				{
					int16_t x, y;
				} logging_Coord;

				// small rect structure
				typedef struct logging_SmallRect
				{
					int16_t l, t, r, b;
				} logging_SmallRect;

				// CSBI structure
				typedef struct logging_CSBI
				{
					logging_Coord csbiSize;
					logging_Coord cursorPos;
					int16_t attributes;
					logging_SmallRect windowRect;
					logging_Coord maxWindowSize;
				} logging_CSBI;

				void * __stdcall GetStdHandle(uint32_t );
				int SetConsoleMode(void *, uint32_t );
				int GetConsoleMode(void *, uint32_t *);
				int __stdcall GetConsoleScreenBufferInfo(void *, logging_CSBI *);
				int __stdcall CreateConsoleScreenBuffer(void *, void *, void *, void *, void *);
				bool __stdcall SetConsoleActiveScreenBuffer(int);
	]])
	local cmode = ffi.new("uint32_t[1]")
	ffi.C.GetConsoleMode(ffi.C.GetStdHandle(-12), cmode);
	ffi.C.SetConsoleMode(ffi.C.GetStdHandle(-12), bit.bor(cmode[0], 14))

	self.csbi = ffi.new("logging_CSBI")
	self:retrieveWindowSize()

	-- build the low level functions
	for k, v in pairs(self.codes) do
		if(v[2] == 0) then
			self[k] = function(_)
				return v[1]
			end
		end

		if(v[2] == 1) then
			self[k] = function(_, a1)
				return string.format(v[1], a1)
			end
		end

		if(v[2] == 2) then
			self[k] = function(_, a1, a2)
				return string.format(v[1], a1, a2)
			end
		end

		if(v[2] == 3) then
			self[k] = function(_, a1, a2, a3)
				return string.format(v[1], a1, a2, a3)
			end
		end

		if(v[2] == 4) then
			self[k] = function(_, a1, a2, a3, a4)
				return string.format(v[1], a1, a2, a3, a4)
			end
		end
	end
end

function console:retrieveWindowSize()
	ffi.C.GetConsoleScreenBufferInfo(ffi.C.GetStdHandle(-12), self.csbi)
	self.width = self.csbi. windowRect.r
	self.height = self.csbi. windowRect.b
end

console:init()

return console