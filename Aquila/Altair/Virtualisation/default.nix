{pkgs, ...}: {
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
}
