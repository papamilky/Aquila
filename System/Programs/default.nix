{lib, ...}: {
  nixpkgs.config.allowUnfree = true;
  imports = [
    # Basic User QOL
    ./fonts.nix
    ./zsh.nix

    # Emacs
    ./emacs.nix

    # Zen Browser
    ./zen-browser.nix

    # Steam
    ./steam.nix

    # LactD - GPU Software
    ./lact.nix

    # Wine - Not an Emulator
    ./wine.nix

    # Unsorted
    ./Unsorted/cli.nix
    ./Unsorted/gui.nix
    ./Unsorted/neither.nix

    # Android - mostly just ADB
    ./android.nix

    # GTK - GTK3
    ./gtk.nix

    # Hyprland - Pretty (cool?) Compositor
    ./Hyprland/hyprland.nix
  ];
}
