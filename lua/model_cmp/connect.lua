local popen = io.popen
local curl = require("plenary.curl")

local M = {}

function M.send_and_receive(context_message)
  local body = vim.fn.json_encode(context_message)

  local response = curl.post("http://127.0.0.1:5000/context", {
    body = body,
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#body),
    },
  })

  local parsed = vim.fn.json_decode(response.body)
  return parsed.suggestion
end

local action = {}

function action.start()
  popen("python3 modelapi/run.py")
  print("Model inference started ")
end

function action.stop()
  M.send_and_receive({ action = "stop", context_message = "" })
end

function action.change_model(model_name)
  M.send_and_receive({ action = "change_model", context_message = model_name })
end

function action.contextsend(context)
  M.send_and_receive({ action = "code_completion", context_message = context })
end

M.action = action

return M
