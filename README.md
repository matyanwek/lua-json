# lua-json

A JSON parser and composer for Lua.

## Installation

Clone the git repository, then add the cloned path to the LUA_PATH environment variable:
```console
$ git clone https://github.com/matyanwek/lua-json
$ export LUA_PATH="$(realpath .)/?.lua;$LUA_PATH"
```

## Usage

Import the `load_json` function and use it to create a table from a JSON string:
```lua
local load_json = require("lua_json.load_json")
local json_table = load_json(json_string)
```

Dump a table as a JSON string with the `dump_json` function:
```lua
local dump_json = require("lua_json.dump_json")
local json_string = dump_json(json_table)
```

By default, `dump_json` will output JSON in compact form.
To dump an indented, more human-readable form, include a string argument to use as the indent:
```lua
local indent = "    "
local tbl = { ["a"] = { ["b"] = "c", ["d"] = "e" } }
local json_string = dump_json(tbl, indent)
print(json_string)
```
Output looks like this:
```
{
    "a": {
        "b": "c",
        "d": "e"
    }
}
```
