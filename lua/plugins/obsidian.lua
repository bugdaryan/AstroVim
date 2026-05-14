-- Obsidian integration: edit your vault from Neovim without opening the Obsidian app.
-- Vault: ~/Documents/Obsidian (change `path` under `workspaces` if you move it).

local VAULT = "~/Documents/Obsidian"

-- Return `to` expressed as a relative path from directory `from_dir`.
-- e.g. relpath("/v/20 Permanent", "/v/assets/imgs/x.png") -> "../assets/imgs/x.png"
local function relpath(from_dir, to)
  from_dir = vim.fn.fnamemodify(from_dir, ":p"):gsub("/$", "")
  to = vim.fn.fnamemodify(to, ":p")
  local from_parts = vim.split(from_dir, "/", { plain = true })
  local to_parts = vim.split(to, "/", { plain = true })
  local i = 1
  while i <= #from_parts and i <= #to_parts and from_parts[i] == to_parts[i] do
    i = i + 1
  end
  local out = {}
  for _ = i, #from_parts do table.insert(out, "..") end
  for j = i, #to_parts do table.insert(out, to_parts[j]) end
  return table.concat(out, "/")
end

-- Prompts for a title, fills the template, writes a new note in `folder`, opens it.
-- Templates live in `90 Templates/{template}.md` and may use {{title}}, {{date}}, {{id}}.
local function new_typed_note(folder, template)
  return function()
    vim.ui.input({ prompt = "Title: " }, function(title)
      if not title or title == "" then return end

      local vault = vim.fn.expand(VAULT)
      local date = os.date("%Y-%m-%d")
      local slug = title
        :gsub("[/\\:%*%?\"<>|]", "") -- strip filename-illegal chars
        :gsub("%s+", "-")             -- spaces → hyphens
        :lower()
      local id = date .. "-" .. slug
      local folder_path = vault .. "/" .. folder
      local filepath = folder_path .. "/" .. id .. ".md"

      vim.fn.mkdir(folder_path, "p")

      if vim.fn.filereadable(filepath) == 1 then
        vim.notify("Note exists, opening: " .. filepath, vim.log.levels.WARN)
        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
        return
      end

      local template_path = vault .. "/90 Templates/" .. template .. ".md"
      local lines
      if vim.fn.filereadable(template_path) == 1 then
        lines = vim.fn.readfile(template_path)
        for i, line in ipairs(lines) do
          line = line:gsub("{{title}}", title)
          line = line:gsub("{{date}}", date)
          line = line:gsub("{{id}}", id)
          lines[i] = line
        end
      else
        lines = { "# " .. title, "" }
        vim.notify("Template missing: " .. template_path, vim.log.levels.WARN)
      end

      vim.fn.writefile(lines, filepath)
      vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    end)
  end
end

---@type LazySpec
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = {
      "ObsidianNew",
      "ObsidianOpen",
      "ObsidianQuickSwitch",
      "ObsidianSearch",
      "ObsidianTags",
      "ObsidianBacklinks",
      "ObsidianTemplate",
      "ObsidianWorkspace",
      "ObsidianRename",
      "ObsidianPasteImg",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      -- Navigation / search
      { "<Leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch note" },
      { "<Leader>os", "<cmd>ObsidianSearch<cr>",      desc = "Search vault (grep)" },
      { "<Leader>oT", "<cmd>ObsidianTags<cr>",        desc = "Browse tags" },
      { "<Leader>ob", "<cmd>ObsidianBacklinks<cr>",   desc = "Backlinks for current note" },

      -- New typed notes  (<Leader>on{type})
      { "<Leader>onn", new_typed_note("20 Permanent",  "Permanent"),  desc = "New permanent note" },
      { "<Leader>onl", new_typed_note("10 Literature", "Literature"), desc = "New literature note" },
      { "<Leader>onp", new_typed_note("40 Projects",   "Project"),    desc = "New project note" },
      { "<Leader>onm", new_typed_note("30 MOCs",       "MOC"),        desc = "New MOC" },
      { "<Leader>oni", new_typed_note("00 Inbox",      "Inbox"),      desc = "New inbox note" },

      -- Note actions
      { "<Leader>or", "<cmd>ObsidianRename<cr>",   desc = "Rename note (update links)" },
      { "<Leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard" },
      { "<Leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "Switch workspace" },

      -- Visual-mode linking
      { "<Leader>oL", "<cmd>ObsidianLink<cr>",    mode = "v", desc = "Link selection to existing note" },
      { "<Leader>oN", "<cmd>ObsidianLinkNew<cr>", mode = "v", desc = "Link selection to new note" },
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = VAULT,
        },
      },

      -- Templates folder (used by :ObsidianTemplate picker, kept compatible with
      -- Obsidian app's templates plugin).
      templates = {
        folder = "90 Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      -- Image paste from clipboard (:ObsidianPasteImg / <Leader>op).
      -- The default `img_text_func` inserts a vault-relative path, which breaks
      -- when the note is in a subfolder. We compute a path relative to the
      -- current note instead — works in nvim, Obsidian, and plain markdown.
      attachments = {
        img_folder = "assets/imgs",
        img_text_func = function(_client, path)
          local note_dir = vim.fn.expand("%:p:h")
          local rel = relpath(note_dir, tostring(path))
          return string.format("![%s](%s)", path.name, rel)
        end,
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      mappings = {
        ["gf"] = {
          action = function() return require("obsidian").util.gf_passthrough() end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<Leader>oc"] = {
          action = function() return require("obsidian").util.toggle_checkbox() end,
          opts = { buffer = true, desc = "Toggle checkbox" },
        },
        ["<CR>"] = {
          action = function() return require("obsidian").util.smart_action() end,
          opts = { buffer = true, expr = true },
        },
      },

      -- Where notes go when created from a [[wikilink]] that doesn't exist yet
      -- (i.e. you wikilink to something, then `gf` to create it).
      new_notes_location = "current_dir",
      preferred_link_style = "wiki",

      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.date("%Y-%m-%d")) .. "-" .. suffix
      end,

      picker = {
        name = "telescope.nvim",
      },

      open_app_foreground = false,
      use_advanced_uri = false,
      disable_frontmatter = false,

      ui = {
        enable = false, -- using render-markdown.nvim instead
      },
    },
  },

  -- Pretty in-buffer markdown rendering (checkboxes, headings, code blocks, tables).
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      file_types = { "markdown" },
      heading = { sign = false },
      code = { sign = false, width = "block", right_pad = 2 },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked   = { icon = "󰱒 " },
      },
    },
  },
}
