{
  description = "First Revision of the Aquila Nix System";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./Aquila
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    hjem.url = "github:feel-co/hjem";
    mint = {
      url = "github:trumank/mint"; # Deep Rock Galactic Mod Loader
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    breeze-cursor = {
      url = "git+https://git.drinkmymilk.org/PapaMilky/breeze-cursors";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tree-sitter-odin = {
      url = "github:tree-sitter-grammars/tree-sitter-odin";
      flake = false;
    };
    odin-ts-mode = {
      url = "github:Sampie159/odin-ts-mode";
      flake = false;
    };
  };
}
