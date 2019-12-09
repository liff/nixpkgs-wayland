#!/usr/bin/env bash

set -euo pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# keep track of what we build for the README
pkgentries=(); nixpkgentries=();
cache="nixpkgs-wayland";

up=0 # updated_performed # up=$(( $up + 1 ))

function update() {
  typ="${1}"
  pkg="${2}"

  metadata="${pkg}/metadata.nix"
  pkgname="$(basename "${pkg}")"

  [[ ! -f "${metadata}" ]] && return

  branch="$(nix eval --raw -f "${metadata}" branch)"
  rev="$(nix eval --raw -f "${metadata}" rev)"
  date="$(nix eval --raw -f "${metadata}" revdate)"
  sha256="$(nix eval --raw -f "${metadata}" sha256)"
  skip="$(nix eval -f "${metadata}" skip || true)"

  newdate="${date}"
  if [[ "${skip}" != "true" ]]; then
    # Determine RepoTyp (git/hg)
    if   nix eval --raw -f "${metadata}" repo_git; then repotyp="git";
    elif nix eval --raw -f "${metadata}" repo_hg;  then repotyp="hg";
    else echo "unknown repo_typ" && exit -1;
    fi

    # Update Rev
    if [[ "${repotyp}" == "git" ]]; then
      repo="$(nix eval --raw -f "${metadata}" repo_git)"
      newrev="$(git ls-remote "${repo}" "${branch}" | awk '{ print $1}')"
    elif [[ "${repotyp}" == "hg" ]]; then
      repo="$(nix eval --raw -f "${metadata}" repo_hg)"
      newrev="$(hg identify "${repo}" -r "${branch}")"
    fi

    if [[ "${rev}" != "${newrev}" ]]; then
      up=$(( $up + 1 ))

      # Update RevDate
      d="$(mktemp -d)"
      if [[ "${repotyp}" == "git" ]]; then
        git clone -b "${branch}" --single-branch --depth=1 "${repo}" "${d}"
        newdate="$(cd "${d}"; git log --format=%ci --max-count=1)"
      elif [[ "${repotyp}" == "hg" ]]; then
        hg clone "${repo}#${branch}" "${d}"
        newdate="$(cd "${d}"; hg log -r1 --template '{date|isodate}')"
      fi
      rm -rf "${d}"

      # Update Sha256
      # TODO: nix-prefetch without NIX_PATH?
      if [[ "${typ}" == "pkgs-"* ]]; then
        newsha256="$(NIX_PATH=nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz \
          nix-prefetch \
            -E "(import ./build.nix).${typ}.${pkgname}" \
            --rev "${newrev}" \
            --output raw)"
      elif [[ "${typ}" == "nixpkgs" ]]; then
        # TODO: why can't nix-prefetch handle this???
        url="$(nix eval --raw -f "${metadata}" url)"
        newsha256="$(NIX_PATH=nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz \
          nix-prefetch-url --unpack "${url}")"
      fi

      # TODO: do this with nix instead of sed?
      sed -i "s/${rev}/${newrev}/" "${metadata}"
      sed -i "s/${date}/${newdate}/" "${metadata}"
      sed -i "s/${sha256}/${newsha256}/" "${metadata}"
    fi
  fi

  if [[ "${skip}" == "true" ]]; then
    newdate="${newdate} (pinned)"
  fi
  if [[ "${typ}" == "pkgs-"* ]]; then
    desc="$(nix eval --raw "(import ./build.nix).${typ}.${pkgname}.meta.description")"
    home="$(nix eval --raw "(import ./build.nix).${typ}.${pkgname}.meta.homepage")"
    pkgentries=("${pkgentries[@]}" "| [${pkgname}](${home}) | ${newdate} | ${desc} |");
  elif [[ "${typ}" == "nixpkgs" ]]; then
    nixpkgentries=("${nixpkgentries[@]}" "| ${pkgname} | ${newdate} |");
  fi
}

function update_readme_pkgs-chromium() {
  replace="$(printf "<!--pkgs-chromium-->")"
  replace="$(printf "%s\n| Package | Last Update | Description |" "${replace}")"
  replace="$(printf "%s\n| ------- | ----------- | ----------- |" "${replace}")"
  d="$(nix eval --raw -f "${metadata}" rev)"
  p="chromium | $d | chromium (ozone) (wayland)"
  replace="$(printf "%s\n%s\n" "${replace}" "${p}")"
  replace="$(printf "%s\n<!--pkgs-chromium-->" "${replace}")"

  rg --multiline "(?s)(.*)<!--pkgs-chromium-->(.*)<!--pkgs-chromium-->(.*)" "README.md" \
    --replace "\$1${replace}\$3" \
      > README2.md; mv README2.md README.md
}
function update_readme_pkgs-wayland() {
  replace="$(printf "<!--pkgs-wayland-->")"
  replace="$(printf "%s\n| Package | Last Update | Description |" "${replace}")"
  replace="$(printf "%s\n| ------- | ----------- | ----------- |" "${replace}")"
  for p in "${pkgentries[@]}"; do
    replace="$(printf "%s\n%s\n" "${replace}" "${p}")"
  done
  replace="$(printf "%s\n<!--pkgs-wayland-->" "${replace}")"

  rg --multiline "(?s)(.*)<!--pkgs-wayland-->(.*)<!--pkgs-wayland-->(.*)" "README.md" \
    --replace "\$1${replace}\$3" \
      > README2.md; mv README2.md README.md
}

function update_readme_nixpkgs() {
  replace="$(printf "<!--nixpkgs-->")"
  replace="$(printf "%s\n| Channel | Last Channel Commit Time |" "${replace}")"
  replace="$(printf "%s\n| ------- | ------------------------ |" "${replace}")"
  for p in "${nixpkgentries[@]}"; do
    replace="$(printf "%s\n%s\n" "${replace}" "${p}")"
  done
  replace="$(printf "%s\n<!--nixpkgs-->" "${replace}")"
  set -x

  rg --multiline '(?s)(.*)<!--nixpkgs-->(.*)<!--nixpkgs-->(.*)' "README.md" \
    --replace "\$1${replace}\$3" \
      > README2.md; mv README2.md README.md
}

function cache_build() {
  cachix push -w "${cache}" &
  CACHIX_PID="$!"
  trap "kill ${CACHIX_PID}" EXIT

  nix-build build.nix \
    --no-out-link --keep-going \
    --attr "${1}" \
    | cachix push "${cache}"
}

function run() {
  for p in nixpkgs/*; do
    update "nixpkgs" "${p}"
  done

  for p in pkgs-wayland/*; do
    update "pkgs-wayland" "${p}"
  done

  # TODO: why is the set necessary?
  set +e; version="$(git ls-remote --tag https://github.com/chromium/chromium | cut -d'	' -f2 | \
    rg ".*/(\d+\.\d+\.\d+\.\d+)" -r '$1' | sort -hr | head -1)"; set -e

  echo "{ version = \"${version}\"; }" > "./pkgs-chromium/chromium-git/metadata.nix"
  if [[ ! -f "pkgs-chromium/chromium-git/vendor-${version}.nix" ]]; then
    (cd pkgs-chromium/chromium-git; ./mk-vendor-file.pl "${version}";)
  fi

  cache_build "pkgs-wayland"
  cache_build "pkgs-chromium"

  update_readme_nixpkgs
  update_readme_pkgs-chromium
  update_readme_pkgs-wayland
}

run

