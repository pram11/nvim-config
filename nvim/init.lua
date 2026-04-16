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
  -- LSP 관련 플러그인
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Neovim 0.11+ / lspconfig v3.0.0 대응 설정
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "pyright", "rust_analyzer", "clangd", "jdtls" },
        handlers = {
          -- 이 방식이 lspconfig v3.0.0에서 권장하는 자동 설정 방식입니다.
          function(server_name)
            -- Java는 nvim-jdtls가 따로 처리하므로 무시합니다.
            if server_name ~= "jdtls" then
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

  -- 터미널 (Alt+r 빌드/실행용)
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- 구문 강조 (에러 방지 구조)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- nvim-treesitter 1.0+ 버전 대응
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
        highlight = { enable = true },
      })
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

  -- 언어별 실행 로직 (확장자 기반)
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
