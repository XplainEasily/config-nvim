local secondbrain_path = vim.fn.expand("~/Mon_Drive/SecondBrain")

local function in_secondbrain(bufnr)
  return vim.startswith(vim.api.nvim_buf_get_name(bufnr or 0), secondbrain_path)
end

local function project_formatter(bufnr)
  -- Check for oxfmt config (millenium project uses this now)
  local has_oxfmt = vim.fs.find({ ".oxfmtrc.json" }, { upward = true })[1]
  if has_oxfmt then
    return { "oxfmt" }
  end

  -- Check for biome LSP (other projects)
  local has_biome_lsp = vim.lsp.get_clients({
    bufnr = bufnr,
    name = "biome",
  })[1]
  if has_biome_lsp then
    return {}
  end

  -- Check for prettier (fallback)
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

local oxfmt_config = vim.fn.expand("~/Mon_Drive/SecondBrain/.oxfmtrc.json")

return {
  -- Use Biome for most files, ESLint for JSX/TSX
  -- In SecondBrain vault: oxfmt for markdown/sh, oxlint for linting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        -- Default oxfmt (auto-discovers .oxfmtrc.json in project)
        oxfmt = {
          command = "oxfmt",
          args = { "--stdin-filepath", "$FILENAME" },
          stdin = true,
        },
        -- Pinned oxfmt for SecondBrain (never picks up parent project configs)
        oxfmt_secondbrain = {
          command = "oxfmt",
          args = { "--stdin-filepath", "$FILENAME", "-c", oxfmt_config },
          stdin = true,
        },
      },
      formatters_by_ft = {
        ["javascript"] = project_formatter,
        ["javascriptreact"] = { "eslint_d" },
        ["typescript"] = project_formatter,
        ["typescriptreact"] = { "eslint_d" },
        ["vue"] = project_formatter,
        ["css"] = project_formatter,
        ["scss"] = project_formatter,
        ["less"] = project_formatter,
        ["html"] = project_formatter,
        ["json"] = project_formatter,
        ["jsonc"] = project_formatter,
        ["yaml"] = project_formatter,
        ["markdown"] = function(bufnr)
          if in_secondbrain(bufnr) then
            local filepath = vim.api.nvim_buf_get_name(bufnr)
            local templates_path = vim.fn.expand("~/Mon_Drive/SecondBrain/Templates/")
            if vim.startswith(filepath, templates_path) then
              return {}
            end
            return { "oxfmt_secondbrain" }
          end
          return project_formatter(bufnr)
        end,
        ["markdown.mdx"] = project_formatter,
        ["graphql"] = project_formatter,
        ["handlebars"] = project_formatter,
        ["sh"] = function(bufnr)
          if in_secondbrain(bufnr) then
            return { "oxfmt_secondbrain" }
          end
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
            -- Skip Templates/ directory
            local filepath = vim.api.nvim_buf_get_name(bufnr)
            local templates_path = vim.fn.expand("~/Mon_Drive/SecondBrain/Templates/")
            if not vim.startswith(filepath, templates_path) then
              lint.try_lint({ "oxlint" })
            end
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
