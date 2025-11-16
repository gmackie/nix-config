{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh
    lazygit

    # AI Development tools
    cursor
    cursor-cli
    codex
    gemini-cli

    # Terminal utilities
    tmux
    zellij
    starship
    zoxide
    fzf
    ripgrep
    fd
    bat
    eza
    du-dust
    procs
    bottom

    # Development tools
    nodejs
    yarn
    python3
    python3Packages.pip
    go
    rustc
    cargo
    
    # Cloud tools
    awscli2
    google-cloud-sdk
    azure-cli
    terraform
    ansible
    
    # Kubernetes tools
    kubectl
    kubernetes-helm
    k9s
    kubectx
    
    # Database tools
    postgresql
    mysql
    sqlite
    redis
    mongodb-tools
    
    # Network tools
    curl
    wget
    httpie
    ngrok
    mosh
    
    # JSON/Data tools
    jq
    yq
    fx
    
    # Security tools
    gnupg
    pass
    age
    sops
    
    # Archive tools
    zip
    unzip
    p7zip
    
    # Media tools
    ffmpeg
    imagemagick
    
    # Text processing
    pandoc
    graphviz
    
    # System monitoring
    htop
    btop
    iotop
    ncdu
    duf
    
    # Misc utilities
    tree
    tldr
    neofetch
    cowsay
    lolcat
  ];
}