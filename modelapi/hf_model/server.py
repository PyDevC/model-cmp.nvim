import asyncio
from lupa import LuaRuntime
import os

model_cmp_nvim_path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
lua_connect_path = os.path.join(model_cmp_nvim_path, "lua", "model_cmp", "connect.lua")

class Server:
    def __init__(self):
        self.running
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.queue = asyncio.Queue()

        with open(lua_connect_path) as connect:
            luacode = connect.read()
        self.lua.execute(luacode)
        self.send_suggestion = self.lua.globals().receive
        self.get_context = self.lua.globals().send

    def start_server(self):
        """Start a server to send and receive context and suggestions"""
        if self.running:
            return
        self.running = True
        return
    
    def send(self, suggestion):
        if self.running:
            self.send_suggestion(suggestion)

    async def receive(self):
        context = self.get_context()
        return context
    
    def stop_server(self):
        self.running = False
