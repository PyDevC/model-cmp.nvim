local plenary = require("plenary.curl")
local string = string
local M = {}

local message_types = {
  code = 1,
  command = 2,
  general = 3,
}

M.Client = {
  url = "http://127.0.0.1:",
  port = 8888,
}

M.message = {
  type = message_types.general,
  content = "",
  max_token_limit = 128,
}

local check_message = function(message)
  -- Checking availability of message
  if message.type == nil then
    return false
  elseif message.content == "" then
    return false
  elseif message.max_token_limit < 20 then
    return false
  end

  -- Check the code completion validity
  if message.type == 1 then
    if string.find(message.content, "<|fim_hole|>") then
      return false
    end
  end
  return true
end

local action = {}

function action.connect(url, port)
  url = url or M.Client.url
  port = port or M.Client.port

  local full_url = url .. port
  return full_url
end

function action.send(message)
  if check_message(message) then
    -- send the message
  end
end

function action.receive()
end

function action.send_command(command)
end

M.action = action

return M
