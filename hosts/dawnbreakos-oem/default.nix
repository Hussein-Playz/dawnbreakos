{username, ...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  home-manager.users.${username}.imports = [
    ./home
  ];
}
