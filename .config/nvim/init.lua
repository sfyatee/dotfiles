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

-- setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    'martineausimon/nvim-lilypond-suite'
  },
  -- configure any other settings here. see the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- vim opts
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

-- XXX
vim.opt.termguicolors = false

-- ruby and lua have soft tabs
au("FileType", { pattern = { "ruby", "eruby", "lua" }, command = "setlocal ts=2 sw=2 tw=79 et sts=2 autoindent colorcolumn=81",})
au("FileType", { pattern = "ruby", command = "setlocal commentstring=#\\ %s",})
au("FileType", { pattern = "yaml", command = "setlocal ts=2 sw=2 et colorcolumn=81",})
