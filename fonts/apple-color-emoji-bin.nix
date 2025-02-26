{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "17.4";
  dontUnpack = true;

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    hash = "sha256-SG3JQLybhY/fMX+XqmB/BKhQSBB0N1VRqa+H6laVUPE=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype
  '';

  meta = {
    description = "A derivation for the Apple Color Emoji font";
  };
}
