{
  pkgs,
  profile,
  ...
}:

  pkgs.writeShellScriptBin "db-battery" ''
    #!${pkgs.bash}/bin/bash

    set -euo pipefail

    HYPR_DIR="$HOME/.config/hypr"
    MONITORS_LUA="$HYPR_DIR/monitors.lua"
    MONITORS_BACKUP="$HYPR_DIR/monitors.lua.dbb"

    print_help() {
      echo "DawnbreakOS Battery Utility"
      echo ""
      echo "Usage: db-battery on/off"
      echo ""
      echo "Commands:"
      echo "  on              Enable Battery-Saving mode"
      echo "  off             Disable Battery-Saving mode"
      echo "  help            Show this help message."
    }

    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }

    #
    # --------------------------------------------------------------------------
    # Brightness
    # --------------------------------------------------------------------------
    #

    set_brightness() {
      local value="$1"

      if command_exists brightnessctl; then
        brightnessctl set "$value" >/dev/null 2>&1 || true
      fi
    }

    #
    # --------------------------------------------------------------------------
    # CPU energy/performance preference
    # --------------------------------------------------------------------------
    #

    set_cpu_epp() {
      local value="$1"

      for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        [[ -d "$policy" ]] || continue

        local epp="$policy/energy_performance_preference"

        if [[ -w "$epp" ]]; then
          echo "$value" > "$epp" 2>/dev/null || true
        fi
      done
    }

    #
    # --------------------------------------------------------------------------
    # CPU boost
    # --------------------------------------------------------------------------
    #

    set_cpu_boost() {
      local enabled="$1"

      #
      # Generic cpufreq boost interface
      #
      if [[ -w /sys/devices/system/cpu/cpufreq/boost ]]; then
        echo "$enabled" \
          > /sys/devices/system/cpu/cpufreq/boost \
          2>/dev/null || true
      fi

      #
      # Intel pstate no_turbo interface
      #
      if [[ -w /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
        if [[ "$enabled" == "1" ]]; then
          echo 0 \
            > /sys/devices/system/cpu/intel_pstate/no_turbo \
            2>/dev/null || true
        else
          echo 1 \
            > /sys/devices/system/cpu/intel_pstate/no_turbo \
            2>/dev/null || true
        fi
      fi

      #
      # AMD pstate boost interface
      #
      if [[ -w /sys/devices/system/cpu/cpufreq/boost ]]; then
        echo "$enabled" \
          > /sys/devices/system/cpu/cpufreq/boost \
          2>/dev/null || true
      fi
    }

    #
    # --------------------------------------------------------------------------
    # Wi-Fi power saving
    # --------------------------------------------------------------------------
    #

    set_wifi_power_save() {
      local enabled="$1"

      if ! command_exists iw; then
        return
      fi

      while read -r interface; do
        [[ -n "$interface" ]] || continue

        if [[ "$enabled" == "1" ]]; then
          iw dev "$interface" set power_save on \
            >/dev/null 2>&1 || true
        else
          iw dev "$interface" set power_save off \
            >/dev/null 2>&1 || true
        fi
      done < <(
        iw dev 2>/dev/null |
          awk '$1 == "Interface" {print $2}'
      )
    }

    #
    # --------------------------------------------------------------------------
    # Hyprland monitor detection
    # --------------------------------------------------------------------------
    #

    detect_internal_monitor() {
      if ! command_exists hyprctl; then
        return 1
      fi

      if ! command_exists jq; then
        return 1
      fi

      #
      # Prefer conventional laptop connector names.
      #
      local monitor

      monitor="$(
        hyprctl monitors -j 2>/dev/null |
          jq -r '
            .[]
            | select(
                (.name | startswith("eDP-"))
                or
                (.name | startswith("LVDS-"))
            )
            | .name
          ' |
          head -n 1
      )"

      if [[ -n "$monitor" ]]; then
        printf '%s\n' "$monitor"
        return 0
      fi

      #
      # If the connector has a weird name, identify the monitor using
      # the fact that Hyprland reports the physical monitor description.
      #
      monitor="$(
        hyprctl monitors -j 2>/dev/null |
          jq -r '
            .[]
            | select(
                (.description // "" | test(
                  "Laptop|Built-in|Internal|eDP|LVDS";
                  "i"
                ))
            )
            | .name
          ' |
          head -n 1
      )"

      if [[ -n "$monitor" ]]; then
        printf '%s\n' "$monitor"
        return 0
      fi

      #
      # Last resort:
      # if there is only one monitor, it must be the laptop display.
      #
      local count
      count="$(
        hyprctl monitors -j 2>/dev/null |
          jq 'length'
      )"

      if [[ "$count" == "1" ]]; then
        hyprctl monitors -j 2>/dev/null |
          jq -r '.[0].name'
        return 0
      fi

      return 1
    }

    #
    # --------------------------------------------------------------------------
    # Generate battery monitors.lua
    # --------------------------------------------------------------------------
    #

    generate_battery_monitors() {
      local monitor="$1"

      #
      # nwg-displays uses Hyprland's Lua API for Hyprland >= 0.55.
      #
      cat > "$MONITORS_LUA" <<EOF
    -- Generated by db-battery.
    -- Original configuration is stored in monitors.lua.dbb.
    --
    -- Battery mode:
    --   Resolution: 1920x1080
    --   Refresh:    60 Hz
    --
    -- Monitor detected automatically:
    --   $monitor

    hl.monitor({
      output = "$monitor",
      mode = "1920x1080@60",
      position = "0x0",
      scale = 1,
    })
    EOF
    }

    #
    # --------------------------------------------------------------------------
    # Enable battery mode
    # --------------------------------------------------------------------------
    #

    battery_on() {
      echo "Enabling Battery-Saving Mode"

      #
      # --------------------------------------------------------------
      # Monitor configuration
      # --------------------------------------------------------------
      #

      if [[ -f "$MONITORS_LUA" ]]; then

        if [[ ! -f "$MONITORS_BACKUP" ]]; then
          echo "Backing up monitors.lua"
          cp "$MONITORS_LUA" "$MONITORS_BACKUP"
        else
          echo "Monitor backup already exists; leaving it untouched."
        fi

        if command_exists hyprctl && command_exists jq; then
          monitor="$(detect_internal_monitor || true)"

          if [[ -n "$monitor" ]]; then
            echo "Detected internal monitor: $monitor"

            generate_battery_monitors "$monitor"

            echo "Reloading Hyprland..."
            hyprctl reload >/dev/null 2>&1 || true
          else
            echo "WARNING: Could not identify internal monitor."
            echo "Leaving monitor configuration unchanged."
          fi
        else
          echo "WARNING: hyprctl/jq unavailable."
          echo "Skipping monitor power optimization."
        fi

      else
        echo "No monitors.lua found; skipping monitor optimization."
      fi

      #
      # --------------------------------------------------------------
      # Display brightness
      # --------------------------------------------------------------
      #

      echo "Reducing display brightness..."
      set_brightness "40%"

      #
      # --------------------------------------------------------------
      # CPU
      # --------------------------------------------------------------
      #

      echo "Setting CPU energy preference to power..."

      set_cpu_epp "power"

      echo "Disabling CPU boost where supported..."
      set_cpu_boost 0

      #
      # --------------------------------------------------------------
      # Wi-Fi
      # --------------------------------------------------------------
      #

      echo "Enabling Wi-Fi power saving..."

      set_wifi_power_save 1

      echo ""
      echo "Battery-Saving Mode enabled."
    }

    #
    # --------------------------------------------------------------------------
    # Disable battery mode
    # --------------------------------------------------------------------------
    #

    battery_off() {
      echo "Disabling Battery-Saving Mode"

      #
      # --------------------------------------------------------------
      # Restore monitor configuration
      # --------------------------------------------------------------
      #

      if [[ -f "$MONITORS_BACKUP" ]]; then
        echo "Restoring original monitors.lua"

        rm -f "$MONITORS_LUA"
        mv "$MONITORS_BACKUP" "$MONITORS_LUA"

        if command_exists hyprctl; then
          echo "Reloading Hyprland..."
          hyprctl reload >/dev/null 2>&1 || true
        fi
      else
        echo "No monitors.lua.dbb backup found."
      fi

      #
      # --------------------------------------------------------------
      # Display brightness
      # --------------------------------------------------------------
      #

      echo "Restoring display brightness..."
      set_brightness "80%"

      #
      # --------------------------------------------------------------
      # CPU
      # --------------------------------------------------------------
      #

      echo "Restoring CPU energy preference..."

      set_cpu_epp "balance_performance"

      echo "Re-enabling CPU boost where supported..."
      set_cpu_boost 1

      #
      # --------------------------------------------------------------
      # Wi-Fi
      # --------------------------------------------------------------
      #

      echo "Disabling Wi-Fi power saving..."

      set_wifi_power_save 0

      echo ""
      echo "Battery-Saving Mode disabled."
    }

    #
    # --------------------------------------------------------------------------
    # Main
    # --------------------------------------------------------------------------
    #

    if [[ $# -lt 1 ]]; then
      print_help
      exit 1
    fi

    case "$1" in
      on)
        battery_on
        ;;

      off)
        battery_off
        ;;

      help|-h|--help)
        print_help
        ;;

      *)
        echo "Error: Invalid command '$1'" >&2
        echo ""
        print_help
        exit 1
        ;;
    esac
  ''
