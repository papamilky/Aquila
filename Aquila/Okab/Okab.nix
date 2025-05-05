{
  pkgs,
  self,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "okab";
  time.timeZone = "Australia/Brisbane";

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  ## System Components
  aquila.system = {
    services = {
      ssh = {
        enable = true;
        permittedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMTVubkDraz9VhKO1Y4iHgJ1fE+rGVr4YE7YoPTt6xGL milky@alshain"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4iSC6WdaeBss3x/NxLqj9vYB7IaGO/2aVhSh286GKi milky@altair"
        ];
      };
    };
  };
}
