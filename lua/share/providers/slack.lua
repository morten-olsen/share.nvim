local curl = require "plenary.curl"

local function merge_lists(t1, t2)
  local result = {}
  table.foreach(t1, function(_, v) table.insert(result, v) end)
  table.foreach(t2, function(_, v) table.insert(result, v) end)
  return result
end

local function test_http_response(res)
  local body = vim.fn.json_decode(res.body)
  if body.error then
    error("Slack error " .. body.error)
  end
end

local M = function(slack_token)
  local token = slack_token
  local function post(receiver, content, opts)
    local text = content
    if opts.format == "code" then
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
    test_http_response(res)
  end

  local function fetch_channels()
    local query = {
      types = "public_channel,private_channel",
      exclude_archived = "true",
      limit = "1000",
    }
    local res = curl.get("https://slack.com/api/conversations.list", {
      query = query,
      headers = {
        Authorization = "Bearer " .. token
      }
    })
    test_http_response(res)
    local channels = vim.fn.json_decode(res.body).channels
    table.foreach(channels, function(_, k)
      k.name = "# " .. k.name
    end)
    return channels
  end

  local function fetch_users()
    local res = curl.get("https://slack.com/api/users.list", {
      headers = {
        Authorization = "Bearer " .. token
      }
    })
    test_http_response(res)
    local users = vim.fn.json_decode(res.body).members
    table.foreach(users, function(_, k)
      local name = k.real_name or k.name
      if k.real_name then
        name = name .. " (" .. k.name .. ")"
      end
      k.name = "@ " .. name
    end)
    return users
  end

  local function fetch_recipients()
    local users = fetch_users()
    local channels = fetch_channels()
    return merge_lists(users, channels)
  end

  return {
    fetch_recipients = fetch_recipients,
    post = post,
  }
end

return M
