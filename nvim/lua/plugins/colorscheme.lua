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
      -- Function to update wezterm theme
      local function sync_wezterm_theme(theme_name)
        -- Map nvim themes to wezterm color schemes
        local theme_map = {
          ["Koda Dark"] = "Koda Dark",
          ["Koda Light"] = "Koda Light",
          ["gruvbox"] = "Gruvbox dark, medium (base16)",
          ["gruvbox-material"] = "Gruvbox Material (Gogh)",
          ["tokyonight-night"] = "Tokyo Night",
          ["tokyonight-storm"] = "Tokyo Night Storm",
          ["kanagawa"] = "Kanagawa (Gogh)",
        }

        local wezterm_theme = theme_map[theme_name]
        if not wezterm_theme then
          return
        end

        -- Update wezterm config using sed
        local config_path = vim.fn.expand("~/Documents/github/dotfiles/.wezterm.lua")
        local sed_cmd = string.format(
          [[sed -i '' 's/^config\.color_scheme = .*/config.color_scheme = "%s"/' '%s']],
          wezterm_theme,
          config_path
        )
        vim.fn.system(sed_cmd)
      end

      require("themery").setup({
        notify = false, -- Disable "theme saved" message
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

      -- Auto-sync wezterm and lualine themes when nvim colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Get current background (dark/light)
          local bg = vim.o.background
          local colorscheme = vim.g.colors_name

          -- Determine theme name based on colorscheme + background
          local theme_name = colorscheme
          if colorscheme == "koda" then
            theme_name = bg == "dark" and "Koda Dark" or "Koda Light"
          elseif colorscheme == "solarized" then
            theme_name = bg == "dark" and "Solarized Dark" or "Solarized Light"
          end

          -- Sync wezterm
          sync_wezterm_theme(theme_name)

          -- Sync tmux theme (dark/light for tmux-gruvbox plugin)
          local tmux_variant = bg == "dark" and "dark" or "light"

          -- Update config file
          local tmux_config = vim.fn.expand("~/Documents/github/dotfiles/.tmux.conf")
          local tmux_sed = string.format(
            [[sed -i '' "s/set -g @tmux-gruvbox .*/set -g @tmux-gruvbox '%s'/" '%s']],
            tmux_variant,
            tmux_config
          )
          vim.fn.system(tmux_sed)

          -- Set tmux option directly (immediate effect)
          vim.fn.system(string.format("tmux set-option -g @tmux-gruvbox '%s' 2>/dev/null", tmux_variant))
          -- Reload tmux config
          vim.fn.system("tmux source-file ~/.tmux.conf 2>/dev/null")

          -- Sync lualine theme
          local lualine_theme_map = {
            ["Koda Dark"] = "gruvbox_dark",
            ["Koda Light"] = "gruvbox_light",
            ["gruvbox"] = "gruvbox_dark",
            ["gruvbox-material"] = "gruvbox-material",
            ["tokyonight-night"] = "tokyonight",
            ["tokyonight-storm"] = "tokyonight",
            ["tokyonight-day"] = "tokyonight",
            ["tokyonight-moon"] = "tokyonight",
            ["kanagawa"] = "kanagawa",
            ["kanagawa-wave"] = "kanagawa",
            ["kanagawa-dragon"] = "kanagawa",
            ["kanagawa-lotus"] = "kanagawa",
            ["Solarized Dark"] = "solarized_dark",
            ["Solarized Light"] = "solarized_light",
          }

          local lualine_theme = lualine_theme_map[theme_name] or "auto"
          require("lualine").setup({ options = { theme = lualine_theme } })
        end,
      })
    end,
  },
}
