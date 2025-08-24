{ nixpkgs, nixpkgs-stable, inputs }:

name:
{ system
, user
, wsl ? false
, darwin ? false
, desktop ? false
, laptop ? false
}:

let
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerModule = if darwin then inputs.home-manager.darwinModules.home-manager else inputs.home-manager.nixosModules.home-manager;
in
systemFunc rec {
  inherit system;
  
  specialArgs = {
    inherit inputs nixpkgs-stable user wsl desktop laptop;
    hostname = name;
  };
  
  modules = [
    (../hosts + "/${name}/configuration.nix")
    homeManagerModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs user;
          hostname = name;
        };
        users.${user} = import (../home + "/${user}/${if darwin then "darwin" else "nixos"}.nix");
      };
    }
    {
      networking.hostName = name;
    }
  ] ++ (if wsl then [ inputs.nixos-wsl.nixosModules.wsl ] else []);
}