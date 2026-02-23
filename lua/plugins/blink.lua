return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      per_filetype = {
        markdown = { "lsp", "path", "snippets", "buffer", "obsidian", "obsidian_tags", "obsidian_new" },
      },
      providers = {
        obsidian = {
          name = "obsidian",
          module = "obsidian.completion.sources.blink.refs",
        },
        obsidian_tags = {
          name = "obsidian_tags",
          module = "obsidian.completion.sources.blink.tags",
        },
        obsidian_new = {
          name = "obsidian_new",
          module = "obsidian.completion.sources.blink.new",
        },
      },
    },
  },
}
