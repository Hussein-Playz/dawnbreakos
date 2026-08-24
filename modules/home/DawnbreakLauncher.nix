{ config, pkgs, ...}:

{
    home.file.".local/share/applications/DawnbreakLauncher.desktop".text = ''
        [Desktop Entry]
        Categories=Game;
        Exec="$HOME/Desktop/Dawnbreak Launcher/atlauncher"
        Icon=atlauncher
        Keywords=game;Minecraft;
        MimeType=
        Name=Dawnbreak Launcher
        StartupWMClass=com-atlauncher-App
        Comment=A launcher for Minecraft which integrates multiple different modpacks to allow you to download and install modpacks easily and quickly.
        Path=
        StartupNotify=true
        Terminal=false
        TerminalOptions=
        Type=Application
    '';
}
