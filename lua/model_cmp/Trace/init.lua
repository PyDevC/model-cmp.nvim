local M = {}

---@class Logs
---@field type LogType
---@field LogHistory table<string>

---@enum LogType
M.LogType = {
    Event = 0,
    Error = 1,
    Warning = 2,
    FallBack = 3
}

function M.get_timestamp()
    return "[" .. os.date() .. "]: "
end

return M
