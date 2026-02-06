return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "json",
          "javascript",
          "typescript",
          "tsx",
          "yaml",
          "html",
          "css",
          "python",
          "markdown",
          "bash",
          "lua",
          "vim",
          "vimdoc",
          "vue", -- Add vue parser
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-n>",
            node_incremental = "<C-n>",
            scope_incremental = false,
          },
        },
        additional_vim_regex_highlighting = false,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    enabled = true,
    ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
        per_filetype = {
          ["html"] = {
            enable_close = true,
          },
          ["vue"] = {
            enable_close = true,
          },
          ["typescriptreact"] = {
            enable_close = true,
          },
        },
      })
    end,
  },
}
