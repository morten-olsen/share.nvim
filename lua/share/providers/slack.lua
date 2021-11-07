local curl = require "plenary.curl"

local M = function(slack_token)
  local token = slack_token
  local function post(receiver, content, opts)
    local text = content
    if opts.format = "markdown" then
      text = "```\n" .. text .. "```"
    end
    local body = {
      text = text,
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

return M
