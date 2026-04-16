-- ========================================================================== --
--                           1. 기본 옵션 (Options)                           --
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
--                        2. 플러그인 관리 (lazy.nvim)                         --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- [LSP] Neovim 0.12 내장 vim.lsp.config 최적화
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
      
      -- 최신 mason-lspconfig 핸들러 설정 (v3.0.0 대응)
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "pyright", "rust_analyzer", "clangd", "jdtls" },
        handlers = {
          function(server_name)
            if server_name ~= "jdtls" then
              -- lspconfig 프레임워크 경고 없이 직접 설정 호출
              require("lspconfig")[server_name].setup({
                capabilities = capabilities,
              })
            end
          end,
        },
      })
    end
  },

  -- [Java] nvim-jdtls
  { "mfussenegger/nvim-jdtls" },

  -- [Completion] nvim-cmp
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

  -- [Terminal] ToggleTerm
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- [Highlight] nvim-treesitter (v1.0+ / 0.12 대응 수정 완료)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 중요: 더 이상 'nvim-treesitter.configs'를 사용하지 않습니다.
      local ts = require("nvim-treesitter")
      ts.setup({
        ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- [Theme] Tokyo Night
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, 
    config = function() vim.cmd[[colorscheme tokyonight]] end 
  },
})

-- ========================================================================== --
--                     3. 조작 최소화: 빌드 및 실행 (Alt + r)                    --
-- ========================================================================== --
local function run_project()
  local file_ext = vim.fn.expand('%:e')
  local cmd = ""

  -- 언어별 실행 로직
  if file_ext == 'java' then
    if vim.fn.filereadable('pom.xml') == 1 then cmd = "mvn spring-boot:run"
    elseif vim.fn.
