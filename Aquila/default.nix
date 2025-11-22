{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) nixosSystem toLower;
in {
  flake.nixosConfigurations = let
    inherit (import "${self}/System") imports;
    inherit (import "${self}/Modules") blocks;
    inherit (import "${self}/Users" {inherit inputs;}) users;
    secrets = builtins.fromJSON (builtins.readFile "${self}/Secrets/Secrets.json");
    specialArgs = {inherit inputs self secrets;};

    hostDirs = builtins.attrNames (builtins.readDir ./.);

    mkHost = dirName: let
      hostName = toLower dirName;
    in
      nixosSystem {
        inherit specialArgs;
        modules = imports ++ blocks ++ users ++ [./${dirName}/${dirName}.nix];
      };
  in
    builtins.listToAttrs (map (dir: {
        name = toLower dir;
        value = mkHost dir;
      })
      hostDirs);
}
