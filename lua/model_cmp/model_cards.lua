local M = {}

M.model_cards_list = {
  "DeepSeek_Coder_1_3B_Instruct",
  "DeepSeek_Coder_6_7B_Instruct",
  "DeepSeek_Coder_6_7B_Instruct_Quant",
  "DeepSeek_Coder_V2_Instruct",
  "DeepSeek_Coder_V2_Instruct_Quant",
  "DeepSeek_Coder_V2_Lite_Instruc"
}

M.current_model = M.model_cards_list[1]

function M.change_model(model)
  M.current_model = model
end

return M
