{
  host,
  config,
  pkgs,
  lib,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  extraMonitorSettings = vars.extraMonitorSettings or "";
  keyboardLayout = vars.keyboardLayout or "us";
  keyboardVariant = vars.keyboardVariant or "";
  stylixImage = vars.stylixImage or null;

  # Treat only known US-based variants as implying layout = "us".
  usVariants = ["dvorak" "colemak" "workman" "intl" "us-intl" "altgr-intl"];
  normalizeUSVariant = v:
    if v == "us-intl"
    then "intl"
    else v;

  # If layout itself is a US variant (e.g., "dvorak", "us-intl"), normalize it
  layoutFromLayout =
    if builtins.elem keyboardLayout usVariants
    then "us"
    else keyboardLayout;
  variantFromLayout =
    if builtins.elem keyboardLayout usVariants
    then normalizeUSVariant keyboardLayout
    else "";

  # If the provided variant is a US variant, force layout to us; otherwise keep layout
  layoutFromVariant =
    if builtins.elem keyboardVariant usVariants
    then "us"
    else layoutFromLayout;
  variantFinal =
    if builtins.elem keyboardVariant usVariants
    then normalizeUSVariant keyboardVariant
    else if variantFromLayout != ""
    then variantFromLayout
    else keyboardVariant;

  hyprKbLayout = layoutFromVariant;
  hyprKbVariant = variantFinal;
in {
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprshot
    hyprshutdown
    hyprpicker
    hyprland-qtutils # needed for banners and ANR messages
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };
  wayland.windowManager.hyprland = {
    enable = true;
#     configType = "hyprlang";
    configType = "lua";
    package = pkgs.hyprland;
    extraLuaFiles = {
      monitors-loader = {
        content = ''
          dofile(os.getenv("HOME") .. "/.config/hypr/monitors.lua")
        '';
        autoLoad = true;
      };
    };
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    xwayland = {
      enable = true;
    };
     extraConfig = ''
        hl.gesture({
            fingers = 3,
            direction = "horizontal",
            action = "workspace",
        })

        hl.config({
            general = {
                border_size = 2,
                col = {
                    active_border = { colors = { "rgb(cb74ab)", "rgb(b580a9)" }, angle = 45 },
                    inactive_border = "rgb(732c5d)",
                },
                gaps_in = 6,
                gaps_out = 8,
                layout = "dwindle",
                resize_on_border = true,
            },
            gestures = {
                workspace_swipe_cancel_ratio = 0.500000,
                workspace_swipe_create_new = true,
                workspace_swipe_distance = 500,
                workspace_swipe_forever = true,
                workspace_swipe_invert = true,
                workspace_swipe_min_speed_to_force = 30,
            },
            input = {
                kb_options = "grp:alt_caps_toggle",
                touchpad = {
                    disable_while_typing = true,
                    natural_scroll = true,
                    scroll_factor = 0.800000,
                    clickfinger_behavior = true
                },
                float_switch_override_focus = 0,
                follow_mouse = 1,
                kb_layout = "us",
                numlock_by_default = true,
                repeat_delay = 300,
                sensitivity = 0,
            },
            master = {
                always_keep_position = false,
                center_master_fallback = "left",
                drop_at_cursor = true,
                mfact = 0.550000,
                new_on_active = "none",
                new_on_top = false,
                new_status = "slave",
                orientation = "left",
                slave_count_for_center_master = 2,
                smart_resizing = true,
            },
            misc = {
                anr_missed_pings = 15,
                disable_hyprland_logo = true,
                disable_splash_rendering = true,
                enable_anr_dialog = true,
                enable_swallow = false,
                initial_workspace_tracking = 0,
                key_press_enables_dpms = true,
                layers_hog_keyboard_focus = true,
                mouse_move_enables_dpms = true,
                vrr = 0,
            },
            render = {
                cm_auto_hdr = 1,
                cm_enabled = true,
                direct_scanout = 0,
            },
            scrolling = {
                column_width = 0.800000,
                direction = "right",
                follow_focus = true,
                fullscreen_on_one_column = true,
            },
            xwayland = {
                force_zero_scaling = true,
            },
            cursor = {
              enable_hyprcursor = false,
              no_hardware_cursors = 2,
              no_warps = true,
              sync_gsettings_theme = true,
              warp_on_change_workspace = 2,
            },
            decoration = {
                blur = {
                    enabled = true,
                    ignore_opacity = false,
                    new_optimizations = true,
                    passes = 3,
                    size = 5,
                },
                shadow = {
                    color = "rgba(1a1a1aee)",
                    enabled = true,
                    range = 4,
                    render_power = 3,
                },
                rounding = 10,
            },
            dwindle = {
                default_split_ratio = 1.000000,
                precise_mouse_move = false,
                preserve_split = true,
                smart_resizing = true,
                smart_split = false,
                special_scale_factor = 0.800000,
                split_bias = 0,
                use_active_for_splits = true,
            },
            ecosystem = {
                no_donation_nag = true,
                no_update_news = false,
            },
        })
     '';
    };
  }

