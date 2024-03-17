
if vim.g.loaded_go_back_plugin then
	return
end
vim.g.loaded_go_back_plugin = true

require("go-back").setup({ excesive_logging = true })

