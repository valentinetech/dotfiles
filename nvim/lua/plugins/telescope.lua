return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    
    telescope.setup({
      defaults = {
        path_display = { "absolute" },
        file_ignore_patterns = {
          "^.git/",
          "node_modules",
          "%.lock",
          "translations/",
          "translationsV2/",
          "coverage/",
          "autotests/",
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            preview_cutoff = 0,
            preview_height = 0.5,
            width = 0.8,
          },
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob", "!.git/*",
            "--glob", "!node_modules/*",
            "--glob", "!translations/*",
            "--glob", "!translationsV2/*",
            "--glob", "!coverage/*",
            "--glob", "!autotests/*",
          },
        },
      },
    })
    
    telescope.load_extension("fzf")
    
    -- File/buffer navigation
    vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
    -- vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
    -- vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
    
    -- Search in current file - normal mode (no default text)
    vim.keymap.set("n", "ff", function()
      builtin.current_buffer_fuzzy_find()
    end, { desc = "Search in file" })

    -- Search in current file - visual mode (with selection)
    vim.keymap.set("v", "ff", function()
      local text = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
      builtin.current_buffer_fuzzy_find({
        default_text = table.concat(text, "\n")
      })
    end, { desc = "Search selection in file" })

    -- Global search - normal mode (empty search prompt)
    vim.keymap.set("n", "ss", function()
      builtin.live_grep()
    end, { desc = "Search in project" })

    -- Global search - visual mode (with selection)
    vim.keymap.set("v", "ss", function()
      local text = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
      builtin.grep_string({ search = table.concat(text, "\n") })
    end, { desc = "Search selection in project" })
  end,
}
