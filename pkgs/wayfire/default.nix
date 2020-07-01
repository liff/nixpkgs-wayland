{ stdenv, fetchFromGitHub
, meson, pkgconfig, ninja
, wayland, wayland-protocols
, cairo, glm
, libevdev, freetype, libinput
, pixman, libxkbcommon, libdrm
, libjpeg, libpng
, libGL, mesa
, libcap, xcbutilerrors, xcbutilwm, libxml2
, buildDocs ? true
}:

let
  metadata = import ./metadata.nix;
  wlroots_ = wlroots.overrideAttrs (old: {
    postPatch = ''
      substituteInPlace "backend/rdp/peer.c" \
       --replace \
         "nsc_context_set_pixel_format(context->nsc_context, PIXEL_FORMAT_BGRA32);" \
         "return nsc_context_set_parameters(context->nsc_context, NSC_COLOR_FORMAT, PIXEL_FORMAT_BGRA32);"
    '';
  });
in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "wayfire";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wayfire";
    rev = version;
    sha256 = metadata.sha256;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [
    # egl glesv2
    wayland wayland-protocols
    cairo glm
    libevdev freetype libinput
    pixman libxkbcommon libdrm
    libjpeg libpng
    libGL mesa
    libcap xcbutilerrors xcbutilwm libxml2
  ];
  mesonFlags = [
    "-Duse_system_wlroots=disabled"
    "-Duse_system_wfconfig=disabled"
    "-Dwlroots:logind-provider=systemd"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "3D wayland compositor";
    homepage    = "https://wayfire.org/";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ colemickens ];
  };
}
