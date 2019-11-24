self: pkgs:
let
  waylandPkgs = rec {
    # wlroots-related
    cage             = pkgs.callPackage ./pkgs-wayland/cage { wlroots = wlroots-tmp; };
    drm_info         = pkgs.callPackage ./pkgs-wayland/drm_info {};
    gebaar-libinput  = pkgs.callPackage ./pkgs-wayland/gebaar-libinput {};
    glpaper          = pkgs.callPackage ./pkgs-wayland/glpaper {};
    grim             = pkgs.callPackage ./pkgs-wayland/grim {};
    kanshi           = pkgs.callPackage ./pkgs-wayland/kanshi {};
    imv              = pkgs.callPackage ./pkgs-wayland/imv {};
    mako             = pkgs.callPackage ./pkgs-wayland/mako {};
    oguri            = pkgs.callPackage ./pkgs-wayland/oguri {};
    rootbar          = pkgs.callPackage ./pkgs-wayland/rootbar {};
    slurp            = pkgs.callPackage ./pkgs-wayland/slurp {};
    sway             = pkgs.callPackage ./pkgs-wayland/sway {};
    swaybg           = pkgs.callPackage ./pkgs-wayland/swaybg {};
    swayidle         = pkgs.callPackage ./pkgs-wayland/swayidle {};
    swaylock         = pkgs.callPackage ./pkgs-wayland/swaylock {};
    waybar           = pkgs.callPackage ./pkgs-wayland/waybar {};
    waybox           = pkgs.callPackage ./pkgs-wayland/waybox { wlroots = wlroots-tmp; };
    waypipe          = pkgs.callPackage ./pkgs-wayland/waypipe {};
    wayvnc           = pkgs.callPackage ./pkgs-wayland/wayvnc {};
    wdisplays        = pkgs.callPackage ./pkgs-wayland/wdisplays {};
    wev              = pkgs.callPackage ./pkgs-wayland/wev {};
    wf-recorder      = pkgs.callPackage ./pkgs-wayland/wf-recorder {};
    wlay             = pkgs.callPackage ./pkgs-wayland/wlay {};
    wlrobs           = pkgs.callPackage ./pkgs-wayland/wlrobs {};
    wl-clipboard     = pkgs.callPackage ./pkgs-wayland/wl-clipboard {};
    wldash           = pkgs.callPackage ./pkgs-wayland/wldash {};
    wlroots          = pkgs.callPackage ./pkgs-wayland/wlroots {};
    wlr-randr        = pkgs.callPackage ./pkgs-wayland/wlr-randr {};
    wofi             = pkgs.callPackage ./pkgs-wayland/wofi {};
    wtype            = pkgs.callPackage ./pkgs-wayland/wtype {};
    xdg-desktop-portal-wlr = pkgs.callPackage ./pkgs-wayland/xdg-desktop-portal-wlr {};

    wlroots-tmp = pkgs.callPackage ./pkgs-temp/wlroots {};


    # misc
    redshift-wayland = pkgs.callPackage ./pkgs-wayland/redshift-wayland {
      inherit (pkgs.python3Packages) python pygobject3 pyxdg wrapPython;
      geoclue = pkgs.geoclue2;
    };
    freerdp = pkgs.callPackage ./pkgs-wayland/freerdp {
      inherit (pkgs) libpulseaudio;
      inherit (pkgs.gst_all_1) gstreamer gst-plugins-base gst-plugins-good;
    };
    neatvnc = pkgs.callPackage ./pkgs-wayland/neatvnc {};

    # i3 related
    i3status-rust    = pkgs.callPackage ./pkgs-wayland/i3status-rust {};

    # wayfire stuff
    wf-config        = pkgs.callPackage ./pkgs-wayland/wf-config {};
    wayfire          = pkgs.callPackage ./pkgs-wayland/wayfire {};

    # bspwc/wltrunk stuff
    bspwc    = pkgs.callPackage ./pkgs-wayland/bspwc { wlroots = pkgs.wlroots; };
    wltrunk  = pkgs.callPackage ./pkgs-wayland/wltrunk { wlroots = pkgs.wlroots; };  
  };
  chromiumPkgs = {
    # chromium
    chromium-git-ozone = (pkgs.callPackages ./pkgs-chromium/chromium-git {}).chromium-git-ozone;
    #chromium-git-ozone-widevine = (pkgs.callPackages ./pkgs-chromium/chromium-git {}).chromium-git-ozone-widevine;
  };
in
  waylandPkgs // chromiumPkgs // { inherit waylandPkgs; inherit chromiumPkgs; }

