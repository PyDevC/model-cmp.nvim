local M = {}

M.complete_few_shots = {
    {
        role = "user",
        content = [[# language: lua
<code>
local ghosttext = require("model_cmp.ghosttext")
local utils = require("model_cmp.utils")

local M = {}

vim.b.requ<missing>

local get_server_url = function() -- get server url from the user or from the config
    return "http://127.0.0.1:8080/v1/chat/completions"
end
</code>]]
    },
    {
        role = "assistant",
        content = [[vim.b.request_sent = false]]
    },
    {
        role = "user",
        content = [[# language: lua
<code>
function M.get_trigger_characters()
    return { '@', '.', '(', '[', ':', ' ' }
end

function M.get_capabilities()
    return {
        completion<missing>
            triggerCharacters = M.get_trigger_characters(),
        },
    }
end
</code>
]]
    },
    {
        role = "assistant",
        content = [[        completionProvider = {]]
    },
    {
        role = "user",
        content = [[# language: Python
<code>
from transformers.agents import (
    ReactCodeAgent,
    ReactJsonAgent,
    HfApiEngine,
    ManagedAgent,
)
from transformers.agents.search import DuckDuckGoSearchTool

llm_engine = <missing>

web_agent = ReactJsonAgent(
    tools=[DuckDuckGoSearchTool(), visit_webpage],
    llm_engine=llm_engine,
    max_iterations=10,
)
</code>
]]
    },
    {
        role = "assistant",
        content = [[llm_engine = HfApiEngine(model)]]
    },
}

M.default = {
    role = "user",
    content = [[Act as GitHub Copilot. Complete the code where the <missing> token is.

Instructions:
- Output only the code that replaces <missing>.
- No explanations, no comments, no full file.
- Limit to ≤ 2 lines of code.
- Match language and indentation.
]]
}

-- After this we are going to collect and send new data
M.closecall_suggestions = {
    role = "user",
    content = [[You almost got the right answer, try again with a different but similar result,
]]
}

M.wrong_suggestion = {
    role = "user",
    content = [[You predicted wrong, try again with a completly new suggestion but with this code
]]
}

return M
