return {
  -- Formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "eslint_d" },
          typescript = { "eslint_d" },
          javascriptreact = { "eslint_d" },
          typescriptreact = { "eslint_d" },
          vue = { "eslint_d" },
          python = {
            "ruff_fix",        -- Fix auto-fixable lint errors
            "ruff_format",     -- Run Ruff formatter
            "ruff_organize_imports", -- Organize imports
          },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Manual format keybinding
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format file or range" })
    end,
  },

  -- Install formatters via Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "eslint_d",
          "ruff",
        },
      })
    end,
  },
}
