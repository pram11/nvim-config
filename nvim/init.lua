-- ========================================================================== --
--                               1. 기본 옵션 (Options)                          --
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
--                             2. 플러그인 관리 (lazy.nvim)                      --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Neovim 0.12에서는 vim.loop 대신 vim.uv를 사용합니다.
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- [LSP] Neovim 0.12+ 전용 설정
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

      -- [수정 핵심] 0.12 버전의 lspconfig deprecation 경고를 완벽히 피하는 법:
      -- m_lsp.setup_handlers 대신 setup 내부의 handlers 속성을 사용합니다.
      m_lsp.setup({
        ensure_installed = servers,
        handlers = {
          function(server_name)
            -- require('lspconfig').server.setup 방식이 아닌 인덱싱 방식을 사용합니다.
            require('lspconfig')[server_name].setup({
              capabilities = caps,
            })
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

  -- [Highlight] Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Neovim 0.12 호환성을 위해 configs를 명시적으로 로드
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua" },
        highlight = { enable = true },
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

  -- [File Explorer] nvim-tree (모든 탭 공유 설정)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        -- 탭 간 동기화를 위한 핵심 옵션
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 30,
          side = "left",
        },
      })

      -- [자동화] 새 탭을 열 때마다 탐색기를 자동으로 열어 모든 탭에서 공통 사용 느낌을 줌
      vim.api.nvim_create_autocmd("TabNewEntered", {
        callback = function()
          require("nvim-tree.api").tree.open()
        end,
      })
    end,
  },
})

-- ========================================================================== --
--                             3. 키 매핑 (Keymaps)                            --
-- ========================================================================== --
-- 탐색기 토글 (Ctrl + n)
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

-- ========================================================================== --
--                             4. 빌드 및 실행 (Alt + r)                        --
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
