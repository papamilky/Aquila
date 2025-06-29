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

    ./ContainersInternal
    ./ContainersPublic
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

  ## Qemu
  environment.systemPackages = with pkgs; [
    virt-manager
    qemu
    libvirt
    virt-viewer
    iptables
    iptables-legacy
    looking-glass-client
    spice
  ];

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = ["br0"];
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };

      verbatimConfig = ''
        cgroup_device_acl = [
           "/dev/null", "/dev/full", "/dev/zero",
           "/dev/random", "/dev/urandom",
           "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
           "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
           "/dev/kvmfr0"
        ]
      '';
    };
  };

  networking.bridges.br0.interfaces = [];
  networking.interfaces.br0.ipv4.addresses = [
    {
      address = "10.25.0.1";
      prefixLength = 24;
    }
  ];

  networking.nat.enable = true;
  networking.nat.externalInterface = "wlp13s0";
  networking.nat.internalInterfaces = ["br0"];

  users.users.milky.extraGroups = ["libvirtd" "kvm"];
  environment.etc."vbios/AMDGopDriver.rom" = {
    source = ./AMDGopDriver.rom; # Replace with the path to your ROM file
    mode = "0444"; # Read-only for everyone (adjust if needed)
  };
  environment.etc."vbios/vbios_164e.dat" = {
    source = ./vbios_164e.dat; # Replace with the path to your ROM file
    mode = "0444"; # Read-only for everyone (adjust if needed)
  };

  networking.firewall = {
    allowedTCPPorts = [ 10000 ];
    allowedUDPPorts = [ 10000 ];
  };
}
