{inputs, ...}: let
  dir = ./.;
  entries = builtins.readDir dir;
  directories =
    builtins.filter (name: entries.${name} == "directory")
    (builtins.attrNames entries);
  usersMap = map (name: dir + "/${name}/${name}.nix") directories;
  users = [inputs.hjem.nixosModules.default] ++ usersMap;
in {
  inherit users;
}
