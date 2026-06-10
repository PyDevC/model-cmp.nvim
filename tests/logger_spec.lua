---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local logger = require("model_cmp.Trace.logger")
local levels = require("model_cmp.Trace.level")
local assert_eq = assert.are.same

describe("model_cmp.Trace.logger", function()
    it("Log at DEBUG level while Logger level is set to different levels", function()
        logger:warn("This is a Warning")
        logger:info("This is a Warning")
        logger:debug("This is a Warning")
        logger:error("This is a Warning")
        logger.print_logs()
    end)
end)
