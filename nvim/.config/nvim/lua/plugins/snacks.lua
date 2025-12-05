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
          projects = {
            dev = { "~/code" },
          },
        },
      },
    },
    dependencies = {},
  },
  -- Disable mini-starter if present
  { "nvim-mini/mini.starter", enabled = false },
}
