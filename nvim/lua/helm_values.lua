local M = {}

local api = vim.api

-- Include the tinyyaml parser
local tinyyaml = require("tinyyaml")

-- Function to get the value under the cursor
local function get_cursor_value()
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2] + 1
  local start = col
  while start > 0 and line:sub(start, start):match("[%w_%.]") do
    start = start - 1
  end
  local finish = col
  while finish <= #line and line:sub(finish, finish):match("[%w_%.]") do
    finish = finish + 1
  end
  return line:sub(start + 1, finish - 1)
end

-- Function to read YAML files using tinyyaml
local function read_yaml(file)
  local f = io.open(file, "r")
  if not f then
    print("Error: Could not open file " .. file)
    return nil
  end

  local content = f:read("*all")
  f:close()

  if not content or content == "" then
    return {} -- Return an empty table if the file is empty
  end

  local status, result = pcall(tinyyaml.parse, content)
  if not status then
    print("Error: Failed to parse YAML content in file " .. file)
    return nil
  end

  return result
end

-- Function to condense the content to fit within a specified width
local function condense_content(lines, max_width)
  local condensed_lines = {}
  for _, line in ipairs(lines) do
    while #line > max_width do
      table.insert(condensed_lines, line:sub(1, max_width))
      line = line:sub(max_width + 1)
    end
    table.insert(condensed_lines, line)
  end
  return condensed_lines
end

-- Function to display the values in a popup window
local function display_values(values)
  local lines = {}
  for file, value in pairs(values) do
    table.insert(lines, string.format("File: %s", file))
    table.insert(lines, string.format("Value: %s", value))
    table.insert(lines, "") -- Add an empty line between entries
  end

  -- Get the current window width and set max_width
  local current_win_width = vim.api.nvim_win_get_width(0)
  local max_width = math.floor(current_win_width * 0.8) -- Use 80% of the current window width
  max_width = math.min(max_width, 100) -- Set an upper limit to avoid extremely wide windows

  -- Condense the content to fit within the specified width
  local condensed_lines = condense_content(lines, max_width)

  -- Create a new buffer
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, condensed_lines)

  -- Set buffer to be non-modifiable
  api.nvim_buf_set_option(buf, "modifiable", false)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Create the popup window
  local win = api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = max_width,
    height = #condensed_lines,
    col = 1,
    row = 1,
    border = "rounded",
  })

  -- Map 'q' to close the window
  api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })

  -- Auto-close the popup window when it loses focus
  api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    callback = function()
      api.nvim_win_close(win, true)
    end,
  })
end

-- Function to find all values-*.yaml files
local function find_values_files()
  local handle = io.popen('find . -type f \\( -name "values.yaml" -o -name "values-*.yaml" \\)')
  local result = handle:read("*a")
  handle:close()

  local files = {}
  for file in result:gmatch("[^\r\n]+") do
    table.insert(files, file)
  end
  return files
end

-- Main function
function M.show_values()
  if vim.bo.filetype ~= "helm" then
    print("Not a Helm template file")
    return
  end

  local key = get_cursor_value()
  if not key:match("^%.Values%.") then
    print("Not a Values key")
    return
  end

  key = key:gsub("^%.Values%.", "")

  local values_files = find_values_files()
  local values = {}

  for _, file in ipairs(values_files) do
    local yaml_content = read_yaml(file)
    if yaml_content then
      local value = yaml_content
      local key_found = true
      for part in key:gmatch("[^%.]+") do
        part = vim.trim(part) -- Trim whitespace around the part
        if value[part] then
          value = value[part]
        else
          key_found = false
          break
        end
      end
      if key_found then
        values[file] = value
      end
    else
      print(string.format("Warning: Could not read YAML content from file '%s'", file))
    end
  end

  if vim.tbl_isempty(values) then
    print("No values found")
  else
    display_values(values)
  end
end

return M
