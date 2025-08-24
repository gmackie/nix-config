{ config, pkgs, lib, user, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Enable Docker rootless mode for better security
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    
    # Periodic cleanup
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };
  
  # Add user to docker group
  users.users.${user}.extraGroups = [ "docker" ];
  
  # Docker-related packages
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    docker-credential-helpers
    dive # Docker image explorer
    lazydocker # Terminal UI for docker
  ];
}