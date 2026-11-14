{profile, pkgs, ...}: {
  # Services to start
  services = {
    cloudflare-warp.enable = true;
    ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
    };
  };
}
