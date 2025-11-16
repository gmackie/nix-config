{
  config,
  pkgs,
  lib,
  inputs,
  user,
  desktop,
  laptop,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/common-packages.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/thinkpad.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/languages/python.nix
    ../../modules/nixos/languages/nodejs.nix
    ../../modules/nixos/languages/go.nix
    ../../modules/nixos/languages/rust.nix
  ];

  # Host identification
  networking.hostName = "brnr";

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ThinkPad T440 specific hardware optimizations
  hardware = {
    # Enable CPU microcode updates
    cpu.intel.updateMicrocode = true;

    # Graphics acceleration for Intel HD Graphics 4400
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # ThinkPad specific features
    trackpoint = {
      enable = true;
      sensitivity = 128;
      speed = 128;
      emulateWheel = true;
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    # Audio
    pulseaudio.enable = false;
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH
      allowedUDPPorts = [ 5353 ]; # mDNS for .local hostname resolution
    };

    # Enable SSH
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  # Audio with PipeWire
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Input configuration
  services.xserver = {
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
    };
  };

  # ThinkPad specific services
  services = {
    # TLP for power management (configured in laptop.nix)
    tlp.enable = true;

    # Thermal management
    thermald.enable = true;

    # Bluetooth management
    blueman.enable = true;

    # Fingerprint reader (if available on T440)
    fprintd.enable = true;

    # Automatic screen rotation and backlight
    upower.enable = true;
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # Kernel parameters for ThinkPad T440
  boot.kernelParams = [
    "acpi_backlight=vendor" # Better backlight control
    "i915.enable_fbc=1" # Enable framebuffer compression
    "i915.enable_psr=1" # Enable panel self refresh
  ];

  # Additional kernel modules
  boot.kernelModules = [
    "thinkpad_acpi" # ThinkPad ACPI support
    "tp_smapi" # ThinkPad battery info
  ];

  # ThinkPad specific packages
  environment.systemPackages = with pkgs; [
    # Power management
    powertop
    tlp
    acpi

    # Hardware control
    brightnessctl
    light

    # ThinkPad utilities
    tpacpi-bat # Battery management

    # System monitoring
    lm_sensors
    psensor

    # Wireless tools
    iw
    wireless-tools

    # Development tools (inherited from modules)
    # Network tools
    networkmanager
    networkmanagerapplet

    # Bluetooth
    bluez
    bluez-tools
  ];

  # Enable firmware updates
  services.fwupd.enable = true;

  # Hibernation configuration
  boot.resumeDevice = "/dev/disk/by-uuid/SWAP-UUID"; # Replace with actual swap UUID

  # User configuration
  users.users.${user} = {
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
    ];
  };

  # System state version
  system.stateVersion = "24.05";
}
