{ config, pkgs, lib, ... }:

{
  # ThinkPad specific hardware optimizations
  hardware = {
    # TrackPoint configuration
    trackpoint = {
      enable = true;
      sensitivity = 128;
      speed = 128;
      emulateWheel = true;
    };
  };

  # ThinkPad ACPI support
  boot.kernelModules = [
    "thinkpad_acpi"
    "tp_smapi"
  ];

  # Kernel parameters for better ThinkPad support
  boot.kernelParams = [
    # Better backlight control
    "acpi_backlight=vendor"
    
    # Intel graphics optimizations
    "i915.enable_fbc=1"        # Framebuffer compression
    "i915.enable_psr=1"        # Panel self refresh
    "i915.fastboot=1"          # Skip unnecessary mode sets
    
    # Power management
    "intel_pstate=active"
  ];

  # ThinkPad specific services
  services = {
    # Enable fingerprint reader
    fprintd.enable = true;
    
    # ThinkPad fan control
    thinkfan = {
      enable = true;
      levels = [
        [0  0   55]
        [1  48  60] 
        [2  50  61]
        [3  52  63]
        [4  56  65]
        [5  59  66]
        [7  63  32767]
      ];
    };
    
    # Enable firmware updates
    fwupd.enable = true;
  };

  # Power management optimizations
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  # ThinkPad specific packages
  environment.systemPackages = with pkgs; [
    # ThinkPad utilities
    tpacpi-bat              # Battery management
    thinkfan                # Fan control
    
    # Hardware monitoring
    lm_sensors
    acpi
    
    # Power management tools
    powertop
    tlp
    
    # Backlight control
    brightnessctl
    light
    
    # System info
    dmidecode
    lshw
  ];

  # Additional hardware support
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  # Improved touchpad configuration for ThinkPads
  services.xserver.libinput = {
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
      accelProfile = "adaptive";
      accelSpeed = "0.3";
    };
  };

  # ThinkPad T440 specific tweaks
  boot.extraModprobeConfig = ''
    # Improve trackpad sensitivity
    options psmouse synaptics_intertouch=1
    
    # ThinkPad ACPI options
    options thinkpad_acpi fan_control=1
  '';

  # Hibernation support (configure swap accordingly)
  boot.kernelParams = [ "resume_offset=0" ];
  
  # Runtime power management
  services.udev.extraRules = ''
    # Enable runtime PM for PCI devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    
    # USB autosuspend
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    
    # SATA link power management
    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';
}