import torch

cpu = torch.device("cpu")
gpu = torch.device(f"cuda:{torch.cuda.current_device()}")

gpu_complete_modules = []

def get_free_memory_gb(device=None):
    """Gets all the memory free and reserved in gpu in GB"""
    if device == cpu:
        return 0
    elif device is None:
        device = gpu

    if len(torch.cuda.memory_stats().items()) == 0:
        free_bytes, _ = torch.cuda.mem_get_info()
        return free_bytes / (1024 ** 3)

    stats = torch.cuda.memory_stats(device)
    reserved_bytes = stats['reserved_bytes.all.current']
    active_bytes = stats['active_bytes.all.current']
    free_bytes, _ = torch.cuda.mem_get_info()
    reserved_inactive_bytes = reserved_bytes - active_bytes
    total_free_bytes = free_bytes + reserved_inactive_bytes
    return total_free_bytes / (1024 ** 3)

def fake_weight_shift(model, target_device):
    """Shifts the first weights of model to the target_device"""
    for m in model.named_parameters():
        if hasattr(m, 'weights'):
            m.to(target_device)
            return

def onload_model_to_device_with_memory_preservation(model, target_device=None, preserved_memory=0):
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

def offload_model_from_device_for_memory_preservation(model, target_device, preserved_memory=0):
    print(f"moving {model.__class__.__name__} to {target_device} with preserved memory {preserved_memory} GB")

    for m in model.modules():
        if get_free_memory_gb(target_device) >= preserved_memory:
            torch.cuda.empty_cache()
            return 

        if hasattr(m, 'weights'):
            m.to(cpu)

    model.to(target_device)
    torch.cuda.empty_cache()
    return

def unload_complete_model(*args):
    for m in gpu_complete_modules + list(args):
        m.to(cpu)
        print(f"Unloaded Model {m.__class__.__name__} to cpu")

    gpu_complete_modules.clear()
    torch.cuda.empty_cache()
    return

def load_complete_model(model, target_device, unload_other=True):
    if unload_other:
        unload_complete_model()

    model.to(target_device)
    print(f"Loaded Complete model {model.__class__.__name__} to {target_device}")
    gpu_complete_modules.append(model)
    return
