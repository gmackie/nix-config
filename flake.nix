{
  description = "Multi-system NixOS and nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, darwin, home-manager, nixos-wsl, ... }@inputs: 
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs nixpkgs-stable inputs;
      };
    in
    {
      nixosConfigurations = {
        # NixOS laptop configuration
        nixos-laptop = mkSystem "nixos-laptop" {
          system = "x86_64-linux";
          user = "mackieg";
        };
        
        # ThinkPad T440 configuration (hostname: brnr)
        brnr = mkSystem "brnr" {
          system = "x86_64-linux";
          user = "mackieg";
        };
        
        # WSL NixOS configuration
        wsl = mkSystem "wsl" {
          system = "x86_64-linux";
          user = "mackieg";
          wsl = true;
        };
        
        # Future homelab configurations
        # rpi = mkSystem "rpi" {
        #   system = "aarch64-linux";
        #   user = "mackieg";
        # };
        
        # nuc = mkSystem "nuc" {
        #   system = "x86_64-linux";
        #   user = "mackieg";
        # };
        
        # nas = mkSystem "nas" {
        #   system = "x86_64-linux";
        #   user = "mackieg";
        # };
      };
      
      darwinConfigurations = {
        # Mac M2 configuration
        mac-m2 = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/mac-m2/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.mackieg = import ./home/mackieg/darwin.nix;
              };
            }
          ];
        };
      };
      
      # Development shells for different environments
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixfmt
              statix
              deadnix
            ];
          };
        }
      );
      
      # Custom packages
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Add custom packages here
        }
      );
      
      # Overlays
      overlays = import ./overlays;
      
      # NixOS modules
      nixosModules = import ./modules/nixos;
      
      # Home Manager modules  
      homeManagerModules = import ./modules/home-manager;
    };
}