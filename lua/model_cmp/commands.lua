local api = require("model_cmp.modelapi.common")
local logger = require("model_cmp.logger")
local config = require("model_cmp.config")
local uv = vim.uv

local M = {}

---@return boolean Editspace
local function check_editing_space(event)
    local file = event["file"]
    if file == "" or file == nil then
        return false
    elseif file:find("oil:///") then
        return false
    end

    return true
end

---@alias Augroup integer

---@param group Augroup
local function create_autocmds(group)
    M.timer = uv.new_timer()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
        group = group,
        callback = function(event)
            if vim.g.model_cmp_connection_server == nil then
                return
            end
            if vim.g.server_error_count == config.requests.max_retries then
                if vim.g.model_cmp_connection_server == nil then
                    return
                end
                vim.g.model_cmp_connection_server = nil
                error(
                    "There is something wrong with your server setup,"
                        .. " please check your logs before doing anything :ModelCmpLogs"
                )
                return
            end
            if not check_editing_space(event) or M.timer:is_active() or vim.fn.mode() ~= "i" then
                return
            end
            M.timer:start(1000, 0, function() end)
            api.send_request()
        end,
    })

    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = group,
        callback = function(event)
            if not check_editing_space(event) then
                return
            end
            require("model_cmp.virtualtext").action.clear_preview()
        end,
    })

    vim.api.nvim_create_autocmd({ "VimLeave" }, {
        group = group,
        callback = function()
            logger.save_logs()
        end,
    })
end

local function create_usercmds()
    vim.api.nvim_create_user_command("ModelCmp", function(args)
        args = args.fargs
        if #args == 0 or args == nil then
            return
        end
        local virtualtext = require("model_cmp.virtualtext")

        local actions = {}
        actions.virtualtext = {
            enable = function()
                virtualtext.action.enable_auto_trigger()
            end,
            disable = function()
                virtualtext.action.disable_auto_trigger()
            end,
            toggle = function()
                virtualtext.action.toggle_auto_trigger()
            end,
        }
        actions.server = {
            local_server = function() end,
            gemini = function() end,
        }
        actions.capture = {
            first = function()
                virtualtext.action.capturefirstline()
            end,
            all = function()
                virtualtext.action.capturealllines()
            end,
        }
        actions[args[1]][args[2]]()
    end, {
        nargs = "+",
        complete = function(_, cmdline, _)
            cmdline = cmdline or ""

            if cmdline:find("virtualtext") then
                return {
                    "enable",
                    "disable",
                    "toggle",
                }
            end
            if cmdline:find("capture") then
                return { "first", "all" }
            end
            return { "virtualtext", "capture", "server" }
        end,
    })

    vim.api.nvim_create_user_command("ModelCmpStart", function(args)
        local ok = pcall(vim.api.nvim_get_autocmds, { group = "model_cmp_grp" })
        if not ok then
            M.setup()
        end
        args = args.fargs
        local servers = {
            local_llama = function()
                vim.g.model_cmp_connection_server = "local_llama"
                vim.g.server_error_count = 0
            end,
            gemini = function()
                vim.g.model_cmp_connection_server = "gemini"
                vim.g.server_error_count = 0
            end,
        }
        servers[args[1]]()
    end, {
        nargs = "+",
        complete = function()
            return {
                "local_llama",
                "gemini",
            }
        end,
    })

    vim.api.nvim_create_user_command("ModelCmpStop", function(args)
        if args.fargs[1] == "all" then
            vim.api.nvim_del_augroup_by_name("model_cmp_grp")
        end
        vim.g.model_cmp_virtualtext_auto_trigger = ""
    end, { nargs = "+" })

    vim.api.nvim_create_user_command("ModelCmpLogs", function()
        vim.cmd("tabnew")
        local newbuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(newbuf, "Model Cmp logs")
        vim.api.nvim_set_current_buf(newbuf)
        vim.api.nvim_buf_set_option(newbuf, "bufhidden", "wipe") -- Close buffer when window is closed
        vim.api.nvim_buf_set_option(newbuf, "buftype", "nofile") -- Not a file buffer
        vim.api.nvim_buf_set_option(newbuf, "swapfile", false) -- No swap file
        vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, logger.Logs)
        vim.api.nvim_buf_set_option(newbuf, "modifiable", false) -- Make it read-only
    end, {})
end

function M.setup()
    local autogrp = vim.api.nvim_create_augroup("model_cmp_grp", {})
    create_autocmds(autogrp)
    create_usercmds()
end

return M
