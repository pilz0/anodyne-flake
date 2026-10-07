{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.anodyne-wiki.caddy;
  webRoot = config.anodyne-wiki.frontend.package;
in
{
  options.anodyne-wiki.caddy = {
    enable = lib.mkEnableOption "";
    domain = lib.mkOption {
      type = lib.types.str;
    };
    serverName = lib.mkOption {
      type = lib.types.str;
      default = "anodyne_wiki";
    };
    contactEmail = lib.mkOption {
      type = lib.types.str;
    };
    adminPort = lib.mkOption {
      type = lib.types.int;
      default = 2019;
    };
    apiPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
    };
  };

  config = lib.mkIf (config.anodyne-wiki.enable && cfg.enable) {
  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/mholt/caddy-ratelimit@v0.1.0"
        "github.com/caddyserver/transform-encoder@v0.0.0-20260423033309-ba4124974830"
      ];
      hash = "sha256-GprhSYIk0x7ugpR9YZFeDGX/IANRYZl8lHA6t3NLMqo=";
    };

    email = cfg.contactEmail;

    globalConfig = ''
      debug
      metrics
      order rate_limit after basic_auth
      admin localhost:${toString cfg.adminPort}
      servers ${cfg.domain} {
          name ${cfg.serverName}
      }
      servers http://localhost:${toString cfg.apiPort} {
          trusted_proxies static private_ranges
      }
    '';

    # idk if we still need this
    virtualHosts."127.0.0.1:80".extraConfig = ''
      handle {
          respond "{\"NotFound\": True}" 200
      }
    '';

    virtualHosts."${cfg.domain}" = {
      logFormat = ''
        output file ${config.services.caddy.logDir}/caddy_cust.txt
        format transform `[{ts}]: {request>remote_ip} - "{request>headers>User-Agent>[0]}" - {request>method}({status}) {request>host}{request>uri} [{request>headers>Referer>[0]}]` {
            time_format "15:04:05"
        }
      '';

      extraConfig = ''
        root ${webRoot}
        @banned {
            path /.git/*
            path /wordpress/*
            path /wp/*
            path /wp2/*
            path /wp-includes/*
            path /wp-admin/*
            path /news/*
            path /shop/*
            path /site/*
            path /test/*
            path /media/*
            path /media/system/*
            path /.aws/credentials
            path /.AWS/credentials
            path /.env
            path /.env.bak
        }
        handle @banned {
            abort
        }

        @blockedAgents {
            header_regexp User-Agent "(GPTBot|ClaudeBot|CCBot|SemrushBot)"
        }
        respond @blockedAgents 403

        @static {
            method GET
            path /user/0xea/pics/*.jpg
            path /assets/*.png
            path /assets/*.jpg
            path /composite/*.jpg
            path /assets/*.ico
            path /structure/*.svg
            path /css/*.css
            path /jsmol/*.js
            path /j2s/*.js
            path /j2s/core/*.kjs
            path /j2s/img/*
            path /j2s/J/translation/*.js
            path /j2s/J/export/*.js
            path /j2s/J/g3d/*.js
            path /js/*.js
            path /mol/*.mol
            path /robots.txt
        }
        handle @static {
            file_server
            header {
                /static/* Cache-Control "public, max-age=2592000"
            }
        }
        rate_limit {
            distributed
            zone anodyne {
                match {
                    method GET
                }
                key static
                events 1000
                window 1m
            }
            log_key
        }
        @effects file {
            root ${webRoot}
            try_files /effect/{path}.md
        }
        @notes file {
            root ${webRoot}
            try_files /note/{path}.md
        }
        @userend file {
            root ${webRoot}
            try_files /user/{path}/preferences.json
        }
        @indexes file {
            root ${webRoot}/index
            try_files /{path}.json
        }
        @classes file {
            root ${webRoot}/class
            try_files /{path}.json
        }
        @substs file {
            root ${webRoot}/substituted
            try_files /{path}.json
        }
        @roas file {
            root ${webRoot}/administration
            try_files /{path}/vars.json
        }
        @onlyPost {
            method POST
            path /api/*
        }
        @html file /{path}.html

        @subPath path /substance/*
        @compPath path /composite/*
        @cmpPath path /compound/*
        @protPath path /protein/*
        @sendPath path /send/*
        @formPath path /form/*
        @idxPath path /index/*
        @rdxPath path /random/*
        @ccPath path /class/*
        @substPath path /substituted/*
        @rtPath path /*
        @roaPath path /administration/*
        @effPath path /effect/*
        @notePath path /note/*
        @setDark query theme=dark
        @setLight query theme=light
        @setExpand query collapse=none
        @setCollapse query collapse=all
        @set3dmoljs query conformer=3dmoljs
        @setjsmol query conformer=jsmol
        @setNomol query conformer=none
        @setNoHint query hint=none
        @setWikiHint query hint=wiki
        @userPath {
            not path *.jpg
            not path *.png
            path /user/*
        }

        handle_path /api/* {
              handle /status/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /substance/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /composite/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /compound/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /protein/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /structure/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
              handle /request/* {
                reverse_proxy localhost:${toString cfg.apiPort} {
                  @error status 500 503
                  handle_response @error {
                    respond "{\"NotFound\": True}"
                  }
                }
              }
            handle /userpage/* {
              reverse_proxy localhost:${toString cfg.apiPort} {
                @error status 500 503
                handle_response @error {
                  respond "{\"NotFound\": True}"
                }
              }
            }
            handle_path /user/* {
                try_files "/user/{path}/preferences.json"
                file_server
            }
            handle_path /index/* {
                try_files "/index/{path}.json"
                file_server
            }
            handle_path /random/* {
                try_files "/index/{path}.json"
                file_server
            }
            handle_path /substituted/* {
                try_files "/substituted/{path}.json"
                file_server
            }
            handle_path /class/* {
                try_files "/class/{path}.json"
                file_server
            }
            handle_path /administration/* {
                try_files "/administration/{path}.json"
                file_server
            }
        }
        handle {
            @noConformer not {
                header Cookie *conformer=*
            }
            handle @noConformer {
                header Set-Cookie "conformer=3dmoljs; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly"
            }

            @noHint not {
                header Cookie *hint=*
            }
            handle @noHint {
                header Set-Cookie "hint=wiki; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly"
            }

            handle @setDark {
                header Set-Cookie "theme=dark; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -theme
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }
            handle @setLight {
                header Set-Cookie "theme=light; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -theme
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }

            handle @setExpand {
                header Set-Cookie "collapse=none; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -collapse
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }
            handle @setCollapse {
                header Set-Cookie "collapse=all; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -collapse
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }

            handle @set3dmoljs {
                header Set-Cookie "conformer=3dmoljs; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -conformer
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }
            handle @setjsmol {
                header Set-Cookie "conformer=jsmol; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -conformer
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }
            handle @setNomol {
                header Set-Cookie "conformer=none; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -conformer
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }

            handle @setNoHint {
                header Set-Cookie "hint=none; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -hint
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }
            handle @setWikiHint {
                header Set-Cookie "hint=wiki; Max-Age=31536000; Path=/; SameSite=Strict; HttpOnly; Secure"
                uri query -hint
                redir https://${cfg.domain}{http.request.orig_uri.path} permanent
            }

            rewrite /index.html /about.html
            rewrite @subPath /substance.html
            rewrite @compPath /composite.html
            rewrite @cmpPath /compound.html
            rewrite @protPath /protein.html
            rewrite @sendPath /send.html
            rewrite @formPath /form.html
            rewrite @idxPath /index.html
            rewrite @rdxPath /random.html
            rewrite @ccPath /class.html
            rewrite @substPath /substituted.html
            rewrite @roaPath /administration.html
            rewrite @userPath /user.html
            rewrite @effPath /effect.html
            rewrite @notePath /note.html
            rewrite /substance /about.html
            rewrite /composite /about.html
            rewrite /substance/ /about.html
            rewrite /composite/ /about.html
            rewrite /compound /about.html
            rewrite /compound/ /about.html
            rewrite /protein /about.html
            rewrite /protein/ /about.html
            rewrite /send/ /about.html
            rewrite /send /about.html
            rewrite /form/ /form.html
            rewrite /form /form.html
            rewrite /quotes /quotes.html
            rewrite /legal /legal.html
            rewrite /donate /donate.html
            rewrite /logger /logger.html
            rewrite / /about.html
            rewrite /about /about.html
            rewrite /api /api.html

            templates
            try_files {path}.html /{path}
            file_server
        }
        handle_errors {
            @404 {
                expression {http.error.status_code} == 404
            }
            handle @404 {
                rewrite * /404.html
                templates
                file_server
            }
            redir @effects https://www.effectindex.com/effects{uri} permanent
        }
      '';
    };
  };
  };
}
