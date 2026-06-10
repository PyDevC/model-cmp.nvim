---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local logger = require("model_cmp.Trace.logger")
local levels = require("model_cmp.Trace.level")
local assert_eq = assert.are.same

describe("model_cmp.Trace.logger", function()
    it("Log at DEBUG level while Logger level is set to different levels", function()
        logger:warn("This is a Warning")
        logger:info("This is a Info")
        logger:debug("This is a Debug")
        logger:error("This is a Error")
        logger.print_logs()
    end)
    it("Test logs saving to a file", function()
        logger:info("Hello, World!")
        logger:save("testing.log")
        local path = vim.fn.stdpath("log") .. "/testing.log"
        local fd, err = vim.uv.fs_open(path, "r", 420)

        if err then
            error("Failed to open log file: " .. err)
        end

        local readline = vim.uv.fs_read(fd, 1024)

        -- remove the file after testing
        vim.uv.fs_unlink(path)
        assert.is_not_nil(readline)
    end)
end)
