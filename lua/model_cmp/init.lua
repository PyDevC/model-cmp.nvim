local model_cards_list = require("model_cmp.model_cards_list")
local default_config = {} -- will add config later

local M = {}

function M.setup(config)
  M.presets = config.presets or {}
  M.presets.original = config

  config.presets = nil
  M.config = vim.tbl_deep_extend('force', default_config, config or {})
end

local function choose_model_card()
  vim.ui.select(model_cards_list.model_cards_list, {
    prompt = "Select the model card: ",
    format_item = function(item)
      return item
    end,
  }, function(choosen)
    if choosen then
      return M.change_model(choosen)
    end
  end)
end

function M.change_model(model_card)
  model_card = model_card or choose_model_card()
  vim.notify("Model Changed to: " .. model_card.name)
end

vim.api.nvim_create_user_command('Modelcmp', function(args)
  local fargs = args.fargs
  local actions = {}

  actions.ghosttext = {
    enable = require('model_cmp.ghosttext').action.enable_auto_trigger,
    disable = require('model_cmp.ghosttext').action.disable_auto_trigger,
    toggle = require('model_cmp.ghosttext').action.toggle_auto_trigger,
  }
end, {
  nargs = '+',
  complete = function(_, cmdline, _)
    cmdline = cmdline or ''

    if cmdline:find 'change_model' then
      return M.change_model()
    end

    if cmdline:find 'ghosttext' then
      return {
        'enable',
        'disable',
        'toggle',
      }
    end

    return { 'ghosttext' }
  end,
})


return M
