return {
  "XplainEasily/pg_nvim",
  branch = "main",
  cmd = { "PgOpen", "PgQuery", "PgExplorer", "PgDisconnect" },
  keys = {
    {
      "<leader>pg",
      function()
        require("pg_nvim").toggle()
      end,
      desc = "PostgreSQL Client",
    },
  },
  opts = {
    psql_path = "psql",
    max_rows = 500,
    max_col_width = 40,
    table_style = "rounded",
  },
  config = function(_, opts)
    require("pg_nvim").setup(opts)
  end,
}
