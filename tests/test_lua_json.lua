

---@description compare any two values for equality
---@param a any
---@param b any
---@return boolean
local function cmp(a, b)
    if type(a) ~= "table" and type(b) ~= "table" then
        return a == b
    end
    if #a ~= #b then
        return false
    end
    local keys = {}
    for key, aval in pairs(a) do
        keys[key] = true
        local bval = b[key]
        if not cmp(aval, bval) then
            return false
        end
    end
    for key, _ in pairs(b) do
        if not keys[key] then
            return false
        end
    end
    return true
end


---@description dump string representation of a table for visual inspection
---@param t table
---@param depth number?
---@return string
local function dump_tbl(t, depth)
    if not depth then
        depth = 1
    end
    local indent = ""
    for _ = 1, depth do
        indent = indent .. "    "
    end
    local lines = {}
    for key, val in pairs(t) do
        if type(val) == "table" then
            val = dump_tbl(val, depth+1)
        end
        table.insert(lines, ("%s: %s"):format(key, val))
    end
    local repr_pat = "{\n%s%s\n%s}"
    return repr_pat:format(
        indent,
        table.concat(lines, "\n"..indent),
        indent:gsub("    $", "")
    )
end


local load_json = require("lua_json.load_json")
local dump_json = require("lua_json.dump_json")

local JSON_VALUES_TABLE = {
    ["string"] = "string_val",
    ['\\"escaped\\"_string'] = '\\"escaped\\"_string_val',
    ["int"] = 1,
    ["float"] = 1.1,
    ["array"] = {1, 2, 3},
    ["nested_array"] = { {1, 2, 3}, {4, 5, 6} },
    ["object"] = { ["a"] = 1, ["b"] = 2, ["c"] = 3 },
    ["nested_object"] = {
        ["d"] = 1,
        ["e"] = {1, 2, 3},
        ["f"] = {
            ["h"] = 1,
            ["i"] = {1, 2, 3},
            ["k"] = { ["a"] = 1, ["b"] = 2, ["c"] = 3 },
        },
    },
}
local JSON_VALUES_STRING = [[{
    "string": "string_val",
    "\"escaped\"_string": "\"escaped\"_string_val",
    "int": 1,
    "float": 1.1,
    "array": [1, 2, 3],
    "nested_array": [ [1, 2, 3], [4, 5, 6] ],
    "object": {"a": 1, "b": 2, "c": 3},
    "nested_object": {
        "d": 1,
        "e": [1, 2, 3],
        "f": {
            "h": 1,
            "i": [1, 2, 3],
            "k": {"a": 1, "b": 2, "c": 3}
        }
    }
}]]

local json_values_table = load_json(JSON_VALUES_STRING)
assert(cmp(JSON_VALUES_TABLE, json_values_table), "load_json failed!")
-- NOTE: there's no way to guarantee dump order of a table.
-- Since load_json already passed, use that to ensure that dump_json outputs the
-- expected json string
local json_values_table = load_json(dump_json(JSON_VALUES_TABLE))
assert(cmp(JSON_VALUES_TABLE, json_values_table), "dump_json failed!")


local JSON_INDENT_TABLE = { ["a"] = { ["b"] = "c", ["d"] = "e" } }
local JSON_COMPACT_A = [[{"a":{"b":"c","d":"e"}}]]
local JSON_INDENTED_A = [[{
    "a": {
        "b": "c",
        "d": "e"
    }
}]]
local JSON_COMPACT_B = [[{"a":{"d":"e","b":"c"}}]]
local JSON_INDENTED_B = [[{
    "a": {
        "d": "e",
        "b": "c"
    }
}]]

local compact_json = dump_json(JSON_INDENT_TABLE)
assert(
    JSON_COMPACT_A == compact_json or JSON_COMPACT_B == compact_json,
    "compact json failed!"
)
local indented_json = dump_json(JSON_INDENT_TABLE, "    ")
assert(
    JSON_INDENTED_A == indented_json or JSON_INDENTED_B == indented_json,
    "indented json failed!"
)
print("all tests passed!")
