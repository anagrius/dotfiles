return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure corpus is in the treesitter config
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "corpus" })
      end
    end,
    init = function()
      -- Set up filetype detection for .corpus files
      vim.filetype.add({
        extension = {
          corpus = "corpus",
        },
        pattern = {
          [".*_corpus/.*%.txt"] = "corpus",
        },
      })

      -- Register the corpus parser
      vim.treesitter.language.register("corpus", "corpus")

      -- Ensure error highlighting is visible
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "@error.corpus", {
            fg = "#ff0000",
            bg = "#3d0000",
            bold = true,
            underline = true
          })
        end,
      })

      -- Set it immediately too
      vim.api.nvim_set_hl(0, "@error.corpus", {
        fg = "#ff0000",
        bg = "#3d0000",
        bold = true,
        underline = true
      })
    end,
  },
}
