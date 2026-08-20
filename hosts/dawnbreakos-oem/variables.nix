{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Hussein-Orabi";
  gitEmail = "houseinplayz@gmail.com";

  # Set Displau Manager
  # `tui` for Text login
  # `sddm` for graphical GUI (default)
  # SDDM background is set with stylixImage
  displayManager = "sddm";

  # Emable/disable bundled applications
  tmuxEnable = false;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;
  vscodeEnable = true;
  # Note: This is evil-helix with VIM keybindings by default
  helixEnable = false;
  #To install: Enable here, ncli rebuild, then run ncli doom install
  doomEmacsEnable = false;

  dbwl="/home/dawn/Desktop/Dawnbreak Launcher/atlauncher";

  # Python development tools are included by default

  # Hyprland Settings
  # Examples:
  # extraMonitorSettings = "monitor = Virtual-1,1920x1080@60,auto,1";
  # extraMonitorSettings = "monitor = HDMI-A-1,1920x1080@60,auto,1";
  # You can configure multiple monitors.
  # Inside the quotes, create a new line for each monitor.
  extraMonitorSettings = "
   monitor = eDP-1,2560x1600@240.00000,1920x0,1
   monitor = HDMI-A-1,1920x1080@60.0,0x0,1
    ";

  # Bar/Shell Settings
  # Choose between noctalia or waybar
  barChoice = "waybar";

  # Waybar Settings (used when barChoice = "waybar")
  clock24h = false;

  # Program Options
  # Set Default Browser (google-chrome-stable for google-chrome)
  # This does NOT install your browser
  # You need to install it by adding it to the `packages.nix`
  # or as a flatpak
  #browser = "brave";
  browser = "app.zen_browser.zen";
  

  # Host-level default applications (picked up by Home Manager xdg.mimeApps)
  # Uncomment and adjust the .desktop IDs to set per-host defaults.
  # mimeDefaultApps = {
  #   # PDFs
  #   "application/pdf" = ["okular.desktop"];
  #   "application/x-pdf" = ["okular.desktop"];
  #   # Web browser
  #   "x-scheme-handler/http"  = ["google-chrome.desktop"];  # or brave-browser.desktop, firefox.desktop
  #   "x-scheme-handler/https" = ["google-chrome.desktop"];
  #   "text/html"              = ["google-chrome.desktop"];
  #   # Files
  #   "inode/directory" = ["thunar.desktop"];      # file manager
  #   "text/plain"      = ["nvim.desktop"];        # or code.desktop
  # };
  mimeDefaultApps = {
  # File manager
#   "inode/directory" = [ "org.kde.dolphin.desktop" ];
  "inode/directory" = [ "nemo.desktop" ];

  # Text editor
  "text/plain" = [ "org.kde.kate.desktop" ];

  # Images
  "image/jpeg" = [ "qimgv.desktop" ];
  "image/gif" = [ "qimgv.desktop" ];
  "image/png" = [ "qimgv.desktop" ];
  "image/bmp" = [ "qimgv.desktop" ];
  "image/webp" = [ "qimgv.desktop" ];

  # Archives
  "application/x-deb" = [ "org.kde.ark.desktop" ];
  "application/x-cd-image" = [ "org.kde.ark.desktop" ];
  "application/x-bcpio" = [ "org.kde.ark.desktop" ];
  "application/x-cpio" = [ "org.kde.ark.desktop" ];
  "application/x-cpio-compressed" = [ "org.kde.ark.desktop" ];
  "application/x-sv4cpio" = [ "org.kde.ark.desktop" ];
  "application/x-sv4crc" = [ "org.kde.ark.desktop" ];
  "application/x-rpm" = [ "org.kde.ark.desktop" ];
  "application/x-compress" = [ "org.kde.ark.desktop" ];
  "application/gzip" = [ "org.kde.ark.desktop" ];
  "application/x-bzip" = [ "org.kde.ark.desktop" ];
  "application/x-bzip2" = [ "org.kde.ark.desktop" ];
  "application/x-lzma" = [ "org.kde.ark.desktop" ];
  "application/x-xz" = [ "org.kde.ark.desktop" ];
  "application/zlib" = [ "org.kde.ark.desktop" ];
  "application/zstd" = [ "org.kde.ark.desktop" ];
  "application/x-lz4" = [ "org.kde.ark.desktop" ];
  "application/x-lzip" = [ "org.kde.ark.desktop" ];
  "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
  "application/vnd.rar" = [ "org.kde.ark.desktop" ];
  "application/zip" = [ "org.kde.ark.desktop" ];
  "application/x-java-archive" = [ "org.kde.ark.desktop" ];
  "application/x-tar" = [ "org.kde.ark.desktop" ];
  "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-bzip-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-bzip2-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-xz-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-lzma-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-lzip-compressed-tar" = [ "org.kde.ark.desktop" ];
  "application/x-zstd-compressed-tar" = [ "org.kde.ark.desktop" ];

  # Video
  "video/mp4" = [ "vlc.desktop" ];
  "video/x-matroska" = [ "vlc.desktop" ];
  "video/webm" = [ "vlc.desktop" ];
  "video/mpeg" = [ "vlc.desktop" ];
  "video/quicktime" = [ "vlc.desktop" ];
  "video/x-msvideo" = [ "vlc.desktop" ];

  # Audio
  "audio/mpeg" = [ "vlc.desktop" ];
  "audio/ogg" = [ "vlc.desktop" ];
  "audio/wav" = [ "vlc.desktop" ];
  "audio/flac" = [ "vlc.desktop" ];
  "audio/x-wav" = [ "vlc.desktop" ];
  # Torrenting
  "application/x-bittorrent" = [ "org.qbittorrent.qBittorrent.desktop" ];
  "x-scheme-handler/magnet" = [ "org.qbittorrent.qBittorrent.desktop" ];
};
  # Available Options:
  # Kitty, ghostty, wezterm, aalacrity
  # Note: kitty, wezterm, alacritty have to be enabled in `variables.nix`
  # Setting it here does not enable it. Kitty is installed by default
  terminal = "kitty"; # Set Default System Terminal

  keyboardLayout = "us";
  keyboardVariant = "";
  consoleKeyMap = "us";

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  # Requires manual changing to work correctly
  intelID = "PCI:0@0:2:0";
  amdgpuID = "PCI:5:0:0";
  nvidiaID = "PCI:2@0:0:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Enable Thunar GUI File Manager
  # Yazi is alternate File Manager
  thunarEnable = false;

  # Themes, waybar and animation.
  #  Only uncomment your selection
  # The others much be commented out.

  # Set Stylix Image
  # This will set your color palette
  # Default background
  # Add new images to ~/dawnbreakos/wallpapers
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  stylixImage = ../../wallpapers/KonochanPaper.png;
  # Set Waybar
  #  Available Options:
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-dwm.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-dwm-2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jerry.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-TheBlackDon.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-tony.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubsos-v1.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-mecha.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;
  waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin-v2.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-ml4w-modern.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jak-oglo-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-transparent.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jwt-ultradark.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-pctrade-catppuccin.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-old-ddubsos.nix;

  # Set Animation style
  # Available options are:
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations-end4-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations-end-slide.nix;
  animChoice = ../../modules/home/hyprland/animations-dynamic.nix;
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;
  #animChoice = ../../modules/home/hyprland/animations-hyde-optimized.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-1.nix;
  #animChoice = ../../modules/home/hyprland/animations-mahaveer-me-2.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-classic.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-fast.nix;
  #animChoice = ../../modules/home/hyprland/animations-ml4w-high.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";
}
