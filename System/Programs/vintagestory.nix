{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.vintagestory;

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
  options.aquila.system = {
    programs.vintagestory = {
      enable = lib.mkEnableOption "Install Vintage Story";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vintage
    ];
  };
}
