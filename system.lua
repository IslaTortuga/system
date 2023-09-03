local EXT_CONFIG = ".conf"
local EXT_INFO = ".info"
local EXT_MESSAGE = ".msg"

---@class PATHS
local PATHS = {
    info = "/usr/info/",
    config = "/usr/config/",
    temp = "/usr/temp/",
    locales = "/usr/locales/",
    messages = "/usr/locales/messages/",
    apis = "/usr/apis/",
    modules = "/usr/modules/",
    programs = "/usr/programs/",
    home = "/home/",
    startup = "/startup/"
}

---@class LOCALES
local LOCALES = {
    language = {
        default = "en",
        value = "en"
    },
    timezone = {
        default = "UTC",
        value = "UTC"
    }
}

--- Unserialize table from a file.
--- @param path string
--- @return table
fs.readTable = function (path)
    local file = fs.open(path, "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    return data
end

--- Serializes table into a file.
--- @param path string
--- @param data table
fs.writeTable = function (path, data)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(data))
    file.close()
end

--- Loads an api given its name
--- @param api string
--- @return boolean
function loadAPI(api)
    return os.loadAPI(PATHS.apis..api..".lua")
end

--- Imports a module given its name
--- @param module string
--- @return table|nil
function import(module)
    return dofile(PATHS.modules..module..".lua", _ENV)
end

--- Runs a program/command given its name
--- @param program string
--- @param ... string
--- @return boolean
function run(program, ...)
    local path = fs.combine(PATHS.programs, program)
    local args = { ... }    
    if args and #args > 0 then
        return shell.run(path, table.unpack(args))
    else
        return shell.run(path)
    end
end

--- Loads a config file given its name
--- @param name string
--- @return table|nil
function loadConfig(name)
    local path = fs.combine(PATHS.config, name..EXT_CONFIG)
    if not fs.exists(path) then return end
    return fs.readTable(path)
end

--- Writes a config file given its name
--- @param name string
--- @param data table
function writeConfig(name, data)
    fs.writeTable(fs.combine(PATHS.config, name..EXT_CONFIG), data)
end

--- Loads a info file given its name
--- @param name string
--- @return table|nil
function loadInfo(name)
    local path = fs.combine(PATHS.info, name..EXT_INFO)
    if not fs.exists(path) then return end
    return fs.readTable(path)
end

--- Check if a package is installed
--- @param package_name string
--- @return boolean
function isInstalled(package_name)
    return fs.exists(fs.combine(PATHS.info, package_name..EXT_INFO))
end

--- Returns package version
--- @param package_name string
--- @return string
function getVersion(package_name)
    if not isInstalled(package_name) then
        return package_name.. " not found"
    end
    return loadInfo(package_name).version
end

--- Retrieves all messages of a given program
--- @param package_name string
--- @return table|nil
function getMessages(package_name)
    local path = fs.combine(PATHS.messages, package_name)
    if not fs.exists(path) then return end
    local lang = locales.language
    local messages = fs.readTable(fs.combine(path, lang.default..EXT_MESSAGE))
    if lang.default == lang.value then return messages end
    local translated = fs.readTable(fs.combine(path, lang.value..EXT_MESSAGE))
    if translated then
        for k, v in pairs(translated) do
            messages[k] = v
        end
    end
    return messages
end

--- Set language locale
--- @param language string
function setLanguage(language)
    LOCALES.language.value = language or LOCALES.language.default
    writeConfig("locales", LOCALES)
end

--- Set timezone locale
--- @param timezone string
function setTimezone(timezone)
    LOCALES.timezone.value = timezone or LOCALES.timezone.default
    writeConfig("locales", LOCALES)
end

--- A table with all existent paths (read only)
---@type PATHS
paths = setmetatable({}, {
    __index = function(_, k) return PATHS[k] end,
    __pairs = function(_)
        local function iter(_, k)
            local v
            k, v = next(PATHS, k)
            if v ~= nil then return k, v end
        end
        return iter, PATHS, nil
    end,
    __newindex = function() error("system.paths is read only") end,
    __metatable = false,
    __tostring = function()
        local msg = ""
        for k, v in pairs(PATHS) do
            msg = msg..k..": "..v.."\n"
        end
        return msg:sub(1, #msg-1)
      end
});

--- A table with current locales
---@type LOCALES
locales = setmetatable({}, {
    __index = function(_, k)
        return LOCALES[k].value
    end,
    __newindex = function() error("system.locales is read only") end,
    __metatable = false,
    __tostring = function()
        return "Language: "..LOCALES.language.value.."\nTimezone: "..LOCALES.timezone.value
    end
});

-- LOAD LOCALES
local locales = loadConfig("locales")
if locales then
    LOCALES = locales
end