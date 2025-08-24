{ config, pkgs, lib, ... }:

{
  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };
  
  # Auto-cpufreq as alternative to TLP (choose one)
  # services.auto-cpufreq = {
  #   enable = true;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "never";
  #     };
  #     charger = {
  #       governor = "performance";
  #       turbo = "auto";
  #     };
  #   };
  # };
  
  # Laptop-specific services
  services = {
    # Enable automatic screen brightness
    clight = {
      enable = true;
      settings = {
        verbose = true;
        backlight.no_smooth_transition = false;
      };
    };
    
    # Battery notification
    upower.enable = true;
    
    # Lid switch behavior
    logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
    };
  };
  
  # Hibernation support
  boot.kernelParams = [ "resume_offset=0" ]; # Configure based on swap setup
  
  # Additional laptop tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    brightnessctl
    light
    tlp
  ];
}