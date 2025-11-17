{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable tmux
  programs.tmux.enable = true;

  # Symlink Oh My Tmux configuration files
  home.file = {
    # Main tmux config from gpakosz/.tmux submodule
    ".config/tmux/tmux.conf".source = ./tmux/.tmux.conf;

    # Local customizations
    ".config/tmux/tmux.conf.local".source = ./tmux.conf.local;
  };
}
