{
  pkgs,
  self,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ./wireguard.nix
  ];

  networking.hostName = "alshain";
  time.timeZone = "Australia/Brisbane";
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce true;

  # To be sorted.
  programs.nix-ld.enable = true;

  ## Window Management
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "milky";
  };

  aquila.system = {
    services = {
      ssh = {
        enable = true;
        permittedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4iSC6WdaeBss3x/NxLqj9vYB7IaGO/2aVhSh286GKi milky@altair"
        ];
      };
    };
    programs = {
      gui.enable = true;
    };
  };
}
