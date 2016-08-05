{pkgs, ...}:

with pkgs;
let
  deps = import ./deps.nix { inherit pkgs; };
in
deps.haskellPackagesExtended.mkDerivation { # haskell.lib.buildStackProject {
  pname = "rscoin";
  version = "0.1.0.0";
  src = pkgs.fetchgit {
      url = "https://github.com/serokell/rscoin";
      rev = "208b0c128696c8ab78cced311db63fd5a005224a";
      sha256 = "14r9xc05lw3514sm4x1r8zmspx3p7p06j2wmq59n83j3hhvzn3gd";
    };

  isLibrary = true;
  isExecutable = true;
  doCheck = false;


  patchPhase = ''
    echo "WARNING: Removing Setup.hs which wants to run shell commands which will always fail in nix-build"
    rm Setup.hs
  '';


  libraryHaskellDepends = deps.rscoinLibraryHaskellDepends;
  executableHaskellDepends = deps.rscoinExecutableHaskellDepends;
  testHaskellDepends = deps.rscoinTestHaskellDepends;
  libraryPkgconfigDepends = deps.rscoinLibraryPkgconfigDepends;
  executableToolDepends = [ makeWrapper ];
  executableSystemDepends = [ gtk3 ];
  buildDepends = [ makeWrapper ];

  license = stdenv.lib.licenses.gpl3;
}
