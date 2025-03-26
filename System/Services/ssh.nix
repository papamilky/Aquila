{
  lib,
  config,
  ...
}: let
  cfg = config.aquila.system.services.ssh;
in {
  options.aquila.system.services.ssh = {
    enable = lib.mkEnableOption "Enable SSH service";
    permittedKeys = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = "Set the list of public keys permitted for login";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkForce "no";
      };
    };
    users.users.milky.openssh.authorizedKeys.keys = cfg.permittedKeys;
  };
}
