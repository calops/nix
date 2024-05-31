{ lib, config, ... }:
let
  mkNginxHost = host: port: {
    upstreams.${host}.servers."127.0.0.1:${port}" = { };
    virtualHosts.${host} = {
      locations."/" = {
        proxyPass = "http://${host}";
        proxyWebsockets = true;
      };
      listen = [
        {
          addr = "192.168.1.10";
          port = port;
        }
      ];
    };
  };
in
{
  options.my.roles.monitoring.enable = lib.mkEnableOption "Monitoring utilities";

  config = lib.mkIf config.my.roles.monitoring.enable {
    services.prometheus.enable = true;
    services.loki.enable = true;
    services.promtail.enable = true;
    services.grafana.enable = true;

    services.nginx =
      {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
      }
      // mkNginxHost "grafana" 8010
      // mkNginxHost "prometheus" 8020
      // mkNginxHost "loki" 8030
      // mkNginxHost "promtail" 8031;
  };
}
