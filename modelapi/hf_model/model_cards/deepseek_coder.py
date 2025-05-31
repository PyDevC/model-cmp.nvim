from .base_card import BaseModelCard

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

class DeepSeek_Coder_6_7B_Instruct(BaseModelCard):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct")
        super().__init__(model, tokenizer)

    def get_layers(self):
        print(dir(self.model))
        print(self.model.__class__.__name__)

    def generate(self, message, max_new_tokens=900, batch_size=64):
        inputs = self.tokenizer(message, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(**inputs, max_new_tokens=max_new_tokens)
        decoded_output = self.tokenizer.decode(outputs[0], skip_special_tokens=True)[len(message):]
        return decoded_output
