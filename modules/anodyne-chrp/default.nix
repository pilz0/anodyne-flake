{
  pkgs,
  anodyneInputs,
  lib,
  config,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  anodyne-chrp = anodyneInputs.anodyne-chrp.packages.${system}.default;
  anodyne-molpic = anodyneInputs.anodyne-molpic.packages.${system}.default;
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
      default = "/var/lib/anodyne/db.sqlite";
    };
  };
  config = lib.mkIf (config.anodyne-wiki.enable && cfg.enable) {
    systemd.services.anodyne-chrp = {
      description = "anodyne wiki scraper";
      after = [
        "network-online.target"
        "anodyne-frontend-sync.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "anodyne-frontend-sync.service" ];
      serviceConfig = {
        User = "anodyne";
        Group = "anodyne";
        Type = "oneshot";
        ExecStart = "${anodyne-chrp}/bin/chrp --database ${cfg.databasePath} --molpic ${anodyne-molpic}/bin/molpic --frontend ${config.anodyne-wiki.frontend.root} --cache=${cfg.cacheDir} --mode=search --skip dbi-igs";
      };
    };
    systemd.services.anodyne-chrp-init = {
      description = "anodyne chrp setup script";
      after = [
        "network-online.target"
        "anodyne-frontend-sync.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "anodyne-frontend-sync.service" ];
      serviceConfig = {
        User = "anodyne";
        Group = "anodyne";
        Type = "oneshot";
        ExecStart = "${anodyne-chrp}/bin/chrp --database ${cfg.databasePath} --molpic ${anodyne-molpic}/bin/molpic --frontend ${config.anodyne-wiki.frontend.root} --cache=${cfg.cacheDir} --mode=init";
      };
    };
  };
}
