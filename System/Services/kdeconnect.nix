{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.kdeconnect;
in {
  options.aquila.system.programs = {
    kdeconnect = {
      enable = lib.mkEnableOption "Enable kdeconnect For System";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      package = pkgs.kdePackages.kdeconnect-kde;
      enable = true;
    };
  };
}
