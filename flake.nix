{
  description = "Dawnbreak OS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # QML shape components used by the Caelestia-derived dashboard.
    m3shapes = {
      url = "github:soramanew/m3shapes/32ad9ce328bb77ed349b40a3be10ee9ea610b8ab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    # Checking nixvim to see if it's better
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    synfetch = {
      url = "github:SXSLVT/synfetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixvim,
    nix-flatpak,
    alejandra,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    host = "dawnbreakos-oem";
    profile = "nvidia-laptop";
    username = "dawn";

    # Deduplicate nixosConfigurations while preserving the top-level 'profile'
    mkNixosConfig = gpuProfile:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
          inherit username;
          inherit host;
          inherit profile;
        };

        modules = [
          ./modules/core/overlays.nix
          ./profiles/${gpuProfile}
          nix-flatpak.nixosModules.nix-flatpak

          {
            home-manager.extraSpecialArgs = {
              inherit inputs username host profile;
            };
          }
        ];
      };
  in {
    nixosConfigurations = {
      amd = mkNixosConfig "amd";
      nvidia = mkNixosConfig "nvidia";
      nvidia-laptop = mkNixosConfig "nvidia-laptop";
      amd-nvidia-hybrid = mkNixosConfig "amd-nvidia-hybrid";
      intel = mkNixosConfig "intel";
      vm = mkNixosConfig "vm";
    };

    formatter.x86_64-linux = inputs.alejandra.packages.x86_64-linux.default;
  };
}
