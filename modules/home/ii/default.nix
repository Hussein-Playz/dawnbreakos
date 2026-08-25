{pkgs, lib}: let
  root = ./.;

  collect = predicate: directory: prefix: let
    entries = builtins.readDir directory;
  in
    lib.concatMap (
      name: let
        path = directory + "/${name}";
        relativePath =
          if prefix == ""
          then name
          else "${prefix}/${name}";
      in
        if entries.${name} == "directory"
        then collect predicate path relativePath
        else if predicate relativePath
        then [{inherit path relativePath;}]
        else []
    )
    (builtins.attrNames entries);

  qmlDefinitions = collect (path: lib.hasSuffix ".nix" path && path != "default.nix") root "";
  runtimeFiles = collect (path: !lib.hasSuffix ".nix" path) root "";

  qmlFiles = map (
    file: {
      target = "${lib.removeSuffix ".nix" file.relativePath}.qml";
      source = pkgs.writeText "ii-${lib.replaceStrings ["/"] ["-"] file.relativePath}" (import file.path);
    }
  ) qmlDefinitions;

  link = file: ''
    mkdir -p "$out/${builtins.dirOf file.target}"
    ln -s ${lib.escapeShellArg (toString file.source)} "$out/${file.target}"
  '';
in
  pkgs.runCommand "quickshell-ii" {} ''
    mkdir -p "$out"
    ${lib.concatMapStrings link (map (file: {
      target = file.relativePath;
      source = file.path;
    }) runtimeFiles)}
    ${lib.concatMapStrings link qmlFiles}
  ''
