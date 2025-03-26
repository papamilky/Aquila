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
        kicad
        postman
        r2modman
        anki-bin
        kdePackages.filelight
        fluent-reader
        rpi-imager
        obs-studio

        (prismlauncher.override {
          jdks = [jdk8 jdk17 jdk23];
          additionalLibs = [
            nss
            libcef
            nspr
            libgbm
            glib
            dbus
            atk
            cups
            libGL
            libpulseaudio
            libglvnd
            libdrm
          ];
        })

        kdePackages.kdenlive
        nicotine-plus
        motrix
        obsidian
        thunderbird

        spotify
        vesktop
        angryipscanner

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
