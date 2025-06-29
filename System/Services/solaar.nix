{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.services.solaar;
in {
  options.aquila.system.services = {
    solaar = {
      enable = lib.mkEnableOption "Enable Solaar Service For System";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      solaar
      logitech-udev-rules
    ];
  };
}
