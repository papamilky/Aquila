{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # DO NOT TOUCH!
  system.stateVersion = "23.11"; # Did you read the comment? DO NOT TOUCH!
  
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2b7a0e08-4547-4be5-ae6b-2f569e67a539";
    fsType = "btrfs";
    options = ["subvol=@root"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/2b7a0e08-4547-4be5-ae6b-2f569e67a539";
    fsType = "btrfs";
    options = ["subvol=@nix"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2b7a0e08-4547-4be5-ae6b-2f569e67a539";
    fsType = "btrfs";
    options = ["subvol=@home"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C2B6-90E1";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens3.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens4.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
