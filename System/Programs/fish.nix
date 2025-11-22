{
  lib,
  pkgs,
  ...
}: let 
  inherit (lib) pipe attrValues concatStringsSep map;
in {
  documentation.man.generateCaches = false; 
  programs.fish = {
    enable = true;
    useBabelfish = true;
    generateCompletions = false; 
    shellAbbrs = {
      ## nothing here
    };
    shellAliases = {
      ## nothing here
    };

    interactiveShellInit = '''';
  };

  programs = {
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--cmd cd"];
    };
    direnv.enableFishIntegration = true;
    command-not-found.enable = false;
    fzf.keybindings = true;
  };

  environment.systemPackages = attrValues {
    inherit (pkgs.fishPlugins) done sponge tide;
    # inherit (pkgs) eza fish-lsp;
  };
}