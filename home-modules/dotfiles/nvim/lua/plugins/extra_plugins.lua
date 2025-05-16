return {
  {
    "olexsmir/gopher.nvim",
    event = "User LazyDone",
    ft = "go",
    config = function(_, opts) require("gopher").setup(opts) end,
    build = function() vim.cmd [[silent! GoUpdateBinaries]] end,
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
