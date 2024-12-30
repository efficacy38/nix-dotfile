-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type function|AstroLSPOpts
  opts = function(_, opts)
    -- customization
    opts.formatting = opts.formatting or {}
    opts.servers = opts.servers or {}

    opts.formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          "yaml",
          "sh",
          "md"
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    };

		vim.list_extend(opts.servers, {
			"ansiblels",
			"bashls",
			"clangd",
			"denols",
			"gopls",
			"jsonnet_ls",
			"lua_ls",
			"marksman",
			"nil_ls",
			"ocamllsp",
			"pyright",
			"ruff",
			"rust_analyzer",
			"taplo",
			"terraformls",
			"typos_lsp",
			"yamlls",
			-- add more servers as needed...
		})

		opts.config.clangd = opts.config.clangd or {}
		opts.config.clangd.capabilities = {
			offsetEncoding = "utf-8",
		}
  end
}
