return {
  {
    "neovim/nvim-lspconfig",
    ---@param opts PluginLspOpts
    opts = function(_, opts)
      opts.inlay_hints = opts.inlay_hints or {}
      -- Disable LazyVim's immediate inlay-hint enablement; we'll enable after a delay below.
      opts.inlay_hints.enabled = false
      opts.inlay_hints.delay_ms = 500
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      if not (vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable) then
        return
      end

      local delay = opts.inlay_hints.delay_ms or 0
      local exclude = opts.inlay_hints.exclude or {}

      Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
        if
          vim.api.nvim_buf_is_valid(buffer)
          and vim.bo[buffer].buftype == ""
          and not vim.tbl_contains(exclude, vim.bo[buffer].filetype)
        then
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buffer) then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end, delay)
        end
      end)
    end,
  },
}
