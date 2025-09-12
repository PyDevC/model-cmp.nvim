local M = {}

local function get_cursor()

    return vim.api.nvim_win_get_cursor(0)
end

local function get_context_before(currentline)
    local start = 0
    local stop = currentline - 1
    return vim.api.nvim_buf_get_lines(0, start, stop, false)
end

local function get_context_after(currentline)
    local start = currentline
    local stop = -1
    return vim.api.nvim_buf_get_lines(0, start, stop, false)
end

---@class ModelCmp.ContextEngine
---@field bufnr integer -- current buffer number
---@field cursor integer[] -- current cursor pos
---@field currlang string -- current language eg: python, c, cpp, markdown
---@field id integer -- context id
---@field ctx table<string, string[]> -- context
M.ContextEngine = {
    bufnr = vim.api.nvim_get_current_buf(),
    cursor = { 0, 0 },
    currlang = "text", -- default if none is set or found
    id = 0, -- Need to think how to manipulate this this is imp to put the right virtual text for right context
    ctx = {
        before = {},
        current = {},
        after = {}
    },
}

function M.ContextEngine:get_ctx()
    self.cursor = get_cursor()
    self.ctx.before = get_context_before(self.cursor[1])
    self.ctx.after = get_context_after(self.cursor[1])
    self.ctx.current = vim.api.nvim_buf_get_lines(0, self.cursor[1] - 1, self.cursor[1] + 1, false)
    if not self.ctx.current then
        self.ctx.current = { "" }
    end
end

function M.ContextEngine:clear_ctx()
    self.ctx = {
        before = {},
        current = {},
        after = {}
    }
end

function M.ContextEngine:get_currlang()
    return vim.bo.filetype
end

function M.generate_context_text()
    if next(M.ContextEngine.ctx.current) == nil or M.ContextEngine.ctx.current == nil then
        M.ContextEngine:get_ctx()
    end

    -- before
    local lines = [[]]
    for idx, line in ipairs(M.ContextEngine.ctx.before) do
        lines = lines .. line .. '\n'
    end

    -- current
    local line = M.ContextEngine.ctx.current[1]
    local col = M.ContextEngine.cursor[2]
    if line == nil then
        line = lines .. "\n<missing>\n"
    else
        lines = lines .. line:sub(1, col) .. "<missing>" .. line:sub(col + 1)
    end

    -- after
    for idx, line in ipairs(M.ContextEngine.ctx.after) do
        lines = lines .. line .. '\n'
    end

    M.ContextEngine:clear_ctx()
    return lines
end

return M
