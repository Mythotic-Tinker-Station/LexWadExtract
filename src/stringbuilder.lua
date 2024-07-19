--[[
    https://github.com/Wiladams/peettles/blob/master/peettles/stringbuilder.lua

    MIT License

    Copyright (c) 2018 William Adams

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
]]

--[[
    A simple class to help build up strings

    Usage:
    local sb = stringbuilder();
    sb:append("this ")
    sb:append("is a ")
    sb:append("long ")
    sb:append("string.")

    print(sb:toString())

    You can also do it this way:

    local sb = stringbuilder();
    sb.."this ".."is a ".."long ".."string."

    But, that's more wasteful as mostly it's doing regular string concatenation
    until the final 'this', which is appended to the string builder.
--]]

local stringbuilder = {}
setmetatable(stringbuilder, {
	__call = function(self, ...)
		return self:create(...)
	end
})

local stringbuilder_mt = {
	__index = stringbuilder;

	__add = function(self, ...)
		return self:append(...)
	end,

	__concat = function(self, ...)
		return self:append(...)
	end,

	__tostring = function(self)
		return self:toString()
	end
}

function stringbuilder:init(...)
	local obj = {
		buffer = {}
	}
	setmetatable(obj, stringbuilder_mt)

	return obj
end

function stringbuilder:create(...)
	return self:init(...)
end

function stringbuilder:empty()
	return #self.buffer == 0
end

--[[
    The append can deal with two cases.
    1) The 'other' is a simple string, in which case
    we just append it to our list and  move on.
    2) The 'other' represents another table, and that table
    is itself a stringbuilder.
]]
function stringbuilder:append(other)
	if type(other) == "string" then
		table.insert(self.buffer, other)
		return self
	elseif type(other) == "table" then
		if other.buffer ~= nil then
			for _, value in ipairs(other.buffer) do
				table.insert(self.buffer, value)
			end
		end
	end

	return self
end

function stringbuilder:toString(perLine)
	perLine = perLine or ""
	return table.concat(self.buffer, perLine)
end

function stringbuilder:str()
	return table.concat(self.buffer)
end

return stringbuilder