{
  pkgs,
  inputs,
  ...
}: {
  services.gvfs.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  environment.systemPackages = with pkgs; [
    gvfs
    dunst
    jdk21
    SDL2
    libxkbcommon
    v4l-utils
    fuse3
    fuse-emulator
    fuse-overlayfs
    dwarfs
    iproute2
    nmap
    libGL
    virtiofsd
  ];
}
