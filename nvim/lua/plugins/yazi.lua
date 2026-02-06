return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    {
      "<leader>e",
      function()
        require("yazi").yazi(nil, vim.fn.expand('%:p:h'))
      end,
      desc = "Open yazi",
    },
  },
  opts = {
    open_for_directories = false,
    yazi_floating_window_border = "rounded",
    
    -- Pass args to yazi to show hidden files
    yazi_opts = {
      "--show-hidden",
    },
    
    keymaps = {
      show_help = '?',
      open_file_in_vertical_split = '<c-v>',
      open_file_in_horizontal_split = '<c-x>',
      open_file_in_tab = '<c-t>',
      grep_in_directory = '<c-s>',
      replace_in_directory = '<c-g>',
      cycle_open_buffers = '<tab>',
      copy_relative_path_to_selected_files = '<c-y>',
      send_to_quickfix_list = '<c-q>',
    },
    
    -- ESC and q both close
    hooks = {
      yazi_closed_successfully = function() end,
    },
  },
}
