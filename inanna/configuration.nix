{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelParams = [ "radeon.audio=0" ];
#  boot.kernelPackages = pkgs.linuxPackages_5_8;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "snd_pcsp" ];

  hardware.cpu.amd.updateMicrocode = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.video.hidpi.enable = true;

  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  hardware.sane.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;

  
  fileSystems."/void" = {
    device = "10.0.5.10:/void";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto"];
  };

  networking.useDHCP = true;
  networking.hostName = "inanna";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 2222 4040 3000 8333 ];
  networking.firewall.allowPing = true;

  nixpkgs.config.allowUnfree = true;

  console ={
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  time.timeZone = "US/Eastern";

  environment.homeBinInPath = true;
  environment.systemPackages = with pkgs; [
     SDL
     SDL2
     SDL2_mixer
     airsonic
     alsaLib
     alsaTools
     alsaUtils
     apacheKafka
     apcupsd
     apg
     aspell
     aspellDicts.en
     aspellDicts.en-computers
     aspellDicts.en-science
     atop
     audacity
     bind
     binutils
     bitcoin
     chrony
     claws-mail
     cmus
     darktable
     dcm2niix
     dep
     digikam
     dmidecode
     dnsutils
     dvdplusrwtools
     electrum
     elinks
     emacs
     ffmpeg-full
     file
     filezilla
     fluidsynth
     gcc9
     gdb
     geeqie
     ghc
     gimp
     gitAndTools.git-hub
     gitAndTools.gitFull
     glxinfo
     gnumake
     gnupg
     go
     haskellPackages.xmonad
     haskellPackages.xmonad-contrib
     haskellPackages.xmonad-extras
     haskellPackages.xmonad-utils
     haskellPackages.xmonad-wallpaper
     haskellPackages.yeganesh
     hddtemp
     hdparm
     hlint
     html-tidy
     htop
     imagemagick
     imapsync
     inxi
     iotop
     ispell
     iw
     jq
     kdeApplications.okular
     kodi
     libinput
     libstrophe
     lm_sensors
     lsb-release
     lsof
     man-pages
     mplayer
     mtr
     nix-index
     nmap
     nmon
     openssl
     p7zip
     pass
     pciutils
     pidgin
     pstree
     redis
     redshift
     ripgrep
     ruby
     rustup
     smartmontools
     socat
     sshfs-fuse
     sshguard
     stack
     stunnel
     tmux
     tree
     ttyplot
     unrar
     unzip
     usbutils
     vim
     wget 
     whois
     wine
     wirelesstools
     wireshark
     wrk
     xclip
     xmobar
     xorg.xdpyinfo
     xorg.xeyes
     xscreensaver
     yq
     yquake2-all-games
     zip
     zlib
     zsh
     zsh-autosuggestions
  ];

  programs.mtr.enable = true;

  programs.gnupg.agent.enable = true;

  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  services.openssh.ports = [ 22 2222 ];
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";
  services.sshguard.enable = true;

  services.printing.enable = true;

  sound.enable = true;

  services.upower.enable = true;
  systemd.services.upower.enable = true;

  services.logind.extraConfig = ''
       HandlePowerKey=ignore
  '';

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.windowManager.xmonad.enableContribAndExtras = true;

  users.users.adam = {
     description = "Adam Flott";
     isNormalUser = true;
     extraGroups = [
	 "audio"
	 "cdrom"
	 "disk"
	 "docker"
	 "lp"
	 "networkmanager"
	 "scanner"
	 "systemd-journal"
	 "users"
	 "vboxusers"
	 "video"
         "wheel"
     ];
     shell = pkgs.zsh;
  };

  security.pam.loginLimits = [
      { domain = "adam"; item = "nofile"; type = "hard"; value = "65536"; }
  ];

  security.pki.certificateFiles = [
    /root/pki/AkamaiClientCA.pem
    /root/pki/AkamaiCorpRoot-G1.pem
    /root/pki/AkamaiIssuerSHA2.pem
    /root/pki/akamai-pki-issuing.pem
    /root/pki/akamai-pki.pem
    /root/pki/AkamaiServerCA.pem
  ];
  
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  
  services.airsonic = {
    enable = true;
    maxMemory = 4096;
    listenAddress = "0.0.0.0";
  };

  services.zookeeper.enable = true;
  
  services.apache-kafka = {
    enable = true;
    extraProperties = ''
offsets.topic.replication.factor=1
delete.topic.enable=true
'';
  };

  services.apcupsd.enable = true;
  
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
