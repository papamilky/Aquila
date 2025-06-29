{secrets, ...}: {
  # Networking
  services.dnsmasq.enable = false;
  networking = {
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  networking = {
    firewall.enable = true;
  };

  networking.hosts = {
    "192.168.1.144" = [
      "vaultwarden.internal"
      "forgejo.internal"

      "lidarr.internal"
      "slskd.internal"
      "navi.internal"
    ];
  };

  security.pki.certificates = ["${secrets.caddy.root_cert}"];

  systemd.services.nix-daemon = {
    enable = true;
    serviceConfig = {
      Environment = [
        "NIX_CURL_FLAGS=\"--cacert /etc/ssl/certs/ca-certificates.crt\""
      ];
    };
  };
}
