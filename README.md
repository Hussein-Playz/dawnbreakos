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

Inside hyprland you can click SUPER + / (Super is the windows key) to display a list of ALL keybinds

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

# If you already have your own host but different device
then **BEFORE REBUILDING** you can manually change the flake.nix's `profile = "nvidia-laptop";` to whatever GPU the new pc has (You can check their names under ./profiles) and then do `sudo nixos-generate-config --show-hardware-config > ~/dawnbreakos/hosts/your_host/hardware.nix` where your_host is your hostname then lastly rebuild using the correct profile so say you chose amd profile then u do `sudo nixos-rebuild switch --flake ~/dawnbreakos#amd`

</details>
