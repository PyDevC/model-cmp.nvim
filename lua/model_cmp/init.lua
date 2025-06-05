local model_cards = require("model_cmp.model_cards")
local default_config = {}

local M = {}

function M.setup(config)
  M.presets = config.presets or {}
  M.presets.original = config

  config.presets = nil
  M.config = vim.tbl_deep_extend('force', default_config, config or {})
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

  if fargs[1] == 'start' then
    local start = require("model_cmp.connect").action.start
    start()
  elseif fargs[1] == 'stop' then
    local stop = require("model_cmp.connect").action.stop
    stop()
  elseif fargs[1] == 'change_model' then
    model_cards.change_model(fargs[2])
    print("Model updated to " .. model_cards.current_model)
  else
    actions[fargs[1]][fargs[2]]()
  end
end, {
  nargs = '+',
  complete = function(_, cmdline, _)
    cmdline = cmdline or ''

    if cmdline:find 'change_model' then
      return model_cards.model_card_list
    end

    if cmdline:find 'ghosttext' then
      return {
        'enable',
        'disable',
        'toggle',
      }
    end

    return { 'ghosttext', 'change_model', 'start' }
  end,
})

return M
