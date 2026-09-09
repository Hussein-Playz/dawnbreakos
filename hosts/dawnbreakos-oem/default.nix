{username, ...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
    ./core
  ];

  home-manager.users.${username}.imports = [
    ./home
  ];
}
