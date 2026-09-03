{ pkgs, ... }:

pkgs.writeShellScriptBin "dbb-mode" ''
  exec ${pkgs.bash}/bin/bash ${./dbb-mode.sh} "$@"
''
