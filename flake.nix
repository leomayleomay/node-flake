{
  description = "A `flake-parts` module for Node development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { dream2nix, ... }: {
    flakeModule = import ./flake-module.nix { inherit dream2nix; };

    nixci.default =
      let
        overrideInputs = {
          node-flake = ./.;
        };
      in
      {
        dev = { inherit overrideInputs; dir = "dev"; };
      };
  };
}
