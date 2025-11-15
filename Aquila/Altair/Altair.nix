{
  pkgs,
  self,
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ./wireguard.nix

    ./ContainersPublic
    ./Virtualisation
  ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  networking.hostName = "altair";
  time.timeZone = "Australia/Brisbane";

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce true;

  programs.nix-ld.enable = true;

  ## Window Management
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  ## System Components
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
    "olm-3.2.16"
  ];
  aquila.system = {
    services = {
      solaar.enable = true;
      hyprland.enable = true;
      steam.enable = true;
      ssh = {
        enable = true;
        permittedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMTVubkDraz9VhKO1Y4iHgJ1fE+rGVr4YE7YoPTt6xGL milky@alshain"
        ];
      };
      podman-rootless.enable = true;
      navidrome.enable = true;
    };
    programs = {
      gui.enable = true;
      kdeconnect.enable = true;
      vintagestory.enable = true;
    };
  };
}
