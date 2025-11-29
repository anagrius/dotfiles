return {
  {
    "saghen/blink.cmp",
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      local delay_ms = 500
      local augroup = vim.api.nvim_create_augroup("BlinkCmpDelayedGhostText", { clear = false })
      local ghost_ready = {}
      local function schedule_ghost(bufnr)
        ghost_ready[bufnr] = false
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            ghost_ready[bufnr] = true
          end
        end, delay_ms)
      end

      vim.api.nvim_create_autocmd({ "InsertEnter", "TextChangedI" }, {
        group = augroup,
        callback = function(event)
          schedule_ghost(event.buf)
        end,
      })
      schedule_ghost(vim.api.nvim_get_current_buf())

      opts.completion = opts.completion or {}
      opts.completion.menu = vim.tbl_deep_extend("force", opts.completion.menu or {}, {
        -- Delay before the completion menu auto-shows
        auto_show_delay_ms = delay_ms,
      })
      opts.completion.documentation = vim.tbl_deep_extend("force", opts.completion.documentation or {}, {
        -- Match the menu delay for docs popups
        auto_show_delay_ms = delay_ms,
      })
      -- Disable inline ghost text to avoid distraction
      opts.completion.ghost_text = vim.tbl_deep_extend("force", opts.completion.ghost_text or {}, {
        enabled = false,
      })
      -- Drop built-in snippet completion results (keep LSP/paths/buffer)
      opts.sources = opts.sources or {}
      opts.sources.default = { "lsp", "path", "buffer" }
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        snippets = { enabled = false },
      })
      return opts
    end,
  },
}
