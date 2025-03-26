{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.gui;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gtk3
      sweet
    ];
    programs = {
      # make HomeManager-managed GTK stuff work
      dconf.enable = true;
    };
  };
}
