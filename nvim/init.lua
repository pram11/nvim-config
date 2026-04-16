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
  -- [LSP] 현대적인 설정 방식 (0.11, 0.12 대응)
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
      
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "pyright", "rust_analyzer", "clangd", "jdtls" },
        handlers = {
          function(server_name)
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

  -- [Terminal] 빌드 및 실행용
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- [Highlight] Treesitter (0.12 최신 호환)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 최신 버전의 모듈 호출 방식
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
        highlight = { enable = true },
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
    print("지원하지 않는 파일 형식입니다.")
  end
end

-- Alt + r 단축키 설정
vim.keymap.set('n', '<M-r>', run_project, { silent = true, desc = "Run Project" })
