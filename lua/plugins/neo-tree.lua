---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["<tab>"] = "toggle_preview", -- Preview file temporarily
        ["<cr>"] = "open", -- Open file permanently (creates buffer)
      },
    },
    filesystem = {
      filtered_items = {
        visible = true, -- This enables visibility toggling
        hide_dotfiles = false, -- This ensures dotfiles are shown by default
        hide_gitignored = false, -- optional, hides gitignored files by default
      },
      -- use_libuv_file_watcher = true,
    },
  },
}
