{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.services.hyprland;
in {
  options.aquila.system.services.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland For System";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      extra-substituters = [
        "https://hyprland.cachix.org"
      ];
      extra-trusted-substituters = [
        "https://hyprland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    xdg.portal = {
      enable = true;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QML2_IMPORT_PATH = "/home/milky/quickshell-plugins/";
    };

    environment.systemPackages = with pkgs; [
      hyprcursor
      hypridle
      hyprlock

      hyprpolkitagent
    ];
  };
}
