{ stdenv, fetchFromGitHub
, meson, ninja, pkgconfig
, systemd, libxkbcommon, wayland, wayland-protocols
, pixman, mesa, libX11
, xwayland
, scdoc, buildDocs ? true
}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "sommelier";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "platform2-sommelier";
    rev = version;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [ pkgconfig meson ninja ]
    ++ stdenv.lib.optional buildDocs scdoc;

  buildInputs = [
    systemd libxkbcommon wayland wayland-protocols
    pixman mesa libX11
  ];

  preConfigure = ''
    cd vm_tools/sommelier
  '';

  mesonFlags = [
    "-DXWAYLAND_PATH=${xwayland}/bin/Xwayland"
    "-DXWAYLAND_GL_DRIVER_PATH=/run/opengl-driver/lib/dri"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A fork of Chromium's wayland proxy to allow HiDPI X11 clients in swaywm";
    homepage    = "https://github.com/akvadrako/sommelier";
    license     = licenses.mit; # TODO ??
    platforms   = platforms.linux;
    maintainers = with maintainers; [ colemickens ];
  };
}
