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
  local suggested_packages = core.list_insert_unique(nil, opts.ensure_installed or {})
  local f = io.open(data_dir .. "/suggested-pkgs.json", "w")
  -- print(dump(suggested_packages))

  f:write(vim.fn.json_encode(suggested_packages))
  f:close()

  opts.ensure_installed = {}
  opts.run_on_start = false
end

---@type LazySpec
return {
  -- Capture AstroCommunity's suggested packages without installing them through Mason.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = disable_auto_install,
  },
  {
    "williamboman/mason.nvim",
    opts = { PATH = "skip" },
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
