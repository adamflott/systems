{
  config,
  pkgs,
  lib,
  ...
}:

let
  hostname = "inanna";
  lanCIDR = "10.0.5.0/24";
in
{
  imports = [
    ./hardware-configuration.nix
    ./observability.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.networkmanager.enable = true;
  networking.hostId = "e426c146";
  networking.hostName = hostname;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      445
      139
    ];
    allowedUDPPorts = [
      137
      138
    ];
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.fish.enable = true;

  users.users.root = {
    shell = pkgs.fish;
  };
  users.users."adam" = {
    isNormalUser = true;
    description = "Adam Flott";
    extraGroups = [
      "networkmanager"
      "wheel"
      "media"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    btop
    curl
    emacs
    git
    htop
    iftop
    inxi
    iotop
    lm_sensors
    mc
    neovim
    nixfmt
    nvme-cli
    openssl
    pciutils
    rclone
    tmux
    usbutils
    zfs
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
    };

    trim = {
      enable = true;
      interval = "weekly";
    };

    autoSnapshot = {
      enable = true;
      frequent = 8;
      hourly = 24;
      daily = 14;
      weekly = 8;
      monthly = 6;
    };
  };

  #  fileSystems."/void" = {
  #    device = "void";
  #    fsType = "zfs";
  #  };

  #  fileSystems."/vacuum" = {
  #    device = "vacuum";
  #    fsType = "zfs";
  #  };

  users.groups.media = { };

  users.users.samba = {
    isSystemUser = true;
    group = "media";
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = hostname;
        "netbios name" = hostname;
        security = "user";
        "map to guest" = "Bad User";
        "server min protocol" = "SMB3";
        "smb encrypt" = "desired";
      };

      void = {
        path = "/void";
        browseable = "yes";
        writable = "yes";
        "guest ok" = "no";
        "valid users" = "@media";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
      vacuum = {
        path = "/vacuum";
        browseable = "yes";
        writable = "yes";
        "guest ok" = "no";
        "valid users" = "@media";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.userServices = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
