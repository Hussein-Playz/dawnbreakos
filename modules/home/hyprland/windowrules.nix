_: {
  wayland.windowManager.hyprland = {
#     configType = "lua";
    extraConfig = ''
      hl.window_rule({
          name = "Resolve",
          match = {
              class = "^(\\bresolve\\b)$",
              xwayland = 1,
          },
          no_blur = true,
      })

      hl.window_rule({
          name = "Terminals",
          match = {
              class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm|dropterminal)$",
          },
          tag = "+terminal",
      })

      hl.window_rule({
          name = "vscodium",
          match = {
              class = "^(codium|codium-url-handler|VSCodium)$",
          },
          tag = "+projects",
      })

      hl.window_rule({
          name = "vscode",
          match = {
              class = "^(VSCode|code-url-handler)$",
          },
          tag = "+projects",
      })

      hl.window_rule({
          name = "Discord",
          match = {
              class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$",
          },
          tag = "+im",
      })
      hl.window_rule({
          name = "Whatsapp",
          match = {
              class = "^([Ww]hatsapp-for-linux)$",
          },
          tag = "+im",
      })

      hl.window_rule({
          name = "gamescope",
          match = {
              class = "^(gamescope)$",
          },
          tag = "+games",
      })

      hl.window_rule({
          name = "steam-app",
          match = {
              class = "^(steam_app\\d+)$",
          },
          tag = "+games",
      })

      hl.window_rule({
          name = "Steam",
          match = {
              class = "^([Ss]team)$",
          },
          tag = "+gamestore",
      })

      hl.window_rule({
          name = "Lutris",
          match = {
              title = "^([Ll]utris)$",
          },
          tag = "+gamestore",
      })

      hl.window_rule({
          name = "gnome-disks",
          match = {
              class = "^(gnome-disks|wihotspot(-gui)?)$",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "rofi",
          match = {
              class = "^([Rr]ofi)$",
          },
          tag = "+settings",
          no_blur = false,
      })

      hl.window_rule({
          name = "FileRoller",
          match = {
              class = "^(file-roller|org.gnome.FileRoller)$",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "NetworkManger",
          match = {
              class = "^(nm-applet|nm-connection-editor|blueman-manager)$",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "PlusAudio",
          match = {
              class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
          },
          center = true,
          tag = "+settings",
          no_blur = false,
      })

      hl.window_rule({
          name = "nwg-look",
          match = {
              class = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "xdg-desktop-portal-gtk",
          match = {
              class = "(xdg-desktop-portal-gtk)",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "blueman",
          match = {
              class = "(.blueman-manager-wrapped)",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "nwg-displays",
          match = {
              class = "(nwg-displays)",
          },
          tag = "+settings",
      })

      hl.window_rule({
          name = "Picture-in-Picture",
          match = {
              title = "^(Picture-in-Picture)$",
          },
          float = true,
          move = "72% = 7%",
          pin = false,
          keep_aspect_ratio = true,
      })

      hl.window_rule({
          name = "ThunarFileMgr",
          match = {
              class = "([Tt]hunar)",
              title = "negative:(.*[Tt]hunar.*)",
          },
          center = true,
          float = true,
      })

      hl.window_rule({
          name = "Authentication-Required",
          match = {
              title = "^(Authentication Required)$",
          },
          center = true,
          float = true,
      })

      hl.window_rule({
          name = "IdleInhibit-fullscreen-1",
          match = {
              class = "^(.*)$",
          },
          idle_inhibit = "fullscreen",
      })

      hl.window_rule({
          name = "IdleInhibit-fullscreen-2",
          match = {
              title = "^(.*)$",
          },
          idle_inhibit = "fullscreen",
      })

      hl.window_rule({
          name = "IdleInhibit-fullscreen-3",
          match = {
              fullscreen = 1,
          },
          idle_inhibit = "fullscreen",
      })

      hl.window_rule({
          name = "Settings-Tag",
          match = {
              tag = "settings*",
          },
          float = true,
          size = "70% = 70%",
          no_blur = false,
      })

      hl.window_rule({
          name = "WayPaper",
          match = {
              class = "^([Ww]aypaper)$",
          },
          float = true,
          no_blur = false,
      })

      hl.window_rule({
          name = "mpv-or-clapper",
          match = {
              class = "^(mpv|com.github.rafostar.Clapper)$",
          },
          float = true,
      })

      hl.window_rule({
          name = "codium-url-handler",
          match = {
              class = "(codium|codium-url-handler|VSCodium)",
              title = "negative:(.*codium.*|.*VSCodium.*)",
          },
          float = true,
      })

      hl.window_rule({
          name = "Steam",
          match = {
              class = "^([Ss]team)$",
              title = "negative:^([Ss]team)$",
          },
          float = true,
      })

      hl.window_rule({
          name = "Add-Folder",
          match = {
              initial_title = "(Add Folder to Workspace)",
          },
          float = true,
          size = "70% = 60%",
      })

      hl.window_rule({
          name = "Open-File",
          match = {
              initial_title = "(Open Files)",
          },
          float = true,
          size = "70% = 60%",
      })

      hl.window_rule({
          name = "Wants-to-Save",
          match = {
              initial_title = "(wants to save)",
          },
          float = true,
      })

      hl.window_rule({
          name = "Browsers",
          match = {
              tag = "browser*",
          },
      })

      hl.window_rule({
          name = "Projects",
          match = {
              tag = "projects*",
          },
      })

      hl.window_rule({
          name = "Instant-Messaging",
          match = {
              tag = "im*",
          },
      })

      hl.window_rule({
          name = "File-Managers",
          match = {
              tag = "file-manager*",
          },
      })

      hl.window_rule({
          name = "Terminals-opacity",
          match = {
              tag = "terminal*",
          },
          no_blur = false,
      })

      hl.window_rule({
          name = "windowrule-77",
          match = {
              class = "^(gedit|org.gnome.TextEditor|mousepad)$",
          },
      })

      hl.window_rule({
          name = "windowrule-78",
          match = {
              class = "^(seahorse)$",
          },
      })

      hl.window_rule({
          name = "windowrule-79",
          match = {
              tag = "games*",
          },
          no_blur = true,
      })

      hl.window_rule({
          name = "windowrule-80",
          match = {
              tag = "games*",
          },
          fullscreen = true,
      })

      hl.window_rule({
          name = "qs-keybinds",
          match = {
              title = "^(Hyprland Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration)$",
          },
          float = true,
          center = true,
          size = "55% = 66%",
      })

      hl.window_rule({
          name = "qs-cheatsheets",
          match = {
              title = "^(Cheatsheets Viewer)$",
          },
          float = true,
          center = true,
          size = "65% = 60%",
      })

      hl.window_rule({
          name = "qs-extended-viewers",
          match = {
              title = "^(Hyprland Keybinds|Niri Keybinds|BSPWM Keybinds|i3 Keybinds|Sway Keybinds|DWM Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration|Cheatsheets Viewer|Documentation Viewer)$",
          },
          float = true,
          center = true,
          size = "55% = 66%",
      })

      hl.window_rule({
          name = "QS-Wallpapers",
          match = {
              class = "^(org\\.qt-project\\.qml)$",
              title = "^(Wallpapers)$",
          },
          border_size = 0,
          float = true,
          no_blur = true,
          no_shadow = true,
          rounding = 12,
      })

      hl.window_rule({
          name = "QA-Video-Wallpapers",
          match = {
              class = "^(org\\.qt-project\\.qml)$",
              title = "^(Video Wallpapers)$",
          },
          border_size = 0,
          center = true,
          float = true,
          no_blur = true,
          no_shadow = true,
          rounding = 12,
      })

      hl.window_rule({
          name = "QS-wlogout",
          match = {
              initial_class = "^(org[.]qt-project[.]qml)$",
              initial_title = "^(qs-wlogout)$",
          },
          border_size = 0,
          center = true,
          float = true,
          rounding = 20,
      })

      hl.window_rule({
          name = "QA-Panels",
          match = {
              class = "^(org\\.qt-project\\.qml)$",
              title = "^(Panels)$",
          },
          center = true,
          float = true,
          no_blur = true,
          no_shadow = true,
          rounding = 12,
      })

      hl.window_rule({
          name = "QS-Cheatsheets",
          match = {
              class = "^(org\\.qt-project\\.qml)$",
              title = "^(Cheatsheets Viewer)$",
          },
          border_size = 0,
          center = true,
          float = true,
          no_shadow = true,
          rounding = 12,
      })

      hl.window_rule({
          name = "QS-Documentation-Viewer",
          match = {
              class = "^(org\\.qt-project\\.qml)$",
              title = "^(Documentation Viewer)$",
          },
          border_size = 0,
          center = true,
          float = true,
          no_shadow = true,
          rounding = 12,
      })
      hl.window_rule({
          match = { class = "^(.*)$" },
          idle_inhibit = "fullscreen",
      })

      hl.window_rule({
          match = { title = "^(.*)$" },
          idle_inhibit = "fullscreen",
      })

      hl.window_rule({
          match = { fullscreen = 1 },
          idle_inhibit = "fullscreen",
      })
      hl.window_rule({
          match = { title = "^(Authentication Required)$" },
          center = true,
          float = true,
      })
    '';
  };
}
