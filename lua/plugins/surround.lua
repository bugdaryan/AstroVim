---@type LazySpec
return {
  "kylechui/nvim-surround",
  version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup {
      surrounds = {
        ["("] = { add = { "(", ")" } },
        ["["] = { add = { "[", "]" } },
        ["{"] = { add = { "{", "}" } },
      },
    }
  end,
}
