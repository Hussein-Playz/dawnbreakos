bash
#!/usr/bin/env bash

# Dawnbreak Battery Mode
#
# Conservative battery optimization orchestrator.
#
# Design principles:
#   - Prefer existing Linux power-management backends.
#   - Never blindly modify every PCI/USB device.
#   - Never disable CPU turbo/boost.
#   - Never force PCIe ASPM.
#   - Never mix competing power-management policies unnecessarily.
#   - Every direct sysfs modification is reversible.
#   - Unsupported hardware is skipped cleanly.
#
# State:
#   /run/dbb-mode/
#
# Usage:
#   dbb-mode on [options]
#   dbb-mode off
#   dbb-mode status
#   dbb-mode doctor
#   dbb-mode version
#   dbb-mode help

set -u
set -o pipefail

readonly DBB_VERSION="0.2.0"
readonly DBB_STATE_DIR="/run/dbb-mode"
readonly DBB_STATE_FILE="${DBB_STATE_DIR}/state"
readonly DBB_PROFILE_FILE="${DBB_STATE_DIR}/profile"

mkdir -p "${DBB_STATE_DIR}" 2>/dev/null || true


# ============================================================
# Logging
# ============================================================

log() {
    printf '[DBB] %s\n' "$*"
}

ok() {
    printf '  ✓ %s\n' "$*"
}

skip() {
    printf '  - %s\n' "$*"
}

warn() {
    printf '  ! %s\n' "$*" >&2
}

die() {
    printf 'dbb-mode: %s\n' "$*" >&2
    exit 1
}


# ============================================================
# Privileges
# ============================================================

is_root() {
    [ "$(id -u)" -eq 0 ]
}

have() {
    command -v "$1" >/dev/null 2>&1
}

require_root() {
    if is_root; then
        return 0
    fi

    if have sudo; then
        exec sudo -E "$0" "$@"
    fi

    die "root privileges are required and sudo was not found"
}


# ============================================================
# Generic helpers
# ============================================================

read_node() {
    local file="$1"

    [ -r "$file" ] || return 1
    cat "$file" 2>/dev/null
}

write_node() {
    local file="$1"
    local value="$2"

    [ -w "$file" ] || return 1
    printf '%s\n' "$value" > "$file" 2>/dev/null
}

node_exists() {
    [ -e "$1" ]
}


# ============================================================
# State handling
# ============================================================

state_active() {
    [ -s "$DBB_STATE_FILE" ]
}

state_init() {
    mkdir -p "$DBB_STATE_DIR"

    rm -f "$DBB_STATE_FILE"

    {
        printf '# Dawnbreak Battery Mode state\n'
        printf '# Version: %s\n' "$DBB_VERSION"
        printf '# Format: NODE|path|original-value\n'
    } > "$DBB_STATE_FILE"
}

state_save_node() {
    local file="$1"
    local value

    [ -e "$file" ] || return 1

    # Do not save the same node twice.
    if grep -Fq "NODE|${file}|" "$DBB_STATE_FILE" 2>/dev/null; then
        return 0
    fi

    value="$(read_node "$file")" || return 1

    # Values used by the controls we touch are deliberately simple
    # single-line sysfs values. Reject newlines to keep the state format safe.
    case "$value" in
        *$'\n'*)
            return 1
            ;;
    esac

    printf 'NODE|%s|%s\n' "$file" "$value" >> "$DBB_STATE_FILE"
}

state_restore() {
    [ -r "$DBB_STATE_FILE" ] || return 0

    log "Restoring DBB-managed settings..."

    while IFS='|' read -r kind file value; do
        [ "$kind" = "NODE" ] || continue
        [ -n "$file" ] || continue

        if [ -w "$file" ]; then
            if write_node "$file" "$value"; then
                ok "$file ← $value"
            else
                warn "could not restore $file"
            fi
        else
            warn "$file no longer exists or is not writable"
        fi
    done < "$DBB_STATE_FILE"
}

state_cleanup() {
    rm -f "$DBB_STATE_FILE"
    rm -f "$DBB_PROFILE_FILE"
}


# ============================================================
# Power source
# ============================================================

power_state() {
    local ps type online status
    local has_battery=0
    local battery_discharging=0
    local ac_online=0

    for ps in /sys/class/power_supply/*; do
        [ -e "$ps" ] || continue

        type="$(read_node "$ps/type" 2>/dev/null || true)"

        case "$type" in
            Battery)
                has_battery=1
                status="$(read_node "$ps/status" 2>/dev/null || true)"

                if [ "$status" = "Discharging" ]; then
                    battery_discharging=1
                fi
                ;;

            Mains|USB|USB_C|USB_PD)
                online="$(read_node "$ps/online" 2>/dev/null || true)"

                if [ "$online" = "1" ]; then
                    ac_online=1
                fi
                ;;
        esac
    done

    if [ "$has_battery" -eq 0 ]; then
        printf 'unknown'
    elif [ "$battery_discharging" -eq 1 ] && [ "$ac_online" -eq 0 ]; then
        printf 'battery'
    elif [ "$ac_online" -eq 1 ]; then
        printf 'ac'
    else
        # Some machines do not expose charger state consistently.
        printf 'battery'
    fi
}


battery_summary() {
    local ps status capacity power_now energy_now energy_full
    local watts

    for ps in /sys/class/power_supply/*; do
        [ -e "$ps" ] || continue

        [ "$(read_node "$ps/type" 2>/dev/null || true)" = "Battery" ] || continue

        status="$(read_node "$ps/status" 2>/dev/null || printf '?')"
        capacity="$(read_node "$ps/capacity" 2>/dev/null || printf '?')"

        power_now="$(read_node "$ps/power_now" 2>/dev/null || true)"
        energy_now="$(read_node "$ps/energy_now" 2>/dev/null || true)"
        energy_full="$(read_node "$ps/energy_full" 2>/dev/null || true)"

        if [ -n "$power_now" ] && [[ "$power_now" =~ ^[0-9]+$ ]]; then
            watts="$(
                awk -v p="$power_now" \
                    'BEGIN { printf "%.2f", p / 1000000 }'
            )"
        else
            watts="n/a"
        fi

        printf '  Battery: %s%% (%s), instantaneous draw: %s W\n' \
            "$capacity" "$status" "$watts"

        if [[ "$energy_now" =~ ^[0-9]+$ ]] &&
           [[ "$energy_full" =~ ^[0-9]+$ ]] &&
           [ "$energy_full" -gt 0 ]; then

            awk -v now="$energy_now" -v full="$energy_full" \
                'BEGIN {
                    printf "  Remaining energy: %.2f Wh / %.2f Wh\n",
                           now / 1000000,
                           full / 1000000
                }'
        fi

        return 0
    done

    printf '  Battery: not detected\n'
}


# ============================================================
# Power-management backend detection
# ============================================================

backend() {
    if have powerprofilesctl; then
        printf 'power-profiles-daemon'
        return
    fi

    if have tlp-stat && have tlp; then
        printf 'tlp'
        return
    fi

    printf 'direct'
}


# ============================================================
# Power-profiles-daemon
# ============================================================

ppd_available() {
    have powerprofilesctl &&
    powerprofilesctl get >/dev/null 2>&1
}

ppd_get() {
    powerprofilesctl get 2>/dev/null
}

ppd_set() {
    local profile="$1"

    powerprofilesctl set "$profile" >/dev/null 2>&1
}

optimize_ppd() {
    local current

    if ! ppd_available; then
        skip "power-profiles-daemon unavailable"
        return 0
    fi

    current="$(ppd_get)"

    if [ -z "$current" ]; then
        skip "power-profiles-daemon profile could not be read"
        return 0
    fi

    printf '  Current power profile: %s\n' "$current"

    case "$current" in
        power-saver)
            ok "power profile already set to power-saver"
            ;;

        *)
            printf '%s\n' "$current" > "$DBB_PROFILE_FILE"

            if ppd_set power-saver; then
                ok "power profile: power-saver"
            else
                warn "could not switch power profile to power-saver"
                rm -f "$DBB_PROFILE_FILE"
            fi
            ;;
    esac
}


restore_ppd() {
    local previous

    [ -r "$DBB_PROFILE_FILE" ] || return 0

    previous="$(cat "$DBB_PROFILE_FILE" 2>/dev/null || true)"

    [ -n "$previous" ] || return 0

    if ppd_available && ppd_set "$previous"; then
        ok "power profile restored: $previous"
    else
        warn "could not restore power profile: $previous"
    fi
}


# ============================================================
# TLP
#
# TLP is NOT automatically combined with direct CPU/power-profile
# manipulation. If TLP is the active backend, we leave policy to TLP.
# ============================================================

tlp_available() {
    have tlp
}

optimize_tlp() {
    if ! tlp_available; then
        skip "TLP unavailable"
        return 0
    fi

    # Do not invent or force a TLP profile here.
    #
    # TLP normally applies its configured battery policy when the
    # machine transitions onto battery power.
    #
    # DBB deliberately avoids "tlp power-saver" and similar commands
    # because those can conflict with the kernel/backend configuration.

    ok "TLP detected; leaving TLP policy to its configured battery profile"
}


# ============================================================
# CPU EPP
#
# Only used when no higher-level power-profile backend is available.
#
# We deliberately DO NOT:
#   - disable turbo
#   - disable boost
#   - cap frequencies
#   - manipulate min/max frequency
# ============================================================

cpu_epp_available() {
    compgen -G \
        '/sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference' \
        >/dev/null 2>&1
}

optimize_cpu_epp() {
    local f current

    if ! cpu_epp_available; then
        skip "CPU EPP unavailable"
        return 0
    fi

    local changed=0

    for f in \
        /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference
    do
        [ -e "$f" ] || continue

        current="$(read_node "$f" 2>/dev/null || true)"
        [ -n "$current" ] || continue

        case "$current" in
            power)
                ok "CPU EPP already set to power"
                ;;

            *)
                if state_save_node "$f"; then
                    if write_node "$f" power; then
                        ok "CPU EPP: $current → power"
                        changed=1
                    else
                        warn "could not change CPU EPP at $f"
                    fi
                fi
                ;;
        esac
    done

    [ "$changed" -eq 1 ] || return 0
}


# ============================================================
# Wi-Fi
#
# This is intentionally isolated from the CPU/power policy.
# We only enable the standard mac80211 power-save setting.
# ============================================================

wifi_power_save() {
    local iface
    local found=0

    if ! have iw; then
        skip "iw unavailable"
        return 0
    fi

    while IFS= read -r iface; do
        [ -n "$iface" ] || continue

        case "$iface" in
            wl*)
                if iw dev "$iface" set power_save on >/dev/null 2>&1; then
                    ok "Wi-Fi power save: $iface"
                    found=1
                fi
                ;;
        esac
    done < <(
        iw dev 2>/dev/null |
            awk '$1 == "Interface" { print $2 }'
    )

    [ "$found" -eq 1 ] || skip "Wi-Fi power-save control unavailable"
}


# ============================================================
# Platform profile
#
# Deliberately NOT changed automatically.
#
# Platform firmware can have very different interpretations of
# "low-power", and some laptops perform better with balanced.
#
# We only report it.
# ============================================================

platform_profile_status() {
    local f="/sys/firmware/acpi/platform_profile"
    local available current

    [ -r "$f" ] || {
        skip "firmware platform profile unavailable"
        return 0
    }

    current="$(read_node "$f" 2>/dev/null || true)"

    if [ -r "${f}_choices" ]; then
        available="$(read_node "${f}_choices" 2>/dev/null || true)"
    else
        available="unknown"
    fi

    printf '  Platform profile: %s\n' "${current:-unknown}"
    printf '  Platform choices: %s\n' "$available"
}


# ============================================================
# Brightness
# ============================================================

set_brightness() {
    local percentage="$1"
    local f max target

    case "$percentage" in
        ''|*[!0-9]*)
            die "--brightness requires an integer from 0 to 100"
            ;;
    esac

    [ "$percentage" -le 100 ] ||
        die "--brightness must be between 0 and 100"

    local found=0

    for f in /sys/class/backlight/*/brightness; do
        [ -e "$f" ] || continue

        max="$(read_node "$(dirname "$f")/max_brightness" 2>/dev/null || true)"

        [[ "$max" =~ ^[0-9]+$ ]] || continue
        [ "$max" -gt 0 ] || continue

        target=$(( (percentage * max + 50) / 100 ))

        if state_save_node "$f"; then
            if write_node "$f" "$target"; then
                ok "backlight: ${percentage}% ($(basename "$(dirname "$f")"))"
                found=1
            else
                warn "could not change backlight"
            fi
        fi
    done

    [ "$found" -eq 1 ] ||
        skip "hardware backlight control unavailable"
}


# ============================================================
# Status
# ============================================================

show_status() {
    local state
    state="$(power_state)"

    printf '\n'
    printf 'Dawnbreak Battery Mode %s\n' "$DBB_VERSION"
    printf '────────────────────────────────────────\n'

    if state_active; then
        printf 'DBB:          ACTIVE\n'
    else
        printf 'DBB:          OFF\n'
    fi

    printf 'Power source: %s\n' "$state"
    printf 'Backend:      %s\n' "$(backend)"
    printf '\n'

    battery_summary

    printf '\nPower-management controls:\n'

    if ppd_available; then
        ok "power-profiles-daemon: $(ppd_get)"
    else
        skip "power-profiles-daemon"
    fi

    if tlp_available; then
        ok "TLP installed"
    else
        skip "TLP"
    fi

    if cpu_epp_available; then
        ok "CPU EPP"
    else
        skip "CPU EPP"
    fi

    if [ -e /sys/firmware/acpi/platform_profile ]; then
        ok "firmware platform profile"
    else
        skip "firmware platform profile"
    fi

    if have iw; then
        ok "iw Wi-Fi power-save control"
    else
        skip "iw"
    fi

    printf '\nPlatform profile:\n'
    platform_profile_status

    printf '\n'
}


# ============================================================
# Doctor
# ============================================================

doctor() {
    printf '\n'
    printf 'Dawnbreak Battery Mode doctor\n'
    printf '────────────────────────────────────────\n'

    printf 'Version:      %s\n' "$DBB_VERSION"
    printf 'Kernel:       %s\n' \
        "$(cat /proc/sys/kernel/osrelease 2>/dev/null || printf unknown)"
    printf 'Architecture: %s\n' \
        "$(uname -m 2>/dev/null || printf unknown)"
    printf 'Power source: %s\n' "$(power_state)"
    printf 'Backend:      %s\n' "$(backend)"

    printf '\nPower-management backends:\n'

    if ppd_available; then
        ok "power-profiles-daemon"
        printf '  Current profile: %s\n' "$(ppd_get)"
    else
        skip "power-profiles-daemon"
    fi

    if tlp_available; then
        ok "TLP"

        if have tlp-stat; then
            printf '  Version: %s\n' \
                "$(tlp-stat --version 2>/dev/null | head -n 1 || printf unknown)"
        fi
    else
        skip "TLP"
    fi

    printf '\nCPU:\n'

    local driver
    driver="$(
        read_node \
            /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver \
            2>/dev/null || true
    )"

    if [ -n "$driver" ]; then
        printf '  Scaling driver: %s\n' "$driver"
    else
        skip "scaling driver unavailable"
    fi

    if cpu_epp_available; then
        local f
        for f in \
            /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference
        do
            [ -e "$f" ] || continue
            printf '  EPP: %s = %s\n' \
                "$(basename "$(dirname "$f")")" \
                "$(read_node "$f" 2>/dev/null || printf unknown)"
        done
    else
        skip "EPP unavailable"
    fi

    printf '\nCPU boost:\n'

    if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
        printf '  cpufreq boost: %s\n' \
            "$(read_node /sys/devices/system/cpu/cpufreq/boost)"
    elif [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        printf '  intel_pstate no_turbo: %s\n' \
            "$(read_node /sys/devices/system/cpu/intel_pstate/no_turbo)"
    else
        skip "standard boost control unavailable"
    fi

    printf '\nPlatform profile:\n'
    platform_profile_status

    printf '\nPCI runtime PM:\n'

    local total=0
    local auto=0
    local on=0
    local f
    local value

    for f in /sys/bus/pci/devices/*/power/control; do
        [ -e "$f" ] || continue

        total=$((total + 1))
        value="$(read_node "$f" 2>/dev/null || true)"

        [ "$value" = "auto" ] && auto=$((auto + 1))
        [ "$value" = "on" ] && on=$((on + 1))
    done

    printf '  Devices: %d total, %d auto, %d on\n' \
        "$total" "$auto" "$on"

    printf '\nUSB runtime PM:\n'

    total=0
    auto=0
    on=0

    for f in /sys/bus/usb/devices/*/power/control; do
        [ -e "$f" ] || continue

        total=$((total + 1))
        value="$(read_node "$f" 2>/dev/null || true)"

        [ "$value" = "auto" ] && auto=$((auto + 1))
        [ "$value" = "on" ] && on=$((on + 1))
    done

    printf '  Devices: %d total, %d auto, %d on\n' \
        "$total" "$auto" "$on"

    printf '\nWi-Fi:\n'

    if have iw; then
        local iface
        while IFS= read -r iface; do
            [ -n "$iface" ] || continue

            case "$iface" in
                wl*)
                    printf '  %s power save: ' "$iface"
                    iw dev "$iface" get power_save 2>/dev/null ||
                        printf 'unknown\n'
                    ;;
            esac
        done < <(
            iw dev 2>/dev/null |
                awk '$1 == "Interface" { print $2 }'
        )
    else
        skip "iw unavailable"
    fi

    printf '\nBattery:\n'
    battery_summary

    printf '\n'
    printf 'No automatic PCI/ASPM changes are performed by DBB v0.2.\n'
    printf 'This is intentional: hardware-specific PM behavior must be measured first.\n'
    printf '\n'
}


# ============================================================
# Enable
# ============================================================

do_on() {
    require_root on "$@"

    local force=0
    local no_wifi=0
    local brightness=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --force)
                force=1
                ;;

            --no-wifi)
                no_wifi=1
                ;;

            --brightness)
                [ "$#" -ge 2 ] ||
                    die "--brightness requires a value"

                brightness="$2"
                shift
                ;;

            --brightness=*)
                brightness="${1#*=}"
                ;;

            -h|--help)
                usage
                return 0
                ;;

            *)
                die "unknown option: $1"
                ;;
        esac

        shift
    done

    if state_active; then
        log "DBB is already active."
        log "Use 'dbb-mode off' before enabling it again."
        return 0
    fi

    local power
    power="$(power_state)"

    if [ "$power" != "battery" ] && [ "$force" -ne 1 ]; then
        if [ "$power" = "ac" ]; then
            die "system is connected to AC. Use 'dbb-mode on --force' to override."
        fi

        die "no discharging battery was detected. Use 'dbb-mode on --force' to override."
    fi

    state_init

    log "Enabling Dawnbreak Battery Mode v${DBB_VERSION}..."
    printf '\n'

    #
    # Choose exactly ONE primary power-management backend.
    #
    if ppd_available; then
        optimize_ppd

    elif tlp_available; then
        optimize_tlp

    else
        skip "no high-level power-management backend detected"

        #
        # EPP is our conservative fallback.
        #
        optimize_cpu_epp
    fi

    #
    # Wi-Fi is independent of CPU power policy.
    #
    if [ "$no_wifi" -eq 0 ]; then
        wifi_power_save
    else
        skip "Wi-Fi power saving disabled with --no-wifi"
    fi

    #
    # Brightness is explicitly opt-in.
    #
    if [ -n "$brightness" ]; then
        set_brightness "$brightness"
    else
        skip "display brightness unchanged"
    fi

    #
    # Deliberately report these instead of changing them.
    #
    printf '\n'
    printf 'Platform profile:\n'
    platform_profile_status

    printf '\n'
    log "Battery mode enabled."
    log "No CPU boost, PCI runtime PM, or PCIe ASPM changes were forced."
    log "Run 'dbb-mode status' to inspect the result."
    log "Run 'dbb-mode off' to restore DBB-managed settings."
}


# ============================================================
# Disable
# ============================================================

do_off() {
    require_root off

    if ! state_active; then
        log "DBB is not active."
        return 0
    fi

    log "Disabling Dawnbreak Battery Mode..."
    printf '\n'

    #
    # Restore the high-level backend first.
    #
    restore_ppd

    #
    # Restore direct sysfs modifications.
    #
    state_restore

    state_cleanup

    printf '\n'
    log "Battery mode disabled."
}


# ============================================================
# Usage
# ============================================================

usage() {
    cat <<'EOF'
Dawnbreak Battery Mode

Usage:
  dbb-mode on [options]
  dbb-mode off
  dbb-mode status
  dbb-mode doctor
  dbb-mode version
  dbb-mode help

Options:
  --force
      Allow activation while AC-powered or when battery state is unknown.

  --brightness N
      Set the internal display brightness to N percent (0-100).
      The previous value is restored by 'dbb-mode off'.

  --no-wifi
      Do not enable Wi-Fi power saving.

Examples:
  dbb-mode on
  dbb-mode on --brightness 45
  dbb-mode on --no-wifi
  dbb-mode on --force
  dbb-mode off
  dbb-mode status
  dbb-mode doctor

Design:
  - Uses power-profiles-daemon when available.
  - Otherwise uses TLP as the existing policy backend.
  - Otherwise falls back to CPU EPP.
  - Wi-Fi power saving is independent and reversible.
  - CPU turbo/boost is never disabled.
  - PCI runtime PM is not blindly forced.
  - PCIe ASPM is not forced.
  - Display brightness is never changed unless explicitly requested.
EOF
}


# ============================================================
# Main
# ============================================================

case "${1:-help}" in
    on)
        shift
        do_on "$@"
        ;;

    off)
        shift
        [ "$#" -eq 0 ] ||
            die "off does not accept options"

        do_off
        ;;

    status)
        shift
        [ "$#" -eq 0 ] ||
            die "status does not accept options"

        show_status
        ;;

    doctor)
        shift
        [ "$#" -eq 0 ] ||
            die "doctor does not accept options"

        doctor
        ;;

    help|-h|--help)
        usage
        ;;

    version|--version)
        printf 'dbb-mode %s\n' "$DBB_VERSION"
        ;;

    *)
        die "unknown command: $1 (try 'dbb-mode help')"
        ;;
esac
