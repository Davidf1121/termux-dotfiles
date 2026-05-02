return {
  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Commenting with gcc
  {
    "numToStr/Comment.nvim",
    config = true,
  },

  -- Discord Rich Presence
  -- {
  --   "lipeedev/termuxcord.nvim",
  --   config = function()
  --     require("termuxcord").setup({
  --       -- NOTE: You must join their Discord server for this to work.
  --       -- See: https://github.com/lipeedev/termuxcord.nvim
  --       -- token = "YOUR_DISCORD_TOKEN_HERE", -- Your Discord user token (DO NOT COMMIT SECRETS)
  --       application_id = "1098418041926225960", -- Default ID
  --       title = "Termux Neovim",
  --       state = "Coding in %w",
  --       details = "Editing %f",
  --     })
  --   end,
  -- },
}
