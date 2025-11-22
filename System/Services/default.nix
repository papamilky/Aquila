{lib, ...}: let
  dir = ./.;
  nixFiles = lib.filterAttrs (
    name: type:
      type
      == "regular"
      && lib.hasSuffix ".nix" name
      && name != "default.nix"
  ) (builtins.readDir dir);
in {
  imports = map (name: dir + "/${name}") (builtins.attrNames nixFiles);
}
