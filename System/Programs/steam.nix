{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.aquila.system.services.steam;
in {
  options.aquila.system.services.steam = {
    enable = lib.mkEnableOption "Enable Hyprland User Configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];

      # fix gamescope inside steam
      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            keyutils
            libkrb5
            libpng
            libpulseaudio
            libvorbis
          ];
      };
    };

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 27014;
        to = 27030;
      }
      {
        from = 3478;
        to = 4380;
      }
    ];
  };
}
