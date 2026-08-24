{
  pkgs,
  lib,
  ...
}: {
  gtk = {
    gtk4.theme = lib.mkForce null;
    iconTheme = {
       name = "breeze-dark";
       package = pkgs.kdePackages.breeze-icons;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
