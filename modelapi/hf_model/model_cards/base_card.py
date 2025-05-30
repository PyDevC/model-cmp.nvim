import torch

from abc import ABC, abstractmethod
import os

os.environ['HF_HOME'] = os.path.abspath(os.path.realpath(os.path.join(os.path.dirname(__file__), './hf_download')))

class BaseModelCard(ABC):
    r"""Base Structure of Every Model
    
    Example:
    class DeepSeek(ModelCard):
        def __init__(self, model, tokenizer):
            model = 
            tokenizer = 
            super().__init__(model, tokenizer)
    """
    def __init__(self, model, tokenizer):
        self.model = model
        self.tokenizer = tokenizer

    @abstractmethod
    def generate(self, message, max_new_tokens, temperature):
        r"""Generate the text from message using model.generate or similar
        functions
        """
