{
  description = "rft's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #home-manager.url = "github:nix-community/home-manager";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "";

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
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
    inputs@{ self, ... }:
    let
      lib = inputs.nixpkgs.lib;
      sharedOverlays = with inputs; [
        nur.overlays.default
        nix-vscode-extensions.overlays.default
      ];
      homesLib = import ./lib/homes.nix { inherit lib; };
      mkPkgs = system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = sharedOverlays;
        };
      mkHomeConfig = system: module:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ module ];
          extraSpecialArgs = { inherit inputs; };
        };
      manualHomeConfigurations =
        lib.foldl'
          (acc: system:
            let
              userModules = homesLib.forSystem system;
              userAttrs =
                lib.mapAttrs'
                  (user: module:
                    lib.nameValuePair "${user}@${system}"
                      (mkHomeConfig system module))
                  userModules;
            in
            acc // userAttrs)
          { }
          homesLib.systems;
      snowfallFlake =
        inputs.snowfall-lib.mkFlake {
          inherit inputs;
          src = ./.;

          channels-config = {
            allowUnfree = true;
          };

          overlays = sharedOverlays;

          snowfall = {
            meta = {
              name = "Yuki";
              title = "rft's nix flake";
            };
          };

        };
    in
    snowfallFlake // {
      homeConfigurations = manualHomeConfigurations;
    };
}
