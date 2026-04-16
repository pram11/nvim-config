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
-- [수정됨] Neovim 0.12 호환성을 위해 vim.loop.fs_stat 대신 vim.uv.fs_stat 사용
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- [LSP] 0.10~0.12 모든 버전에서 에러 없는 범용 설정
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
      local lspconfig = require("lspconfig")
      local caps = require('cmp_nvim_lsp').default_capabilities()

      -- 자동 설치할 서버 목록
      local servers = { "ts_ls", "pyright", "rust_analyzer", "clangd" }

      m_lsp.setup({ ensure_installed = servers })

      -- mason-lspconfig의 버그(handlers)를 피하기 위해 수동으로 연결
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = caps })
      end
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

  -- [Highlight] Treesitter (0.12 및 v1.0+ 대응)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- [수정됨] 0.12 버전과의 충돌을 막기 위해 반드시 main 브랜치 지정
    build = ":TSUpdate",
    config = function()
      -- [수정됨] 새로운 Treesitter API 및 Neovim 0.12 내장 하이라이트 연동
      require("nvim-treesitter").setup()
      
      -- 필수 파서(c, lua, vim, vimdoc, query)를 포함하여 설치
      require("nvim-treesitter").install({ 
        "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua", "vim", "vimdoc", "query" 
      })

      -- [수정됨] Neovim 0.12부터는 파일 오픈 시 내장 vim.treesitter.start()를 호출하는 방식 권장
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end
  },

  -- [Theme] Tokyo Night
  { 
    "folke/tokyonight.nvim", 
    lazy = false, 
    priority = 1000, 
    config = function() vim.cmd[[colorscheme tokyonight]] end 
  },
})

-- ========================================================================== --
--                     3. 빌드 및 실행 (Alt + r)                              --
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
    require('toggleterm.terminal').Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
  else
    print("실행 명령을 찾을 수 없습니다.")
  end
end

vim.keymap.set('n', '<M-r>', run_project, { silent = true, desc = "Run" })
