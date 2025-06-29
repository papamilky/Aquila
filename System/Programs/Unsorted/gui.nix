{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.gui;
in {
  options.aquila.system.programs = {
    gui = {
      enable = lib.mkEnableOption "Enable GUI Components For System";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # The Holy Grail
        firefox
        kitty

        heroic
        bottles
        cinny-desktop
        element-desktop
        jetbrains.goland
        jetbrains.webstorm

        kdePackages.k3b

        # Programs - Userspace
        satty
        gimp
        vscode
        wlogout
        vlc
        mpv
        qalculate-qt
        wofi
        kdePackages.kate
        rofi-wayland

        libreoffice-still
        hunspell
        hunspellDicts.en_AU

        swww
        flameshot
        helvum
        bitwarden
        nautilus
        r2modman
        anki-bin
        kdePackages.filelight
        fluent-reader
        rpi-imager
        obs-studio

        (prismlauncher.override {
          jdks = [jdk8 jdk17 jdk23];
        })

        kdePackages.kdenlive
        motrix

        obsidian
        pandoc

        spotify
        (vesktop.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
          postFixup = ''
            ${old.postFixup or ""}
            wrapProgramShell $out/bin/vesktop --add-flags "--use-gl=angle --use-angle=vulkan"
          '';
        }))

        kdePackages.dolphin
        kdePackages.ark

        # LibGL (why do I have this?)
        libGL
        wayland
        xorg.libX11
      ]
      ++ [
        inputs.mint.packages.${pkgs.system}.mint
      ];
  };
}
