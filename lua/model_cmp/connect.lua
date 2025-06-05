--Module directly connects to the python modelapi
--It directly connects to the server established in modelapi run.py
--It has capability to start and stop modelapi run.py
--
--Once the connection is established, the following commands can be allowed
--1. send the context message for getting the model output
--2. receives the suggestions made by the modelapi
--3. can perform co-tasks such as changing model.

local popen = io.popen

local M = {}

function M.get_suggestion(ctx)
  M.action.send(ctx)
  local suggestion = M.action.receive()
  return suggestion
end

local action = {}

function action.start()
  popen("python3 modelapi/run.py")
  print("Model inference started ")
end

--Signals the modelapi server to stop
function action.stop()
  action.send({ "Stop" })
end

function action.change_model(model_name)
end

--Send the message to the modelapi server
---@param message table: message can be a command or context
function action.send(message)
end

--Gets the message from the async queue in modelapi server
---@return table: receives the completion from the model for now
function action.receive()
  return {}
end

M.action = action

return M
