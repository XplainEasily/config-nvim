-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Enable spell checking for markdown files inside the vault
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = vim.fn.expand("~/SecondBrain") .. "/**/*.md",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "fr,en"
  end,
})
