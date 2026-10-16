{host, ...}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
        hl.bind("SUPER + R",
            hl.dsp.exec_cmd("dawnbreak-launcher"),
            { description = "Apps: Dawnbreak Launcher" })
        hl.bind("SUPER + ALT + R",
            hl.dsp.exec_cmd("env DESKTOPINTEGRATION=1 LD_LIBRARY_PATH=/run/current-system/sw/lib /home/dawn/AppImages/osu.appimage %u"),
            { description = "Apps: Osu!"})
    '';
  };
}
