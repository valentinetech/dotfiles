local opts = { noremap = true, silent = true }

-- Better window navigation with Ctrl+hjkl (works with tmux-navigator)
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right" })

-- Async save + lint: save immediately, fix in background
vim.keymap.set("n", "<leader>w", function()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Save immediately
  vim.cmd("w")

  -- Run ESLint fix asynchronously in background
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({
      bufnr = bufnr,
      async = true,
      timeout_ms = 5000,
    }, function(err)
      if not err then
        -- Auto-save after fix completes
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("silent! w")
            end)
          end
        end)
      end
    end)
  end
end, { desc = "Save + async lint/fix" })

-- Close buffer (switches to another buffer first to prevent Neo-tree from expanding)
vim.keymap.set("n", "<leader>q", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  -- Find another buffer to switch to
  local target_buf = nil
  for _, buf in ipairs(buffers) do
    if buf.bufnr ~= current_buf then
      target_buf = buf.bufnr
      break
    end
  end

  -- If there's another buffer, switch to it first
  if target_buf then
    vim.api.nvim_set_current_buf(target_buf)
  end

  -- Delete the original buffer
  vim.api.nvim_buf_delete(current_buf, { force = false })
end, { desc = "Close buffer" })

-- Previous buffer
vim.keymap.set("n", "<leader>b", "<C-^>", { desc = "Previous buffer" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })

-- Move lines in visual mode (hold Shift+j/k to keep moving)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true, noremap = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true, noremap = true })

-- Duplicate lines (Alt+j/k)
vim.keymap.set("n", "<A-j>", ":t.<CR>", { desc = "Duplicate line down", silent = true })
vim.keymap.set("n", "<A-k>", ":t.-1<CR>", { desc = "Duplicate line up", silent = true })
vim.keymap.set("v", "<A-j>", ":t'><CR>gv", { desc = "Duplicate selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":t'<-1<CR>gv", { desc = "Duplicate selection up", silent = true })

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
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", { desc = "Decrease width", silent = true })
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", { desc = "Increase width", silent = true })
vim.keymap.set("n", "<A-Up>", ":resize -2<CR>", { desc = "Decrease height", silent = true })
vim.keymap.set("n", "<A-Down>", ":resize +2<CR>", { desc = "Increase height", silent = true })

-- Navigate splits with Ctrl+hjkl (already works)
-- Close split
vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", { desc = "Close split" })

-- Clipboard (use system clipboard)
vim.opt.clipboard = "unnamedplus"

-- Move lines in NORMAL mode (add to your existing visual mode ones)
vim.keymap.set("n", "<S-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<S-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })

-- o and O without auto-comments (just add blank line)
vim.keymap.set("n", "o", "o<Esc>", { desc = "Add line below without comment" })
vim.keymap.set("n", "O", "O<Esc>", { desc = "Add line above without comment" })

-- System clipboard copy (you already have clipboard set, add these for explicit copy)
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })

-- Clear search highlights with Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic navigation (global, not just LSP)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Jump through errors only (ESLint + TypeScript)
vim.keymap.set("n", "<leader><", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "<leader>>", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

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
