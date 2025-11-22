{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.aquila.system.hardware.sound;
in {
  options.aquila.system.hardware.sound = {
    enable = lib.mkEnableOption "Enable sound for the system";
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
