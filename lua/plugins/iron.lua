if true then return {} end -- disabled: replaced by molten-nvim (see molten.lua)

---@type LazySpec
return {
  "hkupty/iron.nvim",
  config = function()
    require("iron.core").setup {
      config = {
        repl_definition = {
          python = { command = { "python" } },
        },
        repl_open_cmd = require("iron.view").split.vertical.botright(0.3),
      },
      keymaps = {
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_mark = "<space>sm",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",
        exit = "<space>sq",
        clear = "<space>cl",
      },
      highlight = { italic = true },
      ignore_blank_lines = true,
    }
  end,
}
