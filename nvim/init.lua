-- ========================================================================== --
--                           NVIM 기본 설정 (Options)                         --
-- ========================================================================== --
vim.opt.number = true            -- 줄 번호 표시
vim.opt.relativenumber = true    -- 상대 줄 번호 (이동 편리)
vim.opt.mouse = 'a'              -- 마우스 사용 허용
vim.opt.ignorecase = true        -- 검색 시 대소문자 무시
vim.opt.smartcase = true         -- 대문자 포함 검색 시 대소문자 구분
vim.opt.tabstop = 4              -- Tab 너비
vim.opt.shiftwidth = 4           -- 자동 들여쓰기 너비
vim.opt.expandtab = true         -- Tab을 공백으로 변환
vim.opt.termguicolors = true     -- 24비트 RGB 컬러 사용

-- ========================================================================== --
--                         플러그인 관리 (lazy.nvim)                          --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP & 언어 서버 관리
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { "neovim/nvim-lspconfig" },

  -- 언어별 특화 플러그인
  { "mfussenegger/nvim-jdtls" }, -- Java 전용

  -- 자동 완성 엔진
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- 터미널 (빌드 및 실행용)
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- 구문 강조
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- 테마 (Tokyo Night)
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, 
    config = function() vim.cmd[[colorscheme tokyonight]] end 
  },
})

-- ========================================================================== --
--                           언어별 LSP 설정 (Mason)                          --
-- ========================================================================== --
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 자동 설치 및 설정할 언어 서버 목록
local servers = { 'ts_ls', 'pyright', 'rust_analyzer', 'clangd' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup { capabilities = capabilities }
end

-- ========================================================================== --
--                     조작 최소화: 빌드 및 실행 (Alt + r)                    --
-- ========================================================================== --
local Terminal = require('toggleterm.terminal').Terminal

local function run_project()
  local file_extension = vim.fn.expand('%:e')
  local cmd = ""

  -- 언어별 실행 로직 감지
  if file_extension == 'java' then
    if vim.fn.filereadable('pom.xml') == 1 then cmd = "mvn spring-boot:run"
    elseif vim.fn.filereadable('gradlew') == 1 then cmd = "./gradlew bootRun"
    else cmd = "javac % && java %:r" end
  elseif file_extension == 'python' or file_extension == 'py' then
    cmd = "python3 %"
  elseif file_extension == 'javascript' or file_extension == 'js' then
    cmd = "node %"
  elseif file_extension == 'typescript' or file_extension == 'ts' then
    cmd = "ts-node %"
  elseif file_extension == 'rs' then
    if vim.fn.filereadable('Cargo.toml') == 1 then cmd = "cargo run"
    else cmd = "rustc % -o %:r && ./%:r" end
  elseif file_extension == 'c' or file_extension == 'cpp' then
    if vim.fn.filereadable('Makefile') == 1 then cmd = "make && ./main"
    else
        local compiler = (file_extension == 'c') and "gcc" or "g++ -std=c++17"
        cmd = compiler .. " % -o %:r && ./%:r"
    end
  end

  if cmd ~= "" then
    local exec_term = Terminal:new({ 
        cmd = cmd, 
        direction = "float", 
        close_on_exit = false,
        float_opts = { border = "double" }
    })
    exec_term:toggle()
  else
    print("지원하지 않는 파일 형식이거나 실행 명령어가 없습니다.")
  end
end

-- Alt + r 키를 눌러 바로 빌드/실행 (Normal Mode)
vim.keymap.set('n', '<M-r>', run_project, { silent = true, desc = "Build and Run Project" })

-- ========================================================================== --
--                         자동 완성 (CMP) 상세 설정                          --
-- ========================================================================== --
local cmp = require('cmp')
cmp.setup({
  snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({ { name = 'nvim_lsp' } })
})

-- ========================================================================== --
--                          Treesitter (구문 강조)                            --
-- ========================================================================== --
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
  highlight = { enable = true },
}