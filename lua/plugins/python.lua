return {
    -- Python LSP support
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pyright = {}, -- Python LSP for code completion, linting
            },
        },
    },

    -- Ensure pyright & formatting tools are installed via Mason
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "pyright", "black", "isort" })
        end,
    },

    -- Autoformat using black and isort
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "black", "isort" },
            },
        },
    },
}
