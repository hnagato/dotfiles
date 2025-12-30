vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- Use a writable cache path for the Lua module loader
if vim.loader then
  local lua_cache = vim.fn.stdpath('state') .. '/luac'
  vim.loader.path = lua_cache
  vim.fn.mkdir(lua_cache, 'p')
end

-- Vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.confirm = true

-- =============================================================================
-- BASIC KEYMAPS
-- =============================================================================

-- Clear search highlight on escape
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')


-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Save without autocommands (no auto-formatting)
vim.keymap.set('n', '<leader>w', ':noautocmd w<CR>', { desc = 'Save without autocommands (no auto-formatting)' })

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- =============================================================================
-- PLUGIN MANAGER SETUP
-- =============================================================================

-- Install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- PLUGIN CONFIGURATION
-- =============================================================================

require('lazy').setup({
  -- Essential utilities
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically


  -- Key mappings helper
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>',
          F5 = '<F5>', F6 = '<F6>', F7 = '<F7>', F8 = '<F8>',
          F9 = '<F9>', F10 = '<F10>', F11 = '<F11>', F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = '[S]earch [H]elp' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = '[S]earch [K]eymaps' },
      { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = '[S]earch [F]iles' },
      { '<leader>ss', '<cmd>Telescope builtin<cr>', desc = '[S]earch [S]elect Telescope' },
      { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = '[S]earch current [W]ord' },
      { '<leader>sg', '<cmd>Telescope live_grep<cr>', desc = '[S]earch by [G]rep' },
      { '<leader>sd', '<cmd>Telescope diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', '<cmd>Telescope resume<cr>', desc = '[S]earch [R]esume' },
      { '<leader>s.', '<cmd>Telescope oldfiles<cr>', desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader><leader>', '<cmd>Telescope buffers<cr>', desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false }) end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() require('telescope.builtin').live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { '%.git/.*' },
          },
        },
      }

      -- Enable extensions
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },

  -- LSP Configuration
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- LSP key mappings
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- Document highlight
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Language servers
      local servers = {
        ts_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        gopls = {},
        rust_analyzer = {},
        kotlin_language_server = {},
        jdtls = {},
        bashls = {},
        marksman = {
          cmd = { 'marksman', 'server', '--config', vim.fn.expand('~/.config/nvim/marksman/global.toml') }
        },
      }

      -- Setup Mason
      require('mason').setup()
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'biome',
        'markdownlint',
        'marksman',
        'gofumpt',
        'goimports',
        'rustfmt',
        'ktfmt',
        'detekt',
        'google-java-format',
        'shfmt',
        'shellcheck',
        'textlint',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            -- Block fish-lsp to prevent resource issues
            if server_name == 'fish_lsp' then
              return
            end

            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Autocompletion
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      keymap = {
        preset = 'enter',
        ['<C-e>'] = {},  -- Disable <C-e> for copilot integration
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      completion = {
        list = {
          selection = { preselect = false }
        }
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { "sources.default" }
  },

  -- Colorschemes
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true,
        dimInactive = false,
        terminalColors = true,
        theme = "dragon",
        background = {
          dark = "dragon",
          light = "lotus",
        },
      })
    end,
  },

  {
    "Tsuzat/NeoSolarized.nvim",
    lazy = false,
    priority = 999,
  },

  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 997,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
    end,
  },

  -- Theme switcher based on environment variable
  {
    dir = ".",
    name = "theme-switcher",
    lazy = false,
    priority = 998,
    config = function()
      local nvim_theme = os.getenv("NVIM_THEME") or "kanagawa"

      -- Helper function to apply transparency
      local function apply_transparency()
        vim.cmd([[
          highlight Normal guibg=NONE ctermbg=NONE
          highlight NonText guibg=NONE ctermbg=NONE
          highlight NormalNC guibg=NONE ctermbg=NONE
        ]])
      end

      local should_apply_transparency = false

      if nvim_theme:match("^solarized_") then
        local style = nvim_theme == "solarized_light" and "light" or "dark"

        require("NeoSolarized").setup({
          style = style,
          transparent = (style == "dark"),
          terminal_colors = true,
          enable_italics = true,
          styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = { bold = true },
            variables = {},
            string = { italic = true },
          },
          underline = true,
          undercurl = true,
        })
        vim.cmd.colorscheme("NeoSolarized")

        -- NeoSolarized handles transparency internally for dark themes
        should_apply_transparency = false
      elseif nvim_theme:match("^gruvbox_") then
        local background = nvim_theme == "gruvbox_light_hard" and "light" or "dark"
        vim.o.background = background
        vim.cmd.colorscheme("gruvbox")

        -- Apply transparency for dark gruvbox themes
        should_apply_transparency = (background == "dark")
      else
        vim.cmd.colorscheme("kanagawa")

        -- Apply transparency for kanagawa (always dark)
        should_apply_transparency = true
      end

      -- Apply transparency once at the end if needed
      if should_apply_transparency then
        apply_transparency()
      end
    end,
  },

  -- Additional plugins
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },

  -- Text objects and surroundings
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },


  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { 'mode'} },
        lualine_b = { 'filename', 'branch' },
        lualine_c = {
          '%=',
          {
            'diagnostics',
            sources = { 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            colored = true,
            update_in_insert = false,
            diagnostics_color = {
              error = { fg = '#c4746e' }, -- dragonRed
              warn  = { fg = '#c4b28a' }, -- dragonYellow
              info  = { fg = '#8ba4b0' }, -- dragonBlue2
              hint  = { fg = '#8992a7' }, -- dragonViolet
            },
          },
          {
            function()
              local clients = vim.lsp.get_clients()
              if next(clients) == nil then
                return ''
              end
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return ' LSP: ' .. table.concat(names, ', ')
            end,
            color = { fg = '#8ba4b0' }, -- dragonBlue2 from kanagawa-dragon
            cond = function()
              return next(vim.lsp.get_clients()) ~= nil
            end,
          },
          {
            'searchcount',
            maxcount = 999,
            timeout = 500,
          },
        },
        lualine_x = {
          {
            'diff',
            colored = true,
            symbols = { added = '+', modified = '~', removed = '-' },
            diff_color = {
              added    = { fg = '#87a987' }, -- dragonGreen
              modified = { fg = '#c4b28a' }, -- dragonYellow
              removed  = { fg = '#c4746e' }, -- dragonRed
            },
          },
        },
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location' },
        },
      },
      inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
      },
    },
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ["\\"] = "close_window",
          },
        },
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable for specific filetypes if needed
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        typescript = { 'biome' },
        typescriptreact = { 'biome' },
        javascript = { 'biome' },
        javascriptreact = { 'biome' },
        json = { 'biome' },
        jsonc = { 'biome' },
        css = { 'biome' },
        markdown = { 'markdownlint-cli2' },
        go = { 'gofumpt' },
        kotlin = { 'ktfmt' },
        rust = { 'rustfmt' },
        java = { 'google-java-format' },
        fish = { 'fish_indent' },
      },
      -- Configure formatters to respect .editorconfig
      formatters = {
        stylua = {
          prepend_args = function()
            local editorconfig = vim.fn.findfile('.editorconfig', '.;')
            if editorconfig ~= '' then
              return { "--respect-ignores" }
            end
            return {}
          end,
        },
        biome = {
          args = { "format", "--stdin-file-path", "$FILENAME", "--use-editorconfig=true" },
          stdin = true,
        },
        ktfmt = {
          args = { '--google-style', '-' },
          stdin = true,
        },
        fish_indent = {
          command = 'fish_indent',
          args = {},
          stdin = true,
        },
      },
      -- Enable .editorconfig support globally
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Custom textlint linter definition
      lint.linters.textlint = {
        cmd = 'npx',
        stdin = true,
        args = {
          'textlint',
          '--format', 'json',
          '--stdin',
          '--stdin-filename',
          function()
            return vim.api.nvim_buf_get_name(0)
          end
        },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local diagnostics = {}
          if output and output ~= "" then
            local ok, result = pcall(vim.json.decode, output)
            if ok and type(result) == "table" and #result > 0 then
              for _, file_result in ipairs(result) do
                if file_result.messages then
                  for _, message in ipairs(file_result.messages) do
                    table.insert(diagnostics, {
                      lnum = (message.line or 1) - 1,
                      col = (message.column or 1) - 1,
                      end_lnum = (message.line or 1) - 1,
                      end_col = (message.column or 1) - 1,
                      severity = message.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                      message = message.message or "textlint error",
                      source = "textlint",
                      code = message.ruleId,
                    })
                  end
                end
              end
            end
          end
          return diagnostics
        end,
      }

      lint.linters_by_ft = {
        markdown = {'markdownlint-cli2', 'textlint'},
        mdx = {'textlint'},
        javascript = {'biomejs'},
        typescript = {'biomejs'},
        javascriptreact = {'biomejs'},
        typescriptreact = {'biomejs'},
        json = {'biomejs'},
        jsonc = {'biomejs'},
        kotlin = {'detekt'},
        sh = {'shellcheck'},
        fish = {},
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      -- Configure markdownlint-cli2 with dynamic config resolution
      -- Function to update markdownlint-cli2 args based on available config files
      local function update_markdownlint_config()
        -- Check for local config files in order of precedence
        local config_files = {
          ".markdownlint-cli2.jsonc",
          ".markdownlint-cli2.yaml",
          ".markdownlint.jsonc",
          ".markdownlint.json"
        }

        for _, config_file in ipairs(config_files) do
          if vim.fn.filereadable(config_file) == 1 then
            lint.linters['markdownlint-cli2'].args = {"--config", config_file}
            return
          end
        end

        -- Fallback to global config if no local config found
        local global_config = vim.fn.expand("~/.markdownlint-cli2.jsonc")
        if vim.fn.filereadable(global_config) == 1 then
          lint.linters['markdownlint-cli2'].args = {"--config", global_config}
        else
          lint.linters['markdownlint-cli2'].args = {}
        end
      end

      -- Create autocmd to dynamically configure markdownlint-cli2 for markdown files
      vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
        pattern = "*.md",
        group = lint_augroup,
        callback = update_markdownlint_config
      })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Ensure nvim-lint is fully loaded before trying to lint
          local ok, lint_module = pcall(require, "lint")
          if ok and lint_module and lint_module.try_lint then
            lint_module.try_lint()
          end
        end,
      })

      vim.keymap.set("n", "<leader>l", function()
        local ok, lint_module = pcall(require, "lint")
        if ok and lint_module and lint_module.try_lint then
          lint_module.try_lint()
        end
      end, { desc = "[L]int current file" })

      -- textlint auto-fix keymap
      vim.keymap.set("n", "<leader>tf", function()
        local filetype = vim.bo.filetype
        if filetype == "markdown" or filetype == "mdx" then
          vim.cmd("silent! write")
          vim.system({ "npx", "textlint", "--fix", vim.fn.expand("%") }, {
            text = false,
          }, function(result)
            if result.code == 0 then
              vim.schedule(function()
                vim.cmd("checktime")
                print("textlint auto-fix applied")
              end)
            else
              vim.schedule(function()
                print("Error applying textlint fixes: " .. (result.stderr or ""))
              end)
            end
          end)
        else
          print("textlint fix only available for markdown/mdx files")
        end
      end, { desc = "[T]extlint [F]ix" })
    end,
  },

  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        filetypes = {
          gitcommit = true,
          gitrebase = true,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-e>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      })

      -- Hide copilot when blink.cmp menu is open to prevent conflicts
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").dismiss()
          end
        end,
      })
    end,
  },

  -- LazyGit integration
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "[L]azy[G]it" },
    },
  },


  -- Diagnostics UI
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        preview_float = {
          mode = "diagnostics",
          preview = {
            type = "float",
            relative = "editor",
            border = "rounded",
            title = "Preview",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.3, height = 0.3 },
            zindex = 200,
          },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- tiny-inline-diagnostic
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require('tiny-inline-diagnostic').setup()
      vim.diagnostic.config({ virtual_text = false })
    end
  },

  -- markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {},
  },

  -- Kickstart plugins
  require('kickstart.plugins.gitsigns'),
  require('kickstart.plugins.debug'),

}, {
  git = {
    url_format = "git@github.com:%s.git",
  },
  rocks = {
    enabled = true,
    hererocks = true,
  },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- =============================================================================
-- CUSTOM CONFIGURATION
-- =============================================================================

-- Custom options
vim.g.yankring_history_dir = "~/.local/share/nvim/tmp"
vim.opt.autochdir = false

-- Modified clipboard settings for selective synchronization
vim.schedule(function()
  -- Disable automatic clipboard sync
  vim.opt.clipboard = ""

  -- Explicit clipboard keymaps
  vim.keymap.set("v", "y", '"+y', { desc = "Yank to system clipboard" })
  vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
  vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste from system clipboard before cursor" })
  vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
end)

-- Custom keymaps
vim.keymap.set("n", "<leader>q", ":q!<CR>", { desc = "Force [Q]uit" })
vim.keymap.set("n", "<leader>k", ":bd<CR>", { desc = "Close buffer" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>o", vim.diagnostic.setloclist, { desc = "[O]pen diagnostic Quickfix list" })

-- Markdown and MDX filetype configuration
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown", "mdx"},
  callback = function()
    -- Enable concealing for better markdown editing experience
    vim.opt_local.conceallevel = 2

    -- Markdown lint fix keymap
    vim.keymap.set("n", "<leader>mf", function()
      vim.cmd("silent! write")
      vim.system({ "markdownlint-cli2", "--fix", vim.fn.expand("%") }, {
        text = false,
      }, function(result)
        if result.code == 0 then
          vim.schedule(function()
            vim.cmd("checktime")
            print("Markdown lint issues fixed")
          end)
        else
          vim.schedule(function()
            print("Error fixing markdown lint issues: " .. (result.stderr or ""))
          end)
        end
      end)
    end, { desc = "[M]arkdown [F]ix lint issues", buffer = true })
  end,
})

-- TypeScript Language Server configuration with Deno exclusion
local ts_ls_config = {
  root_dir = function(fname)
    local util = require("lspconfig.util")
    -- Disable if deno.json/deno.jsonc exists (Deno project)
    if util.root_pattern("deno.json", "deno.jsonc")(fname) then
      return nil
    end
    -- Enable for Node.js projects
    return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
  end,
}

-- Register TypeScript LSP server config
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    -- Custom TypeScript configuration is handled via server-specific settings
  end,
})

-- Store TypeScript config for use in LSP setup
vim.g.custom_ts_ls_config = ts_ls_config

-- =============================================================================
-- PROVIDER CONFIGURATION
-- =============================================================================

-- Disable unused providers to eliminate warnings
vim.g.loaded_perl_provider = 0  -- Disable Perl provider
vim.g.loaded_ruby_provider = 0  -- Disable Ruby provider

-- Configure provider paths if needed
-- vim.g.python3_host_prog = '/path/to/python3'
vim.g.node_host_prog = vim.fn.exepath('neovim-node-host')

-- vim: ts=2 sts=2 sw=2 et
