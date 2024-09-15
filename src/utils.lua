
local utils = 
{
    verbose = 3
}

-- opens a file, and returns the file handle
function utils:openFile(filepath, filemode)
    local file, err = io.open(filepath, filemode)

    if err then
        error("[ERROR] " .. err)
    end

    return file
end

-- pad a string to 8 bytes
function utils:addPadding(str)
    if #str >= 8 then return str end
    local newstr = str

    for i = #str+1, 8 do
        newstr = string.format("%s%s", newstr, "\0")
    end
    return newstr
end

-- remove padding from a string
function utils:removePadding(str)
    local newstr = ""
    for i = 1, #str do
        if str:sub(i,i) == "\0" then break end
        newstr = string.format("%s%s", newstr, str:sub(i,i))
    end
    return newstr
end

-- insert zdoom's grAb chunk in a png file, with x and y offset
function utils:insertGRAB(data, xoff, yoff)
    local offsetdata = love.data.pack("string", ">c4i4i4", "grAb", xoff, yoff)
    local grAb = love.data.pack("string", ">I4c4i4i4I4", 8, "grAb", xoff, yoff, self:crc(offsetdata))
    return data:sub(1, 33) .. grAb .. data:sub(34)
end

-- read zdoom's grAb chunk in a png file, and return the x and y offset
function utils:readGRAB(data)
    local pos = 9
    while pos < #data do
        local size, chunk = love.data.unpack(">i4c4", data, pos)
        if chunk == "grAb" then
            local xoff = love.data.unpack(">i4", data, pos+8)
            local yoff = love.data.unpack(">i4", data, pos+12)
            return xoff, yoff
        end
        pos = pos + size + 12
    end
end

-- CRC code found: https://stackoverflow.com/questions/34120322/converting-a-c-checksum-function-to-lua
function utils:crc(data)
    sum = 65535
    local d
    for i = 1, #data do
        d = string.byte(data, i)    -- get i-th element, like data[i] in C
        sum = bit.bxor(sum, d)
        for i = 0, 7 do     -- lua for loop includes upper bound, so 7, not 8
            if (bit.band(sum, 1) == 0) then
                sum = bit.rshift(sum, 1)
            else
                sum = bit.bxor(bit.rshift(sum, 1),0xA001)  -- it is integer, no need for string func
            end
        end
    end
    return sum
end

-- check the magic(the first bytes of a file usually) of a file
function utils:checkFormat(data, magic, offset, bigendian)

    if #data < #magic then return false end

    -- because mp3s just HAD to be complicated for no reason.
    if magic == "mp3" then
        -- check for ID3 tag or MP3 frame header
        if data:sub(1, 3) == "ID3" then
            return true 
        end
    
        local byte1 = data:byte(1)
        local byte2 = data:byte(2)
        if byte1 == 0xFF and bit.band(byte2, 0xE0) == 0xE0 then
            return true
        else
            return false
        end
        return false
    end

    offset = offset or 1
    bigendian = bigendian or false

    local m
    if(not bigendian) then
        m = love.data.unpack(">c" .. #magic, data, offset)
    else
        m = love.data.unpack("<c" .. #magic, data, offset)
    end

    if(m == magic) then return true end

    return false
end

-- find a value in a table
function utils:findInTable(tbl, val)
    for i = 1, #tbl do
        if(tbl[i] == val) then
            return true
        end
    end
end

-- print with verbosity and logging to file
function utils:printf(verbose, ...)
    local str = string.format(...) .. "\n"
    if(verbose <= self.verbose) then
        io.write(str)
        io.flush()
        self.log_file:write(str)
    end
end

-- print with verbosity and logging to file, but without a newline
function utils:printfNoNewLine(verbose, ...)
    local str = string.format(...)
    if(verbose <= self.verbose) then
        io.write(str)
        io.flush()
        self.log_file:write(str)
    end
end

-- print a table
function utils:printTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if(type(v) == "table") then
            print(formatting)
            self:printTable(v, indent+1)
        elseif(type(v) == 'boolean') then
            print(formatting .. tostring(v))
        elseif(type(v) == "string" and #v > 50) then
            print(formatting .. tostring(k))
        else
            print(formatting .. v)
        end
    end
end

function utils:bench(label, func, ...)
    self:printf(0, label)
    local start = love.timer.getTime()
    collectgarbage()
    local memstart = collectgarbage("count")
    local result = func(...)
    self:printf(1, "\t----------------------------------------")
    self:printf(1, "\tTime Taken: %0.3fms.", (love.timer.getTime() - start) * 1000)
    self:printf(1, "\tMemory Used: %0.2fMB.", (collectgarbage("count") - memstart) / 1024)
    self:printf(1, "\tTotal Memory Used: %0.2fMB.", collectgarbage("count") / 1024)
    self:printf(0, "\tDone.\n")
    return result
end

return utils