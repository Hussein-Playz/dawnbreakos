{profile, pkgs, ...}: {
  # Services to start
  services = {
    ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
    };
  };
}
