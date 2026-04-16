--[[
    Search and Destroy - Navigation Compatibility Shim

    Navigation, portal management, and mapper DB import logic now live under
    mmapper/mm_navigation.lua and are owned by the mapper package.

    This shim keeps legacy S&D entry points working by attaching snd.mapper
    to mm.nav when available and loading the mapper nav module as fallback.
]]

snd = snd or {}
snd.mapper = snd.mapper or {}
mm = mm or {}

if mm.nav then
    snd.mapper = mm.nav
    return
end

local function file_exists(path)
    local f = io.open(path, "rb")
    if not f then return false end
    f:close()
    return true
end

local function dirname(path)
    return (tostring(path or ""):gsub("\\", "/"):match("^(.*)/") or "")
end

local script_source = debug.getinfo(1, "S").source or ""
local script_dir = ""
if script_source:sub(1, 1) == "@" then
    script_dir = dirname(script_source:sub(2))
end

local home = getMudletHomeDir()
local fallback_reason = "module not found in expected paths"
local candidates = {
    home .. "/mmapper/mm_navigation.lua",
    home .. "/packages/mmapper/mm_navigation.lua",
    home .. "/packages/mmapper/mmapper/mm_navigation.lua",
    home .. "/../mmapper/mm_navigation.lua",
    home .. "/../packages/mmapper/mm_navigation.lua",
    home .. "/../packages/mmapper/mmapper/mm_navigation.lua",
    home .. "/../../mmapper/mm_navigation.lua",
    home .. "/../../packages/mmapper/mm_navigation.lua",
    home .. "/../../packages/mmapper/mmapper/mm_navigation.lua",
}

if script_dir ~= "" then
    table.insert(candidates, script_dir .. "/../mmapper/mm_navigation.lua")
    table.insert(candidates, script_dir .. "/../packages/mmapper/mm_navigation.lua")
    table.insert(candidates, script_dir .. "/../packages/mmapper/mmapper/mm_navigation.lua")
end

for _, path in ipairs(candidates) do
    if file_exists(path) then
        local ok, err = pcall(dofile, path)
        if ok then
            if mm.nav then
                snd.mapper = mm.nav
                return
            end
            fallback_reason = "module loaded but mm.nav is unavailable at " .. tostring(path)
            -- keep searching in case a later candidate has a valid module
        else
            cecho("<orange_red>[S&D]<reset> Failed loading mapper navigation module: " .. tostring(err) .. "\n")
            fallback_reason = "load error at " .. tostring(path)
        end
    end
end

local fallback_warned = false
local function fallback_warn(reason)
    if fallback_warned then return end
    fallback_warned = true
    cecho("<orange_red>[S&D]<reset> mapper navigation module unavailable (" .. tostring(reason or "not found") .. "). Navigation features are disabled.\n")
end

local function install_mapper_fallback(reason)
    snd.mapper = snd.mapper or {}
    snd.mapper.config = snd.mapper.config or {}
    snd.mapper.db = snd.mapper.db or {
        open = function() return false end,
        close = function() end,
        query = function() return {} end,
        escape = function(v) return tostring(v or "") end,
    }

    local function sql_escape(v)
        if mm and type(mm.sql_escape) == "function" then
            return mm.sql_escape(v)
        end
        return "'" .. tostring(v or ""):gsub("'", "''") .. "'"
    end

    local function run_query(sql)
        if mm and type(mm.query_mapper_db) == "function" then
            local rows = mm.query_mapper_db(sql)
            if type(rows) == "table" then
                return rows
            end
        end
        return {}
    end

    snd.mapper.searchRoomsExact = function(room, arid, _mobName, _options)
        fallback_warn(reason)
        local roomTxt = tostring(room or ""):lower()
        if roomTxt == "" then return {} end
        local sql = "SELECT uid as rmid, name, area FROM rooms WHERE lower(name) LIKE " .. sql_escape("%" .. roomTxt .. "%")
        if arid and tostring(arid) ~= "" then
            sql = sql .. " AND lower(area) LIKE " .. sql_escape("%" .. tostring(arid):lower() .. "%")
        end
        sql = sql .. " ORDER BY area, name LIMIT 200"
        return run_query(sql)
    end

    snd.mapper.searchMobLocations = function(mobName, areaKey)
        fallback_warn(reason)
        return snd.mapper.searchRoomsExact(mobName, areaKey, mobName, {})
    end

    snd.mapper.searchRooms = function(query)
        fallback_warn(reason)
        if not query or tostring(query) == "" then return {} end
        return run_query(tostring(query))
    end

    snd.mapper.searchRoomsRows = function(rows)
        fallback_warn(reason)
        return type(rows) == "table" and rows or {}
    end

    snd.mapper.searchRoomsResults = function(results)
        fallback_warn(reason)
        local list = type(results) == "table" and results or {}
        if #list > 0 and snd and snd.nav then
            local first = list[1]
            local rid = tonumber(first.rmid or first.uid)
            if rid then snd.nav.nextRoom = rid end
        end
        return #list > 0
    end
    snd.mapper.getRoomInfo = function() fallback_warn(reason); return nil end
    snd.mapper.getPortals = function() fallback_warn(reason); return {} end
    snd.mapper.getPortalsToRoom = function() fallback_warn(reason); return {} end
    snd.mapper.findPath = function() fallback_warn(reason); return nil end
    snd.mapper.gotoRoom = function(roomId)
        fallback_warn(reason)
        local rid = tonumber(roomId)
        if not rid then return false end
        if type(expandAlias) == "function" then
            expandAlias("mapper goto " .. tostring(rid))
            return true
        end
        return false
    end
    snd.mapper.gotoTarget = function() fallback_warn(reason); return false end
    snd.mapper.xrt = function(dest)
        fallback_warn(reason)
        if type(expandAlias) == "function" then
            expandAlias("mapper goto " .. tostring(dest or ""))
            return true
        end
        return false
    end
    snd.mapper.xrtforce = function(dest)
        fallback_warn(reason)
        if type(expandAlias) == "function" then
            expandAlias("mapper goto " .. tostring(dest or ""))
            return true
        end
        return false
    end
    snd.mapper.walkTo = function(dest)
        fallback_warn(reason)
        if type(expandAlias) == "function" then
            expandAlias("mapper walkto " .. tostring(dest or ""))
            return true
        end
        return false
    end
    snd.mapper.help = function() fallback_warn(reason); return false end
    snd.mapper.showDbInfo = function() fallback_warn(reason); return false end
end

install_mapper_fallback(fallback_reason)
