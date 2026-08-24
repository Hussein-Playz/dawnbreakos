{
  config,
  lib,
  ...
}: let
  iiSource = ./ii;
in {
  # Seed the Quickshell ii code into ~/.config/quickshell/ii
  # Copy (not symlink) so QML module resolution works and users can edit files
  home.activation.seedOverviewCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    DEST="$HOME/.config/quickshell/ii"
    SRC="${iiSource}"


    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/quickshell"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"
    fi
  '';
}
