{
  appimageTools,
  fetchurl,
  xorg,
}:

let
  pname = "mochi";
  version = "1.18.7";
  src = fetchurl {
    url = "https://mochi.cards/releases/Mochi-${version}.AppImage";
    hash = "sha256-FCh8KLnvs26GKTVJY4Tqp+iA8sNlK7e0rv+oywBIF+U=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ xorg.libxshmfence ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/${pname}.png -t $out/share/pixmaps/
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=${pname}'
  '';

  meta = {
    description = "A simple markdown-powered SRS app";
  };
}
