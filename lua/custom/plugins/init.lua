-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
      'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
    },
    config = function()
      local null_ls = require 'null-ls'
      local formatting = null_ls.builtins.formatting   -- to setup formatters
      local diagnostics = null_ls.builtins.diagnostics -- to setup linters

      -- list of formatters & linters for mason to install
      require('mason-null-ls').setup {
        ensure_installed = {
          'checkmake',
          'prettier', -- ts/js formatter
          'stylua',   -- lua formatter
          'shfmt',
          'ruff',
        },
        -- auto-install configured formatters & linters (with null-ls)
        automatic_installation = true,
      }

      local sources = {
        diagnostics.checkmake,
        formatting.prettier.with { filetypes = { 'html', 'json', 'yaml', 'markdown' } },
        formatting.stylua,
        formatting.shfmt.with { args = { '-i', '4' } },
        formatting.terraform_fmt,
        require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
        require 'none-ls.formatting.ruff_format',
      }

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
      null_ls.setup {
        -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
        sources = sources,
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end,
      }
    end,
  },
  { -- Interactive REPL over Neovim
    'Vigemus/iron.nvim',
    keys = {
      { '<leader>ii', desc = 'Toggle REPL' },
      { '<leader>ir', desc = 'Restart REPL' },
      { '<leader>io', '<cmd>IronFocus<cr>', desc = 'Focus REPL' },
      { '<leader>ih', '<cmd>IronHide<cr>',  desc = 'Hide REPL' },
    },
    branch = 'master',
    config = function()
      local iron = require 'iron.core'
      local view = require 'iron.view'
      local common = require 'iron.fts.common'

      -- Function to find the virtual environment's IPython
      local function get_venv_ipython()
        -- Check for .venv in the current directory
        local venv_path = vim.fn.getcwd() .. '/.venv'
        local ipython_path = venv_path .. '/bin/ipython'

        -- Check if the venv IPython exists
        if vim.fn.filereadable(ipython_path) == 1 then
          return ipython_path
        end

        -- Fallback to system IPython
        return 'ipython'
      end

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { 'zsh' },
            },
            python = {
              -- Use the virtual environment's IPython if available
              command = function()
                return {
                  get_venv_ipython(),
                  '--no-autoindent',
                  '--no-confirm-exit',
                  '--simple-prompt',
                }
              end,
              format = common.bracketed_paste_python,
              block_deviders = { '# %%', '#%%' },
            },
          },
          repl_filetype = function(bufnr, ft)
            return ft
          end,
          repl_open_cmd = 'botright horizontal split',
          repl_defintion = {
            size = 15,
          },
          repl_border = 'rounded',
        },
        keymaps = {
          toggle_repl = '<leader>ii',
          restart_repl = '<leader>ir',
          send_motion = '<leader>ic',
          visual_send = '<leader>ic',
          send_file = '<leader>is',
          send_line = '<leader>il',
          send_paragraph = '<leader>ip',
          send_until_cursor = '<leader>iu',
          send_mark = '<leader>im',
          send_code_block = '<leader>ib',
          send_code_block_and_move = '<leader>in',
          mark_motion = '<leader>im',
          mark_visual = '<leader>im',
          remove_mark = '<leader>id',
          cr = '<leader>i<cr>',
          interrupt = '<leader>i<space>',
          exit = '<leader>iq',
          clear = '<leader>ic',
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      }
    end,
  },
}
