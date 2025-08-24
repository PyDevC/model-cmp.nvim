# Model-cmp.nvim

AI autocomplete plugin for neovim

## How to launch the server

```bash
llama-server --no-mmap -hf bartowski/Llama-3.2-3B-Instruct-GGUF:Q8_0
```

## Installation

### Lazy.nvim

```lua
return {
  "PyDevC/model-cmp.nvim",
  config = function()
    require("model_cmp").setup({
      delay = 1,

      api = {
        custom_url = {
          url = "http://127.0.0.1",
          port = "8080"
        }
      },

      virtualtext = {
        enable = false,
        type = "inline",

        style = { -- This is just a highlight group
          fg = "#b53a3a",
          italic = false,
          bold = false
        }

      },
    })
  end,
}
```
