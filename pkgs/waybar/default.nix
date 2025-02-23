args_@{ stdenv, lib, fetchFromGitHub, waybar
, libevdev, libxkbcommon, ...}:

let
  metadata = import ./metadata.nix;
  ignore = [ "waybar" "libevdev" "libxkbcommon" ];
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
in
(waybar.override args).overrideAttrs(old: {
  name = "waybar-${metadata.rev}";
  version = "${metadata.rev}";
  src = fetchFromGitHub {
    owner = "Alexays";
    repo = "Waybar";
    inherit (metadata) rev sha256;
  };
  buildInputs = old.buildInputs ++ [ libevdev libxkbcommon ];
  prePatch = ''
    sed -i "s|version: '0.9.7'|version: '-git-${metadata.rev}'|g" meson.build
  '';
})
