{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.follows = "nixpkgs";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: 
    inputs.snowfall-lib.mkFlake {
      inherit inputs; 
      src = ./.;

      snowfall = {
        meta = {
          name = "Yuki";
          title = "rft's nix flake";
	};
      };

    };
}
