{ config, pkgs, lib, ... }:

{
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
      
      # Merge settings
      merge = {
        tool = "nvim";
        conflictStyle = "zdiff3";
      };
      
      # Pager settings
      pager = {
        branch = false;
      };
      
      # Pull settings
      pull = {
        rebase = true;
      };
      
      # Push settings
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      
      # Init settings
      init = {
        defaultBranch = "main";
      };
      
      # Diff settings
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };
      
      # Git LFS
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      
      # Rebase settings
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      
      # Fetch settings
      fetch = {
        prune = true;
        pruneTags = true;
      };
      
      # Branch settings
      branch = {
        autoSetupRebase = "always";
      };
    };
    
    # Git aliases
    aliases = {
      # Status and info
      st = "status";
      s = "status --short";
      
      # Branch management
      br = "branch";
      co = "checkout";
      cob = "checkout -b";
      
      # Commit shortcuts
      ci = "commit";
      ca = "commit -a";
      cam = "commit -am";
      amend = "commit --amend";
      
      # Log aliases
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lga = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      lol = "log --oneline --decorate --graph";
      lola = "log --oneline --decorate --graph --all";
      
      # Diff aliases
      d = "diff";
      dc = "diff --cached";
      ds = "diff --stat";
      
      # Push/pull shortcuts
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";
      
      # Stash shortcuts
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";
      
      # Reset shortcuts
      unstage = "reset HEAD --";
      uncommit = "reset --soft HEAD~1";
      
      # Show shortcuts
      last = "log -1 HEAD --stat";
      visual = "!gitk";
      
      # Cleanup
      prune-branches = "!git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -n 1 git branch -d";
      
      # Find commits
      find = "!git log --pretty=\\\"format:%Cgreen%H %Cblue%s\\\" --name-status --grep";
    };
    
    # Git ignore patterns
    ignores = [
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      
      # Editor files
      "*~"
      "*.swp"
      "*.swo"
      ".vscode/"
      ".idea/"
      
      # Build outputs
      "build/"
      "dist/"
      "out/"
      "target/"
      "bin/"
      "obj/"
      
      # Dependencies
      "node_modules/"
      ".pnp"
      ".pnp.js"
      "coverage/"
      
      # Logs
      "logs"
      "*.log"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      
      # Runtime data
      "pids"
      "*.pid"
      "*.seed"
      "*.pid.lock"
      
      # Environment files
      ".env"
      ".env.local"
      ".env.development.local"
      ".env.test.local"
      ".env.production.local"
      
      # Cache
      ".cache/"
      ".tmp/"
      ".temp/"
      
      # Nix
      "result"
      "result-*"
      
      # Direnv
      ".direnv/"
    ];
  };
  
  # Git LFS
  home.packages = with pkgs; [
    git-lfs
  ];
}