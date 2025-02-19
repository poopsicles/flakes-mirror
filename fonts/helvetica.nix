{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "helvetica";
  version = "303ef85";
  dontUnpack = true;

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/prchann/fonts/${version}/Helvetica/Helvetica.ttc";
    hash = "sha256-q+i5LR/uIXli+Gno1AdZr61cqLsHTVtYAyP1DH/f+OQ=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp -r $src $out/share/fonts/truetype/
  '';

  meta = {
    description = "A derivation for the Helvetica font";
  };
}
