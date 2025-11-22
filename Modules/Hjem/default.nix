{hjem, ...}: {
  hjem = {
    extraModules = [
      ./uwsm.nix
    ];
    clobberByDefault = true;
  };
}
