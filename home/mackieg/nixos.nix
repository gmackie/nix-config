{ config, pkgs, lib, inputs, user, hostname, ... }:

{
  imports = [
    ./common.nix
  ];
  
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
  };
  
  # Linux-specific configurations
  services = {
    # GPG agent
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
  
  # Desktop entries for custom applications
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  
  # Linux-specific packages
  home.packages = with pkgs; [
    xclip
    xsel
  ];
}