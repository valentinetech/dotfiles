-- Line numbers
vim.opt.nu = true
vim.opt.relativenumber = false
vim.opt.showmatch = true   
-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Cursor
vim.opt.guicursor = {
  "n-v-c:block",      -- normal, visual, command: block
  "i-ci-ve:ver25",    -- insert: slim vertical bar
}

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.wrap = true
vim.opt.linebreak = true  -- Wrap at word boundaries
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Misc
vim.opt.updatetime = 50
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.colorcolumn = ""
vim.opt.cmdheight = 0  -- Hide command line when not in use
vim.opt.backspace = "indent,eol,start"  -- Make backspace work like other editors

-- Auto-reload files when changed externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})
-- Disable auto-comments on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
