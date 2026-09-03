{pkgs, ...}: {
  home.packages = with pkgs; [zsh];

  home.file.".zshrc-host".text = ''
    # Host-specific Zsh configuration.
    # Modifications here only affect this host.

    mkrust() {
    nix flake new "$1" -t templates#rust
    cd "$1"
    nix develop -c zsh -c "cargo init"
    git add .
    }

    alias ndev="nix develop"
  '';
}
