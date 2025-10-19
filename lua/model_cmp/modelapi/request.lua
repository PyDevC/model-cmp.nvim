local Job = require("plenary.job")
local uv = vim.uv

local M = {}

--store current jobs
M.current_jobs = {}

function M.add_request(job)
    table.insert(M.current_jobs, job)
end

function M.end_request(job)
    if not uv.kill(job.pid) then
        return false
    end
end

function M.end_all()
    for _, job in ipairs(M.current_jobs) do
        M.end_request(job)
    end
    M.current_jobs = {}
end

function M.remove_request(job)
    for i, ojob in ipairs(M.current_jobs) do
        if job.pid == ojob.pid then
            table.remove(M.current_jobs, i)
        end
    end
end

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
    M.add_request(job)
end

return M
