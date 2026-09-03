{ pkgs }:
pkgs.writeShellScriptBin "dawn-search" ''
  exec ${pkgs.python3}/bin/python3 ${./dawn-search.py} "$@"
''
