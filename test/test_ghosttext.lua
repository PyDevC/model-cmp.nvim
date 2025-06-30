local ghosttext = require("model_cmp.ghosttext")
local contextengine = require("model_cmp.context_engine.engine")

local M = {}

--how suggestions as ghosttext in the current window at
function M.test_suggestion()
  local cursorpos = vim.api.nvim_win_get_cursor(0)
  contextengine.ContextManager:get_context()
  local text = contextengine.ContextManager.ctx_text
  local opts = {
    virt_text = {{text, "IncSearch"}}
  }
  ghosttext.show_ghosttext(cursorpos[1], cursorpos[2], opts)
end

return M
