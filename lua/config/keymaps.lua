-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy current file path and cursor position (e.g. src/foo/bar.ts:42:7)
vim.keymap.set("n", "<leader>yf", function()
  local path = vim.fn.expand("%:t")
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local result = path .. ":" .. line .. ":" .. col
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result)
end, { desc = "Yank file path and cursor position" })

-- Copy path relative to git root and cursor position (e.g. src/foo/bar.ts:42:7)
vim.keymap.set("n", "<leader>yF", function()
  local abs_path = vim.fn.expand("%:p")
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local path
  if git_root and git_root ~= "" and vim.v.shell_error == 0 then
    path = abs_path:gsub("^" .. vim.pesc(git_root) .. "/", "")
  else
    path = abs_path:gsub("^" .. vim.env.HOME, "~")
  end
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  local result = path .. ":" .. line .. ":" .. col
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result)
end, { desc = "Yank git-relative path and cursor position" })
