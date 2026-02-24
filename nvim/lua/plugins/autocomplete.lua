return {
  "saghen/blink.cmp",
  lazy = false,
  priority = 1000, -- Load before LSP to provide capabilities
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "v0.*", -- Use stable version with prebuilt binaries
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          min_keyword_length = 0,  -- Show completions immediately
          score_offset = 100,  -- Prioritize LSP completions
        },
      },
    },

    completion = {
      menu = {
        border = "rounded",
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
        },
      },
    },

    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
  },
}
