{
  pkgs,
  anodyneInputs,
  lib,
  config,
  ...
}:
let
  anodyne-api = anodyneInputs.anodyne-api.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cfg = config.anodyne-wiki.api;
in
{
  options.anodyne-wiki.api = {
    enable = lib.mkEnableOption "";
    databasePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/anodyne/db.sqlite";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
    };
    pageHookFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/anodyne-api-env";
      description = ''
        Environment file containing `PAGE_HOOK=<url>`, the Discord webhook
        url for substance page requests. Page requests are not forwarded
        when unset.
      '';
    };
  };
  config = lib.mkIf (config.anodyne-wiki.enable && cfg.enable) {
    systemd.services.anodyne-api = {
      enable = true;
      description = "Anodyne.wiki API";
      after = [
        "network.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "anodyne";
        Group = "anodyne";
        ExecStart = "${anodyne-api}/bin/anodyne-api -port ${toString cfg.port} -db ${cfg.databasePath}";
        Restart = "on-failure";
      }
      // lib.optionalAttrs (cfg.pageHookFile != null) {
        EnvironmentFile = cfg.pageHookFile;
      };
    };
  };
}
