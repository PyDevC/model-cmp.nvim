--Module directly connects to the python modelapi
--It directly connects to the server established in modelapi run.py
--It has capability to start and stop modelapi run.py
--
--Once the connection is established, the following commands can be allowed
--1. send the context message for getting the model output
--2. receives the suggestions made by the modelapi
--3. can perform co-tasks such as changing model.

local M = {}

local action = {}

--Start the python model server
function action:start()
end

--Stop the python model server
function action:stop()
end

--Send some message
function action:send()
end

--Receive some message
function action:receive()
end

M.action = action

return M
