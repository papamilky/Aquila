{
  lib,
  config,
  ...
}: let
  cfg = config.aquila.system.hardware.bluetooth;
in {
  options.aquila.system.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth hardware for the system";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        Policy.AutoEnable = "true";
        General.Enable = "Source,Sink,Media,Socket";
      };
    };
    services.blueman.enable = true;
  };
}
