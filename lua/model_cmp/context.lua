local string = string
local M = {}

local function get_cursor()
    return vim.api.nvim_win_get_cursor(0)
end

---@class ModelCmp.ContextEngine
---@field bufnr integer -- current buffer number
---@field id integer -- context id
---@field cursor integer[] -- current cursor pos
---@field ctx string[] -- context
---@field currlang string -- current language eg: python, c, cpp, markdown
M.ContextEngine = {
    bufnr = 0,
    id = 0, -- Need to think how to manipulate this this is imp to put the right virtual text for right context
    cursor = { 0, 0 },
    ctx = {},
    currlang = "text" -- default if none is set or found
}

function M.ContextEngine:get_ctx()
    self.cursor = get_cursor()
    self.ctx = vim.api.nvim_buf_get_lines(M.ContextEngine.bufnr, 0, -1, false)
end

function M.ContextEngine:clear_ctx()
    self.ctx = {}
end

function M.ContextEngine:get_currlang()
    return vim.bo.filetype
end

function M.generate_context_text()
    if next(M.ContextEngine.ctx) == nil then
        return M.ContextEngine:get_ctx()
    end

    local lines = [[]]
    for idx, line in ipairs(M.ContextEngine.ctx) do
        lines = lines .. tostring(idx) .. line
    end
    return lines
end

return M
