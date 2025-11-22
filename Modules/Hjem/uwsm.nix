{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption concatStringsSep;
  inherit (lib.types) anything attrsOf;
  inherit (lib.attrsets) mapAttrsToList;

  cfg = config.uwsm;
in {
  options.uwsm = {
    env = mkOption {
      type = attrsOf anything;
      description = "environment variables for uwsm";
      default = {};
    };
  };

  config = {
    files.".config/uwsm/env".text = concatStringsSep "\n" (
      mapAttrsToList (name: value: "export ${name}=${toString value}") cfg.env
    );
  };
}
