{ stdenv, fetchgit, fetchpatch
, meson, ninja
, pkgconfig, scdoc
, cglm, libGL, openxr-loader
, wayland, wayland-protocols, wlroots
, libX11, udev, pixman, libinput, libxkbcommon
, buildDocs ? true
}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "wxrc";
  version = metadata.rev;

  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/wxrc";
    rev = version;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    pkgconfig meson ninja
  ] ++ stdenv.lib.optional buildDocs scdoc;

  buildInputs = [
    cglm libGL openxr-loader
    wayland wayland-protocols wlroots
    libX11 udev pixman libinput libxkbcommon
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "";
    homepage    = "https://git.sr.ht/~sircmpwn/wxrc";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [];
  };
}
