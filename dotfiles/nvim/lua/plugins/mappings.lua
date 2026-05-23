return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
            ["<Leader>r"] = {
              function()
                local file = vim.fn.expand("%")          -- Full file name (main.cpp)
                local extension = vim.fn.expand("%:e")   -- Extension (cpp or c)
                local binary = vim.fn.expand("%:r")      -- File without extension (main)
                local compiler = ""
                -- Logic to distinguish between C and C++
                if extension == "cpp" or extension == "cc" then
                  compiler = "g++"
                elseif extension == "c" then
                  compiler = "gcc"
                else
                  print("Not a C or C++ file")
                  return
                end
                -- Save, Compile, and Run using ToggleTerm's TermExec
                vim.cmd("write")
                local cmd = string.format("%s %s -o %s && %s", compiler, file, binary, binary)
                local total_columns = vim.o.columns
                local target_size = total_columns - 90
                vim.cmd("TermExec cmd='" .. cmd .. "'" .. "' direction=vertical size=" .. target_size)
              end,
              desc = "Compile and Run (C/C++)",
            },
          },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  }
}
