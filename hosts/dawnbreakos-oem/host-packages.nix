{configs, pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    qbittorrent
    jdk17 
    vscode
    kdePackages.kate
    (discord.override {
        withVencord = true;
    })
    kdePackages.konsole
    atlauncher
    protonup-qt
    lutris
    protontricks
    qemu
    gnome-system-monitor
    figma-linux
    unityhub
    codex
  ];
  # Add host specific flatpaks here
  services = {
    flatpak = {
      packages = [
      "com.rtosta.zapzap"
      ];
    };
  };
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

