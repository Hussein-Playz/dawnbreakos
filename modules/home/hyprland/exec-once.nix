{host, ...}: let
  vars = import ../../../hosts/${host}/variables.nix;
  inherit
    (vars)
    stylixImage
    ;
in {
  wayland.windowManager.hyprland = {
    extraConfig = ''
        hl.on("hyprland.start", function()
             hl.exec_cmd("wl-paste --type text --watch bash -c 'cliphist store && qs -c ii ipc call cliphistService update'")
             hl.exec_cmd("wl-paste --type image --watch bash -c 'cliphist store && qs -c ii ipc call cliphistService update'")
             hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
             hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
             hl.exec_cmd("systemctl --user start hyprpolkitagent")
             hl.exec_cmd("qs -c ii")
             hl.exec_cmd("hyprland-change-layout init")
             hl.exec_cmd("easyeffects --hide-window --service-mode")
             hl.exec_cmd("discord")
        end)
    '';
  };
}
