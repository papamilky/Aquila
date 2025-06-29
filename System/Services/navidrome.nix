{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.aquila.system.services.navidrome;
in {
  options.aquila.system.services.navidrome = {
    enable = lib.mkEnableOption "Enable Podman for rootless";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [4533];
    networking.firewall.allowedUDPPorts = [4533];
    services.navidrome = {
      enable = true;

      package = pkgs.navidrome;

      settings = {
        Port = 4533;
        Address = "0.0.0.0";
        EnableInsightsCollector = true;
        MusicFolder = "/mount/Deneb/Music/";
        LogLevel = "DEBUG";
        Scanner.Schedule = "@every 1h";
        TranscodingCacheSize = "150MiB";
      };
    };
  };
}
