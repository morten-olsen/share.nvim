# share.nvim

A neovim plugin for sharing a visual selection using a messenger platform. Currently only Slack is supported, but Microsoft Teams is on the way.
This is my first neovim plugin, so it does have rough edges, be warned. PR for fixes or features are welcome.

![demo](./assets/demo.gif)

## Setup

Setup using `packer` or your favorite package manager. `share.nvim` does depend on `plenary` and `telescope` and will require nvim `0.5` or higher.
Invoke the `.config(opts)` and pass in your providers.

```lua
use({
  "morten-olsen/share.nvim",
  requires = {
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim'}
  },
  config = function()
    local share = require("share")
    local slack = require("share.providers.slack")
    share.config({
      providers = {
        my_slack = slack("your-slack-token")
      }
    })
  end
})
```

## Usage

The easiest way to use it is to setup keybindings for your individual providers and optinally formatting. Below is an example of setting up two key bindings for sharing to a slack provider both as markdown (default for slack provider) or as code (auto wrapping visual highlight in a code block)

```vim
" share as markdown
vnoremap <Leader>ss :!lua require("share").share("my_slack")<CR>

" share as code block 
vnoremap <Leader>ssm :!lua require("share").share("my_slack", { format: "code" })<CR>

```
