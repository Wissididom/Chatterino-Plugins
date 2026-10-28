function cmdRandom(ctx)
    local a = tonumber(ctx.words[2])
    local b = tonumber(ctx.words[3])
    local min
    local max
    if a == nil then
        ctx.channel:add_system_message("Usage: /random <max> OR /random <min> <max>")
        return
    end
    if b == nil then
        -- only one argument: /random 100
        min = 0
        max = a
    else
        -- two arguments: /random 5 20
        min = a
        max = b
    end
    if min > max then
        ctx.channel:add_system_message("Error: min cannot be greater than max.")
        return
    end
    local result = math.random(min, max)
    ctx.channel:add_system_message("🎲 Random number (" .. min .. "-" .. max .. "): " .. result)
end

c2.register_command("/random", cmdRandom)
