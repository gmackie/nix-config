{ config, pkgs, lib, ... }:

{
  # Development tools
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    gh
    lazygit
    tig
    
    # Build tools
    cmake
    meson
    ninja
    pkg-config
    
    # Debugging
    gdb
    lldb
    valgrind
    strace
    ltrace
    
    # Performance analysis
    perf-tools
    flamegraph
    hyperfine
    
    # Code analysis
    clang-tools
    cppcheck
    shellcheck
    
    # Documentation
    doxygen
    sphinx
    mdbook
  ];
  
  # Enable documentation
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };
}