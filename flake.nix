{
  description = "Anodyne.wiki";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    anodyne-molpic.url = "github:pilz0/anodyne-molpic/add-nix-flake";
    anodyne-api.url = "github:pilz0/anodyne-api/add-nix-flake";
    anodyne-chrp.url = "github:pilz0/anodyne-chrp/add-nix-flake";
    anodyne-frontend.url = "github:AnodyneWiki/anodyne-frontend/add-substances-4-10-2026";
    anodyne-frontend.flake = false;
    systems.url = "github:nix-systems/triplet";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    inputs@{
      nixpkgs,
      treefmt-nix,
      flake-utils,
      anodyne-molpic,
      anodyne-api,
      anodyne-chrp,
      anodyne-frontend,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            anodyne-api.packages.${system}.default
            anodyne-chrp.packages.${system}.default
            anodyne-molpic.packages.${system}.default
          ];
        };

        packages.anodyne-frontend = pkgs.callPackage ./modules/frontend/package.nix {
          src = anodyne-frontend;
        };

        formatter =
          (treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          }).config.build.wrapper;
      }
    )
    // {
      nixosModules.default = {
        imports = [
          ./modules
        ];
        _module.args.inputs = inputs;
      };
    };

}
