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

model_list = {
    "DeepSeek_Coder_1_3B_Instruct": DeepSeek_Coder_1_3B_Instruct,
    "DeepSeek_Coder_6_7B_Instruct": DeepSeek_Coder_6_7B_Instruct,
    "DeepSeek_Coder_6_7B_Instruct_Quant": DeepSeek_Coder_6_7B_Instruct_Quant,
    "DeepSeek_Coder_V2_Instruct": DeepSeek_Coder_V2_Instruct,
    "DeepSeek_Coder_V2_Instruct_Quant": DeepSeek_Coder_V2_Instruct_Quant,
    "DeepSeek_Coder_V2_Lite_Instruct": DeepSeek_Coder_V2_Lite_Instruct,
}

from flask import Flask, request, jsonify
from multiprocessing import Process
import logging

app = Flask(__file__)
log = logging.getLogger('werkzeug')
log.disabled = True 

class Server:
    def __init__(self, app, model_card):
        self.app = app
        self.model_card = model_card
        self.server = None

    def change_model(self, name):
        if name == self.model_card.name:
            return
        del self.model_card
        self.model_card = model_list[name]()
    
    def start_inference(self):
        if self.server is None:
            self.server = Process(target=self.app.run)
            self.server.start()
    
    def stop_inference(self):
        if self.server is not None:
            self.server.terminate()

def get_suggestions(context):
    # Will be change in future into more scalable code
    action = context.get("action")
    message = context.get("context_message")
    suggestions = []

    if "stop" in action.lower():
        server.stop_inference()

    elif "change_model" in action.lower():
        server.change_model("message")

    elif "code_completion" in action.lower():
        model_card = server.model_card
        output = model_card.generate(message)
        return output

    else:
        pass


@app.route('/context', methods=['POST'])
def handle_context():
    data = request.get_json()

    if not data:
        return jsonify({"error": "No context_message provided"}), 400

    suggestions = get_suggestions(data)
    if suggestions:
        return jsonify({
            "suggestions": suggestions,
        })
    return jsonify({""})

model_card = model_list["DeepSeek_Coder_1_3B_Instruct"]()
server = Server(app, model_card)
server.start_inference()
