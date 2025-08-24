{ config, pkgs, lib, ... }:

{
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
    
    # Zsh options
    setOptions = [
      "COMPLETE_IN_WORD"
      "HIST_EXPIRE_DUPS_FIRST"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_IGNORE_SPACE"
      "HIST_FIND_NO_DUPS"
      "HIST_SAVE_NO_DUPS"
      "EXTENDED_HISTORY"
      "SHARE_HISTORY"
    ];
    
    # Environment variables
    sessionVariables = {
      TERM = "xterm-256color";
      PATH = "$HOME/bin:$HOME/.cargo/bin:$HOME/.rbenv/bin:$HOME/.local/bin:$HOME/fpga-toolchain/bin:$HOME/.dotnet:$PATH";
    };
    
    # Shell aliases
    shellAliases = {
      # Git aliases from dotfiles
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
    };
    
    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
      plugins = [
        "git"
        "docker"
        "kubectl"
        "aws"
        "rust"
        "golang"
        "python"
        "nodejs"
        "npm"
        "yarn"
        "systemd"
        "ssh-agent"
        "gpg-agent"
        "direnv"
      ];
      custom = "$HOME/.config/oh-my-zsh/custom";
    };
    
    # Additional configuration
    initExtra = ''
      # Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      
      # Advanced completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors '''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu select
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%B%d%b'
      zstyle ':completion:*:warnings' format 'No matches for: %d'
      zstyle ':completion:*' verbose yes
      
      # Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      
      # Load custom completion functions
      fpath=(~/.zsh/completion $fpath)
      autoload -Uz compinit && compinit -i
      
      # NVM setup (if installed outside of Nix)
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
    '';
  };
  
  # Install powerlevel10k
  home.packages = with pkgs; [
    zsh-powerlevel10k
  ];
  
  # Ensure oh-my-zsh custom directory exists
  home.file.".config/oh-my-zsh/.keep".text = "";
}