local connect = require("model_cmp.connect")
local M = {}

M.model_card_list = {
    "DeepSeek_Coder_1_3B_Instruct",
    "DeepSeek_Coder_6_7B_Instruct",
    "DeepSeek_Coder_6_7B_Instruct_Quant",
    "DeepSeek_Coder_V2_Instruct",
    "DeepSeek_Coder_V2_Instruct_Quant",
    "DeepSeek_Coder_V2_Lite_Instruct",
}

M.current_model = ""

function M.change_model(model_name)
  if model_name == M.current_model then
    return
  end
  connect.action.stop()
  connect.action.change_model(model_name)
  M.current_model = model_name
end

return M
