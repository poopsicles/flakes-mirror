{
  stdenv,
  fetchFromGitHub,
  python3,
  optipng,
  zopfli,
  pngquant,
  imagemagick,
  which,
}:

stdenv.mkDerivation rec {
  pname = "apple-color-emoji-src";
  version = "17.4";

  src = fetchFromGitHub {
    owner = "samuelngs";
    repo = "apple-emoji-linux";
    tag = "v${version}";
    hash = "sha256-liklPjOJhHOBWQH8AQwkLfIG0KIqdnZcVAa7oMrVZMk=";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    which
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        fonttools
        nototools
      ]
    ))
    optipng
    zopfli
    pngquant
    imagemagick
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    cp ./AppleColorEmoji.ttf $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "A derivation for the Apple Color Emoji font";
  };
}
