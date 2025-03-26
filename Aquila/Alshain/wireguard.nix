{secrets, ...}: {
  sops.secrets = {
    "wireguard/alshain_private_key" = {
      owner = "systemd-network";
      # restartUnits = ["systemd-networkd.service"];
    };
  };

  wg-quick.interfaces = {
    wg0 = {
      address = ["10.100.0.2/24"];
      dns = ["1.1.1.1"];
      privateKeyFile = config.sops.secrets."wireguard/alshain_private_key".path;

      peers = [
        {
          publicKey = secrets.wireguard.altair_publickey;
          allowedIPs = ["192.168.0.0/16"];
          endpoint = secrets.wireguard.altair_endpoint;
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
