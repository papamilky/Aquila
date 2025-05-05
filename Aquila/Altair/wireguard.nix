{
  secrets,
  config,
  ...
}: {
  networking.firewall.allowedUDPPorts = [51820];
  networking.useNetworkd = true;

  sops.secrets = {
    "wireguard/altair_private_key" = {
      owner = "systemd-network";
      restartUnits = ["systemd-networkd.service"];
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1500";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wireguard/altair_private_key".path;
          ListenPort = 51820;
          RouteTable = "main"; # wg-quick creates routing entries automatically but we must use use this option in systemd.
        };
        wireguardPeers = [
          {
            PublicKey = secrets.wireguard.alshain_publickey;
            AllowedIPs = ["10.100.0.2"];
          } # Alshain
          {
            PublicKey = "QyO5XatMfD2/XSSm0PY1T226JNIfzF3InD06toRSbz4=";
            AllowedIPs = ["10.100.0.3"];
          } # Sirius
        ];
      };
    };

    networks."wg0" = {
      matchConfig.Name = "wg0";
      address = ["10.100.0.1/24"];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPv4Forwarding = true;
      };
    };

    networks."uplink" = {
      matchConfig.Name = "wlp13s0";
      networkConfig = {
        IPMasquerade = true;
      };
    };
  };
}
