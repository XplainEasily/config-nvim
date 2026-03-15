return {
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  {
    "rebelot/kanagawa.nvim",
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  { "yonlu/omni.vim" },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      highlight_groups = {
        Cursor = { fg = "base", bg = "pine" },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "omni",
    },
  },

  { "Mofiqul/dracula.nvim" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-dawn",
    },
  },
}
