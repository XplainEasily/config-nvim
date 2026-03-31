return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  opts = {
    legacy_commands = false,

    picker = {
      name = "snacks.pick",
    },

    workspaces = {
      {
        name = "second-brain",
        path = "~/Mon_Drive/SecondBrain",
      },
    },

    daily_notes = {
      folder = "06-Daily",
      date_format = "%Y-%m-%d",
      template = "daily.md",
      workdays_only = false,
    },

    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    notes_subdir = "00-Inbox",
    new_notes_location = "notes_subdir",

    completion = {
      nvim_cmp = false,
      blink = false,
      min_chars = 2,
    },

    frontmatter = {
      func = function(note)
        local out = { tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
    },

    note_id_func = function(title)
      local date = os.date("%Y-%m-%d")
      local suffix = ""
      if title ~= nil then
        suffix =
          title:gsub(" ", "-"):gsub("[^A-Za-z0-9-àâéèêëïîôùûüÿçÀÂÉÈÊËÏÎÔÙÛÜŸÇ]", ""):lower()
      else
        suffix = tostring(os.time())
      end
      return date .. "_" .. suffix
    end,
  },

  keys = {
    { "<leader>oo", "<cmd>Obsidian open<CR>", desc = "Ouvrir dans Obsidian" },
    { "<leader>on", "<cmd>Obsidian new<CR>", desc = "Nouvelle note" },
    { "<leader>od", "<cmd>Obsidian today<CR>", desc = "Note du jour" },
    { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = "Note d'hier" },
    { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Rechercher" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<CR>", desc = "Quick switch" },
    { "<leader>ot", "<cmd>Obsidian tags<CR>", desc = "Chercher par tag" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Voir backlinks" },
    { "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Voir liens sortants" },
    { "<leader>om", "<cmd>Obsidian template<CR>", desc = "Insérer template" },
    { "<leader>op", "<cmd>Obsidian paste_img<CR>", desc = "Coller une image" },
    { "gf", "<cmd>Obsidian follow_link<CR>", desc = "Follow link" },
    { "<leader>ti", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle checkbox" },
    -- format title: strip date prefix and replace dashes with spaces (cursor must be on title line)
    { "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<CR>", desc = "Format titre" },
    -- move current note to notesToTidyUp for later review
    {
      "<leader>ok",
      function()
        local path = vim.fn.expand("%:p")
        vim.cmd("silent !mv '" .. path .. "' ~/Mon_Drive/SecondBrain/notesToTidyUp/")
        vim.cmd("bd")
      end,
      desc = "Déplacer vers notesToTidyUp",
    },
    -- delete current note
    {
      "<leader>odd",
      function()
        local path = vim.fn.expand("%:p")
        vim.fn.delete(path)
        vim.cmd("bd")
      end,
      desc = "Supprimer la note",
    },
    -- open all inbox files as buffers for end-of-day triage
    {
      "<leader>oi",
      function()
        local inbox = vim.fn.expand("~/Mon_Drive/SecondBrain/00-Inbox")
        local files = vim.fn.glob(inbox .. "/*.md", false, true)
        if #files == 0 then
          vim.notify("Inbox vide ✓", vim.log.levels.INFO, { title = "Inbox" })
          return
        end
        for _, f in ipairs(files) do
          vim.cmd("badd " .. vim.fn.fnameescape(f))
        end
        vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
        vim.notify(#files .. " note(s) dans l'inbox", vim.log.levels.INFO, { title = "Inbox" })
      end,
      desc = "Ouvrir inbox pour triage",
    },
    -- live grep across the entire vault regardless of cwd
    {
      "<leader>oz",
      function()
        Snacks.picker.grep({ cwd = vim.fn.expand("~/Mon_Drive/SecondBrain") })
      end,
      desc = "Grep vault",
    },
    -- run organize script: moves notes from notesToTidyUp to PARA folders by tag
    {
      "<leader>og",
      function()
        local output = vim.fn.system("zsh ~/Mon_Drive/SecondBrain/scripts/organize.sh")
        vim.notify(output, vim.log.levels.INFO, { title = "Vault organisé" })
      end,
      desc = "Organiser le vault",
    },
    -- run finance-sync script: update totals in depense/budget frontmatter
    {
      "<leader>oe",
      function()
        local script = vim.fn.expand("~/Mon_Drive/SecondBrain/scripts/finance-sync.sh")
        local output = vim.fn.system("zsh " .. script)
        local ok = vim.v.shell_error == 0
        -- reload current buffer so frontmatter changes are visible
        vim.cmd("checktime")
        vim.notify(output, ok and vim.log.levels.INFO or vim.log.levels.ERROR, { title = "Finance sync" })
      end,
      desc = "Sync finances",
    },
    -- create/open monthly expense note
    {
      "<leader>oF",
      function()
        local mois_fr = {
          "janvier", "fevrier", "mars", "avril", "mai", "juin",
          "juillet", "aout", "septembre", "octobre", "novembre", "decembre",
        }
        local y = os.date("%Y")
        local m = tonumber(os.date("%m"))
        local nom = mois_fr[m]
        local filename = y .. "-" .. string.format("%02d", m) .. "-01_depenses-" .. nom .. ".md"
        local vault = vim.fn.expand("~/Mon_Drive/SecondBrain")
        local filepath = vault .. "/02-Areas/perso/finances/depenses/" .. filename
        if vim.fn.filereadable(filepath) == 1 then
          vim.cmd("edit " .. filepath)
        else
          vim.cmd("ObsidianNew " .. filename)
          vim.cmd("ObsidianTemplate depense.md")
          vim.cmd("silent !mv '" .. vault .. "/00-Inbox/" .. filename .. "' '" .. filepath .. "'")
          vim.cmd("edit " .. filepath)
        end
      end,
      desc = "Depenses du mois",
    },
  },
}
