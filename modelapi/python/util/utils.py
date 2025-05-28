from huggingface_hub import login, logout
import torch

from transformers import AutoTokenizer, AutoModelForCausalLM
from transformers.trainer import Trainer

from logging import log
import time

def hflogin(token=None, newlogin=False, retrytime=1.0):
    # Create logs for each step
    if token is None:
        log(1,"HF_TOKEN is empty set HF_TOKEN with your access token of huggingface")
    while True:
        try:
            login(token, new_session=newlogin)
            break
        except Exception as e:
            if e is ValueError:
                log(1, f"Invalid token: {e}")
                break
            else:
                log(1, f"Login failed: {e}, Retrying in 1s")
                time.sleep(retrytime)

def hflogout(token=None):
    if token is None:
        log(1, "Token is empty Add a vaild token")
    try:
        logout(token)
    except Exception as e:
        log(1, f"Logout failed: {e}")

def download_model(model="deepseek-ai/deepseek-coder-6.7b-instruct", output_dir="./model/"):
    tokenizer = AutoTokenizer.from_pretrained(model, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(model, trust_remote_code=True, torch_dtype=torch.bfloat16).cuda()

    trainer = Trainer(model=model)
    trainer.save_state()
    state_dict = trainer.model.state_dict()

    if trainer.args.should_save:
        cpu_state_dict = {key: value.cpu() for key, value in state_dict.items()}
        del state_dict
        trainer._save(f"{output_dir}deepseek-pytorch", state_dict=cpu_state_dict)  # noqa

    tokenizer.save_pretrained(f"{output_dir}deepseek-token")

def load_model(model_dir="./model/deepseek-pytorch", 
               token_dir="./model/deepseek-token"
    ):
    model = AutoModelForCausalLM.from_pretrained(model_dir, trust_remote_code=True, torch_dtype=torch.bfloat16).cuda()
    tokenizer = AutoTokenizer.from_pretrained(token_dir, trust_remote_code=True)
    return model, tokenizer
