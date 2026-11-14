{ lib
, stdenvNoCC
, python3
, makeWrapper
, ffmpeg
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.materialyoucolor
    ps.pillow
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "dawnbreak-shell-cli";
  version = "0.1.0";
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/licenses/dawnbreak-shell-cli"
    cp ${./LICENSE-GPL-3.0} "$out/share/licenses/dawnbreak-shell-cli/COPYING"
    makeWrapper ${pythonEnv}/bin/python3 "$out/bin/dawnbreak-shell-cli" \
      --add-flags ${./dawnbreak-shell-cli.py} \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
    runHook postInstall
  '';

  meta = {
    description = "DawnbreakOS local wallpaper and Material You palette helper";
    mainProgram = "dawnbreak-shell-cli";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
