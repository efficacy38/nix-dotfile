if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason
function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local disable_auto_install = function(_, opts)
  local core = require "astrocore"
  local data_dir = vim.fn.stdpath "data"
  suggested_packages = core.list_insert_unique(suggested_packages, opts.ensure_installed or {})
  local f = io.open(data_dir .. "/suggested-pkgs.json", "w")
  -- print(dump(suggested_packages))

  f:write(vim.fn.json_encode(suggested_packages))
  f:close()

  opts.ensure_installed = {}
end

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = disable_auto_install,
  },
}

-- ---@type LazySpec
-- return {
--   -- use mason-tool-installer for automatically installing Mason packages
--   {
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--     -- overrides `require("mason-tool-installer").setup(...)`
--     opts = {
--       -- Make sure to use the names found in `:Mason`
--       ensure_installed = {
--         -- install language servers
--         "lua-language-server",
--
--         -- install formatters
--         "stylua",
--
--         -- install debuggers
--         "debugpy",
--
--         -- install any other package
--         "tree-sitter-cli",
--       },
--     },
--   },
-- }
