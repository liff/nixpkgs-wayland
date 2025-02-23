{stdenv, lib, fetchFromGitHub
, meson, ninja, pkgconfig
, gtk3, gtkmm3, epoxy, nlohmann_json
, gtk-layer-shell
, wayland, wayland-protocols
, wrapGAppsHook
}:

let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "nwg-launchers";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-launchers";
    rev = version;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    pkgconfig meson ninja
  ];

  buildInputs = [
    gtk3 gtkmm3 nlohmann_json epoxy wayland wayland-protocols
    gtk-layer-shell
    wrapGAppsHook
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = " GTK-based launchers: application grid, button bar, dmenu for sway and other window managers ";
    homepage    = "https://github.com/nwg-piotr/nwg-launchers";
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ colemickens ];
  };
}
