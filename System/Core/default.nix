{...}: {
  imports = [
    ./users.nix
    ./networking.nix
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
    };
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };
  };

  # DO NOT TOUCH!
  system.stateVersion = "23.11"; # Did you read the comment? DO NOT TOUCH!
}
