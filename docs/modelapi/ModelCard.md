# ModelCard

## BaseModelCard
base class for all model cards
requires model, and tokenizer to be defined in inherited class
```python
class DeepSeek(ModelCard):
    def __init__(self, model, tokenizer):
        model = AutoModelForCausalLM.from_pretrained()
        tokenizer = AutoTokenizer.from_pretrained()
        super().__init__(model, tokenizer)

```

`abstract-method`: generate(message, max_new_tokens=120, temperature=0.8)
max_new_tokens and temperature are dependent on the model so they can be omitted
when using, any model that doesn't require those parameters

## Download Directory
Models will get downloaded in HF_HOME directory.
HF_HOME is hardcoded and will be changed in future for more control over model
HF_HOME set to modelapi/hf_model/model_cards/hf_download
