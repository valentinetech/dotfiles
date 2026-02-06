return {
  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
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
    end,
  },

  -- Mason-LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { 
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
    end,
  },

  -- LSPConfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Default config for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- VTSLS (TypeScript/JavaScript/Vue)
      vim.lsp.config("vtsls", {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
      })
        vim.lsp.config("html", {
          filetypes = { "html", "vue" },
       })

      -- Vue
      vim.lsp.config("vue_ls", {
        init_options = {
          typescript = {
            tsdk = vim.fn.stdpath("data") .. "/mason/packages/vtsls/node_modules/typescript/lib"
          }
        }
      })

      -- Lua
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Basedpyright for Python (import resolution, type checking)
      vim.lsp.config("basedpyright", {
        root_dir = function(fname)
          return vim.fs.root(fname, { "pyproject.toml", ".git" })
        end,
        before_init = function(_, config)
          local root = config.root_dir
          if root then
            config.settings.python = {
              pythonPath = root .. "/.venv/bin/python",
            }
          end
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })

      -- Ruff LSP for Python diagnostics
      vim.lsp.config("ruff", {
        on_attach = function(client, bufnr)
          -- Disable hover (not needed from ruff)
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- Enable all servers
      vim.lsp.enable({ "vtsls", "vue_ls", "lua_ls", "html", "ruff" })

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
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = ev.buf, desc = "Show diagnostic" })
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = ev.buf, desc = "Previous diagnostic" })
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = ev.buf, desc = "Next diagnostic" })
        end,
      })
    end,
  },
}
