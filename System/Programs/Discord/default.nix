{
  pkgs,
  inputs,
  ...
}: let
  fixxedDiscord = (pkgs.discord.override
    {
      withMoonlight = true;
    }).overrideAttrs (old: {
    installPhase =
      old.installPhase
      + ''
        rm -rf $out/share/applications
      '';
    postFixup =
      old.postFixup or ""
      + ''
        wrapProgram $out/bin/${old.pname} \
          --add-flags "--no-sandbox --disable-gpu-sandbox"
      '';
  });
in {
  environment.systemPackages = with pkgs; [
    fixxedDiscord
    (makeDesktopItem {
      name = "Discord";
      desktopName = "Discord (Moonlight)";
      exec = "discord";
      icon = "discord"; # uses default icon from package
      genericName = "Custom Discord launcher with flags";
      categories = ["Network" "InstantMessaging"];
      mimeTypes = ["x-scheme-handler/discord"];
      startupWMClass = "discord";
    })
  ];
}
