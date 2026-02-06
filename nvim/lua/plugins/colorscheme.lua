return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
  },
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "oskarnurm/koda.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
          "gruvbox",
          "gruvbox-material",
          {
            name = "Koda Dark",
            colorscheme = "koda",
            before = [[vim.o.background = "dark"]],
          },
          {
            name = "Koda Light",
            colorscheme = "koda",
            before = [[vim.o.background = "light"]],
          },
          {
            name = "Solarized Dark",
            colorscheme = "solarized",
            before = [[vim.o.background = "dark"]],
          },
          {
            name = "Solarized Light",
            colorscheme = "solarized",
            before = [[vim.o.background = "light"]],
          },
          "tokyonight-night",
          "tokyonight-storm",
          "tokyonight-day",
          "tokyonight-moon",
          "kanagawa",
          "kanagawa-wave",
          "kanagawa-dragon",
          "kanagawa-lotus",
        },
        livePreview = true,
      })

      -- Keybinding to open theme switcher
      vim.keymap.set("n", "<leader>th", ":Themery<CR>", { desc = "Switch theme" })
    end,
  },
}
