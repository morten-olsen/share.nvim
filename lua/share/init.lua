local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local curl = require "plenary.curl"
local M = {}

local providers = {}

local function get_visual_selection()
  local first = vim.api.nvim_buf_get_mark(0, "<")
  local last = vim.api.nvim_buf_get_mark(0, ">")
  local content = vim.api.nvim_buf_get_lines(0, first[1] - 1, last[1], 0)
  return content
end

M.providers = {}

M.providers.slack = function(slack_token)
  local token = slack_token
  print(vim.inspect(token))
  local function post(receiver, content)
    local body = {
      text = "```\n" .. table.concat(content, "\n") .. "\n```",
      channel = receiver.id,
      as_user = true,
    }
    local res = curl.post("https://slack.com/api/chat.postMessage", {
      body = vim.fn.json_encode(body),
      headers = {
        Authorization = "Bearer " .. token,
        content_type = "application/json"
      }
    })
  end

  local function fetch_users()
    local res = curl.get("https://slack.com/api/users.list", {
      headers = {
        Authorization = "Bearer " .. token
      }
    })
    local users = vim.fn.json_decode(res.body).members
    return users
  end

  return {
    fetch_users = fetch_users,
    post = post,
  }
end

M.config = function(opts)
  providers = opts.providers or {}
end

M.share = function(provider_name)
  local content = get_visual_selection()
  local provider = providers[provider_name]
  local users = provider.fetch_users()
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
        post_to(selection.value, content)
      end)
      return true
    end,
  }):find()

end

return M
