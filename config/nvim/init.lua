-- bootstrap lazy.nvim, options and keymaps
vim.opt.termguicolors = true
vim.opt.background = "dark"

require("config.lazy")
require("config.options")
require("config.keymaps")

-- Set colorscheme last
vim.cmd([[colorscheme tokyonight]])
