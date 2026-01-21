{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Development tools for macOS
  environment.systemPackages = with pkgs; [
    # Build tools
    cmake
    ninja
    meson
    pkg-config

    # Compilers and toolchains
    gcc
    gnumake
    binutils
    llvm
    clang-tools

    # Debugging and profiling
    lldb

    # Code analysis
    shellcheck
    nixfmt-rfc-style
    statix
    deadnix

    # Version control
    lazygit
    delta
    git-lfs

    # JSON/YAML/Config tools
    jq
    yq

    # Network tools
    httpie
    curl
    wget
  ];

  # Homebrew development tools
  homebrew.brews = lib.mkAfter [
    # Additional dev tools via homebrew if needed
  ];

  homebrew.casks = lib.mkAfter [
    # Development GUIs
    "visual-studio-code"
    "docker" # Alternative to orbstack if needed
  ];
}
