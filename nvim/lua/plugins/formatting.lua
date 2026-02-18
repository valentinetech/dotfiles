return {
  -- Formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript = { "eslint_monorepo" },
          typescript = { "eslint_monorepo" },
          javascriptreact = { "eslint_monorepo" },
          typescriptreact = { "eslint_monorepo" },
          vue = { "eslint_monorepo" },
          python = {
            "ruff_fix",        -- Fix auto-fixable lint errors
            "ruff_format",     -- Run Ruff formatter
            "ruff_organize_imports", -- Organize imports
          },
        },
      })

      -- Register custom eslint formatter for monorepo
      conform.formatters.eslint_monorepo = {
        command = "/Users/valentinastauskela/Documents/GitHub/hpanel/node_modules/.bin/eslint",
        args = { "--fix", "$FILENAME" },
        stdin = false,
      }

      -- Manual format keybinding
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        conform.format({ async = true, lsp_fallback = true })
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
