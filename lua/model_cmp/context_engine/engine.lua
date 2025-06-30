local insert = table.insert
local M = {}

local env_list = {
  ENV_VARS = { "VIRTUAL_ENV" },
  SYSTEM_INFO = { "OS", "COMPILER" },
  NVIM_INFO = { "FILETYPE", "TREESITTER" }
}

local _get_env_var = function(ENV_VAR)
  local success, env = pcall(os.getenv, ENV_VAR)
  if success then
    return env
  else
    return nil
  end
end

local collect_env = function()
  local available_env = {}
  for _, env in ipairs(env_list.ENV_VARS) do
    insert(available_env, _get_env_var(env))
  end
  return available_env
end

--Treesitter parsing

local cursorpos = vim.api.nvim_win_get_cursor(0)

---@param entity any: Can be anything such as variable, function, loop, list
local get_scope = function(entity)
  local type = vim.treesitter.get_captures_at_cursor()
end


-- What are the components required to generate a language tree
-- We need to parse the file while typing, it can be fast since only one file is begin parsed

-- One line context gathering:  only for the given context
local get_current_line_ctx = function()
  local cursorloc = vim.api.nvim_win_get_cursor(0)
  local text = vim.api.nvim_buf_get_lines(0, cursorloc[1] - 1, cursorloc[1], false)
  return text[1]
end

---@class contextmanager
---@field env_var table: all the environment variables available in the system
---@field live_var table: all the variables which are live, i.e. can be used
---@field ctx table: context table
---@field ctx_text table: text version of ctx, contain the text that is required
---to generate the output for the LLM, ctx_text acts as input for a particular
---instance of code
M.ContextManager = {
  env_var = {},
  live_var = {},
  ctx = {},
  ctx_text = "",
}

function M.ContextManager:generate()
end

function M.ContextManager:get_context()
  M.ContextManager.ctx_text = get_current_line_ctx()
end

return M
