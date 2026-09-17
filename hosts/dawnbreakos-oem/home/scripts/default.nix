{pkgs, ...}: {
  home.packages = [
    (import ./dawnbreak-launcher.nix {inherit pkgs;})
  ];
}
