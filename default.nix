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
    rev = "6ef15f9045ca075b895661df59d671959d8c703f";
    sha256 = "167nzwv6v9caks0hgyjcg7r21aajvs0wh0lwpsb6pzn894vv6bss";
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
