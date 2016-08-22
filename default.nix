{pkgs, ...}:

with pkgs;
let
  deps = import ./deps.nix { inherit pkgs; };
in
deps.haskellPackagesExtended.mkDerivation { # haskell.lib.buildStackProject {
  pname = "rscoin";
  version = "0.1.0.0";
  src = pkgs.fetchgit {
    url = "https://github.com/input-output-hk/rscoin-haskell";
    rev = "52258dfe4c3c22badfa504f54fb10173037ddb6e";
    sha256 = "19pm7nzl6nj0md5fx6a7c51g15h4pwnq4ypij3d07517chr0sf87";
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
