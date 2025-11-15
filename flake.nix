{
  description = "First Revision of the Aquila Nix System";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./Aquila/Altair
        ./Aquila/Alshain
        ./Aquila/Okab
        ./Aquila/Deneb
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mint = {
      url = "github:trumank/mint"; # Deep Rock Galactic Mod Loader
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
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
    quadlet-nix = {
      url = "github:SEIAROTg/quadlet-nix";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
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

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
