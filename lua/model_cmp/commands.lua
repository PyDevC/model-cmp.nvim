local api = require("model_cmp.modelapi.common")
local virtualtext = require("model_cmp.virtualtext")
local logger = require("model_cmp.logger")

local M = {}

function M.create_autocmds(group)
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' },
        {
            group = group,
            callback = function(event)
                local file = event["file"]
                -- also Check for buffer editing in oil.nvim
                if file == "" or file:find 'oil:///' then
                    return
                end
                api.send_request()
            end
        })

    vim.api.nvim_create_autocmd({ 'InsertLeave' },
        {
            group = group,
            callback = function(event)
                local file = event["file"]
                -- also Check for buffer editing in oil.nvim
                if file == "" or file:find 'oil:///' then
                    return
                end
                virtualtext.action.clear_preview()
            end
        })
end

local function modelcmp_start()
    vim.api.nvim_create_user_command('ModelCmpStart', function()
        -- api.start()
        logger.debugging("Started api")
    end, {})
end

local function modelcmp_stop()
    vim.api.nvim_create_user_command('ModelCmpStop', function()
        -- api.stop()
        logger.debugging("Stopped api")
    end, {})
end

local function modelcmp_logs()
    vim.api.nvim_create_user_command('ModelCmpLogs', function()
        vim.cmd('tabnew')
        local newbuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(newbuf, "Model Cmp logs")
        vim.api.nvim_set_current_buf(newbuf)
        vim.api.nvim_buf_set_option(newbuf, 'bufhidden', 'wipe') -- Close buffer when window is closed
        vim.api.nvim_buf_set_option(newbuf, 'buftype', 'nofile')  -- Not a file buffer
        vim.api.nvim_buf_set_option(newbuf, 'swapfile', false)   -- No swap file
        vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, logger.Logs)
        vim.api.nvim_buf_set_option(newbuf, 'modifiable', false) -- Make it read-only
    end, {})
end

-- This is our main command
function M.create_usercmds()
    vim.api.nvim_create_user_command('ModelCmp', function(args)
        local fargs = args.fargs
        local actions = {}

        -- VirtualText options
        actions.virtualtext = {
            enable = function() virtualtext.action.enable_auto_trigger() end,
            disable = function() virtualtext.action.disable_auto_trigger() end,
            toggle = function() virtualtext.action.toggle_auto_trigger() end
        }
        actions.capture = {
            first = function() virtualtext.action.capturefirstline() end,
            all = function() virtualtext.action.capturealllines() end,
        }

        actions[fargs[1]][fargs[2]]()
    end, {
        nargs = '+',
        complete = function(_, cmdline, _)
            cmdline = cmdline or ''

            if cmdline:find 'virtualtext' then
                return {
                    'enable',
                    'disable',
                    'toggle'
                }
            end
            if cmdline:find 'capture' then
                return { 'first', 'all' }
            end

            return { 'virtualtext', 'capture' }
        end,
    })

    modelcmp_start()
    modelcmp_stop()
    modelcmp_logs()
end

return M
