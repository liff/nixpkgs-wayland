let
  nixpkgs = (import (import ./nixpkgs/nixos-unstable) { overlays = [ (import ./default.nix) ]; });
  pkgs-wayland = nixpkgs.waylandPkgs;
  pkgs-chromium = nixpkgs.chromiumPkgs;
in
  {
    all = [ pkgs-wayland pkgs-chromium ];
    inherit pkgs-wayland pkgs-chromium;
  }

