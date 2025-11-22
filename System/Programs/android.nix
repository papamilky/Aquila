{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.android;
in {
  options.aquila.system.programs = {
    android = {
      enable = lib.mkEnableOption "Enable android utilities for the system";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      scrcpy
      android-tools
    ];
  };
}
