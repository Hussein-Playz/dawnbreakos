{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "dawnbreak-launcher";

  runtimeInputs = [
    pkgs.jdk17
  ];

  text = ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.flite
      pkgs.gamemode
      pkgs.libxxf86vm
      pkgs.libxcursor
      pkgs.libx11
      pkgs.systemdMinimal
      pkgs.libpulseaudio
      pkgs.libglvnd
    ]}"

    exec java \
      -jar "$HOME/Desktop/Dawnbreak Launcher/Dawnbreak-MC-Launcher.jar" \
      --working-dir "$HOME/Desktop/Dawnbreak Launcher" \
      "$@"
  '';
}
