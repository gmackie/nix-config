{
  # Custom overlays for nixpkgs
  default = final: prev: {
    # Example custom package
    # myCustomPackage = final.callPackage ../pkgs/myCustomPackage { };
  };
  
  # Unstable packages overlay
  unstable = final: prev: {
    unstable = import <nixpkgs-unstable> {
      system = prev.system;
      config.allowUnfree = true;
    };
  };
}