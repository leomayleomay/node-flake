inputs @ { dream2nix, ... }:
{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', pkgs, system, ... }:
        let
          cfg = config.node-project;
        in
        {
          imports = [
            {
              options.node-project.args = lib.mkOption {
                default = { };
                type = lib.types.submodule {
                  freeformType = lib.types.attrsOf lib.types.raw;
                };
              };
            }
          ];
          options = {
            node-project.args.buildInputs = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            };

            node-project.args.nativeBuildInputs = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            };

            node-project.src = lib.mkOption {
              type = lib.types.path;
              description = "Source directory for the node-project package";
              default = self;
            };
          };
          config =
            let
              package = dream2nix.lib.evalModules {
                packageSets.nixpkgs = dream2nix.inputs.nixpkgs.legacyPackages.${system};
                modules = [
                  ./package.nix
                  {
                    paths.projectRoot = cfg.src;
                    paths.projectRootFile = "flake.nix";
                    paths.package = cfg.src;
                  }
                ];
              };

              nodeDevShell = pkgs.mkShell {
                buildInputs = cfg.args.buildInputs;
                packages = cfg.args.nativeBuildInputs;
              };
            in
            {
              # Node package
              packages.default = package;

              # Node dev environment
              devShells.default = pkgs.mkShell {
                inputsFrom = [
                  nodeDevShell
                ];
              };
            };
        });
  };
}
