{
  description = "rft's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.follows = "nixpkgs";

    #home-manager.url = "github:nix-community/home-manager";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "nixpkgs";

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
    };
  };

  outputs = inputs: 
  inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;

    channels-config = {
          allowUnfree = true;
    };
    snowfall = {
      meta = {
        name = "Yuki";
        title = "rft's nix flake";
	    };
    };

  };
}
