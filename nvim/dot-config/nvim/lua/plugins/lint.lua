-- Custom nvim-lint configuration to disable markdownlint for Mason files
-- and use global markdownlint configuration
local HOME = os.getenv("HOME")

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          args = { "--config", HOME .. "/.markdownlint.json", "--" },
          condition = function(ctx)
            -- Disable markdownlint for Mason-related markdown files
            local mason_patterns = {
              "mason%.nvim",
              "williamboman/mason",
              "mason%-lspconfig",
              "mason%-tool%-installer",
              "registry%.lua",
              "%.mason",
              "/mason/",
            }
            
            for _, pattern in ipairs(mason_patterns) do
              if string.find(ctx.filename, pattern) then
                return false
              end
            end
            
            return true
          end,
        },
        ["markdownlint-cli2"] = {
          args = { "--config", HOME .. "/.markdownlint.json", "--" },
          condition = function(ctx)
            -- Disable markdownlint-cli2 for Mason-related markdown files
            local mason_patterns = {
              "mason%.nvim",
              "williamboman/mason",
              "mason%-lspconfig", 
              "mason%-tool%-installer",
              "registry%.lua",
              "%.mason",
              "/mason/",
            }
            
            for _, pattern in ipairs(mason_patterns) do
              if string.find(ctx.filename, pattern) then
                return false
              end
            end
            
            return true
          end,
        },
      },
    },
  },
}