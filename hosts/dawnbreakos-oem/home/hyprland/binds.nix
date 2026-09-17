{host, ...}: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
        hl.bind("SUPER + R",
            hl.dsp.exec_cmd("dawnbreak-launcher"),
            { description = "Apps: Dawnbreak Launcher" })
    '';
  };
}
