{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.gui;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
