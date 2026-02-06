local opts = { noremap = true, silent = true }

-- Better window navigation with Ctrl+hjkl (works with tmux-navigator)
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right" })

-- Save file
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Close buffer
vim.keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close buffer" })

-- Previous buffer
vim.keymap.set("n", "<leader>b", "<C-^>", { desc = "Previous buffer" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Duplicate lines with highlight
vim.keymap.set("n", "<A-j>", function()
  vim.cmd("t.")
  vim.highlight.on_yank({ timeout = 200 })
end, { desc = "Duplicate line down" })

vim.keymap.set("n", "<A-k>", function()
  vim.cmd("t.-1")
  vim.highlight.on_yank({ timeout = 200 })
end, { desc = "Duplicate line up" })

vim.keymap.set("v", "<A-j>", function()
  vim.cmd("t'>+0")
  vim.cmd("normal! gv")
  vim.highlight.on_yank({ timeout = 200 })
end, { desc = "Duplicate selection down" })

--Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Center screen on navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Better paste
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "p", '"_dp', opts)

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Prevent x from copying
vim.keymap.set("n", "x", '"_x', opts)

-- Create splits with Alt+h and Alt+l only
vim.keymap.set("n", "<A-h>", ":vsplit<CR>", { desc = "Vertical split (side by side)" })
vim.keymap.set("n", "<A-l>", ":split<CR>", { desc = "Horizontal split (top/bottom)"})

-- Resize splits with Alt+arrows
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })
vim.keymap.set("n", "<A-Up>", ":resize -2<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<A-Down>", ":resize +2<CR>", { desc = "Increase height" })

-- Navigate splits with Ctrl+hjkl (already works)
-- Close split
vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", { desc = "Close split" })

-- Clipboard (use system clipboard)
vim.opt.clipboard = "unnamedplus"

-- Move lines in NORMAL mode (add to your existing visual mode ones)
vim.keymap.set("n", "<S-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<S-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- o and O without auto-comments (just add blank line)
vim.keymap.set("n", "o", "o<Esc>", { desc = "Add line below without comment" })
vim.keymap.set("n", "O", "O<Esc>", { desc = "Add line above without comment" })

-- System clipboard copy (you already have clipboard set, add these for explicit copy)
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })

-- Clear search highlights with Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Fix backspace in insert mode
vim.keymap.set("i", "<BS>", "<BS>", { noremap = true, desc = "Backspace deletes character" })

-- Option/Alt+Backspace deletes word (Mac behavior)
vim.keymap.set("i", "<M-BS>", "<C-w>", { noremap = true, desc = "Delete word backward" })
vim.keymap.set("i", "<A-BS>", "<C-w>", { noremap = true, desc = "Delete word backward" })

-- Close Lazy with q (standard vim way)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lazy",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, desc = "Close Lazy" })
  end,
})
