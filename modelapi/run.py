from hf_model.model_cards.deepseek_coder import (
    DeepSeek_Coder_Base,
    DeepSeek_Coder_1_3B_Instruct,
    DeepSeek_Coder_6_7B_Instruct,
    DeepSeek_Coder_6_7B_Instruct_Quant,
    DeepSeek_Coder_V2_Instruct,
    DeepSeek_Coder_V2_Instruct_Quant,
    DeepSeek_Coder_V2_Lite_Instruct,
)

from hf_model.memory import (
    cpu,
    gpu,
    fake_weight_shift,
    get_free_memory_gb,
    load_complete_model,
    offload_model_from_device_for_memory_preservation,
    onload_model_to_device_with_memory_preservation,
    unload_complete_model, 
)

import torch
import os
from hf_model.server import Server

model_list = {
    "DeepSeek_Coder_1_3B_Instruct": DeepSeek_Coder_1_3B_Instruct,
    "DeepSeek_Coder_6_7B_Instruct": DeepSeek_Coder_6_7B_Instruct,
    "DeepSeek_Coder_6_7B_Instruct_Quant": DeepSeek_Coder_6_7B_Instruct_Quant,
    "DeepSeek_Coder_V2_Instruct": DeepSeek_Coder_V2_Instruct,
    "DeepSeek_Coder_V2_Instruct_Quant": DeepSeek_Coder_V2_Instruct_Quant,
    "DeepSeek_Coder_V2_Lite_Instruct": DeepSeek_Coder_V2_Lite_Instruct,
}

def attach_model(model_name="DeepSeek_Coder_1_3B_Instruct"):
    """Attach model based on the name selected"""
    model_card = model_list[model_name]()
    return model_card

def start_inference(model_card:DeepSeek_Coder_Base):
    server = Server()
    server.start_server()
    while server.running:
        message, secondary = server.receive()
        if message == "Stop":
            server.stop_server()
            break
        elif message == "change_model":
            torch.cuda.empty_cache()
            model_card = attach_model(secondary)

        suggestion = model_card.generate(message)
        server.send(suggestion)

def main():
    model_card = attach_model()
    start_inference(model_card)

main()
