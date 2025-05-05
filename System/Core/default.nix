{inputs, ...}: {
  imports = [
    ./users.nix
    ./networking.nix

    inputs.sops-nix.nixosModules.sops
    inputs.lix-module.nixosModules.default
  ];

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
        "https://walker.cachix.org"
      ];
      extra-trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      ];
    };
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };
  };

  # DO NOT TOUCH!
  system.stateVersion = "23.11"; # Did you read the comment? DO NOT TOUCH!
}
