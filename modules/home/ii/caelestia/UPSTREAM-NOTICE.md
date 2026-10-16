# Dawnbreak dashboard port: upstream notice

This directory contains QML components, services, utilities, modules, and assets adapted from Caelestia Shell.

- Upstream source: https://github.com/caelestia-dots/shell
- Upstream license: see `UPSTREAM-LICENSE`.
- Asset-specific license/attribution files shipped by upstream are preserved in `assets/` (including the Google Sans Flex license).
- The original directory layout is intentionally preserved to make future component/module ports straightforward.
- Imports were renamed from `Caelestia.*` to `Dawnbreak.*` and from `qs.components/services/utils/modules` to the isolated `qs.caelestia.*` namespace to avoid collisions with the existing DawnbreakOS `ii` config.

Review individual asset licenses before redistributing this config outside your own machine.
