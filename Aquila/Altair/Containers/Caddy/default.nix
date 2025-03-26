{
  config,
  lib,
  pkgs,
  secrets,
  ...
}: let
  ConfigDir = "containers/caddy";
  HomeDirectory = config.home.homeDirectory;

  ContainerDir = "${HomeDirectory}/${ConfigDir}";

  cfg = config.caddy;

  firstCaddy = ''
    {
      pki {
        ca Caddy {
          name altair-caddy
          root {
            cert /data/root.crt
            key /data/root.key
            format pem_file
          }
        }
      }
    }


  '';
in {
  imports = [
    ./options.nix
  ];
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) networks pods;
  in {
    containers = {
      caddy = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
          RestartSec = "5";
        };
        containerConfig = {
          image = "docker.io/library/caddy:latest";
          userns = "keep-id:uid=1002,gid=100";
          volumes = [
            "${ContainerDir}/Caddyfile:/etc/caddy/Caddyfile"
            "${ContainerDir}/data:/data"
            "${ContainerDir}/config:/config"
          ];
          publishPorts = [
            "8000:80"
            "8001:443"
            "8001:443/udp"
          ];
          networks = ["podman"] ++ cfg.networks;
        };
      };
    };
  };

  # home.activation = {
  #   writeContainerConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     $DRY_RUN_CMD cat > ${ConfigDir}/Caddyfile << EOF
  #     ${firstCaddy}
  #     ${builtins.concatStringsSep "\n" cfg.config}
  #     EOF
  #     $DRY_RUN_CMD cat > ${ContainerDir}/data/root.crt << EOF
  #     ${secrets.caddy.root_cert}
  #     EOF
  #     $DRY_RUN_CMD cat > ${ContainerDir}/data/root.key << EOF
  #     ${secrets.caddy.root_key}
  #     EOF
  #     run ${pkgs.podman}/bin/podman stop caddy
  #   '';
  # };

  home.activation = {
    writeContainerConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      set -e
      mkdir -p "${ConfigDir}" "${ContainerDir}/data"

      echo "Writing Caddyfile..."
      $DRY_RUN_CMD tee "${ConfigDir}/Caddyfile" > /dev/null << EOF
      ${firstCaddy}
      ${builtins.concatStringsSep "\n" cfg.config}
      EOF

      echo "Writing root certificate..."
      $DRY_RUN_CMD install -m 600 /dev/null "${ContainerDir}/data/root.crt"
      $DRY_RUN_CMD tee "${ContainerDir}/data/root.crt" > /dev/null << EOF
      ${secrets.caddy.root_cert}
      EOF

      echo "Writing root key..."
      $DRY_RUN_CMD install -m 600 /dev/null "${ContainerDir}/data/root.key"
      $DRY_RUN_CMD tee "${ContainerDir}/data/root.key" > /dev/null << EOF
      ${secrets.caddy.root_key}
      EOF

      echo "Stopping Caddy container..."
      $DRY_RUN_CMD ${pkgs.podman}/bin/podman stop caddy || true
    '';
  };

  caddy = {
    config = [
      ''
        localhost {
          respond "Hello, world!"

          tls {
            issuer internal {
              ca Caddy
            }
          }
        }
      ''
    ];
  };
}
