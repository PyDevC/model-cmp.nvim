from hf_model.model_cards.deepseek_coder import DeepSeek_Coder_6_7B_Instruct

model_card = DeepSeek_Coder_6_7B_Instruct()

messages = "" # add your coded here

print(model_card.generate(messages))
