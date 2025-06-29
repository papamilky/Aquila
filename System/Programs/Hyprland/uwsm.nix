{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption concatStringsSep;
  inherit (lib.types) anything attrsOf;
  inherit (lib.attrsets) mapAttrsToList;

  cfg = config.home.uwsm;
in {
  options.home.uwsm = {
    env = mkOption {
      type = attrsOf anything;
      description = "environment variables for uwsm";
      default = {};
    };
  };

  config = {
    home.file.".config/uwsm/env".text = concatStringsSep "\n" (
      mapAttrsToList (name: value: "export ${name}=${toString value}") cfg.env
    );
  };
}
