return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    -- Test adapters
    "marilari88/neotest-vitest",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
      },
      quickfix = {
        open = false,
      },
    })

    -- Keybindings
    vim.keymap.set("n", "<leader>tt", function()
      require("neotest").run.run()
    end, { desc = "Run nearest test" })

    vim.keymap.set("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "Run current test file" })

    vim.keymap.set("n", "<leader>ta", function()
      require("neotest").run.run(vim.fn.getcwd())
    end, { desc = "Run all tests" })

    vim.keymap.set("n", "<leader>tw", function()
      require("neotest").watch.toggle()
    end, { desc = "Toggle test watch mode" })

    vim.keymap.set("n", "<leader>ts", function()
      require("neotest").summary.toggle()
    end, { desc = "Toggle test summary" })

    vim.keymap.set("n", "<leader>to", function()
      require("neotest").output.open({ enter = true })
    end, { desc = "Show test output" })

    vim.keymap.set("n", "<leader>tp", function()
      require("neotest").output_panel.toggle()
    end, { desc = "Toggle test output panel" })
  end,
}
