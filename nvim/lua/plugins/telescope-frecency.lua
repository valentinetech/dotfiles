return {
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("telescope._extensions.frecency").setup({
      db_safe_mode = false,
      auto_validate = false,
    })
    require("telescope").load_extension("frecency")

    -- Override <leader><leader> to use frecency instead of find_files
    vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Find files (by frecency)" })
  end,
}
