{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia-amd-hybrid;
in {
  options.drivers.nvidia-amd-hybrid = {
    enable = mkEnableOption "Enable AMD iGPU + NVIDIA dGPU (Prime offload)";
    # AMD iGPU Bus ID (e.g., PCI:5:0:0). Expose as option for future host wiring.
    amdgpuBusId = mkOption {
      type = types.str;
      default = "PCI:5:0:0";
      description = "PCI Bus ID for AMD iGPU";
    };
    # NVIDIA dGPU Bus ID (e.g., PCI:1:0:0)
    nvidiaBusId = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID for NVIDIA dGPU";
    };
  };

  config = mkIf cfg.enable {
    # Enforce kernel 6.12 when this hybrid config is selected
    # Not sure this is still neeeded but leaving just in case
    # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true; # RTX 50xx requires the open kernel module
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;

      # Helpful on laptops to power down the dGPU when idle
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      # AMD primary, NVIDIA offload
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # Wire from options
        amdgpuBusId = cfg.amdgpuBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };
    };
  };
}
