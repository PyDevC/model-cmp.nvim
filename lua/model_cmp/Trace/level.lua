local WARN = -1
local ERROR = -2
local FATAL = -3

local INFO = 1
local DEBUG = 2

---@param level number
---@return string
local function level_to_string(level)
    if level == DEBUG then
        return "[DEBUG]"
    elseif level == INFO then
        return "[INFO]"
    elseif level == ERROR then
        return "[ERROR]"
    elseif level == WARN then
        return "[WARN]"
    elseif level == FATAL then
        return "[FATAL]"
    end

    assert(false, "unknown level: ", level)
    return ""
end

return {
    DEBUG = DEBUG,
    ERROR = ERROR,
    FATAL = FATAL,
    INFO = INFO,
    WARN = WARN,
    level_to_string = level_to_string,
}
