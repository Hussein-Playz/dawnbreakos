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

      #alias c="clear"
      alias prime-run='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"'
      alias ls="ls"
      alias workf="kate ~/dawnbreakos"
      alias fastfetch="clear && fastfetch"
      if [ -e /run/current-system/etc/set-environment ]; then
        . /run/current-system/etc/set-environment
      fi
  '';
}
