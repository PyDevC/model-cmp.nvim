---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local utils = require("model_cmp.utils")

---@type string
local llama_response_json = [[{
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

local gemini_response_json = [[{
  "candidates": [
    {
      "content": {
        "parts": [
          { "text": "The capital of France is Paris." }
        ]
      },
      "finishReason": "stop",
      "safetyRatings": [
        {
          "category": "HARM",
          "probability": 0.0001,
          "blocked": false
        }
      ],
      "citationMetadata": {
        "citations": [
          {
            "startIndex": 0,
            "endIndex": 5,
            "metadata": {
              "source": "https://en.wikipedia.org/wiki/Paris",
              "title": "Paris — Wikipedia"
            }
          }
        ]
      }
    }
  ],
  "metadata": {
    "model": "gemini-2.5-flash",
    "responseMimeType": "application/json",
    "responseSchemaVersion": "1.0"
  }
}
]]

local llama_error_response_json = [[{
  "error": {
    "message": "Missing required field: 'messages'",
    "type": "invalid_request_error",
    "param": "messages",
    "code": null
  }
}
]]

local gemini_error_response_json = [[{
  "error": {
    "code": 400,
    "message": "Invalid argument: response schema too complex",
    "status": "INVALID_ARGUMENT",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.BadRequest",
        "fieldViolations": [
          {
            "field": "generationConfig.responseSchema",
            "description": "Schema has too many nested levels or too many properties"
          }
        ]
      }
    ]
  }
}
]]

describe("model_cmp.utils", function()
    it(
        "decode gemini response json",
        function()
            assert.are.same("The capital of France is Paris.",
                utils.decode_response(gemini_response_json, "gemini"))
        end
    )

    it(
        "decode local llama response json",
        function()
            assert.are.same("The capital of France is Paris.",
                utils.decode_response(llama_response_json, "local_llama"))
        end
    )

    it("decode gemini error response json",
        function() assert.is_nil(utils.decode_response(gemini_error_response_json, "gemini")) end
    )

    it("decode local llama error response json",
        function() assert.is_nil(utils.decode_response(llama_error_response_json, "local_llama")) end
    )

    it("Parse few shot prompts from inputs",
        function()
            local samplefileinput = {
                "@role: user",
                "@content:",
                "<code>",
                "public int add(int a, int b) {",
                "    return <missing>;",
                "}",
                "</code>",
                "",
                "@role: assistant",
                "@content:",
                "<code>",
                "    return a + b;",
                "</code>"
            }
            local samplemessage = {
                {
                    content = 'public int add(int a, int b) {\n    return <missing>;\n}',
                    role = 'user'
                },
                {
                    content = '    return a + b;',
                    role = 'assistant'
                }
            }
            assert.are.same(samplemessage, utils.parse_messages(samplefileinput))
        end
    )

    it("Text adjusting according to content", function()
        assert.are.same("options", utils.partial_match("return ", "return options"))
        assert.is_nil(utils.partial_match("return ", "print(options)"))
        assert.is_nil(utils.partial_match(";", "return 0;"))
        assert.are.same("0;", utils.partial_match("return ", "return 0;"))
    end
    )
end)
