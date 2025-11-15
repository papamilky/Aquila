{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.programs.gui;
in {
  config = lib.mkIf cfg.enable {
    ## Fonts
    fonts.packages = with pkgs; [
      meslo-lgs-nf
      jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      material-icons
      material-design-icons
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      unifont
      dina-font
      proggyfonts
      corefonts
      vista-fonts
      source-han-sans
      open-sans
      source-han-serif
      meslo-lgs-nf
      roboto-mono
      roboto
      hack-font
      inter
    ];
    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;
  };
}
