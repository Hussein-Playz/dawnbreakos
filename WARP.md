# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Project: DawnbreakOS — NixOS flake for desktop systems with per-host overrides, GPU/VM profiles, and an integrated Home Manager layer.

Important repo expectations
|- This repo is expected at: ~/dawnbreakos (programs.nh.flake points here). If you keep it elsewhere, update modules/core/nh.nix accordingly.
|- Target OS: NixOS 23.11+; UEFI + GPT expected; systemd-boot is supported out of the box (see README for details).

Common commands
|- Rebuild and switch (preferred via nh/ncli)
  - fr            # zsh alias → nh os switch --hostname <profile>
  - fu            # zsh alias → nh os switch --hostname <profile> --update
  - ncli rebuild [--dry|--ask|--cores N|--verbose|--no-nom]
  - ncli update  [--dry|--ask|--cores N|--verbose|--no-nom]
|- Rebuild for next boot (safer for bigger changes)
  - ncli rebuild-boot [same options]
  - sudo nixos-rebuild boot --flake .#<profile>
|- Direct NixOS (without nh/ncli)
  - sudo nixos-rebuild switch --flake .#<profile>
|- Validate the flake
  - nix flake check
|- Format Nix files (nixfmt-rfc-style is included)
  - find . -name "*.nix" -print0 | xargs -0 nixfmt
|- Configuration comparison (compare against upstream)
  - ./modules/src/compare-dawnbreakos-config.sh       # compares against official repo
  - ./modules/src/compare-dawnbreakos-config.sh --branch stable-2.4    # specific branch
|- Host management (ncli)
  - ncli update-host [hostname] [profile]  # auto-detect if args omitted
  - ncli add-host <hostname> [profile]     # copies hosts/default, can gen hardware.nix
  - ncli del-host <hostname>

Notes on profiles and hosts
|- Profiles represent hardware targets: amd, intel, nvidia, nvidia-laptop (intel+NVIDIA hybrid), amd-hybrid (AMD+NVIDIA hybrid), vm.
|- Use the profile in flake targets like .#vm or .#nvidia, or via nh's --hostname.
|- Host-specific settings live under hosts/<hostname>/; variables.nix holds UX and feature toggles: barChoice (noctalia or waybar), waybarChoice (when barChoice="waybar"), clock24h, etc.

High-level architecture (big picture)
|- flake.nix
  - Inputs: nixpkgs 25.11, home-manager 25.11, stylix, nvf, nix-flatpak, noctalia; nixvim and quickshell are included but currently inactive (uncommitted to outputs).
  - Defines system, host, profile, username; constructs nixosConfigurations via mkNixosConfig.
  - Each configuration imports profiles/<profile>.
- profiles/<profile>/default.nix
  - Imports host and stacks: ../../hosts/${host}, ../../modules/drivers, ../../modules/core.
  - Toggles drivers and VM guest services per profile; the nvidia-laptop and amd-hybrid profiles consume Bus IDs from host variables.
- hosts/<hostname>/
  - default.nix imports hardware.nix and host-packages.nix.
  - variables.nix is the primary control surface (display manager, terminal/browser defaults, waybarChoice, stylix image, 24h clock, Thunar/printing/NFS flags, intel/nvidia Bus IDs, etc.).
|- modules/core
  - Composes NixOS modules: boot, flatpak, fonts, hardware, network, nfs, nh, quickshell, packages, printing, display manager (greetd/sddm), security, services (PipeWire/SSH/Bluetooth/fstrim; smartd conditional), steam, stylix, syncthing, system (nix settings, locales, env), thunar, user (Home Manager), virtualization, xserver.
  - quickshell.nix installs quickshell with Qt6 dependencies and required environment variables (needed for noctalia-shell).
  - nh.nix enables nh and pins programs.nh.flake to ~/dawnbreakos.
  - user.nix integrates Home Manager and creates users.${username}, passing { inputs, username, host, profile } to the home layer.
- modules/drivers
  - AMD, Intel, NVIDIA, NVIDIA Prime, NVIDIA AMD-Hybrid, and VM guest services; nvidia-prime options (enable, intelBusID, nvidiaBusID) are consumed by the nvidia-laptop profile; nvidia-amd-hybrid options (enable, amdgpuBusID, nvidiaBusID) are consumed by the amd-hybrid profile.
|- modules/home
  - Composes the user environment: Hyprland, bar/shell choice (noctalia-shell or Waybar via barChoice), Rofi, Yazi, terminals (Kitty/WezTerm/Ghostty/Alacritty toggles), Zsh/Bash config, Git, NVF/Neovim, OBS, swaync, scripts, Stylix, optional Doom Emacs/VSCodium/Helix.
  - default.nix conditionally imports barModule: either noctalia.nix (when barChoice="noctalia") or waybarChoice (when barChoice="waybar").
  - noctalia.nix installs noctalia-shell and seeds ~/.config/quickshell/noctalia-shell from the package distribution.
  - scripts/default.nix installs ncli; ncli wraps rebuild/update/boot, cleanup, diagnostics, host management, and Doom lifecycle.
- Shell aliases (zsh)
  - fr and fu are defined in modules/home/zsh/default.nix, parameterized by the active profile.

Key development choices
- Repo location matters: nh and ncli assume ~/dawnbreakos; move it and adjust modules/core/nh.nix.
- Validation is via nix flake check; there is no separate unit test suite.
- Formatting is via nixfmt-rfc-style (provided in system packages).

Useful docs in-repo
- README.md: requirements, install and upgrade overview (including the 2.3→2.4 process).
- ncli.md: full CLI docs, commands, options, and examples.


