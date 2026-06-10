local loglevel = require("model_cmp.Trace.level")
local time = vim.uv

local function newtime()
    return time.now()
end

local cache = {}

local Logger = {}
Logger.__index = Logger

function Logger:new(level, external_printer)
    level = level or loglevel.FATAL
    external_printer = external_printer or function() end
    local timestamp = newtime()

    return setmetatable({
        level = level,
        external_printer = external_printer,
        timestamp = timestamp,
    }, self)
end

function Logger:setLevel(level)
    self.level = level
    return self
end

-- Log a message in the logcache at loglevel
function Logger:log(level, message, args)
    if self.level > level then
        return
    end

    local log_statement = {
        level = loglevel.level_to_string(level),
        message = message,
    }

    if args then
        args()
    end

    table.insert(cache, log_statement.level .. log_statement.message .. "\n")
end

function Logger:warn(msg, ...)
    self:log(loglevel.WARN, msg, ...)
end

function Logger:info(msg, ...)
    self:log(loglevel.INFO, msg, ...)
end

function Logger:debug(msg, ...)
    self:log(loglevel.DEBUG, msg, ...)
end

function Logger:error(msg, ...)
    self:log(loglevel.ERROR, msg, ...)
end

function Logger.save()
    local path = vim.fn.stdpath("log") .. "/model_cmp.log"
    local fd, err = vim.uv.fs_open(path, "w", 420)
    if not fd then
        error("Coudn't create log file" .. err)
    end

    vim.uv.fs_write(fd, cache)
    vim.uv.fs_fsync(fd)
    vim.uv.fs_close(fd)
end

function Logger.print_logs()
    print("Printing Logs")
    for k, v in pairs(cache) do
        print(k .. " = " .. v)
    end
    return cache
end

local logger = Logger:new(loglevel.DEBUG)

return logger
