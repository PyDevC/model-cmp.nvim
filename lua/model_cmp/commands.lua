local llama = require("model_cmp.modelapi.llama")
local virtualtext = require("model_cmp.virtualtext")

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
            end
        })

    vim.api.nvim_create_autocmd({ 'InsertLeave' },
        {
            group = group,
            callback = function(event)
                virtualtext.action.clear_preview()
            end
        })
end

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
end

return M
