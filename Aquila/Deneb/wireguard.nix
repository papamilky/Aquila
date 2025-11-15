{
  secrets,
  config,
  ...
}: let
  altair = "10.10.0.2";
in {
  sops.secrets = {
    "wireguard/deneb_private_key" = {
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
          PrivateKeyFile = config.sops.secrets."wireguard/deneb_private_key".path;
          ListenPort = 51820;
          RouteTable = "main"; # wg-quick creates routing entries automatically but we must use use this option in systemd.
        };
        wireguardPeers = [
          {
            PublicKey = secrets.wireguard.altair_publickey;
            AllowedIPs = ["10.10.0.2"];
          } # Altair
        ];
      };
    };

    networks."wg0" = {
      matchConfig.Name = "wg0";
      address = ["10.10.0.1/24"];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPv4Forwarding = true;
      };
    };

    networks."uplink" = {
      matchConfig.Name = "ens3";
      networkConfig = {
        IPMasquerade = true;
      };
    };
  };

  services = {
    caddy = {
      enable = true;
      readOnlyPaths = ["/var/www"];
      allowedPaths = ["/var/www"];
      domains = {
        "drinkmymilk.org" = {
          reverseProxyList = [
            # Forgejo
            {
              subdomain = "git";
              address = altair;
              port = 4000;
            }

            # Matrix
            {
              subdomain = "matrix";
              extraConfig = ''
                reverse_proxy /_matrix/* ${altair}:8008
                reverse_proxy /_synapse/client/* ${altair}:8008
              '';
            }
            {
              extraConfig = ''
                header /.well-known/matrix/* Content-Type application/json
                header /.well-known/matrix/* Access-Control-Allow-Origin *

                respond /.well-known/matrix/server `{
                  "m.server": "matrix.drinkmymilk.org:443"
                }`

                respond /.well-known/matrix/client `{
                  "m.homeserver": {
                    "base_url": "https://matrix.drinkmymilk.org"
                  },
                  "org.matrix.msc3575.proxy": {
                    "url": "https://matrix.drinkmymilk.org"
                  }
                }`
              '';
            }

            # Vintage Story
            {
              subdomain = "vintage";
              address = altair;
              port = 42420;
            }

            # Vaultwarden
            {
              subdomain = "thevault";
              address = altair;
              port = 8080;
            }
          ];

          fileServer = {
            subdomain = "files";
            root = "/var/www";
          };
        };
      };
    };
  };

  networking = {
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [
        80 # http
        443 # https
      ];

      allowedUDPPorts = [
        51820 # wireguard
      ];
    };

    nat = {
      enable = true;
      internalInterfaces = ["wg0"];
      externalInterface = "ens3";

      forwardPorts = [
        {
          destination = "${altair}:2222";
          proto = "tcp";
          sourcePort = 2222;
        }
        {
          destination = "${altair}:42420";
          proto = "tcp";
          sourcePort = 42420;
        }
        {
          destination = "${altair}:42420";
          proto = "udp";
          sourcePort = 42420;
        }
      ];
    };
  };
}
