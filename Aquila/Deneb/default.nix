{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    # shorten paths
    inherit (inputs.nixpkgs.lib) nixosSystem;
    mod = "${self}/System";

    # get the basic config to build on top of
    inherit (import "${mod}") server;
    inherit (import "${self}/Modules") blocks;

    # get plaintext "secrets"
    secrets = builtins.fromJSON (builtins.readFile "${self}/Secrets/Secrets.json");

    # get these into the module system
    specialArgs = {
      inherit inputs self secrets;
    };
  in {
    deneb = nixosSystem {
      inherit specialArgs;
      modules =
        server
        ++ blocks
        ++ [
          ./Deneb.nix
        ];
    };
  };
}
