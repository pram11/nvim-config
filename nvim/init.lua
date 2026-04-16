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
        if vim.lsp.config then
          pcall(require, "lspconfig.configs." .. server)
          vim.lsp.config[server] = vim.tbl_deep_extend(
            "force",
            vim.lsp.config[server] or {},
            { capabilities = caps }
          )
          vim.lsp.enable(server)
        else
          require("lspconfig")[server].setup({ capabilities = caps })
        end
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
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install({ 
        "java", "python", "javascript", "typescript", "rust", "c", "cpp", "lua", "vim", "vimdoc", "query" 
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end
  },

  -- [File Explorer] nvim-tree (좌측 디렉토리 트리)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Neovim 기본 탐색기인 netrw를 비활성화 (nvim-tree 공식 권장 사항)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Ctrl + e 로 탐색기 열기/닫기
      vim.keymap.set('n', '<C-e>', ':NvimTreeToggle<CR>', { silent = true, desc = "Toggle File Explorer" })
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
