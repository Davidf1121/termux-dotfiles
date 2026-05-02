local M = {}

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

function M.battery()
  local cache = read_file(vim.fn.expand("~/.tmux_battery_cache"))
  if not cache then return "" end
  local ok, data = pcall(vim.fn.json_decode, cache)
  if not ok then return "" end
  
  local status = "󰁹"
  if data.status == "CHARGING" then status = "󱐋"
  elseif data.status == "DISCHARGING" then status = "󰂄" end
  
  return string.format("%s %d%%", status, data.percentage)
end

function M.cpu()
  -- Using a simpler top-based check for nvim for performance
  return "󰻠 " .. vim.fn.system("cut -c3- ~/.tmux.conf.local | sh -s cpu_usage"):gsub("\n", "")
end

function M.ram()
  return "󰍛 " .. vim.fn.system("free -m | awk '/Mem:/ { printf \"%dMB\", $3 }'"):gsub("\n", "")
end

function M.temp()
  local cache = read_file(vim.fn.expand("~/.tmux_battery_cache"))
  if not cache then return "" end
  local ok, data = pcall(vim.fn.json_decode, cache)
  if not ok then return "" end
  return string.format("󰏈 %.1f°C", data.temperature)
end

return M
