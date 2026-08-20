{configs, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    qbittorrent
    vscode
    #steam
    kdePackages.kate
    #kdePackages.dolphin
    cava
    lxqt.pavucontrol-qt
    wireplumber
    pipewire
    libdbusmenu-gtk3
    playerctl
    geoclue2
    geoclue2-with-demo-agent
    brightnessctl
#     pcmanfm
    nemo
    ddcutil
    bc
    coreutils
    cliphist
    cmake
    curl
    wget
    ripgrep
    jq
    xdg-user-dirs
    rsync
    kdePackages.breeze
    kdePackages.breeze-icons
    darkly
    eza
    fish
    fontconfig
    matugen
    starship
    hyprsunset
    wl-clipboard
    kdePackages.bluedevil
    gnome-keyring
    networkmanager
    kdePackages.plasma-nm
    kdePackages.polkit-kde-agent-1
    kdePackages.systemsettings
    xdg-desktop-portal
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    clang
    uv
    gtk4
    libadwaita
    libportal-gtk4
    gobject-introspection
    hyprshot
    slurp
    swappy
    tesseract
    wf-recorder
    upower
    wtype
    ydotool
    fuzzel
    rubyPackages.glib2
    imagemagick
    hypridle
    hyprlock
    hyprpicker
    songrec
    translate-shell 
    wlogout
    libqalculate
    vulkan-headers
    libdrm
    cpptrace
    jemalloc
    mesa
    (discord.override {
        withVencord = true;
    })
    kdePackages.konsole
    kdePackages.kirigami
    upscayl
    qimgv
    protonup-qt
    lutris
    protontricks
    kdePackages.ark
    kdePackages.kde-cli-tools
    (runCommand "kde-applications-menu" {} ''
      mkdir -p $out/etc/xdg/menus
      cp ${kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu \
        $out/etc/xdg/menus/applications.menu
    '')
    lxappearance
    gnome-system-monitor
#     inputs.millennium.packages."${pkgs.system}".millennium-steam
  ];
  # Add host specific flatpaks here
  services = {
    flatpak = {
      packages = [
      "app.zen_browser.zen"
      "com.rtosta.zapzap"
      ];
    };
  };
#   environment.etc."xdg/menus/applications.menu".source =
#   "${pkgs.kdePackages.plasma-workspace}/sw/etc/xdg/menus/plasma-applications.menu";
  services.auto-cpufreq.enable = false;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };


}

