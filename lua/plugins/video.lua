-- Video playback via mpv + Kitty graphics protocol.
-- Uses `:!` to hand mpv the real terminal — Neovim's :terminal buffer
-- does NOT passthrough Kitty's graphics protocol, so playing "inside" a
-- nvim window doesn't work. Instead we suspend the UI, mpv takes over
-- the Kitty window, and on `q` we redraw.
--
-- Provides :Video and a BufReadCmd autocmd so opening a video file from
-- neo-tree / a picker just plays it.
--
-- Requires: kitty (local), mpv (on whichever host nvim is running on).
-- Inside tmux: set `allow-passthrough on` in ~/.tmux.conf.

---@type LazySpec
return {
  "folke/lazy.nvim",
  init = function()
    local video_exts = {
      mp4 = true, mkv = true, webm = true, mov = true, avi = true,
      flv = true, wmv = true, m4v = true, mpg = true, mpeg = true,
      ["3gp"] = true, ogv = true, ts = true,
    }

    local function play(file)
      file = vim.fn.fnamemodify(vim.fn.expand(file), ":p")
      if vim.fn.filereadable(file) == 0 then
        vim.notify("Video not found: " .. file, vim.log.levels.ERROR)
        return
      end
      -- `:!` suspends nvim and gives mpv the real TTY (Kitty), so
      -- --vo=kitty graphics escapes reach the terminal.
      vim.cmd("silent !mpv --vo=kitty " .. vim.fn.shellescape(file))
      vim.cmd("redraw!")
    end

    local function complete(arg) return vim.fn.getcompletion(arg, "file") end

    vim.api.nvim_create_user_command("Video", function(o) play(o.args) end,
      { nargs = 1, complete = complete, desc = "Play video with mpv + kitty" })

    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = vim.tbl_map(function(e) return "*." .. e end, vim.tbl_keys(video_exts)),
      callback = function(ev)
        vim.schedule(function()
          vim.api.nvim_buf_delete(ev.buf, { force = true })
          play(ev.file)
        end)
      end,
    })
  end,
}
