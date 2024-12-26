# if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.ansible" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.git.blame-nvim" },
  -- import/override with your plugins folder
}
