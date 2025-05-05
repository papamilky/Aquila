{pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [50300]; # slskd
  networking.firewall.allowedUDPPorts = [50300]; # slskd
}
