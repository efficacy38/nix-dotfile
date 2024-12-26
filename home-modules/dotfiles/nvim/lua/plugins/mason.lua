-- Customize Mason plugins
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local disable_auto_install = function(_, opts)
	local core = require("astrocore")
	local data_dir = vim.fn.stdpath("data")
	suggested_packages = core.list_insert_unique(suggested_packages, opts.ensure_installed or {})
	local f = io.open(data_dir .. "/suggested-pkgs.json", "w")
	-- print(dump(suggested_packages))

	f:write(vim.fn.json_encode(suggested_packages))
	f:close()

	opts.ensure_installed = {}
end


---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    -- opts = function(_, opts)
    --   -- add more things to the ensure_installed table protecting against community packs modifying it
    --   opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
    --     -- add more arguments for adding more language servers
    --   })
    --   opts.automatic_installation = true
    -- end,
    opts = disable_auto_install,
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    -- opts = function(_, opts)
    --   -- add more things to the ensure_installed table protecting against community packs modifying it
    --   opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
    --     -- NOTE: geenral purpose language servers
    --     "asmfmt",
    --     "lua_ls",
    --     "stylua",
    --     "python",
    --     "pyright",
    --     "debugpy",
    --     "rust_analyzer",
    --     "delve",
    --     "templ",
    --     "cmakelang",
    --     "bash-language-server",
    --     "shellcheck",
    --     -- NOTE: web language linters
    --     "markdownlint",
    --     "markuplint",
    --     -- NOTE: infra language linter
    --     "yaml-language-server",
    --     "yamllint",
    --     "tflint",
    --     "jsonnet-language-server",
    --     "terraformls",
    --     "jinjalint",
    --     "ansible-lint",
    --     -- NOTE: code quality tools
    --     "prittier",
    --     "sonarlint",
    --     "semgrep",
    --     "write-good",
    --     "typo",
    --     "typo-lsp",
    --     "prettier",
    --     "stylua",
    --     "gitleaks",
    --     -- add more arguments for adding more null-ls sources
    --   })
    -- end,
    opts = disable_auto_install,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    -- opts = function(_, opts)
    --   -- add more things to the ensure_installed table protecting against community packs modifying it
    --   opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
    --     "python",
    --     -- add more arguments for adding more debuggers
    --   })
    -- end,
    opts = disable_auto_install,
  },
}
