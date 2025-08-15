# Model-cmp.nvim

AI autocomplete plugin for neovim

## How to launch the server

launch the llama-server on http://127.0.0.1:8080

## Installation

### Lazy.nvim

```lua
return {
    "PyDevC/model-cmp.nvim",
    config = function ()
        require("model_cmp").setup()
    end
}
```
