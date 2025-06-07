local connect = require("model_cmp.connect")

local M = {}

M.ns_id = vim.api.nvim_create_namespace("ghosttext")
M.augroup = vim.api.nvim_create_augroup("model_cmp")

---@class context_manager
---@field aug_id integer: augroup id
---@field ns_id integer: namespace id
---@field ext_id integer: extmark id
---@field ctx table: context window for the text to be sent to the model
---@field suggestion table: suggestion by the model to be displayed as ghosttext
---@field bufnr integer: where to display the ghosttext
--Context manager collects and stores the context and suggestions for an instance,
--A new context is set depending on the cursor position and the context around
local ctx_manager = {
  aug_id = M.augroup,
  ns_id = M.ns_id,
  ext_id = 1,
  ctx = {},
  suggestion = {},
  bufnr = vim.api.nvim_get_current_buf(),
}

local clear_preview = function()
  vim.api.nvim_buf_del_extmark(0, M.ns_id, M.ext_id)
end

local should_auto_trigger = function()
  if vim.b.model_cmp_ghosttext_auto_trigger then
    return false
  else
    return true
  end
end

--Get the context location based on the cursor location
--gets the location in two formats: 1. line 2. function
--uses function range to get the rows and columns for function
---@return table: eiter {row, column} or {start_row, start_col, end_row, end_col}
local get_ctx_location = function()
  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  local function get_node_at_pos(node, row, col)
    for child in node:iter_children() do
      local start_row, start_col, end_row, end_col = child:range()
      if row >= start_row and row <= end_row and
          (row ~= start_row or col >= start_col) and
          (row ~= end_row or col <= end_col) then
        return get_node_at_pos(child, row, col) or child
      end
    end
    return nil
  end

  local cursorpos = vim.api.nvim_win_get_cursor(0)
  local row, col = cursorpos[1] - 1, cursorpos[2]
  local node = get_node_at_pos(root, row, col)

  while node do
    local type = node:type()
    if type == "function" or type == "function_definition" or type == "function_declaration" then
      local ctx_location = node:range()
      return ctx_location
    else
      local ctx_location = { row, col }
      return ctx_location
    end
    node = node:parent()
  end
end

M.get_ctx = function()
  local ctx_location = get_ctx_location()
  local text = {}
  if #ctx_location == 2 then
    text = vim.api.nvim_buf_get_lines(ctx_manager.bufnr, ctx_location[1] - 1, ctx_location[1], false)
  elseif #ctx_location == 4 then
    text = vim.api.nvim_buf_get_lines(ctx_manager.bufnr, ctx_location[1] - 1, ctx_location[3], false)
  end
  ctx_manager.ctx = { text }
  return text
end

-- RESET functions

local reset_ctx = function()
  ctx_manager.ctx = {}
end

local reset_suggestion = function()
  ctx_manager.suggestion = {}
end

local reset = function()
  reset_ctx()
  reset_suggestion()
end

------------------------------------------------------------------------------
---------------------------------ACTION---------------------------------------
------------------------------------------------------------------------------
local action = {}

function action.accept(n_lines)
  local ctx = M.get_ctx()
  local suggestion = connect.action.contextsend(ctx)

  if not suggestion or vim.fn.empty(suggestion) == 1 then
    return
  end

  reset()
  clear_preview()

  local cursorpos = vim.api.nvim_win_get_cursor(0)
  local line, col = cursorpos[1] - 1, cursorpos[2]

  vim.schedule_wrap(function()
    vim.api.nvim_buf_set_text(0, line, col, line, col, suggestion)
    local new_col = vim.fn.strcharlen(suggestion[#suggestion])
    -- For single-line suggestions, adjust the column position by adding the
    -- current column offset
    if #suggestion == 1 then
      new_col = new_col + col
    end
    vim.api.nvim_win_set_cursor(0, { line + #suggestion, new_col })
  end)()
end

function action.acceptline()
  action.accept(1)
end

function action.is_visible()
  return not not vim.api.nvim_buf_get_extmark_by_id(0, M.ns_id, M.ext_id, { details = false })[1]
end

function action.disable_auto_trigger()
  vim.b.model_cmp_ghosttext_auto_trigger = false
end

function action.enable_auto_trigger()
  vim.b.model_cmp_ghosttext_auto_trigger = true
end

function action.toggle_auto_trigger()
  vim.b.model_cmp_ghosttext_auto_trigger = not should_auto_trigger()
end

M.action = action

return M
