{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "mackieg";
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;
  virtualisation.docker.enable = true;

  networking.dhcpcd.enable = false;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;


  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    wget
    vim
    nano
    curl
    zsh
    git
    gh
    htop
    pv
    killall
    unzip
    tmux
    stow
    gnupg
    ripgrep
    binutils
    
    nmap
    docker
    docker-compose
    cri-tools
    kubernetes-helm
    devd
    heroku
    mongodb-tools
    jq
    dotnet-sdk
    dotnet-netcore
    aspell
    silver-searcher
    sqlite
    gnumake
    gcc
    ngrok
    mosh
    speedtest_cli
    ncdu
    telnet
    unrar
    
    python39
    nodejs
    yarn
    ruby
    glibc
    weechat

  ];

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;

}
