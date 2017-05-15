{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, filepath, hakyll, stdenv }:
      mkDerivation {
        pname = "goamazing";
        version = "0.1.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base filepath hakyll ];
        homepage = "https://goamazinghostel.com/";
        description = "Goamazing Hostel Site";
        license = stdenv.lib.licenses.agpl3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
