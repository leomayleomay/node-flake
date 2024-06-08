{ lib
, config
, dream2nix
, ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  deps =
    { nixpkgs, ... }:
    {
      inherit (nixpkgs) gnugrep;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  nodejs-granular-v3 = {
    buildScript = ''
      mv index.js index.js.tmp
      echo "#!${config.deps.nodejs}/bin/node" > index.js
      cat index.js.tmp >> index.js
      chmod +x ./index.js
      patchShebangs .
    '';
  };

  mkDerivation = {
    src = lib.cleanSource config.paths.projectRoot;
    checkPhase = ''
      ./index.js | ${config.deps.gnugrep}/bin/grep -q "Hello, World!"
    '';
    doCheck = true;
  };

  name = config.nodejs-package-lock-v3.packageLock.name;
  version = config.nodejs-package-lock-v3.packageLock.version;
}
