{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.aquila.system.services.printing;
in {
  options.aquila.system.services.printing = {
    enable = lib.mkEnableOption "Enable printing services for the system";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    environment.systemPackages = with pkgs; [
      brlaser
    ];
  };
}
