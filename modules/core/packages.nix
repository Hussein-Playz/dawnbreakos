{
  inputs,
  pkgs,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit (vars) barChoice;
  # Noctalia-specific packages
  noctaliaPkgs =
    if barChoice == "noctalia"
    then
      with pkgs; [
        matugen # color palette generator needed for noctalia-shell
        app2unit # launcher for noctalia-shell
        gpu-screen-recorder # needed for nnoctalia-shell
      ]
    else [];
in {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    firefox.enable = false; # Firefox is not installed by default
    hyprland = {
      enable = true; # set this so desktop file is created
      withUWSM = false;
    };
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    hyprlock.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];

  environment.systemPackages = with pkgs;
    [
      awww
      inputs.synfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ noctaliaPkgs
    ++ [
      alejandra # nix formatter
      amfora # Fancy Terminal Browser For Gemini Protocol
      appimage-run # Needed For AppImage Support
      brightnessctl # For Screen Brightness Control
      cliamp # terminal music player
      cliphist # Clipboard manager using rofi menu
      cmatrix # Matrix Movie Effect In Terminal
      cowsay # Great Fun Terminal Program
      docker-compose # Allows Controlling Docker From A Single File
      duf # Utility For Viewing Disk Usage In Terminal
      dysk # Disk space util nice formattting
      eza # Beautiful ls Replacement
      ffmpeg # Terminal Video / Audio Editing
      fd # find util needed for emacs but good util regardless vs. find
      #gearlever # Manage / run Appimages
      #icu # dep for gearlever
      gimp # Great Photo Editor
      gnumake # Needed for emacs
      gpu-screen-recorder # needed for noctalia-shell
      power-profiles-daemon # needed for noctalia-shell power cycle
      mesa-demos # needed for inxi diag util
      tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
      htop # Simple Terminal Based System Monitor
      eog # For Image Viewing
      inxi # CLI System Information Tool
      killall # For Killing All Instances Of Programs
      libnotify # For Notifications
      lm_sensors # Used For Getting Hardware Temps
      lolcat # Add Colors To Your Terminal Command Output
      lshw # Detailed Hardware Information
      mdcat # CLI markdown parser
      ncdu # Disk Usage Analyzer With Ncurses Interface
      nixfmt # Nix Formatter
      nwg-displays # configure monitor configs via GUI
      nwg-drawer # Application launcher for wayland
      nwg-dock-hyprland # Dock for hyprland
      nwg-menu # App menu for waybar
      onefetch # provides zsaneyos build info on current system
      pandoc # format MD to HTML for cheatsheet parser
      pavucontrol # For Editing Audio Levels & Devices
      pciutils # Collection Of Tools For Inspecting PCI Devices
      picard # For Changing Music Metadata & Getting Cover Art
      pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
      playerctl # Allows Changing Media Volume Through Scripts
      vlc # audio player
      ripgrep # Improved Grep
      sqlite # needed for emaacs
      socat # Needed For Screenshots
      unrar # Tool For Handling .rar Files
      unzip # Tool For Handling .zip Files
      usbutils # Good Tools For USB Devices
      upower # noctalia shell battery
      uwsm # Universal Wayland Session Manager (optional must be enabled)
      v4l-utils # Used For Things Like OBS Virtual Camera
      waybar #
      waypaper # Change wallpaper
      wget # Tool For Fetching Files With Links
      ytmdl # Tool For Downloading Audio From YouTube
      python3 # Python 3 programming language
      netwatch
      syswatch
      diskwatch
      mousam
      qt6.qtpositioning
      kdePackages.kirigami
      pamixer
      python313Packages.kde-material-you-colors
      libsecret
      rubyPackages.glib2
      xdg-user-dirs
      kdePackages.kcmutils
      yq-go
      glib
      kdePackages.breeze-icons
      xdg-desktop-portal
      xdg-desktop-portal-hyprland
      geoclue2-with-demo-agent
      geoclue2
      tailscale
      fuzzel
      kdePackages.qtstyleplugin-kvantum
      pulseaudio
    ];
    fonts.packages = with pkgs; [
      material-symbols
      fira-code
      nerd-fonts.fira-code
    ];
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libX11
      libXext
      libXrender
      libXi
      libXtst
      libXrandr
      libXcursor
      libXfixes
#      libGL
      freetype
      fontconfig
    ];
  };
}
