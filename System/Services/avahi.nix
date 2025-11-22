{
  lib,
  config,
  ...
}: let
  cfg = config.aquila.system.services.avahi;
in {
  options.aquila.system.services.avahi = {
    enable = lib.mkEnableOption "Enable the avahi service for the system"; ## Avahi - Resolve .local dns
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
