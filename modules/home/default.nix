{host, ...}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit
    (vars)
    alacrittyEnable
    ghosttyEnable
    tmuxEnable
    weztermEnable
    vscodeEnable
    helixEnable
    doomEmacsEnable
    obsEnable
    ;
in {
  imports =
    [
      ./amfora.nix
      ./bash.nix
      ./bashrc-personal.nix
      ./ii.nix
      ./python.nix
      ./cli/bat.nix
      ./cli/btop.nix
      ./cli/bottom.nix
      ./cli/cava.nix
      ./cli/fzf.nix
      ./cli/gh.nix
      ./cli/git.nix
      ./cli/htop.nix
      ./cli/lazygit.nix
      ./emoji.nix
      ./eza.nix
      ./gtk.nix
      ./hyprland
      ./terminals/kitty.nix
      ./editors/nixvim.nix
      ./editors/nano.nix
      ./rofi
      ./qt.nix
      ./scripts
      ./stylix.nix
      ./swappy.nix
      ./swaync.nix
      ./tealdeer.nix
      ./virtmanager.nix
      ./wlogout
      ./xdg.nix
      ./yazi
      ./zoxide.nix
      ./zsh
      ./vencord.nix
      ./DawnbreakLauncher.nix
      ./fuzzel.nix
    ]
    ++ (
      if helixEnable
      then [./editors/evil-helix.nix]
      else []
    )
    ++ (
      if vscodeEnable
      then [./editors/vscode.nix]
      else []
    )
    ++ (
      if doomEmacsEnable
      then [
        ./editors/doom-emacs-install.nix
        ./editors/doom-emacs.nix
      ]
      else []
    )
    ++ (
      if weztermEnable
      then [./terminals/wezterm.nix]
      else []
    )
    ++ (
      if ghosttyEnable
      then [./terminals/ghostty.nix]
      else []
    )
    ++ (
      if tmuxEnable
      then [./terminals/tmux.nix]
      else []
    )
    ++ (
      if obsEnable
      then [./obs-studio.nix]
      else []
    )
    ++ (
      if alacrittyEnable
      then [./terminals/alacritty.nix]
      else []
    );
}
