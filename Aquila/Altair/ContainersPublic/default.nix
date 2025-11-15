{deployment, ...}: {
  imports = [
    ./Gateway
    ./Forgejo
    ./Matrix
    ./VintageStory
    ./Vaultwarden
  ];
  deployment.mainInterface = "wlp13s0";
}
