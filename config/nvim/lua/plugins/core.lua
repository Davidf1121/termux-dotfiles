return {
  -- Tokyo Night Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local sys = require("config.sysinfo")
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "filename", "branch" },
          lualine_c = { 
            { "diff" },
            { "diagnostics" },
          },
          lualine_x = {
            { sys.battery, color = { fg = "#7aa2f7" } },
            { sys.cpu, color = { fg = "#bb9af7" } },
            { sys.ram, color = { fg = "#c0caf5" } },
            { sys.temp, color = { fg = "#e0af68" } },
          },
          lualine_y = { "filetype", "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
      })
    end,
  },

  -- Bufferline (Tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({})
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, treesitter = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      treesitter.setup({
        ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python" },
        highlight = { enable = true },
      })
    end,
  },
}
