{ config, pkgs, lib, ... }:

{
  # Enable home-manager
  programs.home-manager.enable = true;
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Mackie G";
    userEmail = "mackieg@example.com"; # Update with your email
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
      
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };
      
      merge = {
        conflictStyle = "zdiff3";
      };
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
  
  # Zsh configuration
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
    };
    
    initExtra = ''
      # Custom zsh configuration
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS
      
      # Better completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu select
    '';
    
    shellAliases = {
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
      
      # Git aliases
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      
      # Nix aliases
      nrs = "sudo nixos-rebuild switch --flake .#";
      nrb = "sudo nixos-rebuild build --flake .#";
      hms = "home-manager switch --flake .#";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nfs = "nix flake show";
      
      # Docker aliases
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      
      # Kubernetes aliases
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgd = "kubectl get deployment";
      kaf = "kubectl apply -f";
      kdel = "kubectl delete";
      klog = "kubectl logs";
    };
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        [╭─](bold green)$username$hostname$directory$git_branch$git_status$cmd_duration
        [╰─](bold green)$character
      '';
      
      username = {
        show_always = true;
        format = "[$user]($style) in ";
      };
      
      hostname = {
        ssh_only = false;
        format = "on [$hostname]($style) ";
      };
      
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
  
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
  
  # Neovim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-fugitive
      nerdtree
      fzf-vim
      coc-nvim
      vim-airline
      vim-airline-themes
      gruvbox-material
    ];
    
    extraConfig = ''
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set termguicolors
      set scrolloff=8
      set signcolumn=yes
      set updatetime=50
      
      colorscheme gruvbox-material
      
      let mapleader = " "
      
      " NERDTree
      nnoremap <leader>n :NERDTreeToggle<CR>
      
      " FZF
      nnoremap <leader>f :Files<CR>
      nnoremap <leader>g :Rg<CR>
      nnoremap <leader>b :Buffers<CR>
    '';
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