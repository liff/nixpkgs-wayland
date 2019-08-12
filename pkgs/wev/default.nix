{ stdenv, fetchgit, wlroots, wayland
}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "wev";
  version = metadata.rev;
  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/wev";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };
  nativeBuildInputs = [];
  buildInputs = [ wayland wlroots ];
  buildPhase = ''
    cd Release
    make
  '';
  installPhase = ''
    mkdir -p $out/share/obs/obs-plugins/wlrobs/bin/64bit
    cp libwlrobs.so $out/share/obs/obs-plugins/wlrobs/bin/64bit
  '';

  meta = with stdenv.lib; {
    description = "wlrobs is an obs-studio plugin that allows you to screen capture on wlroots based wayland compositors";
    homepage = "https://sr.ht/~scoopta/wlrobs";
    maintainers = with maintainers; [ colemickens ];
    platforms = with platforms; linux;
  };
}
