from hf_model.model_cards.deepseek_coder import DeepSeek_Coder_6_7B_Instruct
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

# Initial cleanup and variable loading
linuxcode = os.path.join(os.path.dirname(os.path.dirname(__file__)), "example_prompt", "linuxcode.txt")
torch.cuda.empty_cache()

# Flags
VRAM_RESTRICTION = True

# Check CPU and GPU capablities with RAM in the system available
vram = get_free_memory_gb(gpu) # getting free memory would be the right choice -- TO-LOOK: whether I should get total vram of the gpu or get the full free space
if vram > 60:
    VRAM_RESTRICTION = True

###############################################################################
# Main program >>> not in main function cause of later integration with neovim
###############################################################################

model_card = DeepSeek_Coder_6_7B_Instruct() # loaded the modelcard

if VRAM_RESTRICTION:
    print("Appling VRAM_RESTRICTION")
    fake_weight_shift(model_card.model, gpu)

with open(linuxcode, 'r') as file:
    messages = file.read()

print(model_card.generate(messages))
