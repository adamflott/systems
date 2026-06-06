{ config, pkgs, ... }:

{
  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "inanna";
      };

      security = {
        admin_user = "admin";
        admin_password = "getout";
        secret_key = "$__file{/var/lib/grafana/secret_key}";
      };

      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;

      datasources.settings = {
        apiVersion = 1;

        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            isDefault = true;
          }
        ];
      };
    };
  };

  # Optional, but useful for SMART health monitoring outside Prometheus too.
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";

    retentionTime = "180d";

    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "zfs"
          "processes"
          "filesystem"
          "diskstats"
          "netdev"
          "thermal_zone"
        ];
      };

      smartctl = {
        enable = true;
        port = 9633;

        # Leave empty for autodiscovery, or explicitly list:
        # devices = [ "/dev/sda" "/dev/sdb" "/dev/nvme0n1" ];
        devices = [ ];
      };

      zfs-siebenmann = {
        enable = true;
        port = 9134;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "127.0.0.1:9100" ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "127.0.0.1:9633" ];
          }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [ "127.0.0.1:9134" ];
          }
        ];
      }
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
          }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    3000 # Grafana
    9090 # Prometheus UI; leave closed unless you want LAN access
    # 9100 # node exporter; usually keep local only
    # 9633 # smartctl exporter; usually keep local only
  ];

  environment.systemPackages = with pkgs; [
    smartmontools
  ];
}
