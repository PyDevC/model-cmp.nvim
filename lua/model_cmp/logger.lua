local M = {}

---@class Logs
---@field timestamp string
---@field loglist table<LogInstance>

---@class LogInstance
---@field type string | vim.log.levels
---@field message string

M.Logs = {}

---@param log LogInstance
local function add_log(log)
    if log.message == "" then
        return
    end
    for k, v in pairs(vim.log.levels) do
        if v == log.type then
            log.type = k
        end
    end

    local strtype = string.format("[%s]: ", log.type)
    local modifiedlog = strtype .. log.message
    table.insert(M.Logs, modifiedlog)
end

local function timestamp()
    return "[TIMESTAMP]: " .. os.date()
end

---@return LogInstance
local function log_template()
    local log = {
        type = vim.log.levels.OFF,
        message = ""
    }
    return log
end

function M.save_logs()
    local logdir = vim.fn.stdpath('log')
    local filepath = logdir .. "/model_cmp.log"
    vim.fn.writefile({timestamp()}, filepath, 'a')
    vim.fn.writefile(M.Logs, filepath, 'a')
end

function M.info(message)
    local log = log_template()
    log.type = vim.log.levels.INFO
    log.message = message
    add_log(log)
    vim.notify(message, log.type)
end

function M.warning(message)
    local log = log_template()
    log.type = vim.log.levels.WARN
    log.message = message
    add_log(log)
    vim.notify_once(message, log.type)
end

function M.trace(message)
    local log = log_template()
    log.type = vim.log.levels.TRACE
    log.message = message
    add_log(log)
end

function M.debugging(message)
    local log = log_template()
    log.type = vim.log.levels.DEBUG
    log.message = message
    add_log(log)
end

function M.error(message)
    local log = log_template()
    log.type = vim.log.levels.ERROR
    log.message = message
    add_log(log)
    vim.notify(message, log.type)
end

return M
