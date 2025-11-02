# Model-cmp.nvim

AI autocomplete with Treesitter Context Engine, and Local LLM and GEMINI Support.

Model-cmp uses various features of neovim to Deliver AI autocompletion features by predicting the current line text.
We use Treesitter deeply to generate Context around the cursor (Treesitter implementation of Context Engine is under development).
We use Few shot prompting to get custom suggestions from the LLM.

You can use which ever LLM you want till its on port you specified in your config.
<img width="1920" height="1080" alt="2025-11-02-081401_hyprshot" src="https://github.com/user-attachments/assets/94f4ca25-cfa8-403a-9dfe-dc2177f57c1c" />
<img width="1920" height="1080" alt="2025-11-02-081433_hyprshot" src="https://github.com/user-attachments/assets/15d1daa3-d26d-4749-a637-6e6849ada351" />


## Installation

Before installing the plugin, please make sure you have following pre-requisities:
- llama.cpp or gemini api key
- system specs for local llm inferencing [Checkout Here for system requriements]()

### Lazy.nvim

```lua
{
    "PyDevC/model-cmp.nvim",
    config = function()
        require("model_cmp").setup()
        vim.keymap.set("i", "<C-s>", "<cmd>ModelCmp capture first<CR>")
    end
}
```

### Setup Gemini API key

There are two ways to setup gemini api keys:
1. Environment variable
2. Inside config

- Environment variable: 
```bash
export GEMINI_API_KEY="<your-key>"
```

 or

you can setup api key in your ~/.bashrc or ~/.zshrc which I highly don't recommend

- Inside Config:

```lua
{
    api = {
        apikeys = {
            GEMINI_API_KEY = "<your-key>"
        }
    }
}
```

## Config

```lua
return {
  "PyDevC/model-cmp.nvim",
  config = function()
    require("model_cmp").setup({
      delay = 1000, -- 1 sec delay

      api = {
        apikeys = {
            GEMINI_API_KEY = "<your-key>"
        }
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
    vim.keymap.set("i", "<C-s>", "<cmd>ModelCmp capture first<CR>")
  end,
}
```

## Support

support me!!! it is difficult to develop open source while searching for jobs. scan and support
![IMG-20250829-WA0012](https://github.com/user-attachments/assets/e86526b6-6819-4ae5-a3b7-6698af3f03ee)
