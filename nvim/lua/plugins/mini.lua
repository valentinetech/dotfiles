return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
  },
  
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })
      
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
          end,
        },
        mappings = {
          comment_line = "<leader>c",
          comment_visual = "<leader>c",
          textobject = "gc",
        },
      })
    end,
  },

  -- Surround (SEPARATE plugin, not inside comment!)
  {
    "echasnovski/mini.surround",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      custom_surroundings = nil,
      highlight_duration = 300,
      mappings = {
        add = 'sa',
        delete = 'ds',
        find = 'sf',
        find_left = 'sF',
        highlight = 'sh',
        replace = 'sr',
        update_n_lines = 'sn',
        suffix_last = 'l',
        suffix_next = 'n',
      },
      n_lines = 20,
      respect_selection_type = false,
      search_method = 'cover',
      silent = false,
    },
  },

  -- Git diff signs
  {
    "echasnovski/mini.diff",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = { add = "+", change = "~", delete = "-" },
        },
        mappings = {
          apply = "gh",
          reset = "gH",
          textobject = "gh",
          goto_first = "[H",
          goto_prev = "[h",
          goto_next = "]h",
          goto_last = "]H",
        },
      })

      -- Toggle diff overlay to see actual changes
      vim.keymap.set("n", "<leader>gd", "<cmd>lua MiniDiff.toggle_overlay()<cr>", { desc = "Toggle diff overlay" })
    end,
  },
}
