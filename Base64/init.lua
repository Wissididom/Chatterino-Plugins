local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--[[Source: http://lua-users.org/wiki/BaseSixtyFour
local function b64encode(data)
  return ((data:gsub('.', function(x)
      local r,bx='',x:byte()
      for i=8,1,-1 do r=r..(bx%2^i-bx%2^(i-1)>0 and '1' or '0') end
      return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
      if (#x < 6) then return '' end
      local c=0
      for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
      return b64chars:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end
local function b64decode(data)
    data = data:gsub('[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f = '', (b64chars:find(x)-1)
        for i=6,1,-1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i=1,8 do
            c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0)
        end
        return string.char(c)
    end))
end]]
-- Math Base64 logic by ChatGPT
local b64lookup = {}
for i = 1, #b64chars do
    b64lookup[b64chars:sub(i, i)] = i - 1
end
local function b64encode(data)
    local result = {}
    local len = #data
    for i = 1, len, 3 do
        local a = data:byte(i)
        local b = data:byte(i+1) or 0
        local c = data:byte(i+2) or 0
        local triple = a * 65536 + b * 256 + c
        table.insert(result, b64chars:sub(math.floor(triple / 262144) % 64 + 1, math.floor(triple / 262144) % 64 + 1))
        table.insert(result, b64chars:sub(math.floor(triple / 4096) % 64 + 1, math.floor(triple / 4096) % 64 + 1))
        table.insert(result, i + 1 <= len and b64chars:sub(math.floor(triple / 64) % 64 + 1, math.floor(triple / 64) % 64 + 1) or '=')
        table.insert(result, i + 2 <= len and b64chars:sub(triple % 64 + 1, triple % 64 + 1) or '=')
    end
    return table.concat(result)
end
local function b64decode(data)
    data = data:gsub("[^" .. b64chars .. "=]", "")
    local result = {}
    for i = 1, #data, 4 do
        local a = b64lookup[data:sub(i,i)] or 0
        local b = b64lookup[data:sub(i+1,i+1)] or 0
        local c = b64lookup[data:sub(i+2,i+2)] or 0
        local d = b64lookup[data:sub(i+3,i+3)] or 0
        local triple = a * 262144 + b * 4096 + c * 64 + d
        local byte1 = math.floor(triple / 65536) % 256
        local byte2 = math.floor(triple / 256) % 256
        local byte3 = triple % 256
        table.insert(result, string.char(byte1))
        if data:sub(i+2,i+2) ~= '=' then
            table.insert(result, string.char(byte2))
        end
        if data:sub(i+3,i+3) ~= '=' then
            table.insert(result, string.char(byte3))
        end
    end
    return table.concat(result)
end

c2.register_command("/b64-encode", function(ctx)
    local text = table.concat(ctx.words, " ", 2)
    if text == "" then
        ctx.channel:add_system_message("Usage: /b64-encode <text>")
        return
    end
    local encoded = b64encode(text)
    ctx.channel:add_system_message("Encoded: " .. encoded)
end)
c2.register_command("/b64-decode", function(ctx)
    local text = table.concat(ctx.words, " ", 2)
    if text == "" then
        ctx.channel:add_system_message("Usage: /b64-decode <text>")
        return
    end
    local ok, decoded = pcall(b64decode, text)
    if not ok or not decoded then
        ctx.channel:add_system_message("Error: Invalid Base64 input.")
        return
    end
    ctx.channel:add_system_message("Decoded: " .. decoded)
end)
