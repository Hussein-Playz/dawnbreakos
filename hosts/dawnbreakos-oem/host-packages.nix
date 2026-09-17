{
  configs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Normal Usuage
    qbittorrent
    kdePackages.kate
    kdePackages.konsole
    (discord.override {
      withVencord = true;
    })
    gnome-system-monitor
    # Development
    jdk17
    vscode
    (pkgs.unityhub.override {
      extraLibs = pkgs: with pkgs; [
        sqlite
        openssl
      ];
    })
    #jetbrains.pycharm
    #jetbrains.idea
    #figma-linux
    # Gaming
    #protonup-qt
    protontricks
    # Uncategorized
    icu
    tree
  ];
  programs.nix-ld = {
  enable = true;
    libraries = with pkgs; [
      icu
    ];
  };

  # Add host specific flatpaks here
  services = {
    flatpak = {
      packages = [
        "com.rtosta.zapzap"
      ];
    };
  };
#   services.auto-cpufreq.enable = false;
#   services.auto-cpufreq.settings = {
#     battery = {
#       governor = "powersave";
#       energy_performance_preference = "power";
#       turbo = "never";
#     };
#     charger = {
#       governor = "performance";
#       energy_performance_preference = "performance";
#       turbo = "auto";
#     };
#   };
}
