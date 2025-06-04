local model_cards_list = require("model_cmp.model_cards_list")
local default_config = {}

local M = {}

function M.setup(config)
  M.presets = config.presets or {}
  M.presets.original = config

  config.presets = nil
  M.config = vim.tbl_deep_extend('force', default_config, config or {})
end

vim.api.nvim_create_user_command('Modelcmp', function(args)
  local fargs = args.fargs
  local actions = {}

  actions.ghosttext = {
    enable = function() require("model_cmp.ghosttext").action.enable_auto_trigger() end,
    disable = function() require("model_cmp.ghosttext").action.disable_auto_trigger() end,
    toggle = function() require("model_cmp.ghosttext").action.toggle_auto_trigger() end,
  }
end, {
  nargs = '+',
  complete = function(_, cmdline, _)
    cmdline = cmdline or ''

    if cmdline:find 'change_model' then
      return model_cards_list.model_card_list
    end

    if cmdline:find 'ghosttext' then
      return {
        'enable',
        'disable',
        'toggle',
      }
    end

    return { 'ghosttext', 'change_model' }
  end,
})

return M
