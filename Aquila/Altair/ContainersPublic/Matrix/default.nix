{
  config,
  pkgs,
  deployment,
  lib,
  ...
}: {
  sops.secrets = {
    "matrix/sharedSecret" = {
      owner = "matrix-synapse";
      restartUnits = ["container@matrix.service"];
    };
  };

  users.users.matrix-synapse = {
    isSystemUser = true;
    uid = config.ids.uids.matrix-synapse;
    group = "matrix-synapse";
  };
  users.groups.matrix-synapse = {
    gid = config.ids.gids.matrix-synapse;
  };

  containers.matrix = deployment.mkContainer "matrix" {
    bindMounts = {
      "${config.sops.secrets."matrix/sharedSecret".path}".isReadOnly = true;
    };

    config = {
      networking = {
        firewall.enable = false;
        defaultGateway.address = deployment.containerHostIp "gateway";
      };

      environment.systemPackages = with pkgs; [
        dig
        traceroute
        mautrix-discord
      ];

      services = {
        matrix-synapse = {
          enable = true;
          withJemalloc = true;

          # TODO: setup turn for voice chat
          # extraConfigFiles = ["/turn-shared-secret/synapse-config"];

          settings = {
            enable_registration = true;
            suppress_key_server_warning = true;
            enable_registration_without_verification = true;
            registration_shared_secret_path = config.sops.secrets."matrix/sharedSecret".path;

            server_name = "drinkmymilk.org";
            dynamic_thumbnails = true;
            max_upload_size = "200M";

            app_service_config_files = [
              "/var/lib/matrix-synapse/registration.yaml"
            ];

            listeners = [
              {
                port = 8008;
                bind_addresses = ["0.0.0.0"];
                type = "http";
                tls = false;
                x_forwarded = true;

                resources = [
                  {
                    names = ["client" "federation"];
                    compress = true;
                  }
                ];
              }
            ];
          };
        };

        postgresql = {
          enable = true;
          enableJIT = true;

          initialScript = pkgs.writeText "postgres-init.sql" ''
            -- Create user and database for matrix-synapse
            CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
            CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
              TEMPLATE template0
              ENCODING 'UTF8'
              LC_COLLATE = 'C'
              LC_CTYPE = 'C';

            -- Create user and database for mautrix-discord
            CREATE ROLE "mautrix-discord" WITH LOGIN PASSWORD 'mautrix-discord';
            CREATE DATABASE "mautrix-discord" WITH OWNER "mautrix-discord"
              TEMPLATE template0
              ENCODING 'UTF8'
              LC_COLLATE = 'C'
              LC_CTYPE = 'C';
          '';
        };
      };

      systemd.services.mautrix-discord = {
        description = "mautrix-discord bridge";
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "exec";
          User = "matrix-synapse";
          Group = "matrix-synapse";
          ExecStart = "${pkgs.mautrix-discord}/bin/mautrix-discord -c /etc/matrix-synapse/config.yaml";
          Restart = "on-failure";
          RestartSec = "30s";

          WorkingDirectory = "/var/lib/matrix-synapse";
          ReadWritePaths = "/var/lib/matrix-synapse";

          # Optional hardening
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          RestrictRealtime = true;
          LockPersonality = true;
          ProtectKernelLogs = true;
          ProtectKernelTunables = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          PrivateUsers = true;
          ProtectClock = true;
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";
          SystemCallFilter = "@system-service";
        };
      };

      environment.etc."matrix-synapse/config.yaml" = {
        user = "matrix-synapse";
        group = "matrix-synapse";
        source = ./discordbridge.yaml;
        mode = "0400";
      };

      system.stateVersion = "23.11";
    };
  };
}
