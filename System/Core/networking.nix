{secrets, ...}: {
  # Networking
  services.dnsmasq.enable = false;
  networking = {
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  networking.hosts = {
    "192.168.1.144" = [
      "vaultwarden.internal"
      "forgejo.internal"
    ];
  };

  security.pki.certificates = ["${secrets.caddy.root_cert}"];
}
