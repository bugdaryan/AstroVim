-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "chipsenkbeil/distant.nvim",
  branch = "v0.3",
  config = function() require("distant"):setup() end,
}
