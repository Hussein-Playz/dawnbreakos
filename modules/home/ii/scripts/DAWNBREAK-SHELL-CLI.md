# dawnbreak-shell-cli

A local, deliberately narrow CLI for DawnbreakOS's Caelestia-derived Quickshell
configuration. It is maintained in this repository and packaged by
`dawnbreak-shell-cli.nix`; it does not add a flake input or install the upstream
`caelestia` executable.

The implemented commands cover the shell's wallpaper/scheme integration:

- `wallpaper -f PATH` delegates actual wallpaper switching to the existing
  `switchwall.sh` pipeline.
- `wallpaper -p PATH` prints a native Material You palette for QML previews.
- `wallpaper generate --image PATH [--mode dark|light]` updates the palette
  state file independently of Matugen.
- `scheme list`, `scheme get`, and `scheme set` expose the dynamic scheme,
  its `default`/`hard` flavours, and Material 3 variants.

The generated state is stored under `${XDG_STATE_HOME:-~/.local/state}/dawnbreak`,
matching `caelestia/utils/Paths.qml` in this shell. `Colours.qml` watches
`scheme.json` there.

Palette generation is based on the Caelestia CLI's GPL-3.0 Material You
algorithm, adapted locally. See `LICENSE-GPL-3.0` and the upstream project:
https://github.com/caelestia-dots/cli
