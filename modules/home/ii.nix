{
  config,
  lib,
  pkgs,
  ...
}: let
  iiSource = ./ii;
in {
  home.packages = [
    (pkgs.callPackage ./ii/scripts/search/dawn-search.nix {})
  ];

  home.activation.quickshellIi = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DEST="$HOME/.config/quickshell/ii"

    rm -rf "$DEST"
    mkdir -p "$DEST"

    cp -R "${iiSource}/." "$DEST/"
    chmod -R u+rwX "$DEST"
  '';
}
