{
 config,
 pkgs,
 inputs,
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
    inputs.anodyne-api.packages.${system}.default
    inputs.anodyne-chrp.packages.${system}.default
    inputs.anodyne-molpic.packages.${system}.default
  ];
};
}
