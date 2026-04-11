return {
  "mfussenegger/nvim-lint",
  enabled = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Configure ESLint to use monorepo root
    lint.linters.eslint.cmd = function()
      -- Find git root first (monorepo root), then fall back to package.json root
      local git_root = vim.fs.root(0, { ".git" })
      local root_dir = git_root or vim.fs.root(0, { "package.json" })
      if root_dir then
        local workspace_eslint = vim.fn.findfile("node_modules/.bin/eslint", root_dir .. ";")
        if workspace_eslint ~= "" then
          return workspace_eslint
        end
      end
      return "eslint" -- Fallback to system eslint
    end

    lint.linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      vue = { "eslint" },
    }

    -- Trigger linting on multiple events for real-time feedback
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        local ok, cmd = pcall(lint.linters.eslint.cmd)
        if ok and cmd and vim.fn.executable(cmd) == 1 then
          pcall(lint.try_lint)
        end
      end,
    })

    -- Manual lint keybinding
    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting" })
  end,
}
