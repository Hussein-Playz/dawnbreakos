<div align="center">

## DawnbreakOS

DawnbreakOS is a simple way of reproducing my configuration on any NixOS system.
This includes the wallpaper, scripts, applications, config files, and more.

I originally installed [ZaneyOS](https://gitlab.com/Zaney/zaneyos) for my nix configurations then I spent some time modifying it and replacing alot of things (including the removal of Waybar and replacing it with Quickshell, who's configurations i obtained from [end-4's Quickshell Configurations](https://github.com/end-4/dots-hyprland))

And in the keybinds menu (`SUPER + /` in hyprland) you may see Dawnbreak Launcher, it's my private minecraft launcher so you may remove it (`./modules/home/hyprland/binds.nix` is where keybinds are located) or you can replace it with any launcher you want by modifying the line containing it in binds.nix

And some keybinds may not function due to me removing the original Quickshell, waybar, and noctalia configurations 

And to allow drivers to work (FOR HYBRID SUPPORT) you must go into `hosts/your-host/variables.nix` and modify the IDs correctly, to figure out how go to FAQ.md and ctrl + F and search for `In the ~/dawnbreakos/hosts/HYBRID-HOST/variables.nix file you will need to set` to find the steps

Lastly, I had AI assist me in some parts of this configuration though I lowkey forgot where, however I did read and test the parts I had written via AI

#### 🍖 Requirements

- You must be running on NixOS, version 24.05+.
- The `dawnbreakos` folder (this repo) is expected to be in your home directory.
- You must have installed NIXOS using **GPT** parition with booting with
  **UEFI**.
- ** 500MB minimum /boot partition required. **
- Systemd-boot is what is supported.
- For GRUB you will have to brave the internet for a how-to. ☺️
- Manually editing your host specific files.
- The host is the specific computer your installing on.

#### 🎹 Pipewire & Notification Menu Controls

- We are using the latest and greatest audio solution for Linux. Not to mention
  you will have media and volume controls in the notification center available
  in the top bar.

#### 🏇 Optimized Workflow & Simple Yet Elegant Neovim

- Using Hyprland for increased elegance, functionality, and efficiency.
- No massive NeoVIM project here, using `nixvim` for an
  incredible NeoVIM setup. With language support already added in.

#### 🖥️ Multi Host & User Configuration

- You can define separate settings for different host machines and users.
- Easily specify extra packages for your users in the `modules/core/user.nix`
  file.
- Easy to understand file structure and simple, but encompassing, configuration.

#### 📦 How To Install Packages?

- You can search the [Nix Packages](https://search.nixos.org/packages?) &
  [Options](https://search.nixos.org/options?) pages for what a package may be
  named or if it has options available that take care of configuration hurdles
  you may face.
- To add a package there are the sections for it in `modules/core/packages.nix`
  and `modules/core/user.nix`. One is for programs available system wide and the
  other for your users environment only.
  
# Hyprland Keybindings

Below are the keybindings for Hyprland, formatted for easy reference.

<table>
<tr>
<td width="50%">

### Application Launching

* `SUPER + Return` → Launch `kitty` terminal
* `SUPER + W` → Launch Zen Browser
* `SUPER + E` → Open Nemo file manager
* `SUPER + Shift + D` → Open Discord
* `SUPER + Alt + M` → Open audio control (`pavucontrol`)
* `SUPER + Alt + W` → Open web search

### Quickshell

* `SUPER + /` → Keybinds Menu
* `SUPER + D` → Toggle Quickshell Search
* `SUPER + Ctrl + D` → Toggle Dock
* `SUPER + Tab` → Toggle Quickshell Overview
* `SUPER + Shift + K` → Open Keybinds Search Tool
* `SUPER + Shift + W` → Open Wallpaper Setter
* `SUPER + Shift + N` → Reset Notifications
* `SUPER + V` → Toggle Clipboard
* `SUPER + .` → Toggle Emoji Picker
* `SUPER + A` → Toggle Left Sidebar
* `SUPER + Alt + A` → Toggle Detached Left Sidebar
* `SUPER + B` → Toggle Left Sidebar
* `SUPER + O` → Toggle Left Sidebar
* `SUPER + N` → Toggle Right Sidebar
* `SUPER + M` → Toggle Media Controls
* `SUPER + G` → Toggle Quickshell Overlay
* `Ctrl + Alt + Delete` → Open Session Menu
* `SUPER + J` → Toggle Bar
* `SUPER + Ctrl + T` → Toggle Wallpaper Selector
* `SUPER + Shift + Alt + /` → Open End-4 Welcome
* `SUPER + Ctrl + Alt + T` → Random Wallpaper
* `SUPER + Ctrl + R` → Restart Quickshell Widgets

### Utilities

* `SUPER + S` → Screenshot
* `SUPER + Ctrl + S` → Screenshot current output
* `SUPER + Alt + S` → Screenshot active window
* `SUPER + Shift + S` → Region screenshot
* `SUPER + Alt + C` → Color Picker
* `SUPER + Shift + T` → Toggle Dropdown Terminal

</td>
<td width="50%">

### Window Management

* `SUPER + Q` → Kill active window
* `SUPER + P` → Toggle pseudo tiling
* `SUPER + Shift + I` → Toggle split mode
* `SUPER + F` → Toggle fullscreen
* `SUPER + Alt + Space` → Toggle floating/tiling
* `SUPER + Alt + F` → Float all windows
* `SUPER + Alt + L` → Toggle window layouts
* `SUPER + Alt + 1` → Dwindle layout
* `SUPER + Alt + 2` → Master layout
* `SUPER + Alt + 3` → Scrolling layout
* `SUPER + Alt + 4` → Monocle layout

### Window Movement

* `SUPER + Shift + ← / → / ↑ / ↓` → Move window left/right/up/down
* `SUPER + Shift + H / L / K / J` → Move window left/right/up/down
* `SUPER + Alt + ← / → / ↑ / ↓` → Swap window left/right/up/down
* `SUPER + Alt + +` → Swap window left
* `SUPER + Alt + .` → Swap window right
* `SUPER + Alt + -` → Swap window up
* `SUPER + Alt + ,` → Swap window down

### Focus Movement

* `SUPER + ← / → / ↑ / ↓` → Move focus left/right/up/down
* `SUPER + H / L / K / J` → Move focus left/right/up/down

### Workspaces

* `SUPER + 1-9` → Switch to workspace 1-9
* `SUPER + 0` → Switch to workspace 10
* `SUPER + Shift + 1-9` → Move window to workspace 1-9
* `SUPER + Shift + 0` → Move window to workspace 10
* `SUPER + Shift + Space` → Move window to special workspace
* `SUPER + Space` → Toggle special workspace
* `SUPER + Ctrl + →` → Switch to next workspace
* `SUPER + Ctrl + ←` → Switch to previous workspace
* `SUPER + Mouse Wheel Down` → Next workspace
* `SUPER + Mouse Wheel Up` → Previous workspace

### Window Cycling

* `Alt + Tab` → Cycle to next window

### Media

* `Volume Up` → Increase volume by 5%
* `Volume Down` → Decrease volume by 5%
* `Mute` → Toggle audio mute
* `Play/Pause` → Play/pause media
* `Next Track` → Next track
* `Previous Track` → Previous track

### Brightness

* `Brightness Down` → Decrease brightness by 5%
* `Brightness Up` → Increase brightness by 5%

### Session

* `SUPER + Shift + C` → Exit/Logout of Hyprland

### Window Interaction

* `SUPER + Left Mouse Button` → Move window
* `SUPER + Right Mouse Button` → Resize window

</td>
</tr>
</table>


## Installation:

> **⚠️ WARNING:** This script will completely replace any existing ~/dawnbreakos
> directory. Do NOT use this if you already have DawnbreakOS installed and
> configured.

Simply copy this and run it:

```
nix-shell -p git curl pciutils
```

Then:

```
sh <(curl -L https://raw.githubusercontent.com/Hussein-Playz/dawnbreakos/main/install-dawnbreakos.sh)
```

</details>
