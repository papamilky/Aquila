{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.aquila.system.services.podman-rootless;
in {
  #
  # Despite being in the services directory, this file does not directly contain anything to enable podman.
  # This contains config for helpful packages and config to make podman actually work as rootless.
  #

  options.aquila.system.services.podman-rootless = {
    enable = lib.mkEnableOption "Enable Podman for rootless";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman
      podman-tui # Terminal mgmt UI for Podman
      passt # For Pasta rootless networking
    ];
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [pkgs.bash]}"
    '';
  };
}
