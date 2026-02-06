return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  config = function()
    require("noice").setup({
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        opts = {
          position = {
            row = "50%",
            col = "50%",
          },
        },
        format = {
          cmdline = { icon = ":" },
          search_down = { icon = "/" },
          search_up = { icon = "?" },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
          },
        },
      },
      messages = {
        enabled = false,
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      notify = {
        enabled = false,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = false,
        inc_rename = false,
        lsp_doc_border = false,
      },
    })
  end,
}
