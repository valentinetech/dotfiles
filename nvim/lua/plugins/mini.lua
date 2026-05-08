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
          apply = "",     -- Disable default
          reset = "",     -- Disable default
          textobject = "",  -- Disable default
          goto_first = "",  -- Disable default
          goto_prev = "",   -- Disable default
          goto_next = "",   -- Disable default
          goto_last = "",   -- Disable default
        },
      })

      -- Cycle through git hunks (wraps to first when reaching last)
      vim.keymap.set("n", "<leader>gg", function()
        local current_line = vim.fn.line('.')
        require('mini.diff').goto_hunk('next')
        local new_line = vim.fn.line('.')

        -- If we didn't move, we're at/past the last hunk, wrap to first
        if current_line == new_line then
          require('mini.diff').goto_hunk('first')
        end
      end, { desc = "Cycle through git hunks" })

      vim.keymap.set("n", "<leader>ga", function() require('mini.diff').apply_hunks() end, { desc = "Git apply/stage hunk" })
      vim.keymap.set("n", "<leader>gr", function() require('mini.diff').reset_hunks() end, { desc = "Git reset hunk" })
      vim.keymap.set("n", "<leader>df", function() require('mini.diff').toggle_overlay() end, { desc = "Toggle diff overlay" })
    end,
  },
}
