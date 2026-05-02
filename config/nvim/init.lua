-- bootstrap lazy.nvim, options and keymaps
require("config.lazy")
require("config.options")
require("config.keymaps")

-- Set colorscheme last
vim.cmd([[colorscheme tokyonight]])
