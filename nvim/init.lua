-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("helm_values")
vim.cmd('command! ShowValues lua require("helm_values").show_values()')
