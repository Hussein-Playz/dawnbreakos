{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.lib) attrByPath;

  # Optional versions; set these to real versions to enable marketplace fetches.
  hyprlsVer = "0.1.2"; # ewen-lbh.vscode-hyprls
  codeRunnerVer = "0.12.4"; # formulahendry.code-runner

  # Helper: prefer Open VSX (pkgs.vscode-extensions). If missing and a version is
  # provided, fetch from the VSCode Marketplace using extensionsFromVscodeMarketplace.
  extOrMarketplace = {
    publisher,
    name,
    version ? null,
    sha256 ? null,
  }: let
    fromOpenVSX = attrByPath [publisher name] null pkgs.vscode-extensions;
  in
    if fromOpenVSX != null
    then [fromOpenVSX]
    else if version == null
    then []
    else
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          inherit name publisher version;
          sha256 =
            if sha256 == null
            then pkgs.lib.fakeSha256
            else sha256;
        }
      ];
  hyprlsExts = extOrMarketplace {
    publisher = "ewen-lbh";
    name = "vscode-hyprls";
    version = hyprlsVer;
    sha256 = "sha256-pTg8ZyfhZj31Rv8gxhPbQ+CYzb5MXYdaI46JQHPU9ng=";
  };
  codeRunnerExts = extOrMarketplace {
    publisher = "formulahendry";
    name = "code-runner";
    version = codeRunnerVer;
    sha256 = pkgs.lib.fakeSha256;
  };
in {
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions =
          (with pkgs.vscode-extensions; [
            catppuccin.catppuccin-vsc
            bbenoist.nix
            kamadorueda.alejandra
            jeff-hykin.better-nix-syntax
            ms-vscode.cpptools-extension-pack
            vscodevim.vim
            mads-hartmann.bash-ide-vscode
            tamasfe.even-better-toml
            zainchen.json
            shd101wyy.markdown-preview-enhanced
          ])
          ++ hyprlsExts
          ++ codeRunnerExts;
        userSettings = lib.mkForce {
          "workbench.colorTheme" = "Dark+";
          "workbench.sideBar.location" = "left";
        };
      };
    };
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
}
