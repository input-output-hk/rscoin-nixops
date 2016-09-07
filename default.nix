# nix-build -E 'with import ../nixpkgs {}; callPackage ./default.nix { }'
# compile with nixpkgs in revision 7c71a897dd0c641e047d6e713dca85764b577c4e aka '16.09-beta'

{pkgs, ...}:

with pkgs;
let
  deps = import ./deps.nix { inherit pkgs; };
in
deps.haskellPackagesExtended.mkDerivation {
  pname = "rscoin-haskell";
  version = "0.1.0.0";
  src = pkgs.fetchgit {
    url = "https://github.com/input-output-hk/rscoin-haskell";
    rev = "480230cdc8cb1c76baf055e4b8c7cfbcfa9fde38";
    sha256 = "0icg9fj6y9a8lnsvnqsxf778sym4wqq5aj9cwbjqgcf9270fg4vj";
  };

  isLibrary = true;
  isExecutable = true;
  doCheck = false;
  doHaddock = false;

  patchPhase = ''
    echo "WARNING: Removing Setup.hs which wants to run shell commands which will always fail in nix-build"
    rm Setup.hs
  '';

  libraryHaskellDepends = deps.RSlibraryHaskellDepends;
  executableHaskellDepends = deps.RSexecutableHaskellDepends;
  testHaskellDepends = deps.RStestHaskellDepends;
  executableToolDepends = [ makeWrapper ];
  buildDepends = [ makeWrapper ];

  license = stdenv.lib.licenses.gpl3;
}
