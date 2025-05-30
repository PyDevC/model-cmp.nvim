import torch

cpu = torch.device("cpu")
gpu = torch.device(f"cuda:{torch.cuda.current_device()}")

def get_free_memory_gb(device=None):
    """Gets all the memory free and reserved in gpu in GB"""
    if device is None:
        device = gpu

    stats = torch.cuda.memory_stats(device)
    reserved_bytes = stats['reserved_bytes']
    active_bytes = stats['active_bytes']
    free_bytes, _ = torch.cuda.mem_get_info()
    reserved_inactive_bytes = reserved_bytes - active_bytes
    total_free_bytes = free_bytes + reserved_inactive_bytes
    return total_free_bytes / (1024 ** 3)

def move_model_to_device_with_memory_preservation(model, target_device=None, preserved_memory=0):
    if not preserved_memory:
        print(f"Can't move {model.__class__.__name__} to {target_device} due to preserved memory {preserved_memory} GB")
        return 

    print(f"moving {model.__class__.__name__} to {target_device} with preserved memory {preserved_memory} GB")
    
    for m in model.modules():
        if get_free_memory_gb(target_device) <= preserved_memory:
            torch.cuda.empty_cache()
            return 

        if hasattr(m, 'weights'):
            m.to(target_device)

    model.to(target_device)
    torch.cuda.empty_cache()
    return
