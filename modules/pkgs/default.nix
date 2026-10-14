{
  config,
  pkgs,
  anodyneInputs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.anodyne-wiki.pkgs = {
    enable = lib.mkEnableOption "";
  };
  config = lib.mkIf (config.anodyne-wiki.enable && config.anodyne-wiki.pkgs.enable) {
    environment.systemPackages = [
      anodyneInputs.anodyne-api.packages.${system}.default
      anodyneInputs.anodyne-chrp.packages.${system}.default
      anodyneInputs.anodyne-molpic.packages.${system}.default
    ];
  };
}
