return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    require("no-neck-pain").setup({
      width = 60,
      autocmds = {
        enableOnVimEnter = false,
      },
      buffers = {
        right = {
          enabled = false,
        },
        wo = {
          fillchars = "eob: ",
        },
        setNames = false,
      },
    })

    -- Toggle centering with leader z
    vim.keymap.set("n", "<leader>z", ":NoNeckPain<CR>", { desc = "Toggle centered mode" })

    -- Ensure wrap is enabled when no-neck-pain is toggled
    vim.api.nvim_create_autocmd("User", {
      pattern = "NoNeckPainToggle",
      callback = function()
        vim.opt.wrap = true
        vim.opt.linebreak = true
      end,
    })
  end,
}
