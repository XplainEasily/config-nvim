local secondbrain_path = vim.fn.expand("~/SecondBrain")

local function in_secondbrain(bufnr)
  return vim.startswith(vim.api.nvim_buf_get_name(bufnr or 0), secondbrain_path)
end

local function biome_lsp_or_prettier(bufnr)
  local has_biome_lsp = vim.lsp.get_clients({
    bufnr = bufnr,
    name = "biome",
  })[1]
  if has_biome_lsp then
    return {}
  end
  local has_prettier = vim.fs.find({
    -- https://prettier.io/docs/en/configuration.html
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
  }, { upward = true })[1]
  if has_prettier then
    return { "prettier" }
  end
  return { "biome" }
end

local oxfmt_config = vim.fn.expand("~/SecondBrain/.oxfmtrc.json")

return {
  -- Use Biome for most files, ESLint for JSX/TSX
  -- In SecondBrain vault: oxfmt for markdown/sh, oxlint for linting
  {
    "stevearc/conform.nvim",
    opts = {
      -- Pin oxfmt to the SecondBrain config so it never picks up parent project configs
      formatters = {
        oxfmt = {
          command = "oxfmt",
          args = { "--stdin-filepath", "$FILENAME", "-c", oxfmt_config },
          stdin = true,
        },
      },
      formatters_by_ft = {
        ["javascript"] = biome_lsp_or_prettier,
        ["javascriptreact"] = { "eslint_d" },
        ["typescript"] = biome_lsp_or_prettier,
        ["typescriptreact"] = { "eslint_d" },
        ["vue"] = { "biome" },
        ["css"] = { "biome" },
        ["scss"] = { "biome" },
        ["less"] = { "biome" },
        ["html"] = { "biome" },
        ["json"] = { "biome" },
        ["jsonc"] = { "biome" },
        ["yaml"] = { "biome" },
        ["markdown"] = function(bufnr)
          if in_secondbrain(bufnr) then return { "oxfmt" } end
          return { "biome" }
        end,
        ["markdown.mdx"] = { "biome" },
        ["graphql"] = { "biome" },
        ["handlebars"] = { "biome" },
        ["sh"] = function(bufnr)
          if in_secondbrain(bufnr) then return { "oxfmt" } end
          return {}
        end,
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local ft = vim.bo[bufnr].filetype
          if in_secondbrain(bufnr) and (ft == "markdown" or ft == "sh") then
            lint.try_lint({ "oxlint" })
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "biome",
        "eslint_d",
        "oxlint",
        "oxfmt",
      },
    },
  },
}
