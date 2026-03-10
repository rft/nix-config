{
  description = "rft's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcats-nvim = {
      url = "github:rft/nixcat-nvim";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { denix, ... }@inputs:
    let
      mkConfigurations =
        moduleSystem:
        denix.lib.configurations {
          inherit moduleSystem;
          homeManagerUser = "nano";
          paths = [
            ./hosts
            ./modules
          ];
          extensions = with denix.lib.extensions; [
            args
            (base.withConfig {
              args.enable = true;
              rices.enable = false;
              hosts.type = {
                types = [
                  "desktop"
                  "server"
                  "wsl"
                ];
              };
            })
          ];
          specialArgs = {
            inherit inputs;
          };
        };
    in
    {
      nixosConfigurations = mkConfigurations "nixos";
      homeConfigurations = mkConfigurations "home";

      packages.x86_64-linux = {
        rofi-desktop = import ./packages/rofi-desktop {
          inherit (inputs) nixpkgs;
          inherit inputs;
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          inherit (inputs.nixpkgs.legacyPackages.x86_64-linux)
            lib
            stdenvNoCC
            fetchgit
            makeWrapper
            runtimeShell
            python3
            gtk3
            glib
            gdk-pixbuf
            pango
            atk
            wrapGAppsHook3
            ;
        };
        xxh = inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/xxh { };
      };
    };
}
