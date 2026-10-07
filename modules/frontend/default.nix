{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  options.anodyne-wiki.frontend = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { src = inputs.anodyne-frontend; };
    };
  };
}
