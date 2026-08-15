{
  config,
  lib,
  ...
}: let
  matugenSource = ./matugen;
in {
  home.activation.seedOverviewCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    DEST="$HOME/.config/matugen"
    SRC="${matugenSource}"


    if [ ! -d "$DEST" ]; then
      mkdir -p "$HOME/.config/matugen"
      cp -R "$SRC" "$DEST"
      chmod -R u+rwX "$DEST"
    fi
  '';
}
