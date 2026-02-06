-- return {
--   "neovim/nvim-lspconfig",
--   dependencies = {
--     "hrsh7th/cmp-nvim-lsp",
--     "williamboman/mason-lspconfig.nvim",
--   },
--   config = function()
--     local capabilities = require("cmp_nvim_lsp").default_capabilities()
--
--     vim.lsp.config("*", {
--       capabilities = capabilities,
--     })
--
--     -- VTSLS first (Vue needs this)
--     vim.lsp.config("vtsls", {
--       settings = {
--         vtsls = {
--           tsserver = {
--             globalPlugins = {
--               {
--                 name = "@vue/typescript-plugin",
--                 location = vim.fn.stdpath("data")
--                   .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
--                 languages = { "vue" },
--                 configNamespace = "typescript",
--               },
--             },
--           },
--         },
--       },
--       filetypes = {
--         "javascript",
--         "javascriptreact",
--         "typescript",
--         "typescriptreact",
--         "vue",
--       },
--     })
--
--     -- Vue_ls config - tell it to use vtsls
--     vim.lsp.config("vue_ls", {
--       init_options = {
--         typescript = {
--           tsdk = vim.fn.stdpath("data") .. "/mason/packages/vtsls/node_modules/typescript/lib"
--         }
--       }
--     })
--
--     vim.lsp.config("lua_ls", {
--       settings = {
--         Lua = {
--           diagnostics = { globals = { "vim" } },
--         },
--       },
--     })
--
--     -- Enable servers
--     vim.lsp.enable({ "vtsls", "vue_ls", "lua_ls", "pyright" })
--
--     -- Keybindings
--     vim.api.nvim_create_autocmd("LspAttach", {
--       callback = function(ev)
--         vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
--         vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf })
--       end,
--     })
--   end,
-- }

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "luasnip" },
        { name = "path" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
