{
  config,
  pkgs,
  deployment,
  ...
}: let
  vintage = pkgs.vintagestory.overrideAttrs (final: prev: {
    version = "1.21.5";
    src = pkgs.fetchurl {
      url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
      hash = "sha256-dG1D2Buqht+bRyxx2ie34Z+U1bdKgi5R3w29BG/a5jg=";
    };

    installPhase = let
      patchedDll = pkgs.fetchurl {
        url = "http://files.drinkmymilk.org/VintageStory-1.21.5-Patch.dll";
        hash = "sha256-+TmFBCq0wlovQYraKGjlIozVo1GAHRsLJXQEKwcGymg=";
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
