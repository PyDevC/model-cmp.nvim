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

## What technique do we use?

We actually use few shot prompting with self experimentation

## Current Limitations

- limited to the capabilities of the underlying LLM model.
- No configurations
- does not work well with markdown
- Output cpature does not work properly
