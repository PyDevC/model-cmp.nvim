from .base_card import BaseModelCard

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

class DeepSeek_Coder_Base(BaseModelCard):
    def __init__(self, model, tokenizer):
        super().__init__(model, tokenizer)

    def get_layers(self):
        print(dir(self.model))
        print(self.model.__class__.__name__)

    def generate(self, message, max_new_tokens=9000, batch_size=64):
        inputs = self.tokenizer(message, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(**inputs, max_new_tokens=max_new_tokens)
        decoded_output = self.tokenizer.decode(outputs[0], skip_special_tokens=True)[len(message):]
        return decoded_output

class DeepSeek_Coder_6_7B_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct")
        super().__init__(model, tokenizer)


class DeepSeek_Coder_V2_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct")
        super().__init__(model, tokenizer)

class DeepSeek_Coder_V2_Instruct_Quant(DeepSeek_Coder_Base):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", torch_dtype=torch.float16, load_in_8bit=True).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct")
        super().__init__(model, tokenizer)

class DeepSeek_Coder_6_7B_Instruct_Quant(DeepSeek_Coder_Base):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", torch_dtype=torch.float16, load_in_8bit=True).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct")
        super().__init__(model, tokenizer)
