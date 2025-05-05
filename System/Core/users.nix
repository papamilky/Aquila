{
  inputs,
  config,
  secrets,
  ...
}: {
  imports = [
    ./Users/milky.nix
    inputs.home-manager.nixosModules.home-manager
  ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit secrets;
    };
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
