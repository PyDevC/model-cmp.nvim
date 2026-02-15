if vim.g.loaded_model_cmp == 1 then
    return
end
vim.g.loaded_model_cmp = 1

vim.api.nvim_create_user_command("ModelCmp", function(args)
        args = args.fargs
        if #args == 0 or args == nil then
            -- launch the default settings
            return
        end
        require("model_cmp.commands").load_actions(args)
end, {
    nargs = "*",
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
