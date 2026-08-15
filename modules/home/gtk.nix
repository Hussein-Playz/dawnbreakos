{
  pkgs,
  lib,
  ...
}: {
  gtk = {
    gtk4.theme = lib.mkForce null;
#     theme = {
#       name = "Breeze";
#       package = pkgs.kdePackages.breeze-gtk;
#     };
    iconTheme = {
       name = "breeze-dark";
       package = pkgs.kdePackages.breeze-icons;
#      package = pkgs.kdePackages.breeze-gtk;
#      name = "Papirus-Dark";
#      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
