return {
  "luckasRanarison/nvim-devdocs",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    float_win = {
      relative = "editor",
      height = 40,
      width = 120,
      border = "rounded",
    },
    wrap = true,
    after_open = function(bufnr)
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, silent = true })
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = bufnr, silent = true })
    end,
  },
  keys = {
    { "<leader>K", "<cmd>DevdocsOpenFloat<cr>", desc = "DevDocs (float)" },
  },
}
