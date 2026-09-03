{pkgs, ...}: {
  home.packages = with pkgs; [zsh];

  home.file.".zshrc-host".text = ''
    # Host-specific Zsh configuration.
    # Modifications here only affect this host.
  '';
}
