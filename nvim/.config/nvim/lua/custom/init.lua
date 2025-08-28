-- Custom configuration overrides and extensions
-- This file contains personal customizations separate from upstream kickstart.nvim

-- Custom options
vim.g.yankring_history_dir = '~/.local/share/nvim/tmp'

-- Override default cursor movement behavior
vim.opt.autochdir = false

-- Modified clipboard settings for selective synchronization
-- Instead of automatic sync, set up custom keymaps for explicit clipboard operations
-- This prevents ciw and similar operations from automatically copying to clipboard
vim.schedule(function()
  -- Disable automatic clipboard sync (override kickstart default)
  vim.opt.clipboard = ''

  -- Set up explicit clipboard keymaps
  -- Visual mode: y copies to both internal register and system clipboard
  vim.keymap.set('v', 'y', '"+y', { desc = 'Yank to system clipboard' })

  -- Normal mode: paste from system clipboard
  vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
  vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste from system clipboard before cursor' })

  -- Visual mode: paste from system clipboard
  vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
end)

-- Custom keymaps
vim.keymap.set('n', '<leader>q', ':q!<CR>', { desc = 'Force quit' })
vim.keymap.set('n', '<leader>k', ':bd<CR>', { desc = 'Close buffer' })

-- Override diagnostic keymap
vim.keymap.set('n', '<leader>o', vim.diagnostic.setloclist, { desc = '[O]pen diagnostic Quickfix list' })

-- Markdown lint fix keymap (only for markdown files)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<leader>mf', function()
      vim.cmd 'silent! write'
      vim.system({ 'markdownlint-cli2', '--fix', vim.fn.expand '%' }, {
        text = false,
      }, function(result)
        if result.code == 0 then
          vim.schedule(function()
            vim.cmd 'checktime'
            print 'Markdown lint issues fixed'
          end)
        else
          vim.schedule(function()
            print('Error fixing markdown lint issues: ' .. (result.stderr or ''))
          end)
        end
      end)
    end, { desc = '[M]arkdown [F]ix lint issues', buffer = true })
  end,
})

-- TypeScript Language Server configuration with Deno exclusion
local ts_ls_config = {
  root_dir = function(fname)
    local util = require('lspconfig.util')
    -- Disable if deno.json/deno.jsonc exists (Deno project)
    if util.root_pattern('deno.json', 'deno.jsonc')(fname) then
      return nil
    end
    -- Enable for Node.js projects
    return util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git')(fname)
  end,
}

-- Register TypeScript LSP server config
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    -- This will be called when any LSP attaches
    -- Custom TypeScript configuration is handled via server-specific settings
  end,
})

-- Store TypeScript config for use in LSP setup
vim.g.custom_ts_ls_config = ts_ls_config

