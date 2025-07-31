---@type LazySpec
return {
  "folke/zen-mode.nvim",
  keys = {
    { "<leader>zm", function() require("zen-mode").toggle() end, desc = "Toggle Zen (maximize window)" },
  },
}
