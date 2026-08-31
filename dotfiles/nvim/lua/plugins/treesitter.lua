if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true, -- enable/disable treesitter based highlighting
      indent = true, -- enable/disable treesitter based indentation
      auto_install = true, -- enable/disable automatic installation of detected languages
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
  },
}
