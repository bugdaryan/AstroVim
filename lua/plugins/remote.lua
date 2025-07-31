-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "hmk114/remote-nvim.nvim",
  version = "*",
  opts = {
    -- everything else can stay at its default
    remote = {
      -- optional but recommended so the remote gets all your plugins too
      copy_dirs = {
        data = { -- send the plugin manager cache
          base = vim.fn.stdpath "data",
          dirs = { "lazy" }, -- adjust if you use paq, packer, etc.
          compression = { enabled = true },
        },
      },
    },
  },
  config = true,
}
