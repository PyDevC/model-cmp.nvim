local M = {}

---@class ctx
---@field scopes TSNode[] Scopes of each function around the cursor
---@field current string[] Current line the cursor is at
---@field imports string[] This is related to Lsp stuff so we are going to integrate this in future

---@class ModelCmp.ContextEngine
---@field bufnr integer current buffer number
---@field cursor integer[] current cursor pos
---@field lang string querylanguage to choose
---@field ctx ctx
M.ContextEngine = {
    bufnr = 0,
    cursor = { 0, 0 },
    lang = "text",
    ctx = {
        scopes = {},
        current = {},
        imports = {},
    },
}

function M.ContextEngine:clear_ctx()
    self.ctx = {
        scopes = {},
        current = {},
        imports = {},
    }
end

function M.ContextEngine:get_root()
    local parser = vim.treesitter.get_parser(0, self.lang, {})

    if parser == nil then
        return {}
    end

    local tree = parser:parse()[1]
    return tree:root()
end

function M.ContextEngine:get_scopes_and_ranges()
    local scope_query = "context-scope"
    local ok, query = pcall(vim.treesitter.query.get, self.lang, scope_query)

    if not ok or query == nil then
        return {}
    end

    local root = self:get_root()

    for _, match, _ in query:iter_matches(root, self.bufnr, 0, -1, { all = true }) do
        for _, nodes in pairs(match) do
            for _, node in ipairs(nodes) do
                table.insert(self.ctx.scopes, node)
            end
        end
    end
end

function M.ContextEngine:get_ctx()
    self.bufnr = vim.api.nvim_get_current_buf()
    self.cursor = vim.api.nvim_win_get_cursor(0)
    self.lang = vim.bo.ft
    self:get_scopes_and_ranges()
end

---@param node TSNode
---@return boolean
local function scopes_inrange(node, cursor)
    local start_r, _, end_r, _ = node:range()
    return cursor[1] >= start_r and cursor[1] <= end_r
end

local function node_to_line_array(node_text)
    local lines = {}
    for line in node_text:gmatch("([^\n]*)[\n]?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    return lines
end

local function add_missing_tag(line, cursor)
    local missing = string.sub(line, 1, cursor[2]) .. "<missing>" .. string.sub(line, cursor[2] + 1)
    return missing
end

function M.ContextEngine:generate_context_text()
    local lines = [[]]
    self:get_ctx()

    for _, k in ipairs(self.ctx.scopes) do
        if scopes_inrange(k, self.cursor) then
            lines = vim.treesitter.get_node_text(k, self.bufnr)
        end
    end

    local lines_list = node_to_line_array(lines)
    local currentline = vim.api.nvim_buf_get_lines(self.bufnr, self.cursor[1] - 1, self.cursor[1] + 1, false)

    for i, _ in ipairs(lines_list) do
        if lines_list[i] == currentline[1] then
            lines_list[i] = add_missing_tag(currentline[1], self.cursor)
        end
    end

    lines = [[]]
    for _, k in ipairs(lines_list) do
        lines = lines .. k .. "\n"
    end

    return lines
end

return M
