

---@param json_text string
---@return string, string
local function pop_string(json_text)
    local q_char = json_text:match("^[\"']")
    if not q_char then
        error(json_text:sub(1, 1) .. " is not a valid string quote")
    end
    local next_q = json_text:find(q_char, 2, true)
    local bslashs = json_text:sub(2, next_q-1):match("[\\]*$")
    while bslashs and #bslashs % 2 == 1 do
        local last_q = next_q
        next_q = json_text:find(q_char, next_q+1, true)
        bslashs = json_text:sub(last_q+1, next_q-1):match("[\\]*$")
    end
    local str = json_text:sub(2, next_q-1)
    local rest = json_text:sub(next_q+1)
    return str, rest
end


---@param json_text string
---@return number, string
local function pop_num(json_text)
    local num_str = json_text:match("^[%d.eE+-]*")
    local rest = json_text:sub(#num_str+1)
    local num = tonumber(num_str)
    if not num then
        error(num_str .. " is not a valid number")
    else
        return num, rest
    end
end


---@param json_text string
---@return boolean | nil, string
local function pop_bool(json_text)
    if json_text:find("^true") then
        return true, json_text:sub(5)
    elseif json_text:find("^false") then
        return false, json_text:sub(6)
    elseif json_text:find("^null") then
        return nil, json_text:sub(5)
    else
        error(json_text:sub(1, 5) .. " is not a valid bool or null")
    end
end


---@param text string
---@return string
local function drop_char(text, char)
    if not char then
        char = ","
    end
    text = text:gsub("%s*", "")
    if text:sub(1, 1) == char then
        text = text:sub(2)
    end
    text = text:gsub("%s*", "")
    return text
end


local dispatch_json_type -- forward declaration


---@param json_text string
---@return any[], string
local function pop_array(json_text)
    local open_brac = json_text:match("^%[")
    if not open_brac then
        error(open_brac .. " is not a valid array opening bracket")
    end
    local array = {}
    json_text = drop_char(json_text, "[")
    while json_text:sub(1, 1) ~= "]" do
        local val
        val, json_text = dispatch_json_type(json_text)
        table.insert(array, val)
        json_text = drop_char(json_text, ",")
    end
    json_text = drop_char(json_text, "]")
    json_text = drop_char(json_text, ",")
    return array, json_text
end


---@param json_text string
---@return { [string]: any }, string
local function pop_object(json_text)
    local open_brac = json_text:match("^{")
    if not open_brac then
        error(open_brac .. " is not a valid object opening bracket")
    end
    local object = {}
    json_text = drop_char(json_text, "{")
    while json_text:sub(1, 1) ~= "}" do
        local key, val
        key, json_text = pop_string(json_text)
        json_text = drop_char(json_text, ":")
        val, json_text = dispatch_json_type(json_text)
        json_text = drop_char(json_text, ",")
        object[key] = val
    end
    json_text = drop_char(json_text, "}")
    json_text = drop_char(json_text, ",")
    return object, json_text
end


---@param json_text string
---@return any, string
dispatch_json_type = function (json_text)
    local next_c = json_text:sub(1, 1)
    if next_c:find("[\"']") then
        return pop_string(json_text)
    elseif next_c:find("^[%d-+.]") then
        return pop_num(json_text)
    elseif next_c:find("[tfn]") then
        return pop_bool(json_text)
    elseif next_c == "[" then
        return pop_array(json_text)
    elseif next_c == "{" then
        return pop_object(json_text)
    else
        error(next_c .. " is an invalid character")
    end
end


---@param json_text string
---@return { [string]: any }
return function (json_text)
    local object, _ = dispatch_json_type(json_text)
    return object
end
