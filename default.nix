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
    rev = "9da548c1a4b5d9d9d34f0e0a1c9ef53ac8b8a64f";
    sha256 = "059fxrv9i022v60w7mmd2hc87qb91bjcfak6i0pq6rds4lbs6lk8";
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
