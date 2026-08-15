# SDDM is a display manager for X11 and Wayland
{
  pkgs,
  config,
  lib,
  host,
  ...
}: let
  foreground = config.stylix.base16Scheme.base00;
  textColor = config.stylix.base16Scheme.base05;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig =
      if lib.hasSuffix "sakura_static.png" config.stylix.image
      then {
        FormPosition = "left";
        Blur = "2.0";
        HourFormat = "h:mm AP";
      }
      else if lib.hasSuffix "studio.png" config.stylix.image
      then {
        Background = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/anotherhadi/nixy-wallpapers/refs/heads/main/wallpapers/studio.gif";
          sha256 = "sha256-qySDskjmFYt+ncslpbz0BfXiWm4hmFf5GPWF2NlTVB8=";
        };
        HourFormat = "h:mm AP";
        HeaderTextColor = "#${textColor}";
        DateTextColor = "#${textColor}";
        TimeTextColor = "#${textColor}";
        LoginFieldTextColor = "#${textColor}";
        PasswordFieldTextColor = "#${textColor}";
        UserIconColor = "#${textColor}";
        PasswordIconColor = "#${textColor}";
        WarningColor = "#${textColor}";
        LoginButtonBackgroundColor = "#${foreground}";
        SystemButtonsIconsColor = "#${foreground}";
        SessionButtonTextColor = "#${textColor}";
        VirtualKeyboardButtonTextColor = "#${textColor}";
        DropdownBackgroundColor = "#${foreground}";
        HighlightBackgroundColor = "#${textColor}";
      }
      else {
        FormPosition = "center";
        Blur = "4.0";
        Background = "${toString config.stylix.image}";
        HourFormat = "h:mm AP";
        HeaderTextColor = "#${textColor}";
        DateTextColor = "#${textColor}";
        TimeTextColor = "#${textColor}";
        LoginFieldTextColor = "#${textColor}";
        PasswordFieldTextColor = "#${textColor}";
        UserIconColor = "#${textColor}";
        PasswordIconColor = "#${textColor}";
        WarningColor = "#${textColor}";
        LoginButtonBackgroundColor = "#7C3AED";
        SystemButtonsIconsColor = "#${textColor}";
        SessionButtonTextColor = "#${textColor}";
        VirtualKeyboardButtonTextColor = "#${textColor}";
        DropdownBackgroundColor = "#202020";
        HighlightBackgroundColor = "#${textColor}";
        FormBackgroundColor = "#202020";
        LoginFieldBackgroundColor = "#202020";
        PasswordFieldBackgroundColor = "#202020";
        HighlightBorderColor = "#7C3AED";
        DateFormat = "dddd, MMMM d";
      };
  };
in {
  services.displayManager = {
    sddm = {
      package = pkgs.kdePackages.sddm;
      extraPackages = [sddm-astronaut];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      settings = let
        vars = import ../../hosts/${host}/variables.nix;
        keyboardLayout = vars.keyboardLayout or "us";
        keyboardVariant = vars.keyboardVariant or "";
        CursorTheme = "Bibata-Modern-Ice";
        CursorSize = 24;
      in {
        X11 = {
          XkbLayout = keyboardLayout;
          XkbVariant = keyboardVariant;
        };
      };
    };
  };

  # Ensure Wayland SDDM also sees XKB defaults
  systemd.services.display-manager.environment = let
    vars = import ../../hosts/${host}/variables.nix;
    keyboardLayout = vars.keyboardLayout or "us";
    keyboardVariant = vars.keyboardVariant or "";
  in ({XKB_DEFAULT_LAYOUT = keyboardLayout;}
    // lib.optionalAttrs (keyboardVariant != "") {XKB_DEFAULT_VARIANT = keyboardVariant;});

  environment.systemPackages = [sddm-astronaut];
}
