local M = {}

local cache = {
  battery = "...",
  cpu = "...",
  ram = "...",
  temp = "...",
  last_update = 0
}

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

local function update_cache()
  local now = os.time()
  if now - cache.last_update < 5 then return end
  cache.last_update = now

  -- Battery & Temp
  local batt_cache = read_file(vim.fn.expand("~/.tmux_battery_cache"))
  if batt_cache then
    local ok, data = pcall(vim.fn.json_decode, batt_cache)
    if ok then
      local status = "󰁹"
      if data.status == "CHARGING" then status = "󱐋"
      elseif data.status == "DISCHARGING" then status = "󰂄" end
      cache.battery = string.format("%s %d%%%%", status, data.percentage)
      cache.temp = string.format("󰏈 %.1f°C", data.temperature)
    end
  end

  -- CPU (Using the helper in tmux config)
  local cpu_usage = vim.fn.system("cut -c3- ~/.tmux.conf.local | sh -s cpu_usage"):gsub("\n", "")
  if cpu_usage ~= "" then
    -- Escape % for statusline
    cache.cpu = "󰻠 " .. cpu_usage:gsub("%%", "%%%%")
  end

  -- RAM
  local ram_usage = vim.fn.system("free -m | awk '/Mem:/ { printf \"%dMB\", $3 }'"):gsub("\n", "")
  if ram_usage ~= "" then
    cache.ram = "󰍛 " .. ram_usage
  end
end

function M.battery()
  update_cache()
  return cache.battery
end

function M.cpu()
  update_cache()
  return cache.cpu
end

function M.ram()
  update_cache()
  return cache.ram
end

function M.temp()
  update_cache()
  return cache.temp
end

return M
