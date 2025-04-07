return {
  -- {
  --   "mrcjkb/rustaceanvim",
  --   version = "^4", -- Recommended
  --   ft = { "rust" },
  --   event = "BufRead",
  -- },
  {
    "olexsmir/gopher.nvim",
    event = "User LazyDone",
    ft = "go",
    config = function(_, opts) require("gopher").setup(opts) end,
    build = function() vim.cmd [[silent! GoUpdateBinaries]] end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        {
          panel = {
            enabled = true,
            auto_refresh = true,
            keymap = {
              jump_prev = "[[",
              jump_next = "]]",
              accept = "<CR>",
              refresh = "gr",
              open = "<M-CR>",
            },
            layout = {
              position = "bottom", -- | top | left | right
              ratio = 0.4,
            },
          },
          suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
              accept = "<C-l>",
              accept_word = false,
              accept_line = false,
              next = "<C-]>",
              prev = "<C-[>",
              dismiss = "<C-d>",
            },
          },
          filetypes = {
            -- yaml = false,
            markdown = false,
            help = false,
            gitcommit = false,
            gitrebase = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            ["."] = true,
          },
          copilot_node_command = "node", -- Node.js version must be > 18.x
          copilot_model = "gpt-4o-copilot",
          server_opts_overrides = {},
        },
      }
    end,
  },
  {
    "mbbill/undotree",
    -- opts = {},
    init = function()
      vim.g.undotree_HelpLine = 0
      vim.g.undotree_ShortIndicators = 1
    end,
    event = "User AstroFile",
    keys = {
      { "<leader>U", ":UndotreeToggle<CR>" },
    },
  },
  { "folke/tokyonight.nvim" },
}
