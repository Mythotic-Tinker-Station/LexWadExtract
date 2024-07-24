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
	__call = function(self)
		return self:new()
	end
})

function stringbuilder:empty()
	return #self.buffer == 0
end

--[[
    The append can deal with 3 cases.
    1) 'item' is a simple string or number, in which case
    we just append it to our list and move on.
    2) 'item' is a boolean, in which case
    we stringify and append it to our list.
    3) 'item' represents another table, in which case we recursively iterate
    through every table until reaching the leaves.
]]
function stringbuilder:append(item)
	if (item == nil) then
		return self
	end

	local itemtype = type(item)

	if (itemtype == "string" or itemtype == "number") then
		table.insert(self.buffer, item)
	elseif (itemtype == "boolean") then
		table.insert(self.buffer, tostring(item))
	elseif (itemtype == "table") then
		for _, value in pairs(item) do
			self:append(value)
		end
	else
		error(string.format("Cannot append item of type %s", itemtype))
	end

	return self
end

function stringbuilder:clear()
	self.buffer = {}
	return self
end

function stringbuilder:toString(sep)
	sep = sep or ""
	return table.concat(self.buffer, sep)
end

local stringbuilder_mt = {
	__index = stringbuilder;
	__add = stringbuilder.append;
	__concat = stringbuilder.append;
	__tostring = stringbuilder.toString;
}

function stringbuilder:new()
	local obj = {
		buffer = {}
	}
	setmetatable(obj, stringbuilder_mt)

	return obj
end

return stringbuilder