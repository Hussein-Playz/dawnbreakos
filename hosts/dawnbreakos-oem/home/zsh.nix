{pkgs, ...}: {
  home.packages = with pkgs; [zsh];

  home.file.".zshrc-host".text = ''
    # Host-specific Zsh configuration.
    # Modifications here only affect this host.

    alias ndev="nix develop"
    alias dbf='OLD_DIR="$PWD"; cd ~/dawnbreakos && onefetch --nerd-fonts --true-color auto -a nix; cd "$OLD_DIR"'
  '';
}
