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

    -- Manual lint keybinding with progress notification
    vim.keymap.set("n", "<leader>l", function()
      vim.notify("Linting...", vim.log.levels.INFO, { title = "ESLint" })

      local done = false
      local augroup = vim.api.nvim_create_augroup("LintNotify", { clear = true })

      local function show_result()
        if done then return end
        done = true
        vim.api.nvim_clear_autocmds({ group = augroup })
        local diags = vim.diagnostic.get(0)
        local errors = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.ERROR end, diags)
        local warns = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.WARN end, diags)
        if errors == 0 and warns == 0 then
          vim.notify("No issues found", vim.log.levels.INFO, { title = "ESLint" })
        else
          vim.notify(string.format("%d error(s), %d warning(s)", errors, warns), vim.log.levels.WARN, { title = "ESLint" })
        end
      end

      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = augroup,
        buffer = 0,
        once = true,
        callback = vim.schedule_wrap(show_result),
      })

      vim.defer_fn(show_result, 5000)

      lint.try_lint()
    end, { desc = "Trigger linting" })
  end,
}
