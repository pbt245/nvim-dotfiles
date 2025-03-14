return {
  { "olimorris/onedarkpro.nvim", priority = 1000 },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = false,
      }
    end,
  },
}
