{ stdenv, fetchFromGitHub
, pkgconfig, meson, ninja
, wayland, wayland-protocols
, libxkbcommon
}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "hawck";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "snyball";
    repo = "Hawck";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [
    wayland wayland-protocols
    libxkbcommon
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "High-level Wayland compositor library based on wlroots";
    homepage    = "https://git.sr.ht/~bl4ckb0ne/wltrunk";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ colemickens ];
  };
}
