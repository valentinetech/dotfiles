return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    })
  end,
}
