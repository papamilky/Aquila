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

  networking.hostName = "deneb";
  time.timeZone = "Australia/Brisbane";

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda"; # Use the full disk, not a partition
  };
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.useOSProber = false;

  ## System Components
  aquila.system = {
    services = {
      ssh = {
        enable = true;
        permittedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4iSC6WdaeBss3x/NxLqj9vYB7IaGO/2aVhSh286GKi milky@altair"
        ];
      };
    };
  };
}
