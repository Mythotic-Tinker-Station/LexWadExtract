local utf8_validator = {
  __VERSION     = '0.0.2',
  __DESCRIPTION = 'Library for easily validating UTF-8 strings in pure Lua',
  __URL         = 'https://github.com/kikito/utf8_validator.lua',
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

setmetatable(utf8_validator, {
    -- Numbers taken from table 3-7 in www.unicode.org/versions/Unicode6.2.0/UnicodeStandard-6.2.pdf
    -- find-based solution inspired by http://notebook.kulchenko.com/programming/fixing-malformed-utf8-in-lua
    __call = function(_, str)
        local i, strlen = 1, #str

        local function hasPattern(pattern)
            return i == str:find(pattern, i)
        end

        while i <= strlen do
            if hasPattern("[%z\1-\127]") then i = i + 1
            elseif hasPattern("[\194-\223][\128-\191]") then i = i + 2
            elseif hasPattern("\224[\160-\191][\128-\191]")
                or hasPattern("[\225-\236][\128-\191][\128-\191]")
                or hasPattern("\237[\128-\159][\128-\191]")
                or hasPattern("[\238-\239][\128-\191][\128-\191]") then i = i + 3
            elseif hasPattern("\240[\144-\191][\128-\191][\128-\191]")
                or hasPattern("[\241-\243][\128-\191][\128-\191][\128-\191]")
                or hasPattern("\244[\128-\143][\128-\191][\128-\191]") then i = i + 4
            else
                return false, i
            end
        end

        return true
    end
})

return utf8_validator