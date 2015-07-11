#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
export dir=$(cd "$(dirname "$0")"; pwd)
export bootstrap_docker=alpine-ghc-bootstrap
export bootstrap_xz=ghc-x86_64-linux-musl-7.10.1.tar.xz
set -e

# Builds a bootstrap ghc cross compiler.
#
# Essentially its the result of make install DESTDIR=/tmp/bootstrap
# for a normal build with --prefix=/usr
docker build -t "${bootstrap_docker}" .
docker run -a stdout "${bootstrap_docker}:latest" /bin/cat "/tmp/${bootstrap_xz}" > "${dir}/${bootstrap_xz}"
docker rmi -t "${bootstrap_docker}"
