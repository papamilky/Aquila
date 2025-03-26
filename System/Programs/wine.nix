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
      lutris
      dotnet-runtime_8
      mono
      wineWowPackages.stable
      wine
      (wine.override {wineBuild = "wine64";})
      wine64
      wineWowPackages.staging
      winetricks
      wineWowPackages.waylandFull
    ];
  };
}
