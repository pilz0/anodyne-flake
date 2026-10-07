{
 pkgs,
 inputs,
 lib,
 ...
}:
let
  anodyne-chrp = inputs.anodyne-chrp.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cfg = config.anodyne-wiki.chrp;
in
{
  options.anodyne-wiki.chrp = {
      enable = lib.mkEnableOption "";
      cacheDir = lib.mkOption {
        type = lib.types.path;
        default = "/tmp/chrp";
      };
      databasePath = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/anodyne/db.sqlite"
      };
    };
  config = lib.mkIf (anodyne-wiki.enable && config.anodyne-wiki.api.enable) {
    systemd.services.anodyne-api = {
      enable = true;
      description = "anodyne wiki scraper";
      path =  [
        inputs.anodyne-molpic.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      serviceConfig = {
        User = "anodyne";
        Group = "anodyne";
        Type = "oneshot"; 
        ExecStart = "${anodyne-chrp}/bin/chrp --database ${cfg.databasePath} --molpic anodyne-molpic--frontend ${config.anodyne-wiki.frontend.package} --cache=${cfg.cacheDir} --mode=search";
      };
    };
  };
}
