-- C++ Configuration for Neovim
-- This file should be placed in lua/cpp_config.lua

local M = {}

-- Configure clangd for C++ development
M.setup = function()
  -- Load required modules
  local lspconfig = require('lspconfig')
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  local mason = require('mason')
  local mason_lspconfig = require('mason-lspconfig')
  local dap = require('dap')

  -- Mason setup for managing LSP servers, DAP, linters, and formatters
  mason.setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })

  -- Ensure C++ related tools are installed via Mason
  mason_lspconfig.setup({
    ensure_installed = {
      "clangd",  -- C/C++ language server
      "cmake",   -- CMake language server
      "codelldb" -- Debugger
    }
  })

  -- Setup clangd language server for C++
  lspconfig.clangd.setup({
    cmd = {
      "clangd",
      "--background-index",
      "--suggest-missing-includes",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm"
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Key mappings for LSP functionality
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

      -- C++ specific mappings
      vim.keymap.set('n', '<space>h', "<cmd>ClangdSwitchSourceHeader<CR>", bufopts)
      vim.keymap.set('n', '<space>s', "<cmd>ClangdSymbolInfo<CR>", bufopts)
      vim.keymap.set('n', '<space>t', "<cmd>ClangdTypeHierarchy<CR>", bufopts)
    end
  })

  -- Setup CMake language server
  lspconfig.cmake.setup({
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })

  -- Setup C++ snippets for LuaSnip
  require("luasnip.loaders.from_vscode").lazy_load()

  -- Add C++ specific snippets
  luasnip.add_snippets("cpp", {
    -- Class declaration
    luasnip.snippet("class", {
      luasnip.text_node("class "),
      luasnip.insert_node(1, "ClassName"),
      luasnip.text_node(" {\npublic:\n\t"),
      luasnip.insert_node(2, "// Constructor"),
      luasnip.text_node("\n\t"),
      luasnip.insert_node(3, "ClassName"),
      luasnip.text_node("();\n\t"),
      luasnip.text_node("\n\t// Methods\n\nprivate:\n\t"),
      luasnip.insert_node(4, "// Private members"),
      luasnip.text_node("\n};"),
    }),

    -- Include guard
    luasnip.snippet("guard", {
      luasnip.text_node("#ifndef "),
      luasnip.insert_node(1, "HEADER_H"),
      luasnip.text_node("\n#define "),
      luasnip.insert_node(2, "HEADER_H"),
      luasnip.text_node("\n\n"),
      luasnip.insert_node(3),
      luasnip.text_node("\n\n#endif // "),
      luasnip.insert_node(4, "HEADER_H"),
    }),

    -- Main function
    luasnip.snippet("main", {
      luasnip.text_node("int main(int argc, char* argv[]) {\n\t"),
      luasnip.insert_node(1),
      luasnip.text_node("\n\treturn 0;\n}"),
    }),
  })

  -- Configure nvim-cmp for C++ completion
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    }),
    formatting = {
      format = function(entry, vim_item)
        -- Add source info
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]",
        })[entry.source.name]
        return vim_item
      end
    },
  })

  -- Configure nvim-dap for C++ debugging
  dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
      command = vim.fn.exepath('codelldb'),
      args = { "--port", "${port}" },
    }
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }

  -- Debug keymaps
  vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
  vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
  vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
  vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
  vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
  vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)

  -- Configure treesitter for C++
  require('nvim-treesitter.configs').setup {
    ensure_installed = { "cpp", "c", "cmake", "make", "json", "yaml" },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  }

  -- Configure linting for C++ with null-ls
  local null_ls = require("null-ls")
  null_ls.setup({
    sources = {
      null_ls.builtins.diagnostics.cppcheck,
      null_ls.builtins.formatting.clang_format.with({
        extra_args = { "-style=file:/home/your_username/.clang-format" }
      }),
    },
  })

  -- Setup telescope for better file navigation
  local telescope = require('telescope')
  telescope.setup {
    defaults = {
      file_ignore_patterns = {
        "build/",
        "bin/",
        "lib/",
        "obj/",
        ".git/"
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
    pickers = {
      find_files = {
        theme = "dropdown",
      },
      live_grep = {
        theme = "dropdown",
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- options for dropdown go here
        }
      }
    }
  }
  telescope.load_extension('ui-select')

  -- Keymaps for telescope
  vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
  vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
  vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')
  vim.keymap.set('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<CR>')
  vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<CR>')
  vim.keymap.set('n', '<leader>fi', '<cmd>Telescope lsp_implementations<CR>')
  vim.keymap.set('n', '<leader>fl', '<cmd>Telescope diagnostics<CR>')

  -- C++ specific features
  -- Add header guard to current file
  vim.api.nvim_create_user_command('AddHeaderGuard', function()
    local filename = vim.fn.expand('%:t'):upper():gsub('[^A-Z0-9]', '_')
    local guard = filename .. '_' .. os.time()
    local lines = {
      '#ifndef ' .. guard,
      '#define ' .. guard,
      '',
      '',
      '#endif  // ' .. guard
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { lines[1], lines[2], lines[3] })
    local last_line = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { lines[4], lines[5] })
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
  end, {})

  -- Create matching cpp file for header and vice versa
  vim.api.nvim_create_user_command('CreateMatchingFile', function()
    local current_file = vim.fn.expand('%:p')
    local extension = vim.fn.expand('%:e')
    local file_without_ext = vim.fn.expand('%:p:r')
    local new_file = ''

    if extension == 'h' or extension == 'hpp' then
      new_file = file_without_ext .. '.cpp'
    elseif extension == 'cpp' then
      new_file = file_without_ext .. '.h'
    else
      print('Not a C++ file')
      return
    end

    if vim.fn.filereadable(new_file) == 1 then
      print('File already exists: ' .. new_file)
    else
      local file = io.open(new_file, 'w')
      if file then
        if extension == 'cpp' then
          -- Creating header file
          local header = vim.fn.expand('%:t:r')
          local guard = header:upper() .. '_H'
          file:write('#ifndef ' .. guard .. '\n')
          file:write('#define ' .. guard .. '\n\n')
          file:write('// Class declaration for ' .. header .. '\n\n')
          file:write('#endif  // ' .. guard .. '\n')
        else
          -- Creating implementation file
          local header = vim.fn.expand('%:t')
          file:write('#include "' .. header .. '"\n\n')
          file:write('// Implementation for ' .. vim.fn.expand('%:t:r') .. '\n\n')
        end
        file:close()
        vim.cmd('edit ' .. new_file)
        print('Created: ' .. new_file)
      else
        print('Failed to create file: ' .. new_file)
      end
    end
  end, {})

  -- Key mappings for C++ specific commands
  vim.keymap.set('n', '<leader>ch', '<cmd>AddHeaderGuard<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>cm', '<cmd>CreateMatchingFile<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>cs', '<cmd>ClangdSwitchSourceHeader<CR>', { noremap = true, silent = true })
end

return M
