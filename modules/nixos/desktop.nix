{ config, pkgs, lib, user, ... }:

{
  # X11/Wayland configuration
  services.xserver = {
    enable = true;
    
    # Display manager
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    
    # Desktop environment - using GNOME as default
    desktopManager.gnome.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  
  # Enable CUPS for printing
  services.printing.enable = true;
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      font-awesome
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
      };
    };
  };
  
  # Desktop applications
  environment.systemPackages = with pkgs; [
    firefox
    chromium
    thunderbird
    libreoffice
    gimp
    inkscape
    vlc
    spotify
    discord
    slack
    vscode
    obsidian
    kitty
    alacritty
  ];
  
  # Enable flatpak for additional applications
  services.flatpak.enable = true;
  
  # XDG portal for better desktop integration
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}