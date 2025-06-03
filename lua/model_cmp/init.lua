local model_cards_list = require("model_cmp.model_cards_list")
local ghosttext = require("model_cmp.ghosttext")
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
    enable = ghosttext.action.enable_auto_trigger,
    disable = ghosttext.action.disable_auto_trigger,
    toggle = ghosttext.action.toggle_auto_trigger,
  }

  actions.change_model = {
    selected = print("hello")
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
