{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      # Utils - Terminal
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
      cava
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

      kitty
    ]
    ++ [
      inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
    ];
}
