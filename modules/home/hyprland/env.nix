{...}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
        hl.env("NIXOS_OZONE_WL", "1")
        hl.env("NIXPKGS_ALLOW_UNFREE", "1")
        hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
        hl.env("XDG_SESSION_TYPE", "wayland")
        hl.env("XDG_SESSION_DESKTOP", "Hyprland")
        hl.env("GDK_BACKEND", "wayland, x11")
        hl.env("CLUTTER_BACKEND", "wayland")
        hl.env("QT_QPA_PLATFORM", "wayland;xcb")
        hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
        hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
        hl.env("SDL_VIDEODRIVER", "x11")
        hl.env("MOZ_ENABLE_WAYLAND", "1")
        hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
        hl.env("GDK_SCALE", "1")
        hl.env("QT_SCALE_FACTOR", "1")
        hl.env("EDITOR", "nvim")
        hl.env("TERMINAL", "kitty")
        hl.env("XDG_TERMINAL_EMULATOR", "kitty")
        hl.env("LIBVA_DRIVER_NAME", "nvidia")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
        hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
        hl.env("QT_QPA_PLATFORM", "wayland;xcb")
        hl.env("QT_QPA_PLATFORMTHEME", "kde")
        hl.env("XDG_MENU_PREFIX", "plasma-")
        hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", "$HOME/.local/state/quickshell/.venv")
    '';
  };
}
