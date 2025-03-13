return {
  -- Install LSP and autoformatting support for C++
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {}, -- C++ LSP for code completion, diagnostics
      },
    },
  },

  -- Ensure clangd is installed via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "clangd", "clang-format" })
    end,
  },

  -- Auto-format on save using clang-format
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
        c = { "clang-format" },
      },
    },
  },
}
