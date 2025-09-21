---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local utils = require("model_cmp.utils")

---@type string
local response_json = [[{
  "id": "chatcmpl-12345",
  "object": "chat.completion",
  "created": 1695400000,
  "model": "llama-2-7b-chat",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 8,
    "total_tokens": 20
  }
}
]]

local error_response_json = [[{
  "error": {
    "message": "Missing required field: 'messages'",
    "type": "invalid_request_error",
    "param": "messages",
    "code": null
  }
}
]]

describe("model_cmp.utils", function()
    it("decode common response json", function()
        assert.are.same("The capital of France is Paris.", utils.decode_response(response_json))
    end)
    it("decode error response json", function()
        assert.is_nil(utils.decode_response(error_response_json))
    end)
end)
