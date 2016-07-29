{ pkgs, ...}:

with pkgs;

# FIXME use npm2nix/bower2nix later to generate the up2date
#       build instead of serving the manually compiled files from src=./.
#       this wasn't implemented due to time-constraints and previous 
#       experiences with these tools (joschi)

stdenv.mkDerivation rec {

  name = "rscoin-block-explorer";
  src = ./.;

  buildPhase = ''

  '';
  configurePhase = ''

  '';

  installPhase = ''
    mkdir -p $out/share
    cp -r static/* $out/share
  '';

  meta = {
    # FIXME don't know the license (joschi)
    pkgs.stdenv.lib.license = licenses.gpl3Plus;
  };
}
