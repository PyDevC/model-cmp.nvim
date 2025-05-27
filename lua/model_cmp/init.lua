local default_config = {}
local managekey = require("model_cmp.modelapi.managekey")

local M = {}

function M.setup(config)
    M.presets = config.presets or {}
    M.presets.original = config

    config.presets = nil
    M.config = vim.tbl_deep_extend('force', default_config, config or {})
    require('model_cmp.ghosttext').setup(M.config)
    require('model_cmp.modelapi.managekey').is_available(M.config)
    require('model_cmp.modelapi.llama').create_autocmd()
end

-- Modelcmp Command
vim.api.nvim_create_user_command('Modelcmp', function(args)
    local fargs = args.fargs
    local actions = {}

    actions.ghosttext = {
        enable = function() require("model_cmp.ghosttext").action.enable_auto_trigger() end,
        disable = function() require("model_cmp.ghosttext").action.disable_auto_trigger() end,
        toggle = function() require("model_cmp.ghosttext").action.toggle_auto_trigger() end,
    }

    actions.modelapi = {
        get_api_key = function() managekey.get_api_key(fargs[3]) end,
    }
    actions.complete = {
        enable = function() require("model_cmp.modelapi.llama").send_request() end,
    }

    actions[fargs[1]][fargs[2]]()
end, {
    nargs = '+',
    complete = function(_, cmdline, _)
        cmdline = cmdline or ''

        if cmdline:find 'ghosttext' then
            return {
                'enable',
                'disable',
                'toggle',
            }
        end

        if cmdline:find 'modelapi' then
            return {
                'get_api_key',
            }
        end

        if cmdline:find 'complete' then
            return {
                "enable"
            }
        end

        return { 'ghosttext', 'modelapi', 'complete' }
    end,
})

return M
