# Raspberry Pi NixOS Configuration Template
{ config, pkgs, lib, inputs, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/secrets.nix
  ];
  
  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  
  # Enable GPIO access
  hardware.raspberry-pi."4" = {
    apply-overlays-dtmerge.enable = true;
    fkms-3d.enable = true;
  };
  
  # Enable I2C, SPI
  hardware.raspberry-pi."4" = {
    i2c1.enable = true;
    spi.enable = true;
  };
  
  # Add user to GPIO groups
  users.users.${user}.extraGroups = [ "gpio" "spi" "i2c" ];
  
  # Raspberry Pi specific packages
  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
    wiringpi
    
    # Monitoring
    rpi-imager
    
    # IoT development
    mosquitto
    
    # Python packages for GPIO
    python311Packages.rpi-gpio
    python311Packages.gpiozero
    python311Packages.adafruit-circuitpython-gpio
  ];
  
  # Network configuration for headless setup
  networking = {
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      networks = {
        # Configure your WiFi networks here
        # "SSID" = {
        #   psk = "password";
        # };
      };
    };
  };
  
  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
  
  # Reduce writes to SD card
  services.journald.extraConfig = "Storage=volatile";
  
  # Enable zram for better performance
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };
}