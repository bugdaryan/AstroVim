-- Video playback inside Neovim via mpv + Kitty graphics protocol.
-- Provides :Video and :VideoFloat commands, and auto-opens common video
-- filetypes with mpv when you `:edit` them.
--
-- Requires: kitty, mpv, ffmpeg (already installed on this machine).
-- Inside tmux, also set `allow-passthrough on` in ~/.tmux.conf.

---@type LazySpec
return {
  "folke/lazy.nvim", -- noop anchor; the real work is in init below
  init = function()
    local video_exts = {
      mp4 = true, mkv = true, webm = true, mov = true, avi = true,
      flv = true, wmv = true, m4v = true, mpg = true, mpeg = true,
      ["3gp"] = true, ogv = true, ts = true,
    }

    local function play(file, opts)
      opts = opts or {}
      file = vim.fn.fnamemodify(vim.fn.expand(file), ":p")
      if vim.fn.filereadable(file) == 0 then
        vim.notify("Video not found: " .. file, vim.log.levels.ERROR)
        return
      end

      local cmd = {
        "mpv", "--vo=kitty", "--really-quiet", "--no-input-terminal", file,
      }

      if opts.float then
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = math.floor((vim.o.columns - width) / 2),
          row = math.floor((vim.o.lines - height) / 2),
          style = "minimal",
          border = "rounded",
          title = " " .. vim.fn.fnamemodify(file, ":t") .. " ",
          title_pos = "center",
        })
      else
        vim.cmd("botright split | resize " .. math.floor(vim.o.lines * 0.6))
      end

      vim.fn.termopen(cmd, {
        on_exit = function()
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(0) then vim.cmd("bd!") end
          end)
        end,
      })
      vim.cmd("startinsert")
    end

    local function complete(arg) return vim.fn.getcompletion(arg, "file") end

    vim.api.nvim_create_user_command("Video", function(o) play(o.args, { float = false }) end,
      { nargs = 1, complete = complete, desc = "Play video in a split (mpv + kitty)" })

    vim.api.nvim_create_user_command("VideoFloat", function(o) play(o.args, { float = true }) end,
      { nargs = 1, complete = complete, desc = "Play video in a floating window" })

    -- Auto-handle when you `:edit foo.mp4` or open one from a picker/file tree
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = vim.tbl_map(function(e) return "*." .. e end, vim.tbl_keys(video_exts)),
      callback = function(ev)
        vim.schedule(function()
          vim.api.nvim_buf_delete(ev.buf, { force = true })
          play(ev.file, { float = true })
        end)
      end,
    })
  end,
}
