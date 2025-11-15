{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      # Utils - Terminal
      zellij
      kitty

      nh
      git-crypt
      sops
      gnupg
      vim
      wget
      nix-search-cli
      zoxide
      imv
      ranger
      cbonsai
      pipes
      cowsay
      neovim
      grim
      wl-clipboard
      cliphist
      jq
      python3
      notify-desktop
      git
      htop
      dialog
      libnotify
      ffmpeg
      pipx
      alejandra
      grimblast
      wev
      pciutils
      bitwarden-cli
      at
      playerctl
      gowall
      wallust
      libqalculate
    ]
    ++ [
      inputs.nixos-anywhere.packages.${pkgs.stdenv.hostPlatform.system}.nixos-anywhere
    ];
}
