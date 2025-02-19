{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "helvetica-neue";
  version = "303ef85";
  dontUnpack = true;

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/prchann/fonts/${version}/HelveticaNeue/HelveticaNeue.ttc";
    hash = "sha256-WptEKC8V5NmS+fKgUo3WQHGrlqYNTMQN+R5bnVEWR5I=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp -r $src $out/share/fonts/truetype/
  '';

  meta = {
    description = "A derivation for the Helvetica Neue font";
  };
}
