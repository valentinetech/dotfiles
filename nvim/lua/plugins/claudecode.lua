return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    auto_start = true,
    log_level = "info",
    focus_after_send = false,
    track_selection = true,

    terminal = {
      split_side = "right",
      split_width_percentage = 0.30,
      provider = "snacks",
      auto_close = true,
    },

    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
      keep_terminal_focus = false,
    },
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },

    -- Terminal mode tmux navigation
    { "<C-h>", [[<C-\><C-n><cmd>TmuxNavigateLeft<cr>]], mode = "t", desc = "Navigate left" },
    { "<C-j>", [[<C-\><C-n><cmd>TmuxNavigateDown<cr>]], mode = "t", desc = "Navigate down" },
    { "<C-k>", [[<C-\><C-n><cmd>TmuxNavigateUp<cr>]], mode = "t", desc = "Navigate up" },
    { "<C-l>", [[<C-\><C-n><cmd>TmuxNavigateRight<cr>]], mode = "t", desc = "Navigate right" },
  },
}
