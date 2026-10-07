{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.anodyne-wiki;
in 
{
  imports = [
    ./caddy
    ./frontend
    ./pkgs
    ./api
  ];
  options.anodyne-wiki = {
    enable = lib.mkEnableOption "";
  };
  config = lib.mkIf anodyne-wiki.enable {
      systemd.tmpfiles.rules = [
      "d /var/lib/anodyne 0755 anodyne anodyne -"
    ];
  };
}
