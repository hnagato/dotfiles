-- Custom plugins and plugin overrides
return {
  -- Custom colorscheme: Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1001, -- Load after tokyonight (priority 1000)
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
        colors = {
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors)
          return {}
        end,
        theme = "dragon",
        background = {
          dark = "dragon",
          light = "lotus",
        },
      })

      -- Apply colorscheme after all plugins are loaded
      vim.schedule(function()
        vim.cmd.colorscheme("kanagawa")
      end)
    end,
  },

  -- Enhanced statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup({
        options = {
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "filename", "branch" },
          lualine_c = {
            "%=", -- Center components placeholder
          },
          lualine_x = {},
          lualine_y = { "filetype", "progress" },
          lualine_z = {
            { "location", separator = { right = "" }, left_padding = 2 },
          },
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
        tabline = {},
        extensions = {},
      })
    end,
  },

  -- Enhanced surround functionality
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Use defaults
      })
    end,
  },

  -- GitHub Copilot integration
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
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      })
    end,
  },

  -- Additional kickstart plugins (enabled)
  require("kickstart.plugins.indent_line"),
  require("kickstart.plugins.lint"),
  require("kickstart.plugins.autopairs"),
  require("kickstart.plugins.neo-tree"),
  require("kickstart.plugins.gitsigns"),

  -- Enhanced LSP server configurations
  {
    "neovim/nvim-lspconfig",
    opts = function()
      return {
        -- Add TypeScript server with Deno exclusion
        servers = {
          ts_ls = vim.g.custom_ts_ls_config or {},
          -- Enhanced Lua server
          lua_ls = {
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          },
        },
        -- Mason tool installer additions
        ensure_installed = {
          "stylua",
          "typescript-language-server",
          "markdownlint-cli2",
        },
        -- Custom LSP setup function
        setup = {
          denols = function()
            return true -- Disable denols completely
          end,
        },
      }
    end,
  },

  -- Enhanced conform formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "markdownlint-cli2" },
      },
    },
  },
}
