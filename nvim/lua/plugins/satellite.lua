return {
  "lewis6991/satellite.nvim",
  enabled = false, -- Temporarily disabled to test performance
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_only = false,
    winblend = 50,
    zindex = 40,
    excluded_filetypes = {},
    width = 6,
    handlers = {
      cursor = {
        enable = true,
        symbols = { "█", "█", "█", "█" },
      },
      diagnostic = {
        enable = true,
        signs = { "█", "█", "█" },
        min_severity = vim.diagnostic.severity.HINT,
      },
      gitsigns = {
        enable = true,
        signs = {
          add = "│",
          change = "│",
          delete = "-",
        },
      },
      marks = {
        enable = true,
        show_builtins = false,
      },
      search = {
        enable = true,
      },
    },
  },
}
