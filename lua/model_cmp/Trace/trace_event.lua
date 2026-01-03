local init = require("model_cmp.Trace.init")

local M = {}

---@class TraceEvent
---@field timestamp string
---@field 
---@field eventmsg string

---@type TraceEvent
TraceEvent = {
    timestamp = init.get_timestamp(),
    eventmsg = "",
}

setmetatable(TraceEvent, {
    __tostring = function()
        return "[Event]" .. TraceEvent.timestamp .. TraceEvent.eventmsg
    end
})

return M
