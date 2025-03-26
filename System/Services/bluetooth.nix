{...}: {
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      Policy.AutoEnable = "true";
      General.Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;
}
