-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Fix cursor visibility on rose-pine-dawn
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    if vim.g.colors_name == "rose-pine-dawn" then
      vim.api.nvim_set_hl(0, "Cursor", { fg = "#faf4ed", bg = "#286983" })
      vim.api.nvim_set_hl(0, "iCursor", { fg = "#faf4ed", bg = "#d7827e" })
      vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-iCursor,r-cr:hor20-Cursor"
    end
  end,
})

-- Enable spell checking for markdown files inside the vault
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = vim.fn.expand("~/Mon_Drive/SecondBrain") .. "/**/*.md",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "fr,en"
  end,
})
