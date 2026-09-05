{
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "breezex-black-cursor";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v${version}/BreezeX-Black.tar.gz";
    hash = "sha256-5su79uUG9HLeAqXDUJa/VhpbYyy9gFj/VdtRPY0yUL4=";

  };

  installPhase = ''
    mkdir -p $out/share/icons
    cp -r $src $out/share/icons/BreezeX-Black
  '';
}
