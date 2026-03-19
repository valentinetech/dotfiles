return {
  -- Mason + LSP Configuration
  {
    "williamboman/mason.nvim", -- Depend on Mason
    event = { "BufReadPre", "BufNewFile" },
    priority = 50,
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
      local vue_typescript_plugin = mason_packages .. "/vue-language-server/node_modules/@vue/typescript-plugin"

      -- Find TypeScript SDK (handle monorepos)
      local function find_tsdk()
        local root = vim.fs.root(0, { "package.json", ".git" })
        if not root then return nil end

        -- Try current directory
        local tsdk = root .. "/node_modules/typescript/lib"
        if vim.fn.isdirectory(tsdk) == 1 then return tsdk end

        -- Try parent directory (monorepo root)
        local parent = vim.fn.fnamemodify(root, ":h")
        tsdk = parent .. "/node_modules/typescript/lib"
        if vim.fn.isdirectory(tsdk) == 1 then return tsdk end

        return nil
      end

      -- Default capabilities for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- TypeScript Language Server with Vue plugin
      vim.lsp.config("ts_ls", {
        cmd = { mason_bin .. "/typescript-language-server", "--stdio" },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        root_markers = { "package.json", "tsconfig.json", ".git" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_typescript_plugin,
              languages = { "vue" },
            },
          },
        },
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "on",
            },
            suggest = {
              completeFunctionCalls = true,
              includeCompletionsForImportStatements = true,
            },
          },
        },
      })

      -- Vue Language Server (Volar)
      vim.lsp.config("volar", {
        cmd = { mason_bin .. "/vue-language-server", "--stdio" },
        filetypes = { "vue" },
        root_markers = { "package.json", ".git" },
        init_options = {
          vue = {
            hybridMode = true,  -- Let ts_ls handle script, Volar handles template
          },
          typescript = {
            tsdk = find_tsdk(),  -- Find TypeScript in monorepo
          },
        },
      })

      -- Lua Language Server
      vim.lsp.config("lua_ls", {
        cmd = { mason_bin .. "/lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Basedpyright for Python
      vim.lsp.config("basedpyright", {
        cmd = { mason_bin .. "/basedpyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", ".git" },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })

      -- Intelephense for PHP
      vim.lsp.config("intelephense", {
        cmd = { mason_bin .. "/intelephense", "--stdio" },
        filetypes = { "php" },
        root_markers = { "composer.json", ".git" },
      })

      -- Ruff for Python linting
      vim.lsp.config("ruff", {
        cmd = { mason_bin .. "/ruff", "server" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
      })

      -- Enable all configured servers
      vim.lsp.enable({ "ts_ls", "volar", "lua_ls", "basedpyright", "ruff", "intelephense" })

      -- Show diagnostics on hover
      vim.diagnostic.config({
        virtual_text = true,
        float = {
          source = "always",
          border = "rounded",
          wrap = true,
        },
      })

      -- Configure hover window
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      -- Set diagnostic colors after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.cmd([[
            highlight DiagnosticError guifg=#fb4934
            highlight DiagnosticWarn guifg=#fabd2f
            highlight DiagnosticInfo guifg=#83a598
            highlight DiagnosticHint guifg=#8ec07c
            highlight DiagnosticVirtualTextError guifg=#fb4934
            highlight DiagnosticVirtualTextWarn guifg=#fabd2f
            highlight DiagnosticVirtualTextInfo guifg=#83a598
            highlight DiagnosticVirtualTextHint guifg=#8ec07c
          ]])
        end,
      })

      -- Set colors immediately too
      vim.cmd([[
        highlight DiagnosticError guifg=#fb4934
        highlight DiagnosticWarn guifg=#fabd2f
        highlight DiagnosticInfo guifg=#83a598
        highlight DiagnosticHint guifg=#8ec07c
        highlight DiagnosticVirtualTextError guifg=#fb4934
        highlight DiagnosticVirtualTextWarn guifg=#fabd2f
        highlight DiagnosticVirtualTextInfo guifg=#83a598
        highlight DiagnosticVirtualTextHint guifg=#8ec07c
      ]])

      -- Keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
          vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { buffer = ev.buf })
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf })
          vim.keymap.set("n", "<leader>ga", vim.lsp.buf.code_action, { buffer = ev.buf })
        end,
      })
    end,
  },
}
