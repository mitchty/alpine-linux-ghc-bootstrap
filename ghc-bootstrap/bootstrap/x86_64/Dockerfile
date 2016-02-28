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
      python \
      pixz

# Install stock bindist for cross compile
env ghc 7.10.3
env arch x86_64
copy ghc-$ghc-$arch-deb8-linux.tar.xz /tmp/ghc.txz
workdir /tmp
run tar xJpf /tmp/ghc.txz
workdir /tmp/ghc-$ghc
run ./configure --prefix=/usr && \
make -j1 install && \
rm -fr /tmp/ghc-$ghc

# HACK unlit/hp2ps gets compiled with stage0 c compiler
# bootstrap cabal and install alex/happy the same way apks are built
# only globally
# env cabal_version 1.22.7.0
# workdir /tmp
# copy cabal-install-$cabal_version.tar.gz /tmp/cabal.tgz
# run tar xzpf /tmp/cabal.tgz && \
#     cd /tmp/cabal-install-$cabal_version && \
#     ./bootstrap.sh --global --no-doc && \
#     cabal update && \
#     cabal install --global alex happy

# build llvm 3.5.2 with the same patches
# as alpine will use, need this for stage2 builds (and eventually arm)
env llvm 3.5.2
workdir /tmp
copy llvm-$llvm.src.tar.xz /tmp/llvm.txz
copy polly-$llvm.src.tar.xz /tmp/polly.txz
copy bootstrap/llvm-3.5.2.sh /tmp/llvm.sh
run tar xJpf /tmp/llvm.txz && \
    tar xJpf /tmp/polly.txz && \
    /tmp/llvm.sh && \
    rm -fr /tmp/llvm-$llvm.src

env tardir /tmp/root
env crosscc musl-gcc

workdir /tmp
copy ghc-$ghc-src.tar.xz /tmp/ghc-src.txz
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
#run exit 1
#copy bootstrap/$arch/build.mk mk/build.mk
copy bootstrap/bootstrap.patch bootstrap.patch
run patch -p1 < bootstrap.patch
run cp mk/build.mk.sample mk/build.mk
run echo "BuildFlavour         = quick-llvm" >> mk/build.mk && \
    echo "INTEGER_LIBRARY      = integer-simple" >> mk/build.mk && \
    echo "HADDOCK_DOCS         = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_HTML   = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_PS     = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_PDF    = NO" >> mk/build.mk
run ./configure \
  --target=$arch-pc-linux-musl \
  --with-gcc=$crosscc \
  --with-ld=ld.gold \
  --with-nm=nm \
  --with-ar=ar \
  --with-ranlib=ranlib \
  --with-readelf=eu-readelf \
  --prefix=/usr
run make -j$(grep -c processor /proc/cpuinfo) || make -j1
run make -j1 install DESTDIR=$tardir

env triple pc-linux-musl
# unlit and hp2ps both build using the stage0, not having luck
# getting the build patched right so for now lets just
# remove and rebuild these c helper programs
run rm $tardir/usr/bin/$arch-$triple-hp2ps $tardir/usr/lib/$arch-$triple-ghc-$ghc/unlit

# remove target prefix from stage2 binaries
# HACK, just build unlit with the cross compiler and move it to /usr/bin in the install dir
workdir /tmp/ghc-$ghc/utils/unlit
run $crosscc unlit.c -o $tardir/usr/lib/$arch-$triple-ghc-$ghc/unlit
run $crosscc unlit.c -o $tardir/usr/bin/unlit

# remove target prefix from stage2 binaries
workdir $tardir/usr/bin
run (for i in $arch-$triple-* ; do ln -s $i ${i#$arch-$triple-} ; done )
copy bootstrap/$arch/settings /tmp/settings
run mv /tmp/settings $(find $tardir -name settings -type f)
run rm -fr $tardir/usr/share/doc

workdir $tardir
# Compress to xz via pixz because xz is normally too
# old for -TN multithreads
run tar -I'pixz -9' -cf /tmp/ghc-$ghc-$arch-$triple.tar.xz .
