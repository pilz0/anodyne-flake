{
  stdenvNoCC,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "anodyne-frontend";
  version = src.shortRev or "unstable";
  inherit src;

  dontBuild = true;

  installPhase = ''
    cp -r . $out
  '';
}
