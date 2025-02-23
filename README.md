# nixpkgs-wayland

[![Build](https://github.com/colemickens/nixpkgs-wayland/actions/workflows/build.yaml/badge.svg)](https://github.com/colemickens/nixpkgs-wayland/actions/workflows/build.yaml)
[![Update](https://github.com/colemickens/nixpkgs-wayland/actions/workflows/update.yaml/badge.svg)](https://github.com/colemickens/nixpkgs-wayland/actions/workflows/update.yaml)

## overview

Automated, pre-built packages for Wayland (sway/wlroots) tools for NixOS (**nixos-unstable** channel).

Community chat is on Matrix: [#nixpkgs-wayland:matrix.org](https://matrix.to/#/#nixpkgs-wayland:matrix.org). We are not on Libera.

- [nixpkgs-wayland](#nixpkgs-wayland)
  - [overview](#overview)
  - [Usage](#usage)
    - [Binary Cache](#binary-cache)
    - [Flake Usage](#flake-usage)
    - [Install for NixOS (non-flakes, manual import)](#install-for-nixos-non-flakes-manual-import)
    - [Install for non-NixOS users](#install-for-non-nixos-users)
  - [Packages](#packages)
  - [Tips](#tips)
      - [General](#general)
      - [`sway`](#sway)
  - [Development Guide](#development-guide)

## Usage

### Binary Cache

The [Cachix landing page for `nixpkgs-wayland`](https://nixpkgs-wayland.cachix.org) shows how to utilize the binary cache.

Packages from this overlay are regularly built against `nixos-unstable` and pushed to this cache.

### Flake Usage

- Build and run [the Wayland-fixed up](https://github.com/obsproject/obs-studio/pull/2484) version of [OBS-Studio](https://obsproject.com/):
  ```
  nix shell "github:colemickens/nixpkgs-wayland#obs-studio" --command obs
  ```
- Build and run `waybar`:
  ```
  nix run "github:colemickens/nixpkgs-wayland#waybar"
  ```

* Use as an overlay or package set via flakes:

  ```nix
  {
    # ...
    inputs = {
      # ...
      nixpkgs-wayland  = { url = "github:colemickens/nixpkgs-wayland"; };

      # only needed if you use as a package set:
      nixpkgs-wayland.inputs.nixpkgs.follows = "cmpkgs";
      nixpkgs-wayland.inputs.master.follows = "master";
    };

    outputs = inputs: {
      nixosConfigurations."my-laptop-hostname" =
      let system = "x86_64-linux";
      in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [({pkgs, config, ... }: {
          config = {
            nix = {
              # add binary caches
              binaryCachePublicKeys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
                # ...
              ];
              binaryCaches = [
                "https://cache.nixos.org"
                "https://nixpkgs-wayland.cachix.org"
                # ...
              ];
            };

            # use it as an overlay
            nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];

            # pull specific packages (built against inputs.nixpkgs, usually `nixos-unstable`)
            environment.systemPackages = with pkgs; [
              inputs.nixpkgs-wayland.packages.${system}.waybar
            ];
          };
        })];
      };
    };
  }
  ```

### Install for NixOS (non-flakes, manual import)

If you are not using Flakes, then consult the [NixOS Wiki page on Overlays](https://nixos.wiki/wiki/Overlays). Also, you can expand this section for a more literal, direct example. If you do pin, use a tool like `niv` to do the pinning so that you don't forget and wind up stuck on an old version.

<details>

```nix
{ config, lib, pkgs, ... }:
let
  rev = "master";
  # 'rev' could be a git rev, to pin the overla.
  # if you pin, you should use a tool like `niv` maybe, but please consider trying flakes
  url = "https://github.com/colemickens/nixpkgs-wayland/archive/${rev}.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball url));
in
  {
    nixpkgs.overlays = [ waylandOverlay ];
    environment.systemPackages = with pkgs; [ wayvnc ];
    # ...
  }
```

You could write that to a file `./wayland.nix` next to your `configuration.nix` and then use it like so:

```nix
{ config, lib, pkgs, ... }:
  {
    # ...
    imports = [
      # ...
      ./wayland.nix
    ];
  }
```

</details>

### Install for non-NixOS users

Non-NixOS users have many options, but here are two explicitly:

1. Activate flakes mode, then just run them outright like the first example in this README.

2. See the following details block for an example of how to add `nixpkgs-wayland` as a user-level
   overlay and then install a package with `nix-env`.

<details>

1. There are two ways to activate an overlay for just your user:

   1. Add a new entry in ``~/.config/nixpkgs/overlays.nix`:
    ```nix
    let
      url = "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
    in
    [
      (import (builtins.fetchTarball url))
    ]
    ```

   2. Add a new file under a dir, `~/.config/nixpkgs/overlays/nixpkgs-wayland.nix`:
    ```nix
    let
      url = "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
    in
      (import (builtins.fetchTarball url))
    ```

  Note, this method does not pin `nixpkgs-wayland`. That's left to the reader. (Just use flakes...)

2. Then, `nix-env` will have access to the packages:

```nix
nix-env -iA neatvnc
```

</details>


## Packages

These packages were mostly recently built (and cached) against:

<!--pkgs-->
| Package | Description |
| --- | --- |
| [aml](https://github.com/any1/neatvnc) | liberally licensed VNC server library that's intended to be fast and neat |
| [cage](https://www.hjdskes.nl/projects/cage/) | A Wayland kiosk |
| [clipman](https://github.com/yory8/clipman) | A basic clipboard manager for Wayland, with support for persisting copy buffers after an application exits |
| [drm_info](https://github.com/ascent12/drm_info) | Small utility to dump info about DRM devices. |
| [dunst](https://dunst-project.org/) | Lightweight and customizable notification daemon |
| [gebaar-libinput](https://github.com/Osleg/gebaar-libinput-fork) | Gebaar, A Super Simple WM Independent Touchpad Gesture Daemon for libinput |
| [glpaper](https://bitbucket.org/Scoopta/glpaper) | GLPaper is a wallpaper program for wlroots based wayland compositors such as sway that allows you to render glsl shaders as your wallpaper |
| [grim](https://github.com/emersion/grim) | Grab images from a Wayland compositor |
| [gtk-layer-shell](https://github.com/wmww/gtk-layer-shell) | A library to create panels and other desktop components for Wayland using the Layer Shell protocol |
| [i3status-rust](https://github.com/greshake/i3status-rust) | Very resource-friendly and feature-rich replacement for i3status |
| [imv](https://github.com/eXeC64/imv) | A command line image viewer for tiling window managers |
| [kanshi](https://github.com/emersion/kanshi) | Dynamic display configuration |
| [lavalauncher](https://git.sr.ht/~leon_plickat/lavalauncher) | A simple launcher for Wayland. |
| [libvncserver_master](https://libvnc.github.io/) | VNC server library |
| [mako](https://wayland.emersion.fr/mako) | A lightweight Wayland notification daemon |
| [neatvnc](https://github.com/any1/neatvnc) | liberally licensed VNC server library that's intended to be fast and neat |
| [nwg-launchers](https://github.com/nwg-piotr/nwg-launchers) |  GTK-based launchers: application grid, button bar, dmenu for sway and other window managers  |
| [nwg-panel](https://github.com/nwg-piotr/nwg-panel) | GTK3-based panel for Sway window manager |
| [obs-studio](https://obsproject.com) | Free and open source software for video recording and live streaming |
| [obs-wlrobs](https://sr.ht/~scoopta/wlrobs) | wlrobs is an obs-studio plugin that allows you to screen capture on wlroots based wayland compositors |
| [oguri](https://github.com/vilhalmer/oguri) | A very nice animated wallpaper tool for Wayland compositors |
| [rootbar](https://hg.sr.ht/~scoopta/rootbar) | Root Bar is a bar for wlroots based wayland compositors such as sway and was designed to address the lack of good bars for wayland |
| [sirula](https://github.com/DorianRudolph/sirula) | Sirula (simple rust launcher) is an app launcher for wayland |
| [slurp](https://github.com/emersion/slurp) | Select a region in a Wayland compositor |
| [swaybg](https://github.com/swaywm/swaybg) | Wallpaper tool for Wayland compositors |
| [swayidle](https://swaywm.org) | Sway's idle management daemon |
| [swaylock](https://swaywm.org) | Screen locker for Wayland |
| [sway-unwrapped](https://swaywm.org) | An i3-compatible tiling Wayland compositor |
| [waybar](https://github.com/alexays/waybar) | Highly customizable Wayland bar for Sway and Wlroots based compositors |
| [wayfire](https://wayfire.org/) | 3D wayland compositor |
| [waypipe](https://gitlab.freedesktop.org/mstoeckl/waypipe/) | Network transparency with Wayland |
| [wayvnc](https://github.com/any1/wayvnc) | A VNC server for wlroots based Wayland compositors |
| [wdisplays](https://github.com/cyclopsian/wdisplays) | GUI display configurator for wlroots compositors |
| [wev](https://git.sr.ht/~sircmpwn/wev) | A tool for debugging events on a Wayland window, analagous to the X11 tool xev. |
| [wf-recorder](https://github.com/ammen99/wf-recorder) | Utility program for screen recording of wlroots-based compositors |
| [wlay](https://github.com/atx/wlay) | Graphical output management for Wayland |
| [wldash](https://wldash.org) | Wayland launcher/dashboard |
| [wlfreerdp](http://www.freerdp.com/) | A Remote Desktop Protocol Client |
| [wlogout](https://github.com/ArtsyMacaw/wlogout) | A wayland based logout menu |
| [wlroots-eglstreams](https://github.com/swaywm/wlroots) | A modular Wayland compositor library |
| [wlroots](https://github.com/swaywm/wlroots) | A modular Wayland compositor library |
| [wlr-randr](https://github.com/emersion/wlr-randr) | An xrandr clone for wlroots compositors |
| [wlsunset](https://git.sr.ht/~kennylevinsen/wlsunset) | Day/night gamma adjustments for Wayland |
| [wlvncc](https://github.com/any1/wlvncc) | A Wayland Native VNC Client |
| [wl-clipboard](https://github.com/bugaevc/wl-clipboard) | Select a region in a Wayland compositor |
| [wl-gammactl](https://github.com/mischw/wl-gammactl) | Small GTK GUI application to set contrast, brightness and gamma for wayland compositors which support the wlr-gamma-control protocol extension. |
| [wofi](https://hg.sr.ht/~scoopta/wofi) | Wofi is a launcher/menu program for wlroots based wayland compositors such as sway |
| [wtype](https://github.com/atx/wtype) | xdotool type for wayland |
| [xdg-desktop-portal-wlr](https://github.com/emersion/xdg-desktop-portal-wlr) | xdg-desktop-portal backend for wlroots |
<!--pkgs-->

</details>

## Tips

#### General

- I recommend using [`home-manager`](https://github.com/rycee/home-manager/)!
- It has modules and options for:
  - `sway`
  - `waybar`
  - `obs` and plugins!
  - more!

#### `sway`

- You will likely want a default config file to place at `$HOME/.config/sway/config`. You can use the upstream default as a starting point: https://github.com/swaywm/sway/blob/master/config.in
- If you start `sway` from a raw TTY, make sure you use `exec sway` so that if sway crashes, an unlocked TTY is not exposed.

## Development Guide

- Use `nix-direnv` (or if you can't, `nix develop`, (or if you can't, `nix-shell`)).
- `./update.sh`:
  - updates flake inputs
  - updates `pkgs/<pkg>/metadata.nix` with the latest commit+hash for each package
  - calls `nix-build-uncached ... packages.nix` to build uncached packages (see: [nix-build-uncached](https://github.com/Mic92/nix-build-uncached))
  - pushes to ["nixpkgs-wayland" on cachix](https://nixpkgs-wayland.cachix.org)

If for some reason the overlay isn't progressing and you want to help, just clone the repo, run `nix-shell --command ./update.sh`
and start fixing issues in the package definitions. Sometimes you might need to edit `default.nix` to change the version
of `wlroots` a certain package uses.
