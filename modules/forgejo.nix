{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in
{
  services.nginx = {
    virtualHosts.${cfg.settings.server.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "code.tinted.dev";
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_ADDR = "::1";
        HTTP_PORT = 3000;
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      # TODO: enable mailing
      mailer = {
        ENABLED = false;
        SMTP_ADDR = "mail.tinted.dev";
        FROM = "noreply@${srv.DOMAIN}";
        USER = "noreply@${srv.DOMAIN}";
      };
    };
    mailerPasswordFile = config.age.secrets.forgejo-mailer-password.path;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = "monolith";
      url = "https://code.tinted.dev";
      # Obtaining the path to the runner token file may differ
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      labels = [ ];
    };
  };

  systemd.services.forgejo.preStart = ''
    create="${lib.getExe config.services.forgejo.package} admin user create"
    $create --admin --email "you@example.com" --username you --password "`cat ${config.sops.secrets.forgejo.path}`" &>/dev/null || true
  '';
}
