-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- this is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mousescroll = "ver:1,hor:6"

-- setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    'ibhagwan/fzf-lua',
    'imsnif/kdl.vim',
    'martineausimon/nvim-lilypond-suite',
    'neovim/nvim-lspconfig',
    'weakish/rcshell.vim'
  },
  -- configure any other settings here. see the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- vimscript equivalents
local au = vim.api.nvim_create_autocmd

local function map(mode, lhs, rhs, opts)
  local options = {}
  if opts then
    if type(opts) == 'string' then
      opts = {desc = opts}
    end
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
local function nmap(lhs, rhs, opts)
  map('n', lhs, rhs, opts)
end
vim.api.nvim_set_hl(0, 'Function', { link = 'Identifier' })
local function tmap(lhs, rhs, opts)
  map('t', lhs, rhs, opts)
end
local function nmapp(lhs, rhs, opts)
  local options = {}
  if opts then
    if type(opts) == 'string' then
      opts = {desc = opts}
    end
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap('n', lhs, rhs, options)
end

-- minor color config
vim.cmd.colorscheme("everforest")

-- all source code gets wrapped at <80 and auto-indented
au("FileType",{
  pattern={"arduino","asm","c","cpp","go","java","javascript","php","html","make","objc","perl"},
  command="setl cc=81",
})

-- ruby and lua have soft tabs
au("FileType",{pattern={"ruby","eruby","lua"},command="setl ts=2 sw=2 tw=79 et sts=2 ai cc=81",})
au("FileType",{pattern="ruby",command="setl commentstring=#\\ %s",})
au("FileType",{pattern="yaml",command="setl ts=2 sw=2 et cc=81",})

-- makefiles and c have tabstops at 8 for portability
au("FileType",{pattern={"arduino","asm","make","c","cpp"},command="setl ts=8 sw=8",})

-- email and commit messages - expand tabs, wrap at 68 for future quoting, enable spelling
au("FileType",{pattern={"cvs","gitcommit","mail"},command="setl tw=68 et spell cc=69",})

-- rc shell
au({"BufRead","BufNewFile"},{pattern="*.rc",command="set filetype=rcshell"})

au("BufReadPost",{pattern = "*", -- fix rc shebang
  callback = function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
    if first_line:match("^#!%s*/usr/bin/env%s+rc") or first_line:match("^#!%s*/.*/rc") then
      vim.bo.syntax = "rcshell"
    end
  end,
})

-- lsp
local lspconfig = require('lspconfig')
lspconfig.gopls.setup{}
nmap('gD', function() require('fzf-lua').lsp_definitions { jump1 = false } end, 'Peek definition')
nmap('gd', function() require('fzf-lua').lsp_definitions { jump1 = true } end, 'Go to definition')
nmap('<C-k>', vim.lsp.buf.signature_help, opts)
nmap('<space>D', '<cmd>FzfLua lsp_typedefs<cr>', 'Go to type definition')
nmap('gr', '<cmd>FzfLua lsp_references<cr>', 'vim.lsp.buf.references()')
