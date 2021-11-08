local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local previewers = require "telescope.previewers"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values

local M = {}
local providers = {}

local function get_visual_selection()
  -- local first = vim.api.nvim_buf_get_mark(0, "<")
  -- local last = vim.api.nvim_buf_get_mark(0, ">")
  -- local content = vim.api.nvim_buf_get_lines(0, first[1] - 1, last[1], 0)
  -- print(vim.inspect(first))
  -- print(vim.inspect(last))
  -- return content
  vim.cmd('noau normal! "vy"')
  return vim.fn.getreg('v')
end

M.config = function(opts)
  providers = opts.providers or {}
end

M.share = function(provider_name, opts)
  local content = get_visual_selection()
  local type = vim.api.nvim_buf_get_option(0, "filetype")
  if content == "" then
    error("No content selected")
  end
  local provider = providers[provider_name]
  if provider == nil then
    error("Provider " .. provider_name .. " not found")
  end
  local users = provider.fetch_recipients(opts)
  pickers.new(nil, {
    prompt_title = "Users",
    finder = finders.new_table {
      results = users,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal= entry.name,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        provider.post(selection.value, content, opts or {})
      end)
      return true
    end,
    previewer = previewers.new_buffer_previewer({
      title = "snippet",
      define_preview = function(self, entry, status)
        local lines = {}
        for k in content:gmatch("([^\n]*)\n?") do
          table.insert(lines, k)
        end
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", type)
        for row,display in pairs(lines) do
          vim.api.nvim_buf_set_lines(self.state.bufnr, row, row + 1, false, { display })
        end

      end
    }),
  }):find()

end

return M
