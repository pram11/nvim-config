-- ========================================================================== --
--                           NVIM 기본 설정 (Options)                         --
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
--                         플러그인 관리 (lazy.nvim)                          --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP 관리 (최신 v3.0.0 대응 구조)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- mason-lspconfig의 handlers를 사용하여 lspconfig 프레임워크 경고 해결
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "pyright", "rust_analyzer", "clangd", "jdtls" },
        handlers = {
          function(server_name)
            if server_name ~= "jdtls" then
              -- require('lspconfig') 호출 대신 직접 서버 설정 호출 (v3.0 대응)
              require("lspconfig")[server_name].setup({
                capabilities = capabilities,
              })
            end
          end,
        },
      })
    end
  },

  -- Java 전용 (nvim-jdtls)
  { "mfussenegger/nvim-jdtls" },

  -- 자동 완성 (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({ { name = 'nvim_lsp' } })
      })
    end
  },

  -- 터미널 (Alt+r 실행용)
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- 에러 발생 지점 수정: nvim-treesitter v1.0+ 대응
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 2026년 최신 버전에서는 configs 모듈 대신 메인 모듈에서 직접 setup하거나 
      -- 모듈 존재 여부를 안전하게 확인해야 합니다.
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then ts = require("nvim-treesitter") end

      ts.setup({
        ensure_installed = {
