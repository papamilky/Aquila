{
  config,
  deployment,
  secrets,
  ...
}: {
  sops.secrets = {
    "wireguard/altair_private_key" = {
      owner = "systemd-network";
      restartUnits = ["systemd-networkd.service"];
    };
  };

  containers.gateway = deployment.mkContainer "gateway" {
    enableTun = true;
    bindMounts."${config.sops.secrets."wireguard/altair_private_key".path}".isReadOnly = true;

    config = {pkgs, ...}: {
      networking = {
        firewall = {
          enable = true;
          allowedUDPPorts = [51820];
        };

        nat = {
          enable = true;
          externalInterface = "wg0";
          internalInterfaces = ["eth0"];

          forwardPorts = [
            # forgejo
            {
              destination = "${deployment.containerHostIp "forgejo"}:2000";
              proto = "tcp";
              sourcePort = 2222;
            }
            {
              destination = "${deployment.containerHostIp "forgejo"}:4000";
              proto = "tcp";
              sourcePort = 4000;
            }

            # matrix
            {
              destination = "${deployment.containerHostIp "matrix"}:8008";
              proto = "tcp";
              sourcePort = 8008;
            }

            # vintage story
            {
              destination = "${deployment.containerHostIp "vintagestory"}:42420";
              proto = "tcp";
              sourcePort = 42420;
            }
            {
              destination = "${deployment.containerHostIp "vintagestory"}:42420";
              proto = "udp";
              sourcePort = 42420;
            }

            # vaultwarden
            {
              destination = "${deployment.containerHostIp "vaultwarden"}:8080";
              proto = "tcp";
              sourcePort = 8080;
            }
          ];
        };

        wg-quick.interfaces = {
          wg0 = {
            address = ["10.10.0.2/24"];
            dns = ["1.1.1.1"];
            privateKeyFile = config.sops.secrets."wireguard/altair_private_key".path;

            postUp = ''
              # MTU Clamping
              ${pkgs.iptables}/bin/iptables -t mangle -A FORWARD -o wg0 -p tcp -m tcp \
                --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
            '';

            postDown = ''
              # MTU Clamping
              ${pkgs.iptables}/bin/iptables -t mangle -D FORWARD -o wg0 -p tcp -m tcp \
                  --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
            '';

            peers = [
              {
                publicKey = secrets.wireguard.deneb_publickey;
                allowedIPs = ["0.0.0.0/0"];
                endpoint = secrets.wireguard.deneb_endpoint;
                persistentKeepalive = 25;
              }
            ];
          };
        };
      };

      system.stateVersion = "24.11";
    };
  };
}
