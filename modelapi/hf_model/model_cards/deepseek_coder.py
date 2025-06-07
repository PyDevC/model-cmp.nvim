from .base_card import BaseModelCard
from typing import LiteralString

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

class DeepSeek_Coder_Base(BaseModelCard):
    def __init__(self,name, model, tokenizer)->None:
        super().__init__(name, model, tokenizer)

    def get_layers(self)->None:
        print(dir(self.model))
        print(self.model.__class__.__name__)

    def generate(self, message, max_new_tokens=512, batch_size=64)->LiteralString:
        inputs = self.tokenizer(message, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(**inputs, max_new_tokens=max_new_tokens)
        decoded_output = self.tokenizer.decode(outputs[0], skip_special_tokens=True)[len(message):]
        return decoded_output

class DeepSeek_Coder_1_3B_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/deepseek-coder-1.3b-instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-1.3b-instruct", trust_remote_code=True, torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-1.3b-instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)

class DeepSeek_Coder_6_7B_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/deepseek-coder-6.7b-instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", trust_remote_code=True, torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)

class DeepSeek_Coder_V2_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/DeepSeek-Coder-V2-Instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", trust_remote_code=True, torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)

class DeepSeek_Coder_V2_Instruct_Quant(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/DeepSeek-Coder-V2-Instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", trust_remote_code=True, torch_dtype=torch.float16, load_in_8bit=True).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)

class DeepSeek_Coder_V2_Lite_Instruct(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct", trust_remote_code=True, torch_dtype=torch.float16).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)
    
class DeepSeek_Coder_6_7B_Instruct_Quant(DeepSeek_Coder_Base):
    def __init__(self):
        name = "deepseek-ai/deepseek-coder-6.7b-instruct"
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", trust_remote_code=True, torch_dtype=torch.float16, load_in_8bit=True).cuda()
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct", trust_remote_code=True)
        super().__init__(name, model, tokenizer)
