{
  config,
  lib,
  pkgs,
  ...
}: let
  faceSource = ./face.png;
in {
  home.activation.faceActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DEST="$HOME/.face"

    if [ -f "${faceSource}" ]; then
      install -m 644 "${faceSource}" "$DEST"
    fi
  '';
}
