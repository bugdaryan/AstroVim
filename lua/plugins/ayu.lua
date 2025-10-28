return {
  {
    "Shatur/neovim-ayu", -- This is the plugin from the community pack
    init = function()
      -- Set the variant *before* the colorscheme is loaded
      require("ayu").setup {
        mirage = true, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
        terminal = false, -- Set to `false` to let terminal manage its own colors.
        overrides = {}, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
      }
    end,
  },
}
