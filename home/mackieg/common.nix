{ config, pkgs, lib, ... }:

{
  # Enable home-manager
  programs.home-manager.enable = true;
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "gmackie";
    userEmail = "graham.mackie@gmail.com";
    
    extraConfig = {
      # Core settings
      core = {
        editor = "nvim";
        excludesfile = "~/.gitignore_global";
      };
      
      # Color settings
      color = {
        ui = "always";
        branch = "always";
        diff = "always";
        interactive = "always";
        status = "always";
      };
      
      # Merge and diff settings
      merge = {
        tool = "nvim";
        conflictStyle = "zdiff3";
      };
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };
      
      # Pull/push settings
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      
      # Init settings
      init.defaultBranch = "main";
      
      # Pager settings
      pager.branch = false;
      
      # Git LFS
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
    
    aliases = {
      # From your dotfiles
      gits = "git status && git branch -vv";
      gitt = "git log --color --graph --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --decorate --branches";
      
      # Standard aliases
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
      "result"
      "result-*"
      ".direnv/"
      ".env"
      ".env.local"
      "node_modules/"
      "target/"
      "build/"
      "dist/"
    ];
  };
  
  # Zsh configuration with Powerlevel10k
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      expireDuplicatesFirst = true;
      extended = true;
    };
    
    # Environment variables from your dotfiles
    sessionVariables = {
      TERM = "xterm-256color";
    };
    
    # Shell options from your dotfiles
    defaultKeymap = "emacs";
    
    initExtra = ''
      # Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      
      # Zsh options from your dotfiles
      setopt COMPLETE_IN_WORD
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt EXTENDED_HISTORY
      setopt SHARE_HISTORY
      
      # Better completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu select
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%B%d%b'
      zstyle ':completion:*:warnings' format 'No matches for: %d'
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      
      # Custom completion paths
      fpath=(~/.zsh/completion $fpath)
      autoload -Uz compinit && compinit -i
      
      # NVM setup (if exists)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      
      # Load p10k config
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      
      # Custom keybindings
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H' backward-kill-word
      bindkey '^[[3;5~' kill-word
      
      # PATH additions from your dotfiles
      export PATH="$HOME/bin:$HOME/.cargo/bin:$HOME/.rbenv/bin:$HOME/.local/bin:$HOME/fpga-toolchain/bin:$HOME/.dotnet:$PATH"
    '';
    
    shellAliases = {
      # From your dotfiles
      gits = "git status && git branch -vv";
      gitt = "git log --color --graph --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --decorate --branches";
      
      # Enhanced commands
      ll = "eza -la";
      la = "eza -a";
      ls = "eza";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      ps = "procs";
      top = "btop";
      du = "dust";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake .#";
      nrb = "sudo nixos-rebuild build --flake .#";
      hms = "home-manager switch --flake .#";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nfs = "nix flake show";
      
      # Docker shortcuts
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      
      # Kubernetes shortcuts
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgd = "kubectl get deployment";
      kaf = "kubectl apply -f";
      kdel = "kubectl delete";
      klog = "kubectl logs";
    };
    
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };
  
  # Powerlevel10k config file
  home.file.".p10k.zsh".source = ../dotfiles/p10k.zsh;
  
  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
  # FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Bat
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      number = true;
    };
  };
  
  # Tmux
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    
    extraConfig = ''
      # Enable mouse support
      set -g mouse on
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
    '';
  };
  
  # Neovim configuration with proper plugin setup
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set autoindent
      set wrap
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set termguicolors
      set scrolloff=8
      set sidescrolloff=8
      set signcolumn=yes
      set updatetime=250
      set timeoutlen=300
      set completeopt=menuone,noselect
      set undofile
      set splitbelow
      set splitright
      
      " Leader key
      let mapleader = " "
      let maplocalleader = " "
      
      " Basic keymaps
      nnoremap <Esc> <cmd>nohlsearch<CR>
      nnoremap <leader>q <cmd>quit<CR>
      nnoremap <leader>w <cmd>write<CR>
      
      " Better up/down
      nnoremap j gj
      nnoremap k gk
      
      " Move to window using the <ctrl> hjkl keys
      nnoremap <C-h> <C-w><C-h>
      nnoremap <C-l> <C-w><C-l>
      nnoremap <C-j> <C-w><C-j>
      nnoremap <C-k> <C-w><C-k>
      
      " Resize with arrows
      nnoremap <C-Up> :resize +2<CR>
      nnoremap <C-Down> :resize -2<CR>
      nnoremap <C-Left> :vertical resize -2<CR>
      nnoremap <C-Right> :vertical resize +2<CR>
      
      " Move text up and down
      nnoremap <A-j> :m .+1<CR>==
      nnoremap <A-k> :m .-2<CR>==
      inoremap <A-j> <Esc>:m .+1<CR>==gi
      inoremap <A-k> <Esc>:m .-2<CR>==gi
      vnoremap <A-j> :m '>+1<CR>gv=gv
      vnoremap <A-k> :m '<-2<CR>gv=gv
      
      " Better indenting
      vnoremap < <gv
      vnoremap > >gv
      
      " Diagnostic keymaps
      nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>
      nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>
      nnoremap <leader>e <cmd>lua vim.diagnostic.open_float()<CR>
      nnoremap <leader>lq <cmd>lua vim.diagnostic.setloclist()<CR>
    '';
    
    plugins = [
      # Mason for LSP/DAP/Linter management
      {
        plugin = pkgs.vimPlugins.mason-nvim;
        type = "lua";
        config = ''
          require("mason").setup({
            ui = {
              icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
              }
            }
          })
        '';
      }
      
      {
        plugin = pkgs.vimPlugins.mason-lspconfig-nvim;
        type = "lua";
        config = ''
          require("mason-lspconfig").setup({
            ensure_installed = {
              -- System languages
              "clangd",          -- C/C++
              "rust_analyzer",   -- Rust
              "gopls",           -- Go
              "zls",            -- Zig
              
              -- Web languages
              "ts_ls",          -- TypeScript/JavaScript
              "html",           -- HTML
              "cssls",          -- CSS
              "intelephense",   -- PHP
              
              -- JVM languages
              "jdtls",          -- Java
              "metals",         -- Scala
              "kotlin_language_server", -- Kotlin
              
              -- Hardware languages
              "verible",        -- Verilog/SystemVerilog
              
              -- Scripting
              "pyright",        -- Python
              "lua_ls",         -- Lua
              "bashls",         -- Bash
              
              -- Config languages
              "nil_ls",         -- Nix
              "jsonls",         -- JSON
              "yamlls",         -- YAML
              "taplo",          -- TOML
              
              -- Other
              "dockerls",       -- Docker
              "cmake",          -- CMake
            },
            automatic_installation = true,
          })
        '';
      }
      
      # LSP Configuration
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        type = "lua";
        config = ''
          local lspconfig = require('lspconfig')
          local mason_lspconfig = require('mason-lspconfig')
          
          -- LSP attach function
          local on_attach = function(client, bufnr)
            local nmap = function(keys, func, desc)
              if desc then
                desc = 'LSP: ' .. desc
              end
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
            end
            
            nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
            nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
            nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
            nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
            nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
            nmap('<leader>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, '[W]orkspace [L]ist Folders')
          end
          
          -- Capabilities for completion
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
          
          -- Setup LSP servers
          mason_lspconfig.setup_handlers({
            function(server_name)
              lspconfig[server_name].setup({
                capabilities = capabilities,
                on_attach = on_attach,
              })
            end,
            
            -- Custom configurations
            ["lua_ls"] = function()
              lspconfig.lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                  Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                    diagnostics = { globals = { 'vim' } },
                  },
                },
              })
            end,
            
            ["jdtls"] = function()
              -- Java LSP handled by nvim-jdtls plugin
            end,
          })
          
          -- Diagnostic configuration
          vim.diagnostic.config({
            virtual_text = {
              spacing = 4,
              source = "if_many",
              prefix = "●",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
              source = "always",
              border = "rounded",
            },
          })
        '';
      }
      
      # GitHub Copilot
      {
        plugin = pkgs.vimPlugins.copilot-vim;
        type = "lua";
        config = ''
          vim.g.copilot_no_tab_map = true
          vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
          vim.g.copilot_filetypes = {
            ["*"] = false,
            ["javascript"] = true,
            ["typescript"] = true,
            ["lua"] = false,
            ["rust"] = true,
            ["c"] = true,
            ["c#"] = true,
            ["c++"] = true,
            ["go"] = true,
            ["python"] = true,
          }
        '';
      }
      
      # Copilot LSP for more advanced features
      {
        plugin = pkgs.vimPlugins.copilot-lsp;
        type = "lua";
        config = ''
          require("lspconfig").copilot.setup({
            on_attach = function(client, bufnr)
              -- Disable hover in favor of copilot suggestions
              client.server_capabilities.hoverProvider = false
            end,
          })
        '';
      }
      
      # Completion
      {
        plugin = pkgs.vimPlugins.nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')
          local luasnip = require('luasnip')
          require('luasnip.loaders.from_vscode').lazy_load()
          luasnip.config.setup {}
          
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert {
              ['<C-n>'] = cmp.mapping.select_next_item(),
              ['<C-p>'] = cmp.mapping.select_prev_item(),
              ['<C-d>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete {},
              ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              },
              ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_locally_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.locally_jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            },
            sources = {
              { name = 'copilot' },
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'path' },
              { name = 'buffer' },
            },
          }
        '';
      }
      
      # Completion sources
      pkgs.vimPlugins.cmp-nvim-lsp
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.cmp-path
      pkgs.vimPlugins.cmp-cmdline
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.cmp_luasnip
      pkgs.vimPlugins.friendly-snippets
      
      # Treesitter with comprehensive language support
      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
          # System languages
          p.tree-sitter-c
          p.tree-sitter-cpp
          p.tree-sitter-rust
          p.tree-sitter-go
          p.tree-sitter-zig
          
          # Web languages
          p.tree-sitter-html
          p.tree-sitter-css
          p.tree-sitter-javascript
          p.tree-sitter-typescript
          p.tree-sitter-tsx
          p.tree-sitter-php
          
          # JVM languages
          p.tree-sitter-java
          p.tree-sitter-scala
          p.tree-sitter-kotlin
          
          # Hardware description languages
          p.tree-sitter-verilog
          
          # Scripting languages
          p.tree-sitter-python
          p.tree-sitter-ruby
          p.tree-sitter-lua
          p.tree-sitter-bash
          p.tree-sitter-fish
          
          # Config/Data languages
          p.tree-sitter-nix
          p.tree-sitter-json
          p.tree-sitter-yaml
          p.tree-sitter-toml
          p.tree-sitter-xml
          p.tree-sitter-sql
          
          # Documentation
          p.tree-sitter-markdown
          p.tree-sitter-vimdoc
          p.tree-sitter-vim
          
          # Other useful languages
          p.tree-sitter-dockerfile
          p.tree-sitter-cmake
          p.tree-sitter-make
          p.tree-sitter-regex
          p.tree-sitter-git-config
          p.tree-sitter-git-rebase
          p.tree-sitter-gitcommit
          p.tree-sitter-gitignore
        ]);
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup {
            auto_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = '<c-space>',
                node_incremental = '<c-space>',
                scope_incremental = '<c-s>',
                node_decremental = '<M-space>',
              },
            },
          }
        '';
      }
      pkgs.vimPlugins.nvim-treesitter-textobjects
      
      # Telescope
      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup {
            defaults = {
              mappings = {
                i = {
                  ['<C-u>'] = false,
                  ['<C-d>'] = false,
                },
              },
            },
          }
          
          -- Enable telescope fzf native
          pcall(require('telescope').load_extension, 'fzf')
          
          -- Telescope keymaps
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
          vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
          vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
          vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
          vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
          vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
          vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
          vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
          vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
          vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
        '';
      }
      pkgs.vimPlugins.telescope-fzf-native-nvim
      
      # Harpoon 2
      {
        plugin = pkgs.vimPlugins.harpoon2;
        type = "lua";
        config = ''
          local harpoon = require("harpoon")
          harpoon:setup()
          
          vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "Harpoon: Add file" })
          vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Quick menu" })
          
          vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: File 1" })
          vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: File 2" })
          vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon: File 3" })
          vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon: File 4" })
          
          vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon: Previous" })
          vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Harpoon: Next" })
        '';
      }
      
      # UI enhancements
      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              theme = 'auto',
              component_separators = { left = '', right = ''},
              section_separators = { left = '', right = ''},
            },
            sections = {
              lualine_a = {'mode'},
              lualine_b = {'branch', 'diff', 'diagnostics'},
              lualine_c = {'filename'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            },
          }
        '';
      }
      
      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup()
        '';
      }
      
      # Color schemes
      {
        plugin = pkgs.vimPlugins.tokyonight-nvim;
        type = "lua";
        config = ''
          require("tokyonight").setup({
            style = "storm",
            transparent = false,
            terminal_colors = true,
          })
          vim.cmd[[colorscheme tokyonight]]
        '';
      }
      pkgs.vimPlugins.gruvbox-material
      pkgs.vimPlugins.catppuccin-nvim
      
      # Navigation and utilities
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.indent-blankline-nvim
      pkgs.vimPlugins.nvim-tree-lua
      pkgs.vimPlugins.vim-fugitive
      pkgs.vimPlugins.vim-rhubarb
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.rust-vim
      pkgs.vimPlugins.which-key-nvim
      pkgs.vimPlugins.comment-nvim
      pkgs.vimPlugins.nvim-autopairs
      pkgs.vimPlugins.todo-comments-nvim
      pkgs.vimPlugins.trouble-nvim
      
      # Debug adapter
      pkgs.vimPlugins.nvim-dap
      pkgs.vimPlugins.nvim-dap-ui
      pkgs.vimPlugins.nvim-dap-virtual-text
    ];
  };
  
  # VS Code
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
      golang.go
      rust-lang.rust-analyzer
      hashicorp.terraform
      redhat.vscode-yaml
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
      bbenoist.nix
    ];
  };
}