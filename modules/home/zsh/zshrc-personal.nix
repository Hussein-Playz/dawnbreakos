{pkgs, ...}: {
  home.packages = with pkgs; [zsh];

  home.file."./.zshrc-personal".text = ''

    # This file allows you to define your own aliases, functions, etc
    # below are just some examples of what you can use this file for

      #!/usr/bin/env zsh
      # Set defaults
      #
      #export EDITOR="nvim"
      #export VISUAL="nvim"
      alias prime-run='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"'
      alias ls="ls"
      alias workf="cd $HOME/dawnbreakos && kate $HOME/dawnbreakos"
      if [ -e /run/current-system/etc/set-environment ]; then
        . /run/current-system/etc/set-environment
      fi
      cpuinfo() {
        local model avg_freq max_freq temp temp_f icon

        # CPU model
        model=$(awk -F ': ' '/model name/{print $2; exit}' /proc/cpuinfo |
            sed 's/@.*//; s/ *\((R)\|(TM)\)//g; s/^[ \t]*//; s/[ \t]*$//')

        # Average CPU frequency
        avg_freq=$(awk '/cpu MHz/ {sum += $4; count++} END {
            if (count) printf "%.0f", sum / count
        }' /proc/cpuinfo)

        max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)

        if [[ -n "$avg_freq" && -n "$max_freq" ]]; then
            max_freq=$((max_freq / 1000))
            freq="''${avg_freq}/''${max_freq} MHz"
        else
            freq="--"
        fi

        # CPU temperature
        temp=$(sensors 2>/dev/null |
            awk '/Package id 0/ {gsub(/[+°C]/, "", $4); print int($4); exit}')

        # AMD fallback
        if [[ -z "$temp" ]]; then
            temp=$(sensors 2>/dev/null |
                awk '/Tctl/ {gsub(/[+°C]/, "", $2); print int($2); exit}')
        fi

        if [[ -z "$temp" ]]; then
            temp="--"
            temp_f="--"
            icon="󱔱"
        else
            temp_f=$(awk -v t="$temp" 'BEGIN {
                printf "%.1f", (t * 9 / 5) + 32
            }')

            if (( temp >= 80 )); then
                icon="󰸁"
            elif (( temp >= 70 )); then
                icon="󱃂"
            elif (( temp >= 60 )); then
                icon="󰔏"
            else
                icon="󱃃"
            fi
        fi

        echo "CPU: ''${model}"
        echo "Clock: ''${freq}"
        echo "Temp:  ''${icon} ''${temp}°C (''${temp_f}°F)"
    }
    x () {
        if [ -f "$1" ] ; then
            case "$1" in
                *.tar.*|*.tar)
                    tar -xf "$1"
                    ;;
                *.bz2)
                    bunzip2 "$1"
                    ;;
                *.rar)
                    unrar x "$1"
                    ;;
                *.gz)
                    gunzip "$1"
                    ;;
                *.jar|*.zip)
                    unzip "$1"
                    ;;
                *.Z)
                    uncompress "$1"
                    ;;
                *.deb)
                    ar x "$1"
                    ;;
                *)
                    echo "'$1' cannot be extracted"
                    ;;
            esac
        else
            echo "'$1' is not a file"
        fi
    }
  '';
}
