-- Enable snacks.nvim dashboard with compact_files layout, and disable mini-starter
return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
   ██████╗  ██████╗ ██████╗       ███████╗███╗   ███╗██████╗ ███████╗██████╗  ██████╗ ██████╗ 
  ██╔════╝ ██╔═══██╗██╔══██╗      ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗
  ██║  ███╗██║   ██║██║  ██║█████╗█████╗  ██╔████╔██║██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝
  ██║   ██║██║   ██║██║  ██║╚════╝██╔══╝  ██║╚██╔╝██║██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██╔══██╗
  ╚██████╔╝╚██████╔╝██████╔╝      ███████╗██║ ╚═╝ ██║██║     ███████╗██║  ██║╚██████╔╝██║  ██║
   ╚═════╝  ╚═════╝ ╚═════╝       ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝
          ]],
        },
      },
      picker = {
        sources = {
          explorer = {
            ignored = true,
            hidden = true,
          },
        },
      },
    },
    dependencies = {},
  },
  -- Disable mini-starter if present
  { "echasnovski/mini.starter", enabled = false },
}
