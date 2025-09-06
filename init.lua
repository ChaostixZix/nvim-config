-- bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({
  -- Neo-tree (file explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- icons
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = { follow_current_file = { enabled = true } },
      })
      -- auto open Neo-tree when starting with a folder
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local arg = vim.fn.argv(0)
          if vim.fn.isdirectory(arg) == 1 then
            require("neo-tree.command").execute({ dir = arg })
          end
        end,
      })
      -- keymap: toggle with <leader>e
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })
    end,
  },

  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "html", "css" }, -- add more langs
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "neo-tree", text = "File Explorer", separator = true },
          },
        },
      })
      -- keymaps for cycling buffers
      vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
      vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true })
    end,
  },

  -- Gitsigns (git gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Buffer delete (safer buffer close)
  {
    "famiu/bufdelete.nvim",
    config = function()
      -- safer buffer close
      vim.keymap.set("n", "<C-q>", ":Bdelete<CR>", { noremap = true, silent = true })
    end,
  },
  -- Copilot (AI code completion)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-J>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },
	{
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier, -- JS/TS/HTML/CSS
        null_ls.builtins.formatting.stylua,   -- Lua
        null_ls.builtins.formatting.black,    -- Python
      },
    })
  end,
},

  -- nvim-cmp (completion engine)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')

      cmp.setup({
        mapping = {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require('copilot.suggestion').is_visible() then
              require('copilot.suggestion').accept()
            else
              fallback()  -- Ini yang akan mengaktifkan indentasi default
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
      })
    end,
  },

	})

-- Terminal keymaps
-- Single Esc stays in terminal app; double Esc escapes to Normal mode
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], {silent = true})


-- Keep Neovim alive when the last buffer is closed
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    if vim.fn.bufnr('$') == 1 then
      vim.cmd("enew")  -- open an empty [No Name] buffer
    end
  end,
})

-- General UI tweaks
vim.o.number = true          -- line numbers
vim.o.relativenumber = true  -- relative line numbers
vim.o.termguicolors = true   -- better colors
vim.opt.shell = "/opt/homebrew/bin/zsh"

-- Zsh shell configuration
vim.opt.shellcmdflag = "-c"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- Custom command alias for Neotree toggle
vim.api.nvim_create_user_command('Ntt', 'Neotree toggle', {})
