{
  inputs,
  sops,
  self,
  ...
}: {
  imports = [
    ./networking.nix

    inputs.sops-nix.nixosModules.sops
  ];

  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key" # All Hosts Should Have SSH Keys
  ];

  sops.defaultSopsFile = "${self}/Secrets/Secrets.yaml";

  # Internationalisation
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  nix = {
    settings = {
      experimental-features = ["flakes" "nix-command"];
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
      extra-substituters = [
        # this is where non-specific extra caches would go.
        # you should prefer a System/Programs entry ahead of defining the cache globally.
      ];
      extra-trusted-public-keys = [
        # this is where non-specific extra cache keys would go.
        # you should prefer a System/Programs entry ahead of defining the cache globally.
      ];
    };
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
