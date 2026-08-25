{pkgs, lib, ...}: {
  programs.quickshell = {
    enable = true;
    activeConfig = "ii";
    configs.ii = import ./ii {inherit pkgs lib;};
  };
}
