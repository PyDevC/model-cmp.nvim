from .base_card import BaseModelCard

from transformers import AutoModelForCausalLM, AutoTokenizer

class DeepSeek_Coder_6_7B_Instruct(BaseModelCard):
    def __init__(self):
        model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct")
        tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-6.7b-instruct")
        super().__init__(model, tokenizer)

    def generate(self, message, max_new_tokens=120, temperature=0.8):
        inputs = self.tokenizer(message, return_tensors="pt").to(self.model.device)
        outputs = self.model.generate(**inputs, max_length=128)
        decoded_output = self.tokenizer.decode(outputs[0], skip_special_tokens=True)[len(message):]
        return decoded_output
