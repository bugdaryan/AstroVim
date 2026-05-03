if true then return {} end -- disabled: revisit later; iron.nvim re-enabled for now

-- Jupyter-kernel-based REPL for Python with inline image output.
-- Requires (in the Python env you `:MoltenInit` from):
--   pip install pynvim jupyter_client ipykernel cairosvg pnglatex pyperclip nbformat
-- Plus a kitty-protocol terminal (you're on kitty) and ImageMagick installed system-wide
-- (e.g. `sudo apt install libmagickwand-dev imagemagick`).
-- After first install, run `:UpdateRemotePlugins` and restart nvim.

---@type LazySpec
return {
  -- Bootstraps luarocks inside Neovim so image.nvim's `magick` rock can be installed.
  {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    lazy = false,
    opts = {
      rocks = { "magick" },
    },
  },

  {
    "3rd/image.nvim",
    dependencies = { "vhyrro/luarocks.nvim" },
    opts = {
      backend = "kitty",
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    ft = { "python" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = true
      vim.g.molten_output_show_more = true
    end,
    keys = {
      -- mirror iron.nvim bindings
      { "<leader>sc", ":MoltenEvaluateOperator<CR>", desc = "Evaluate operator (motion)", silent = true },
      { "<leader>sc", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Evaluate visual selection", silent = true },
      { "<leader>sl", ":MoltenEvaluateLine<CR>", desc = "Evaluate current line", silent = true },
      {
        "<leader>sf",
        function() vim.cmd("1," .. vim.api.nvim_buf_line_count(0) .. "MoltenEvaluateRange") end,
        desc = "Evaluate whole file",
        silent = true,
      },
      { "<leader>s<space>", ":MoltenInterrupt<CR>", desc = "Interrupt kernel", silent = true },
      { "<leader>sq", ":MoltenDeinit<CR>", desc = "Stop kernel for buffer", silent = true },
      { "<leader>s<CR>", ":MoltenReevaluateCell<CR>", desc = "Re-evaluate last cell", silent = true },
      { "<leader>cl", ":MoltenHideOutput<CR>", desc = "Hide output window", silent = true },

      -- molten-only additions
      { "<leader>si", ":MoltenInit<CR>", desc = "Initialize Jupyter kernel", silent = true },
      { "<leader>so", ":MoltenShowOutput<CR>", desc = "Show output window", silent = true },
      { "<leader>se", ":noautocmd MoltenEnterOutput<CR>", desc = "Enter output (scroll)", silent = true },
    },
  },
}
