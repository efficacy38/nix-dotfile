-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
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
        -- "graphql",
        -- "css",
        -- "vue",
        -- "php",
        -- "scss",
        -- "tsx",
        -- "typescript",
        -- "rescript",
        -- "svelte",
        -- "twig",
      -- infra languages(IAC)
      "terraform",
      "yaml",
      "json",
      "jsonnet",
      "jsonc",
      -- other languages
      "markdown",
    })
  end,
}
