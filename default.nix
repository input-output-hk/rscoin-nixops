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
    rev = "c292aedd98a9915ea5238d8f561b9a5bea727206";
    sha256 = "0d9xaz4k9yyn2n7nqihpm9dsbcfr7ry6a93v8nml3cjgz3i37fl9";
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
