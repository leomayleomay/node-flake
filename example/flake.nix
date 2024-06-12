{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    node-flake.url = "github:leomayleomay/node-flake";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.node-flake.flakeModule
      ];
      perSystem = { self', inputs', pkgs, system, lib, ... }: {
        node-projects."nextjs-app" = {
          src = ./nextjs-app;
        };
      };
    };
}
