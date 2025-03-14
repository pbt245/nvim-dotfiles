require("lspconfig").clangd.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  cmd = {
    "clangd",
    "--background-index",
    "--suggest-missing-includes",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--offset-encoding=utf-16", -- Needed for some language servers
  },
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern(
      "compile_commands.json",
      "compile_flags.txt",
      ".git",
      "CMakeLists.txt"
    )(fname) or vim.fn.getcwd()
  end,
  init_options = {
    compilationDatabasePath = ".", -- Look for compile_commands.json in the project root
    fallbackFlags = { "-std=c++17", "-I./include" }, -- Add your project's include directory here
  },
})
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
