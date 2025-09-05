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
    for k, v in pairs(vim.log.levels) do
        if v == log.type then
            log.type = k
        end
    end

    local strtype = string.format("[%s]: ", log.type)
    local modifiedlog = strtype .. log.message
    table.insert(M.Logs, modifiedlog)
end

---@return LogInstance
local function log_template()
    local log = {
        type = vim.log.levels.OFF,
        message = ""
    }
    return log
end

function M.save_logs(logdir)
    logdir = logdir or vim.fn.stdpath('log')
    local filepath = logdir .. "model_cmp.log"

    local strlogs = ""

    for k, v in ipairs(M.Logs) do
        strlogs = strlogs .. v .. "\n"
    end

    vim.fn.writefile(strlogs, filepath, 'a')
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
