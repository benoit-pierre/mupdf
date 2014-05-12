#! /bin/bash

set -x

[ -r "$HOME/.makepkg.conf" ] && . "$HOME/.makepkg.conf"

cd "$(dirname "$0")" &&
. ./PKGBUILD &&
pkgver="$(git describe --tags --match='[0-9].[0-9]' | sed -n '/^[0-9][.0-9a-z-]\+$/{s/\([.0-9]\)a$/\1_a/;s/-/./g;p;Q0};Q1')" &&
src="src/$pkgname-$pkgver-source" &&
rm -rf src pkg &&
mkdir -p "$src" &&
cp -l "$pkgname".{desktop,install,xpm} *.patch src/ &&
sed "s/^pkgver=.*\$/pkgver=$pkgver/" PKGBUILD >PKGBUILD.tmp &&
(cd "$OLDPWD" && git ls-files -z | xargs -0 cp -a --no-dereference --parents --target-directory="$OLDPWD/$src") &&
(cd src && prepare) &&
export PACKAGER="${PACKAGER:-`git config user.name` <`git config user.email`>}" &&
makepkg --noextract --force -p PKGBUILD.tmp &&
rm -rf src pkg PKGBUILD.tmp &&
sudo pacman -U --noconfirm "$pkgname-$pkgver-$pkgrel-`uname -m`${PKGEXT:-.pkg.tar.xz}"

