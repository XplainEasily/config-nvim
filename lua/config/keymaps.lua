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

-- Open current file in GitLab or GitHub at the current line
vim.keymap.set("n", "<leader>go", function()
  local abs_path = vim.fn.expand("%:p")
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" or vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  local remote_url = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " remote get-url origin")[1]
  if not remote_url or remote_url == "" then
    vim.notify("No git remote 'origin' found", vim.log.levels.ERROR)
    return
  end

  -- Normalize remote URL (SSH or HTTPS) to a base web URL
  local web_url = remote_url
    :gsub("^git@([^:]+):", "https://%1/")
    :gsub("%.git$", "")

  local branch = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " rev-parse --abbrev-ref HEAD")[1]
  local rel_path = abs_path:gsub("^" .. vim.pesc(git_root) .. "/", "")
  local line = vim.fn.line(".")

  local file_url
  if web_url:find("github%.com") then
    file_url = web_url .. "/blob/" .. branch .. "/" .. rel_path .. "#L" .. line
  else
    -- GitLab
    file_url = web_url .. "/-/blob/" .. branch .. "/" .. rel_path .. "#L" .. line
  end

  vim.fn.jobstart({ "open", file_url }, { detach = true })
  vim.notify("Opening: " .. file_url)
end, { desc = "Open file in GitLab/GitHub" })

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
