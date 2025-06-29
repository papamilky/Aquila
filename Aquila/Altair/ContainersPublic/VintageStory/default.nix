{
  config,
  pkgs,
  deployment,
  ...
}: let
  vintage = pkgs.vintagestory.overrideAttrs (final: prev: {
    version = "1.20.12";
    src = pkgs.fetchurl {
      url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
      hash = "sha256-h6YXEZoVVV9IuKkgtK9Z3NTvJogVNHmXdAcKxwfvqcE=";
    };

    installPhase = let
      patchedDll = pkgs.fetchurl {
        url = "https://cdn.discordapp.com/attachments/1357478142972792854/1381379100391903252/VintagestoryLib.dll?ex=68474d0a&is=6845fb8a&hm=e8ac412bd2653ad3bf3e1dfab94d498b3bbc8c14acd7452267ee3e9f28b1e8b1&";
        hash = "sha256-VEo4NrGo1+GOsv/Mw3wq1aFCyyElQNnEv0kPiKUmF8k=";
      };
    in
      prev.installPhase
      + ''
        # replace dll with patched dll
        cp ${patchedDll} $out/share/vintagestory/VintagestoryLib.dll
      '';
  });
in {
  containers.vintagestory = deployment.mkContainer "vintagestory" {
    bindMounts = {
      "/mount/Deneb/Vintage".isReadOnly = false;
    };

    config = {
      networking = {
        firewall.enable = false;
        defaultGateway.address = deployment.containerHostIp "gateway";
      };

      environment.systemPackages = with pkgs; [
        vintage
      ];

      systemd.services.vintagestory-server = {
        description = "Vintage Story Server";
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${vintage}/bin/vintagestory-server --dataPath /mount/Deneb/Vintage";
          Restart = "on-failure";
          RestartSec = "30s";

          WorkingDirectory = "/mount/Deneb/Vintage";
          ReadWritePaths = "/mount/Deneb/Vintage";
        };
      };

      system.stateVersion = "23.11";
    };
  };
}
