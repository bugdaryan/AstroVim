---@type LazySpec
return {
  "PedramNavid/dbtpal",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  ft = {
    "sql",
    "md",
    "yaml",
    "yml",
  },
  keys = {
    { "<leader>drf", "<cmd>DbtRun<cr>" },
    { "<leader>drp", "<cmd>DbtRunAll<cr>" },
    { "<leader>dtf", "<cmd>DbtTest<cr>" },
    { "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
  },
  config = function()
    require("dbtpal").setup {
      path_to_dbt = "dbt",
      path_to_dbt_project = "/home/spartak/Documents/repos/data_elt/dbt",
      path_to_dbt_profiles_dir = "/home/spartak/Documents/repos/data_elt/dbt/config",
      include_profiles_dir = true,
      include_project_dir = true,
      include_log_level = true,
      extended_path_search = true,
      protect_compiled_files = true,
      pre_cmd_args = {},
      post_cmd_args = {},
    }
    require("telescope").load_extension "dbtpal"
  end,
}
