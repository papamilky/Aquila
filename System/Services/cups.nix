{pkgs, ...}: {
  services.printing.enable = true;
  environment.systemPackages = with pkgs; [
    brlaser
  ];
}
# MIGRATED TO NEW FLAKES

