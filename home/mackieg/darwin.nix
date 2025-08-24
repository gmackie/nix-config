{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./common.nix
  ];
  
  home = {
    username = "mackieg";
    homeDirectory = "/Users/mackieg";
    stateVersion = "24.05";
  };
  
  # macOS-specific configurations
  targets.darwin = {
    defaults = {
      "com.apple.Safari" = {
        ShowFullURLInSmartSearchField = true;
        ShowFavoritesBar = true;
      };
    };
  };
  
  # macOS-specific packages
  home.packages = with pkgs; [
    cocoapods
    xcbuild
  ];
}