-- ========================================================================== --
--                            1. 기본 옵션 (Options)                             --
-- ========================================================================== --
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- ========================================================================== --
--                        2. 플러그인 관리 (lazy.nvim)                           --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- [LSP] 0.11~0.12 최신 네이티브 방식 대응 완료
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      local m_lsp = require("mason-lspconfig")
      local caps = require('cmp_nvim_lsp').default_capabilities()

      local servers = { "ts_ls", "pyright", "rust_analyzer", "clangd" }

      m_lsp.setup({ ensure_installed = servers })

      -- Nvim 0.12 (Nightly) 최신 규격 대응 (Deprecation 에러 해결)
      for _, server in ipairs(servers) do
