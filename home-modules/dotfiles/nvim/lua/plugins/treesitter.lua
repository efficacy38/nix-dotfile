-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      -- scripting languages
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "astro",
      -- basic coding languages
      "c",
      "rust",
      "python",
      -- web languages
      "html",
      "javascript",
      "graphql",
      "css",
      "vue",
      "php",
      "scss",
      "tsx",
      "typescript",
      "rescript",
      "svelte",
      "twig",
      -- infra languages(IAC)
      "terraform",
      "yaml",
      "json",
      "jsonnet",
      "jsonc",
      -- other languages
      "markdown",
    },
  },
}
