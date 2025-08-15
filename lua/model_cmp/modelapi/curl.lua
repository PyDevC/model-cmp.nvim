local Job = require("plenary.job")

local M = {}

M.requests = {} -- This can store pending jobs or request data

function M.send(request_args, callback)
    local result = {}
    local job = Job:new({
        command = "curl",
        args = request_args,
        on_stdout = function(_, line)
            table.insert(result, line)
        end,
        on_exit = function()
            if callback then
                -- Join all the output lines and send to callback
                callback(table.concat(result, "\n"))
            end
        end,
    })
    job:start()
    table.insert(M.requests, job) -- Optional: keep track of active jobs
end

return M

