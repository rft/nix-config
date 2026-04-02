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
      inputs.nix-darwin.follows = "nix-darwin";
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

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
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
                  "installer"
                  "darwin"
                ];
              };
            })
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      darwinHosts = [ "lemon" ];
    in
    {
      nixosConfigurations = builtins.removeAttrs (mkConfigurations "nixos") darwinHosts;
      darwinConfigurations = mkConfigurations "darwin";
      homeConfigurations = mkConfigurations "home";

      templates = {
        python = {
          path = ./templates/python;
          description = "Python development environment with devenv";
        };
        python-cad = {
          path = ./templates/python-cad;
          description = "Python CAD environment with build123d and cadquery";
        };
        python-electronics = {
          path = ./templates/python-electronics;
          description = "Python electronics environment with skidl";
        };
        python-datascience = {
          path = ./templates/python-datascience;
          description = "Python data science environment with devenv";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust development environment with devenv";
        };
        node = {
          path = ./templates/node;
          description = "Node.js and TypeScript development environment with devenv";
        };
        gleam = {
          path = ./templates/gleam;
          description = "Gleam development environment with devenv";
        };
        haskell = {
          path = ./templates/haskell;
          description = "Haskell development environment with devenv";
        };
        veryl = {
          path = ./templates/veryl;
          description = "Veryl HDL development environment with devenv";
        };
        prolog = {
          path = ./templates/prolog;
          description = "Prolog development environment with SWI-Prolog";
        };
        ada = {
          path = ./templates/ada;
          description = "Ada development environment with GNAT and gprbuild";
        };
        amaranth = {
          path = ./templates/amaranth;
          description = "Amaranth HDL development environment with yosys and surfer";
        };
      };

      packages.x86_64-linux =
        let
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        {
          rofi-desktop = import ./packages/rofi-desktop {
            inherit inputs pkgs;
            inherit (pkgs)
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
          xxh = pkgs.callPackage ./packages/xxh { };
          installer-iso = inputs.self.nixosConfigurations.installer.config.system.build.isoImage;
        };

      packages.aarch64-darwin =
        let
          pkgs = import inputs.nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        in
        {
          xxh = pkgs.callPackage ./packages/xxh { };
        };
    };
}
