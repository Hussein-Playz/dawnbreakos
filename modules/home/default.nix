{host, ...}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit
    (vars)
    alacrittyEnable
    barChoice
    ghosttyEnable
    tmuxEnable
    waybarChoice
    weztermEnable
    vscodeEnable
    helixEnable
    doomEmacsEnable
    ;
in {
  imports =
    [
      ./amfora.nix
      ./bash.nix
      ./bashrc-personal.nix
      ./overview.nix
      ./python.nix
      ./cli/bat.nix
      ./cli/btop.nix
      ./cli/bottom.nix
      ./cli/cava.nix
      ./emoji.nix
      ./eza.nix
      ./fastfetch
      ./cli/fzf.nix
      ./cli/gh.nix
      ./cli/git.nix
      ./gtk.nix
      ./cli/htop.nix
      ./hyprland
      ./terminals/kitty.nix
      ./cli/lazygit.nix
      ./obs-studio.nix
      ./editors/nixvim.nix
      ./editors/nano.nix
      ./rofi
      ./qt.nix
      ./scripts
      ./scripts/gemini-cli.nix
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
      if alacrittyEnable
      then [./terminals/alacritty.nix]
      else []
    );
}
