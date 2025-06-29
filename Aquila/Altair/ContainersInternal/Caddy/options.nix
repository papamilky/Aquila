{
  config,
  lib,
  ...
}: {
  options.caddy = {
    networks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The networks caddy belongs to";
    };
    config = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["# Currently Empty"];
      description = "Caddy config";
    };
  };
}
