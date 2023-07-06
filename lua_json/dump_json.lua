
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


---@param s string
---@param n number
---@return string
local function mult_str(s, n)
    local output = ""
    for _ = 1, n do
        output = output .. s
    end
    return output
end


-- forward declaration
local dispatch_lua_type


---@param a any[]
---@param depth number
---@param indent string?
---@return string
local function dump_array(a, depth, indent)
    local init_sep, cat_sep, final_sep
    if indent then
        init_sep = "\n" .. mult_str(indent, depth + 1)
        cat_sep =  ",\n" .. mult_str(indent, depth + 1)
        final_sep = "\n" .. mult_str(indent, depth)
    else
        init_sep = ""
        cat_sep =  ","
        final_sep = ""
    end
    local vals = {}
    for _, val in ipairs(a) do
        table.insert(vals, dispatch_lua_type(val, depth+1, indent))
    end
    return "[" .. init_sep .. table.concat(vals, cat_sep) .. final_sep .. "]"
end


---@param o table
---@param depth number
---@param indent string?
---@return string
local function dump_object(o, depth, indent)
    local init_sep, kv_sep, cat_sep, final_sep
    if indent then
        init_sep = "\n" .. mult_str(indent, depth + 1)
        kv_sep = ": "
        cat_sep =  ",\n" .. mult_str(indent, depth + 1)
        final_sep = "\n" .. mult_str(indent, depth)
    else
        init_sep = ""
        kv_sep = ":"
        cat_sep =  ","
        final_sep = ""
    end
    local kv_strs = {}
    for key, val in pairs(o) do
        local key_str = dump_string(key)
        local val_str = dispatch_lua_type(val, depth+1, indent)
        table.insert(kv_strs, key_str .. kv_sep .. val_str)
    end
    return "{" .. init_sep .. table.concat(kv_strs, cat_sep) .. final_sep .. "}"
end


---@param lua_obj any
---@param depth number
---@param indent string?
---@return string
dispatch_lua_type = function (lua_obj, depth, indent)
    local type = type(lua_obj)
    if type == "string" then
        return dump_string(lua_obj)
    elseif type == "number" then
        return dump_num(lua_obj)
    elseif type == "boolean" or type == "nil" then
        return dump_bool(lua_obj)
    elseif type == "table" then
        if is_array(lua_obj) then
            return dump_array(lua_obj, depth, indent)
        else
            return dump_object(lua_obj, depth, indent)
        end
    else
        error(tostring(lua_obj) .. " is not a valid JSON type")
    end
end


---@param lua_obj any
---@param indent string?
---@return string
return function(lua_obj, indent)
    return dispatch_lua_type(lua_obj, 0, indent)
end
