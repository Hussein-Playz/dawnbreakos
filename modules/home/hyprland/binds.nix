{host, ...}: let

  vars = import ../../../hosts/${host}/variables.nix;

  inherit
    (vars)
    browser
    terminal
    ;

in {

  wayland.windowManager.hyprland = {

    extraConfig = ''

      local modifier = "SUPER"

      local qsIpcCall = "qs -c $qsConfig ipc call"

      local qsIsAlive = qsIpcCall .. " TEST_ALIVE"


      --##! Quickshell

      hl.bind(modifier .. " + D",
        hl.dsp.global("quickshell:searchToggleRelease"),
        { description = "Quickshell: Search Toggle" })

      --hl.bind(modifier .. " + D",
      --  hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))

      hl.bind(modifier .. " + CTRL + D",
        hl.dsp.exec_cmd("dock"),
        { description = "Quickshell: Toggle Dock" })

      hl.bind(modifier .. " + TAB",
        hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"),
        { description = "Quickshell: Overview" })

      hl.bind(modifier .. " + SHIFT + K",
        hl.dsp.exec_cmd("qs-keybinds"),
        { description = "Quickshell: Keybinds Search Tool" })

      hl.bind(modifier .. " + SHIFT + W",
        hl.dsp.exec_cmd("qs-wallpapers-apply"),
        { description = "Quickshell: Wallpaper Setter" })

      hl.bind(modifier .. " + SHIFT + N",
        hl.dsp.exec_cmd("swaync-client -rs"),
        { description = "Quickshell: Notification Reset" })

      hl.bind(modifier .. " + TAB",
        hl.dsp.global("quickshell:overviewWorkspacesToggle"),
        { description = "Quickshell: Overview" })

      hl.bind(modifier .. " + V",
        hl.dsp.global("quickshell:overviewClipboardToggle"),
        { description = "Quickshell: Clipboard" })

      hl.bind(modifier .. " + period",
        hl.dsp.global("quickshell:overviewEmojiToggle"),
        { description = "Quickshell: Emoji Picker" })

      hl.bind(modifier .. " + A",
        hl.dsp.global("quickshell:sidebarLeftToggle"),
        { description = "Quickshell: Left Sidebar" })

      hl.bind(modifier .. " + ALT + A",
        hl.dsp.global("quickshell:sidebarLeftToggleDetach"),
        { description = "Quickshell: Left Sidebar Detached" })

      hl.bind(modifier .. " + B",
        hl.dsp.global("quickshell:sidebarLeftToggle"),
        { description = "Quickshell: Left Sidebar" })

      hl.bind(modifier .. " + O",
        hl.dsp.global("quickshell:sidebarLeftToggle"),
        { description = "Quickshell: Left Sidebar" })

      hl.bind(modifier .. " + N",
        hl.dsp.global("quickshell:sidebarRightToggle"),
        { description = "Quickshell: Right Sidebar" })

      hl.bind(modifier .. " + slash",
        hl.dsp.global("quickshell:cheatsheetToggle"),
        { description = "Quickshell: Cheatsheet" })

      hl.bind(modifier .. " + M",
        hl.dsp.global("quickshell:mediaControlsToggle"),
        { description = "Quickshell: Media Controls" })

      hl.bind(modifier .. " + G",
        hl.dsp.global("quickshell:overlayToggle"),
        { description = "Quickshell: Overlay" })

      hl.bind("CTRL + ALT + Delete",
        hl.dsp.global("quickshell:sessionToggle"),
        { description = "Quickshell: Session Menu" })

      hl.bind(modifier .. " + J",
        hl.dsp.global("quickshell:barToggle"),
        { description = "Quickshell: Bar Toggle" })

      hl.bind(modifier .. " + CTRL + T",
        hl.dsp.global("quickshell:wallpaperSelectorToggle"),
        { description = "Quickshell: Wallpaper Selector" })

      hl.bind("SHIFT + SUPER + ALT + slash",
        hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/ii/welcome.qml"),
        { description = "Quickshell: End-4 Welcome" })

      hl.bind(modifier .. " + CTRL + ALT + T",
        hl.dsp.global("quickshell:wallpaperSelectorRandom"),
        { description = "Quickshell: Random Wallpaper" })

      hl.bind(modifier .. " + CTRL + R",
        hl.dsp.exec_cmd("killall ydotool qs quickshell; qs -c ii"),
        { description = "Quickshell: Restart Widgets" })


      --##! Apps

      hl.bind(modifier .. " + Return",
        hl.dsp.exec_cmd("kitty"),
        { description = "Apps: Terminal" })

      hl.bind(modifier .. " + SHIFT + D",
        hl.dsp.exec_cmd("discord"),
        { description = "Apps: Discord" })

      hl.bind(modifier .. " + W",
        hl.dsp.exec_cmd("app.zen_browser.zen"),
        { description = "Apps: Web Browser" })

      hl.bind(modifier .. " + E",
        hl.dsp.exec_cmd("nemo"),
        { description = "Apps: File Manager" })

      hl.bind(modifier .. " + R",
        hl.dsp.exec_cmd("\"/home/dawn/Desktop/Dawnbreak Launcher/atlauncher\""),
        { description = "Apps: Dawnbreak Launcher" })

      hl.bind("CTRL + SHIFT + escape",
        hl.dsp.exec_cmd("gnome-system-monitor"),
        { description = "System: GNOME System Monitor" })

      hl.bind(modifier .. " + ALT + M",
        hl.dsp.exec_cmd("pavucontrol"),
        { description = "Apps: Audio Control" })

      hl.bind(modifier .. " + ALT + W",
        hl.dsp.exec_cmd("web-search"),
        { description = "Apps: Web Search" })


      --##! Utilities

      hl.bind(modifier .. " + S",
        hl.dsp.exec_cmd("screenshootin"),
        { description = "Utilities: Screenshot" })

      hl.bind(modifier .. " + CTRL + S",
        hl.dsp.exec_cmd("hyprshot -m output -o $HOME/Pictures/ScreenShots"),
        { description = "Utilities: Screenshot Output" })

      hl.bind(modifier .. " + ALT + S",
        hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/ScreenShots"),
        { description = "Utilities: Screenshot Window" })

      hl.bind(modifier .. " + SHIFT + S",
        hl.dsp.global("quickshell:regionScreenshot"),
        { description = "Utilities: Region Screenshot" })

      hl.bind(modifier .. " + ALT + C",
        hl.dsp.exec_cmd("hyprpicker -a"),
        { description = "Utilities: Color Picker" })

      hl.bind(modifier .. " + SHIFT + T",
        hl.dsp.exec_cmd("sh -lc 'DropTerminal'"),
        { description = "Utilities: Dropdown Terminal" })

      hl.bind(modifier .. " + CTRL + C",
        hl.dsp.exec_cmd("qs-cheatsheets"),
        { description = "Utilities: Cheatsheets Viewer" })


      --##! Window

      hl.bind(modifier .. " + Q",
        hl.dsp.window.close(),
        { description = "Window: Kill Active Window" })

      hl.bind(modifier .. " + SHIFT + Q",
        hl.dsp.exec_cmd("hyprctl kill"),
        { description = "Window: Force Kill Active Window" })

      hl.bind(modifier .. " + P",
        hl.dsp.window.pseudo(),
        { description = "Window: Pseudo Tile" })

      hl.bind(modifier .. " + SHIFT + I",
        hl.dsp.layout("togglesplit"),
        { description = "Window: Toggle Split" })

      hl.bind(modifier .. " + F",
        hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
        { description = "Window: Fullscreen" })

      hl.bind(modifier .. " + ALT + SPACE",
        hl.dsp.window.float({ action = "toggle" }),
        { description = "Window: Float/Tile Toggle" })

      hl.bind(modifier .. " + ALT + 1", function()
        hl.config({ general = { layout = "dwindle" } })
        { description = "Window: Layout Dwindle"}
      end)

      hl.bind(modifier .. " + ALT + 2", function()
        hl.config({ general = { layout = "master" } })
        { description = "Window: Layout Master"}
      end)

      hl.bind(modifier .. " + ALT + 3", function()
        hl.config({ general = { layout = "scrolling" } })
        { description = "Window: Layout Scrolling"}
      end)

      hl.bind(modifier .. " + ALT + 4", function()
        hl.config({ general = { layout = "monocle" } })
        { description = "Window: Layout Monocle"}
      end)

      hl.bind(modifier .. " + SHIFT + left",
        hl.dsp.window.move({ direction = "l" }),
        { description = "Window: Move Left" })

      hl.bind(modifier .. " + SHIFT + right",
        hl.dsp.window.move({ direction = "r" }),
        { description = "Window: Move Right" })

      hl.bind(modifier .. " + SHIFT + up",
        hl.dsp.window.move({ direction = "u" }),
        { description = "Window: Move Up" })

      hl.bind(modifier .. " + SHIFT + down",
        hl.dsp.window.move({ direction = "d" }),
        { description = "Window: Move Down" })

      hl.bind(modifier .. " + SHIFT + h",
        hl.dsp.window.move({ direction = "l" }),
        { description = "Window: Move Left (VI)" })

      hl.bind(modifier .. " + SHIFT + l",
        hl.dsp.window.move({ direction = "r" }),
        { description = "Window: Move Right (VI)" })

      hl.bind(modifier .. " + SHIFT + k",
        hl.dsp.window.move({ direction = "u" }),
        { description = "Window: Move Up (VI)" })

      hl.bind(modifier .. " + SHIFT + j",
        hl.dsp.window.move({ direction = "d" }),
        { description = "Window: Move Down (VI)" })

      hl.bind(modifier .. " + ALT + left",
        hl.dsp.window.swap({ direction = "l" }),
        { description = "Window: Swap Left" })

      hl.bind(modifier .. " + ALT + right",
        hl.dsp.window.swap({ direction = "r" }),
        { description = "Window: Swap Right" })

      hl.bind(modifier .. " + ALT + up",
        hl.dsp.window.swap({ direction = "u" }),
        { description = "Window: Swap Up" })

      hl.bind(modifier .. " + ALT + down",
        hl.dsp.window.swap({ direction = "d" }),
        { description = "Window: Swap Down" })

      hl.bind(modifier .. " + ALT + code:43",
        hl.dsp.window.swap({ direction = "l" }),
        { description = "Window: Swap Left (VI)" })

      hl.bind(modifier .. " + ALT + code:46",
        hl.dsp.window.swap({ direction = "r" }),
        { description = "Window: Swap Right (VI)" })

      hl.bind(modifier .. " + ALT + code:45",
        hl.dsp.window.swap({ direction = "u" }),
        { description = "Window: Swap Up (VI)" })

      hl.bind(modifier .. " + ALT + code:44",
        hl.dsp.window.swap({ direction = "d" }),
        { description = "Window: Swap Down (VI)" })

      hl.bind(modifier .. " + left",
        hl.dsp.focus({ direction = "left" }),
        { description = "Window: Focus Left" })

      hl.bind(modifier .. " + right",
        hl.dsp.focus({ direction = "right" }),
        { description = "Window: Focus Right" })

      hl.bind(modifier .. " + up",
        hl.dsp.focus({ direction = "up" }),
        { description = "Window: Focus Up" })

      hl.bind(modifier .. " + down",
        hl.dsp.focus({ direction = "down" }),
        { description = "Window: Focus Down" })

      hl.bind(modifier .. " + h",
        hl.dsp.focus({ direction = "left" }),
        { description = "Window: Focus Left (VI)" })

      hl.bind(modifier .. " + l",
        hl.dsp.focus({ direction = "right" }),
        { description = "Window: Focus Right (VI)" })

      hl.bind(modifier .. " + k",
        hl.dsp.focus({ direction = "up" }),
        { description = "Window: Focus Up (VI)" })

      hl.bind(modifier .. " + j",
        hl.dsp.focus({ direction = "down" }),
        { description = "Window: Focus Down (VI)" })


      --##! Workspace

      hl.bind(modifier .. " + 1",
        hl.dsp.focus({ workspace = 1 }),
        { description = "Workspace: Focus 1" })

      hl.bind(modifier .. " + 2",
        hl.dsp.focus({ workspace = 2 }),
        { description = "Workspace: Focus 2" })

      hl.bind(modifier .. " + 3",
        hl.dsp.focus({ workspace = 3 }),
        { description = "Workspace: Focus 3" })

      hl.bind(modifier .. " + 4",
        hl.dsp.focus({ workspace = 4 }),
        { description = "Workspace: Focus 4" })

      hl.bind(modifier .. " + 5",
        hl.dsp.focus({ workspace = 5 }),
        { description = "Workspace: Focus 5" })

      hl.bind(modifier .. " + 6",
        hl.dsp.focus({ workspace = 6 }),
        { description = "Workspace: Focus 6" })

      hl.bind(modifier .. " + 7",
        hl.dsp.focus({ workspace = 7 }),
        { description = "Workspace: Focus 7" })

      hl.bind(modifier .. " + 8",
        hl.dsp.focus({ workspace = 8 }),
        { description = "Workspace: Focus 8" })

      hl.bind(modifier .. " + 9",
        hl.dsp.focus({ workspace = 9 }),
        { description = "Workspace: Focus 9" })

      hl.bind(modifier .. " + 0",
        hl.dsp.focus({ workspace = 10 }),
        { description = "Workspace: Focus 10" })

      hl.bind(modifier .. " + SHIFT + SPACE",
        hl.dsp.window.move({ workspace = "special" }),
        { description = "Workspace: Move to Special" })

      hl.bind(modifier .. " + SPACE",
        hl.dsp.workspace.toggle_special(""),
        { description = "Workspace: Toggle Special" })

      hl.bind(modifier .. " + SHIFT + 1",
        hl.dsp.window.move({ workspace = 1 }),
        { description = "Workspace: Move to Workspace 1" })

      hl.bind(modifier .. " + SHIFT + 2",
        hl.dsp.window.move({ workspace = 2 }),
        { description = "Workspace: Move to Workspace 2" })

      hl.bind(modifier .. " + SHIFT + 3",
        hl.dsp.window.move({ workspace = 3 }),
        { description = "Workspace: Move to Workspace 3" })

      hl.bind(modifier .. " + SHIFT + 4",
        hl.dsp.window.move({ workspace = 4 }),
        { description = "Workspace: Move to Workspace 4" })

      hl.bind(modifier .. " + SHIFT + 5",
        hl.dsp.window.move({ workspace = 5 }),
        { description = "Workspace: Move to Workspace 5" })

      hl.bind(modifier .. " + SHIFT + 6",
        hl.dsp.window.move({ workspace = 6 }),
        { description = "Workspace: Move to Workspace 6" })

      hl.bind(modifier .. " + SHIFT + 7",
        hl.dsp.window.move({ workspace = 7 }),
        { description = "Workspace: Move to Workspace 7" })

      hl.bind(modifier .. " + SHIFT + 8",
        hl.dsp.window.move({ workspace = 8 }),
        { description = "Workspace: Move to Workspace 8" })

      hl.bind(modifier .. " + SHIFT + 9",
        hl.dsp.window.move({ workspace = 9 }),
        { description = "Workspace: Move to Workspace 9" })

      hl.bind(modifier .. " + SHIFT + 0",
        hl.dsp.window.move({ workspace = 10 }),
        { description = "Workspace: Move to Workspace 10" })

      hl.bind(modifier .. " + CONTROL + right",
        hl.dsp.focus({ workspace = "e+1" }),
        { description = "Workspace: Next Workspace" })

      hl.bind(modifier .. " + CONTROL + left",
        hl.dsp.focus({ workspace = "e-1" }),
        { description = "Workspace: Previous Workspace" })

      hl.bind(modifier .. " + mouse_down",
        hl.dsp.focus({ workspace = "e+1" }),
        { description = "Workspace: Next Workspace Mouse" })

      hl.bind(modifier .. " + mouse_up",
        hl.dsp.focus({ workspace = "e-1" }),
        { description = "Workspace: Previous Workspace Mouse" })


      --##! Window Management

      hl.bind("ALT + Tab",
        hl.dsp.window.cycle_next({ next = true }),
        { description = "Window Management: Cycle Next Window" })

      --hl.bind("ALT + Tab",
      --  hl.dsp.window.bring_to_top(),
      --  { description = "Window Management: Bring Active To Top" })


      --##! Media

      hl.bind("XF86AudioRaiseVolume",
        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
        { description = "Media: Volume Up" })

      hl.bind("XF86AudioLowerVolume",
        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
        { description = "Media: Volume Down" })

      hl.bind("XF86AudioMute",
        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        { description = "Media: Mute Toggle" })

      hl.bind("XF86AudioPlay",
        hl.dsp.exec_cmd("playerctl play-pause"),
        { description = "Media: Play Pause" })

      hl.bind("XF86AudioPause",
        hl.dsp.exec_cmd("playerctl play-pause"),
        { description = "Media: Play Pause" })

      hl.bind("XF86AudioNext",
        hl.dsp.exec_cmd("playerctl next"),
        { description = "Media: Next Track" })

      hl.bind("XF86AudioPrev",
        hl.dsp.exec_cmd("playerctl previous"),
        { description = "Media: Previous Track" })


      --##! Brightness

      hl.bind("XF86MonBrightnessDown",
        hl.dsp.exec_cmd("brightnessctl set 5%-"),
        { description = "Brightness: Down" })

      hl.bind("XF86MonBrightnessUp",
        hl.dsp.exec_cmd("brightnessctl set +5%"),
        { description = "Brightness: Up" })


      --##! Session

      hl.bind(modifier .. " + SHIFT + C",
        hl.dsp.exit(),
        { description = "Session: Exit/Logout of Hyprland" })


      --##! Window Interaction

      hl.bind(modifier .. " + mouse:272",
        hl.dsp.window.drag(),
        { description = "Window Interaction: Move Window" })

      hl.bind(modifier .. " + mouse:273",
        hl.dsp.window.resize(),
        { description = "Window Interaction: Resize Window" })


    '';

  };

}
