return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = {
      pickers = {
        colorscheme = {
          -- This is the line you need to add
          enable_preview = true,
        },
      },
    },
  },
}
