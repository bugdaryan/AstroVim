-- Video playback via mpv.
--
-- Why not `:!mpv` inline? Neovim's :! doesn't give mpv a clean terminal
-- for Kitty's startup capability query, so mpv exits immediately.
-- Why not :terminal? Neovim's terminal buffer doesn't passthrough
-- Kitty's graphics protocol.
--
-- So: spawn mpv detached. Locally that means a new Kitty window
-- (`kitty mpv ...`). Over SSH there is no local kitty to spawn, so we
-- fall back to a foreground :! and hope the terminal cooperates.

local video_exts = {
  mp4 = true, mkv = true, webm = true, mov = true, avi = true,
  flv = true, wmv = true, m4v = true, mpg = true, mpeg = true,
  ["3gp"] = true, ogv = true, ts = true,
}

local function is_ssh()
  return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil
end

local function play(file)
  file = vim.fn.fnamemodify(vim.fn.expand(file), ":p")
  if vim.fn.filereadable(file) == 0 then
    vim.notify("Video not found: " .. file, vim.log.levels.ERROR)
    return
  end

  if not is_ssh() and vim.fn.executable("kitty") == 1 then
    vim.fn.jobstart({ "kitty", "mpv", file }, { detach = true })
    return
  end

  -- SSH fallback: foreground :! with --vo=kitty.
  vim.cmd("!mpv --vo=kitty " .. vim.fn.shellescape(file))
  vim.cmd("redraw!")
end

vim.api.nvim_create_user_command("Video", function(o) play(o.args) end, {
  nargs = 1,
  complete = function(arg) return vim.fn.getcompletion(arg, "file") end,
  desc = "Play video with mpv (new kitty window locally, :! over SSH)",
})

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = vim.tbl_map(function(e) return "*." .. e end, vim.tbl_keys(video_exts)),
  callback = function(ev)
    vim.schedule(function()
      vim.api.nvim_buf_delete(ev.buf, { force = true })
      play(ev.file)
    end)
  end,
})

---@type LazySpec
return {}
