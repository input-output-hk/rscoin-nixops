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
      rev = "1b5f91ac54c67241973dabf637e17e583a3fdac0";
      sha256 = "1nggfb2m6gy54m565ccag6abq67ydbh5i1825kk3ak2bwkr4bb9l";
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
