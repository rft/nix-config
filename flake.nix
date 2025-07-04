{
  description = "rft's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #home-manager.url = "github:nix-community/home-manager";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "";

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
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
      };

      overlays = with inputs; [
        nur.overlays.default
      ];

      snowfall = {
        meta = {
          name = "Yuki";
          title = "rft's nix flake";
        };
      };

    };
}
