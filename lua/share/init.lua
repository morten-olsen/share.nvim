local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values

local M = {}
local providers = {}

local function get_visual_selection()
  local first = vim.api.nvim_buf_get_mark(0, "<")
  local last = vim.api.nvim_buf_get_mark(0, ">")
  local content = vim.api.nvim_buf_get_lines(0, first[1] - 1, last[1], 0)
  return content
end

M.config = function(opts)
  providers = opts.providers or {}
end

M.share = function(provider_name, opts)
  local content = get_visual_selection()
  local provider = providers[provider_name]
  local users = provider.fetch_users(opts)
  pickers.new(nil, {
    prompt_title = "Users",
    finder = finders.new_table {
      results = users,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.real_name or entry.name,
          ordinal= entry.real_name or entry.name,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        provider.post(selection.value, table.concat(content, "\n"), opts)
      end)
      return true
    end,
  }):find()

end

return M
