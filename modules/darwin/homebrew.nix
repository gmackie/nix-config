{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Homebrew integration (for casks and Mac App Store apps)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
    ];

    # GUI applications via Homebrew Cask
    casks = [
      # Development
      "ghostty"
      "orbstack"
      "sublime-text"

      # Communication
      "discord"
      "slack"

      # Creative
      "blender"
      "openscad"

      # Media
      "spotify"
      "vlc"
      "transmission"

      # Utilities
      "itsycal"
      "ngrok"
      "stats"

      # Quick Look plugins
      "qlcolorcode"
      "qlmarkdown"
      "qlstephen"
      "quicklook-json"
      "webpquicklook"
    ];

    # CLI tools that don't have good nix packages or require special config
    brews = [
      "awscli"
      "cocoapods"
      "dfu-util"
      "hackrf"
      "hcloud"
      "mosquitto"
      "nvm"
      "pyenv"
      "rbenv"
      "riscv-gnu-toolchain"
      "riscv-isa-sim"
      "riscv-pk"
      "riscv-tools"
      "sqld"
      "tea"
      "turso"
      "wifi-password"
    ];

    masApps = {
      # Mac App Store apps
      # "App Name" = app_id;
    };
  };
}
