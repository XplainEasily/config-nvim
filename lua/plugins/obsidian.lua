return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "hrsh7th/nvim-cmp",
  },
  opts = {
    picker = {
      name = "snacks.picker",
    },

    workspaces = {
      {
        name = "second-brain",
        path = "~/SecondBrain",
      },
    },

    daily_notes = {
      folder = "06-Daily",
      date_format = "%Y-%m-%d",
      template = "daily.md",
    },

    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    new_notes_location = "00-Inbox",

    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    note_frontmatter_func = function(note)
      local out = { tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-àâéèêëïîôùûüÿçÀÂÉÈÊËÏÎÔÙÛÜŸÇ]", ""):lower()
      else
        suffix = tostring(os.time())
      end
      return suffix
    end,
  },

  keys = {
    { "<leader>oo", "<cmd>ObsidianOpen<CR>",           desc = "Ouvrir dans Obsidian" },
    { "<leader>on", "<cmd>ObsidianNew<CR>",             desc = "Nouvelle note" },
    { "<leader>od", "<cmd>ObsidianToday<CR>",           desc = "Note du jour" },
    { "<leader>oy", "<cmd>ObsidianYesterday<CR>",       desc = "Note d'hier" },
    { "<leader>os", "<cmd>ObsidianSearch<CR>",          desc = "Rechercher" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>",     desc = "Quick switch" },
    { "<leader>ot", "<cmd>ObsidianTags<CR>",            desc = "Chercher par tag" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>",       desc = "Voir backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<CR>",           desc = "Voir liens sortants" },
    { "<leader>om", "<cmd>ObsidianTemplate<CR>",        desc = "Insérer template" },
    { "<leader>op", "<cmd>ObsidianPasteImg<CR>",        desc = "Coller image" },
  },
}