{host, ...}: {
  wayland.windowManager.hyprland = {
    # Keybinds here cant use the modifier for super due to extraConfig placing them at the top of the file so use a structure such as:
    extraConfig = ''
        hl.bind("SUPER + R",
            hl.dsp.exec_cmd("test"),
            { description = "Apps: Test run (Does nothing) this is just to show the syntax of hl.bind in the host-specific binds.nix" })
    '';
  };
}
