{ nixpkgs ? fetchTarball https://github.com/NixOS/nixpkgs/archive/e725c927d4a09ee116fe18f2f0718364678a321f.tar.gz}:
let
  pkgs = import nixpkgs {};
in {
  rscoin-haskell = import ./default.nix { inherit pkgs;};
}
