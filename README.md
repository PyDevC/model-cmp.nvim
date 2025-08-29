# Model-cmp.nvim

AI autocomplete plugin for neovim

support me!!! it is difficult to develop open source while searching for jobs. scan and support
![IMG-20250829-WA0012](https://github.com/user-attachments/assets/e86526b6-6819-4ae5-a3b7-6698af3f03ee)


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
