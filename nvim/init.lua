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
  -- LSP 관리
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { 
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- v3.0.0 대비: 각 서버를 명시적으로 루프 돌려 설정
      local servers = { 'ts_ls', 'pyright', 'rust_analyzer', 'clangd' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup { capabilities = capabilities }
      end
    end
  },

  -- Java (jdtls는 별도 설정 없이 파일 타입에 따라 로드되는 경우가 많음)
  { "mfussenegger/nvim-jdtls" },

  -- 자동 완성 (nvim-cmp)
  { 
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
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

  -- 에러 발생 지점 수정: Treesitter 설정 내재화
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
      -- 모듈 존재 여부 확인 후 안전하게 실행
      local status, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not status then
        -- 구버전이나 모듈 위치 변경 시 대응
        status, ts_configs = pcall(require, "nvim-treesitter")
      end
      
      if status and ts_configs.setup then
        ts_configs.setup({
          ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
          highlight = { enable = true },
        })
      end
    end
  },

  -- 테마
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, 
    config = function() vim.cmd[[colorscheme tokyonight]] end 
  },
})

-- ========================================================================== --
--                     조작 최소화: 빌드 및 실행 (Alt + r)                    --
-- ========================================================================== --
local function run_project()
  local file_ext = vim.fn.expand('%:e')
  local cmd = ""

  if file_ext == 'java' then
    if vim.fn.filereadable('pom.xml') == 1 then cmd = "mvn spring-boot:run"
    elseif vim.fn.filereadable('gradlew') == 1 then cmd = "./gradlew bootRun"
    else cmd = "javac % && java %:r" end
  elseif file_ext == 'py' or file_ext == 'python' then cmd = "python3 %"
  elseif file_ext == 'js' or file_ext == 'javascript' then cmd = "node %"
  elseif file_ext == 'ts' or file_ext == 'typescript' then cmd = "ts-node %"
  elseif file_ext == 'rs' then
    cmd = (vim.fn.filereadable('Cargo.toml') == 1) and "cargo run" or "rustc % -o %:r && ./%:r"
  elseif file_ext == 'c' or file_ext == 'cpp' then
    if vim.fn.filereadable('Makefile') == 1 then cmd = "make && ./main"
    else
      local compiler = (file_ext == 'c') and "gcc" or "g++ -std=c++17"
      cmd = compiler .. " % -o %:r && ./%:r"
    end
  end

  if cmd ~= "" then
    require('toggleterm.terminal').Terminal:new({ 
      cmd = cmd, 
      direction = "float", 
      close_on_exit = false 
    }):toggle()
  else
    print("실행 명령어를 찾을 수 없습니다.")
  end
end

vim.keymap.set('n', '<M-r>', run_project, { silent = true, desc = "Run Project" })
