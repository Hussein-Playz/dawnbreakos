# Dawnbreak QML Plugin

This directory is a standalone, renamed port of the plugin source shipped in
[Caelestia Shell](https://github.com/caelestia-dots/shell). The implementation
is intentionally kept in C++ where upstream uses C++, with its QML API exposed
through the `Dawnbreak` module URI. It is not a QML-only rewrite.

## Requirements

- CMake 3.24+
- C++20 compiler
- Qt 6.9+ development packages: Core, Qml, Gui, Quick, QuickControls2,
  Concurrent, Sql, Network, DBus, ShaderTools
- pkg-config packages: `libqalculate`, `libpipewire-0.3`, `aubio`, and either
  `libcava` or `cava`
- `libsensors` and headers (`sensors/sensors.h`)
- Quickshell / Qt versions compatible with the upstream source

## Build

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build --parallel
cmake --install build
```

The module is installed below `lib/qt6/qml/Dawnbreak` (with submodules beside
it). Make sure Qt/Quickshell can see `$HOME/.local/lib/qt6/qml`, for example by
setting `QML_IMPORT_PATH` in the environment used to launch Quickshell.

In QML:

```qml
import Dawnbreak
```

Submodules use corresponding URIs such as `Dawnbreak.Config`,
`Dawnbreak.Components`, `Dawnbreak.Services`, and `Dawnbreak.Models`.

## Port notes

- This preserves upstream plugin sources and module layout while renaming
  `Caelestia`/`caelestia` identifiers inside the plugin to `Dawnbreak`/
  `dawnbreak`.
- This is a source port, not a claim of a successful build: dependencies and
  compatibility must be validated on the target system.
- Some upstream shell-level integrations, configuration paths, external
  programs, and assumptions may still need adaptation for a non-Caelestia
  Quickshell shell.
- Preserve the upstream GPL-3.0 license and notices. See `LICENSE`.


## DawnbreakOS integration

The DawnbreakOS project includes `nix/dawnbreak-plugin.nix` and adds this
package to `environment.systemPackages`; its Qt QML import directory is added
to `QML_IMPORT_PATH` and `QML2_IMPORT_PATH` in `modules/core/quickshell.nix`.
