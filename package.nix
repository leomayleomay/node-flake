{ lib
, config
, dream2nix
, node-project-cfg
, ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
    node-project-cfg.extraSettings
  ];

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  nodejs-granular-v3 = lib.mkIf (node-project-cfg.buildScript != null) {
    buildScript = node-project-cfg.buildScript;
  };

  mkDerivation = {
    src = lib.cleanSource config.paths.projectRoot;
  };

  name = config.nodejs-package-lock-v3.packageLock.name;
  version = config.nodejs-package-lock-v3.packageLock.version;
}
