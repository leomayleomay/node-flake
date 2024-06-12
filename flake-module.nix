inputs @ { dream2nix, ... }:
{ self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', pkgs, system, ... }:
        let
          cfg = config;
        in
        {
          options =
            let
              nodeProjectType = types.submodule
                {
                  options =
                    {
                      src = mkOption {
                        type = types.path;
                        description = "Source directory for the node-projects package";
                        default = self;
                      };
                      buildScript = mkOption {
                        type = types.nullOr types.string;
                        description = "Build script for the node-projects package";
                        default = null;
                      };
                      extraSettings = mkOption {
                        type = types.deferredModule;
                        description = "Extra settings for the node-projects package";
                        default = { };
                      };
                    };
                };
            in
            {
              node-projects = mkOption {
                type = types.lazyAttrsOf nodeProjectType;
              };
            };

          config =
            let
              packages =
                lib.concatMapAttrs
                  (name: project: {
                    ${name} = dream2nix.lib.evalModules {
                      specialArgs = {
                        node-project-cfg = project;
                      };
                      packageSets.nixpkgs = dream2nix.inputs.nixpkgs.legacyPackages.${system};
                      modules = [
                        ./package.nix
                        {
                          paths.projectRoot = project.src;
                          paths.projectRootFile = "flake.nix";
                          paths.package = project.src;
                        }
                      ];
                    };
                  })
                  cfg.node-projects;
            in
            {
              inherit packages;
            };
        });
  };
}
