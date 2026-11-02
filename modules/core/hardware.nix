{pkgs, ...}: {
  hardware = {
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    opentabletdriver.enable = true;
    uinput.enable = true;
  };
  boot = {
    kernelModules = [ "uinput" ];
    supportedFilesystems = [ "ntfs" ];
  };
  local.hardware-clock.enable = false;
}
