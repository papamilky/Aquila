{deployment, ...}: {
  imports = [
    ./Gateway
    ./Forgejo
    ./Matrix
    ./VintageStory
  ];
  deployment.mainInterface = "wlp13s0";
}
