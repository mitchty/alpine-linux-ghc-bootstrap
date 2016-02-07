# WIP: simplify generating a bootstrap compiler
from debian:8.0

# all needed packages for compiling
run apt-get update && \
    apt-get install -y \
      binutils-gold \
      musl-tools \
      build-essential \
      wget \
      curl \
      libncurses-dev \
      autoconf \
      elfutils \
      libgmp-dev \
      zlib1g-dev \
      git \
      libtool \
      pkg-config \
      libffi-dev \
      cmake \
      g++ \
      python

# build llvm 3.6 with the same patches
# as alpine will use, need this for stage2 builds (and eventually arm)
env llvm 3.6.2
workdir /tmp
copy llvm-$llvm.src.tar.xz /tmp/llvm.txz
copy polly-$llvm.src.tar.xz /tmp/polly.txz
run tar xJpf /tmp/llvm.txz
run tar xJpf /tmp/polly.txz
copy llvm-0001-fix-shared-build.patch /tmp/llvm-0001-fix-shared-build.patch
copy llvm-0002-musl-triple.patch /tmp/llvm-0002-musl-triple.patch
copy llvm-0003-musl-hacks.patch /tmp/llvm-0003-musl-hacks.patch
copy llvm.sh /tmp/llvm.sh
run /tmp/llvm.sh

workdir /tmp

# Install stock bindist for cross compile
env ghc 7.10.3
copy ghc-$ghc-x86_64-deb8-linux.tar.xz /tmp/ghc.txz
run tar xJpf /tmp/ghc.txz
workdir /tmp/ghc-$ghc
run ./configure --prefix=/usr && make -j1 install
run rm -fr /tmp/ghc-$ghc

# bootstrap cabal and install alex/happy the same way apks are built
# only globally
env cabal_version 1.22.7.0
workdir /tmp
copy cabal-install-$cabal_version.tar.gz /tmp/cabal.tgz
run tar xzpf /tmp/cabal.tgz
workdir /tmp/cabal-install-$cabal_version
run ./bootstrap.sh --global --no-doc
run cabal update
run cabal install --global alex happy

# bootstrap ghc then prep for stage 2 with llvm 3.6
copy ghc-$ghc-src.tar.xz /tmp/ghc-src.txz
workdir /tmp
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
copy build.mk.stage2 mk/build.mk
copy ghc-0001-no-dllsplit.patch ghc-0001-no-dllsplit.patch
copy ghc-0002-llvm-3.6.patch ghc-0002-llvm-3.6.patch
copy bootstrap.patch bootstrap.patch
run patch -p1 < ghc-0001-no-dllsplit.patch
run patch -p1 < ghc-0002-llvm-3.6.patch
run patch -p1 < bootstrap.patch
run ./configure \
  --target=x86_64-pc-linux-musl \
  --with-gcc=musl-gcc \
  --with-ld=ld.gold \
  --with-nm=nm \
  --with-ar=ar \
  --with-ranlib=ranlib \
  --with-readelf=eu-readelf \
  --prefix=/usr
run make -j$(grep -c processor /proc/cpuinfo) || make -j1

# HACK unlit/hp2ps gets compiled with stage0 c compiler
workdir /tmp/ghc-$ghc/utils/unlit
run rm -fr dist && make GHC=/tmp/ghc-$ghc/inplace/bin/ghc-stage1
workdir /tmp/ghc-$ghc/utils/hp2ps
run rm -fr dist && make GHC=/tmp/ghc-$ghc/inplace/bin/ghc-stage1
env tardir /tmp/root
workdir /tmp/ghc-$ghc
run make -j1 install DESTDIR=$tardir

# remove target prefix from stage2 binaries
workdir $tardir/usr/bin
run (for i in x86_64-pc-linux-musl-* ; do ln -s $i ${i#x86_64-pc-linux-musl-} ; done )
workdir $tardir
copy settings /tmp/settings
run mv /tmp/settings $(find $workdir -name settings -type f)
run tar cvfJ /tmp/ghc-$ghc-x86_64-unknown-linux-musl.tar.xz .
