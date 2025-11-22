{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.gui;
  goland = pkgs.jetbrains.goland; #.override {jdk = pkgs.jdk21;};
  idea = pkgs.jetbrains.idea-ultimate; #.override {jdk = pkgs.jdk21;};
  clion = pkgs.jetbrains.clion; #.override {jdk = pkgs.jdk21;};
  rustrover = pkgs.jetbrains.rust-rover; #.override {jdk = pkgs.jdk21;};
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

        heroic
        bottles
        # cinny-desktop # Depends on libsoup 2.74.3 (insecure dependancy)
        # element-desktop # Deps Depend on "Jitsi-Meet" (insecure dependancy)

        kdePackages.k3b
        pulseaudio
        ddcutil

        colloid-gtk-theme
        colloid-icon-theme

        # Programs - Userspace
        satty
        gimp
        vscode

        vlc
        mpv
        qalculate-qt
        kdePackages.kate

        libreoffice-still
        hunspell
        hunspellDicts.en_AU

        swww
        flameshot
        helvum
        bitwarden-desktop
        nautilus
        r2modman
        kdePackages.filelight
        fluent-reader
        # rpi-imager
        obs-studio

        (prismlauncher.override {
          jdks = [jdk8 jdk17 jdk25];
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

        rustup
      ]
      ++ [
        goland
        rustrover
        idea
        clion
        inputs.mint.packages.${pkgs.stdenv.hostPlatform.system}.mint
      ];
  };
}
