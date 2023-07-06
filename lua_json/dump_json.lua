
---@param t table
---@return boolean
local function is_array(t)
    -- check if t has non-number indeces
    for key, _ in pairs(t) do
        if type(key) ~= "number" then
            return false
        end
    end
    -- check if no nil indeces
    for i = 1, #t do
        if not t[i] then
            return false
        end
    end
    return true
end


---@param s string
---@return string
local function dump_string(s)
    return ('"%s"'):format(s)
end


---@param n number
---@return string
local function dump_num(n)
    return tostring(n)
end


---@param b boolean | nil
---@return string
local function dump_bool(b)
    if b == true then
        return "true"
    elseif b == false then
        return "false"
    else
        return "null"
    end
end


local dispatch_lua_type


---@param a any[]
---@return string
local function dump_array(a)
    local vals = {}
    for _, val in ipairs(a) do
        table.insert(vals, dispatch_lua_type(val))
    end
    return ("[%s]"):format(table.concat(vals, ", "))
end


---@param o table
---@return string
local function dump_object(o)
    local kv_strs = {}
    for key, val in pairs(o) do
        local key_str = dump_string(key)
        local val_str = dispatch_lua_type(val)
        table.insert(kv_strs, ("%s: %s"):format(key_str, val_str))
    end
    return ("{%s}"):format(table.concat(kv_strs, ", "))
end


---@param lua_obj any
---@return string
dispatch_lua_type = function (lua_obj)
    local type = type(lua_obj)
    if type == "string" then
        return dump_string(lua_obj)
    elseif type == "number" then
        return dump_num(lua_obj)
    elseif type == "boolean" or type == "nil" then
        return dump_bool(lua_obj)
    elseif type == "table" then
        if is_array(lua_obj) then
            return dump_array(lua_obj)
        else
            return dump_object(lua_obj)
        end
    else
        error(tostring(lua_obj) .. " is not a valid JSON type")
    end
end


---@param lua_obj any
---@return string
return function(lua_obj)
    return dispatch_lua_type(lua_obj)
end
