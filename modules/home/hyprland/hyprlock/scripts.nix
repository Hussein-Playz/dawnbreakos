{...}: {
    home.file = {
    ".config/hypr/hyprlock/check-capslock.sh" = {
        source = ./check-capslock.sh;
        executable = true;
    };

    ".config/hypr/hyprlock/status.sh" = {
        source = ./status.sh;
        executable = true;
    };
    };
}
