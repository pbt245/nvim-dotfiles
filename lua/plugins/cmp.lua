return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completions
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-path", -- Path completions
      "L3MON4D3/LuaSnip", -- Snippet support
      "saadparwaiz1/cmp_luasnip", -- Snippets for completion
    },
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- Expand snippet
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Navigate suggestions
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
          ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions
          { name = "buffer" }, -- Words from the current buffer
          { name = "path" }, -- Path completions
          { name = "luasnip" }, -- Snippet completions
        }),
      })
    end,
  },
}
