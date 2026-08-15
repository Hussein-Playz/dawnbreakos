# {...}: {
#   services = {
#     hypridle = {
#       enable = true;
#       systemdTarget = "hyprland-session.target";
#       settings = {
#         general = {
#           after_sleep_cmd = "hyprctl dispatch dpms on";
#           ignore_dbus_inhibit = false;
#           lock_cmd = "hyprlock";
#         };
#         listener = [
#           {
#             timeout = 900;
#             on-timeout = "hyprlock";
#           }
#           {
#             timeout = 1200;
#             on-timeout = "hyprctl dispatch dpms off";
#             on-resume = "hyprctl dispatch dpms on";
#           }
#         ];
#       };
#     };
#   };
# }
{...}: {
  services.hypridle = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = {
      general = {
        lock_cmd = ''hyprctl dispatch 'hl.dsp.global("quickshell:lock")' & pidof qs quickshell hyprlock || hyprlock'';
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.global("quickshell:lockFocus")' '';
        inhibit_sleep = 3;
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' '';
          on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend || loginctl suspend";
        }
      ];
    };
  };
}
