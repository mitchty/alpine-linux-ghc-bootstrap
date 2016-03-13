# Mostly self contained setup to build a stage2 ghc for musl
from debian:8.0

# Install stock bindist for cross compile
env ghc 7.10.3
env arch x86_64
env llvm 3.5.2

# Get all the sources for compiling
add https://downloads.haskell.org/~ghc/$ghc/ghc-$ghc-$arch-deb8-linux.tar.xz /tmp/
add https://downloads.haskell.org/~ghc/$ghc/ghc-$ghc-src.tar.xz /tmp/
add http://llvm.org/releases/$llvm/llvm-$llvm.src.tar.xz /tmp/
add http://llvm.org/releases/$llvm/polly-$llvm.src.tar.xz /tmp/

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
      pixz \
      openssl \
      bison \
      flex

# Make sure the cksums match
copy bootstrap/cksums /tmp
run cd /tmp && openssl sha1 ghc-$ghc-$arch-deb8-linux.tar.xz ghc-$ghc-src.tar.xz llvm-$llvm.src.tar.xz polly-$llvm.src.tar.xz > cksums.dl && diff /tmp/cksums*

workdir /tmp
run tar xJpf /tmp/ghc-$ghc-$arch-deb8-linux.tar.xz
workdir /tmp/ghc-$ghc
run ./configure --prefix=/usr && \
    make -j1 install && \
    rm -fr /tmp/ghc-$ghc

workdir /tmp
copy bootstrap/llvm-3.5.2.sh /tmp/llvm.sh
run tar xJpf /tmp/llvm-$llvm.src.tar.xz && \
    tar xJpf /tmp/polly-$llvm.src.tar.xz && \
    /tmp/llvm.sh && \
    rm -fr /tmp/llvm-$llvm.src

# First up, install/compile the cross compiler with musl libc
# armv7 hard float cross compiler, we basically rebuild ghc again here with
# the cross compiler, and the llvm we built for x86_64 as well
workdir /tmp
run git clone --depth 1 https://github.com/GregorR/musl-cross.git musl-cross
workdir /tmp/musl-cross
run echo GCC_BUILTIN_PREREQS=yes >> config.sh && \
    echo ARCH=arm >> config.sh && \
    echo TRIPLE=arm-linux-musleabihf >> config.sh && \
    echo GCC_BOOTSTRAP_CONFFLAGS=\"--with-arch=armv6 --with-float=hard --with-fpu=vfp\" >> config.sh && \
    echo GCC_CONFFLAGS=\"--with-arch=armv6 --with-float=hard --with-fpu=vfp\" >> config.sh && \
    echo GCC_STAGE1_NOOPT=1 >> config.sh && \
    echo CC_BASE_PREFIX=/usr >> config.sh && \
    echo MAKEFLAGS=-j$(grep -c processor /proc/cpuinfo) >> config.sh && \
    echo "BINUTILS_CONFFLAGS='CXXFLAGS=-fpermissive --enable-gold --enable-plugins --disable-werror'" >> config.sh && \
    echo "CFLAGS='-g -O2 -fPIC -DPIC'" >> config.sh && \
    echo "CPPFLAGS='-fPIC -DPIC'" >> config.sh && \
    echo "LDFLAGS='-fPIC -DPIC'" >> config.sh
copy bootstrap/gmpurl.patch gmpurl.patch
run patch -p1 < gmpurl.patch
run ./build.sh

env tardir /tmp/root
env crosscc arm-linux-musleabihf-gcc
env target arm-linux-musleabihf

# add cross toolchain to PATH
env PATH /usr/$target/bin:$PATH

workdir /tmp
run tar xJpf /tmp/ghc-$ghc-src.tar.xz
workdir /tmp/ghc-$ghc
copy bootstrap/$arch/bootstrap.patch bootstrap.patch
run patch -p1 < bootstrap.patch && \
    cp mk/build.mk.sample mk/build.mk && \
    echo "BuildFlavour         = cross-llvm" >> mk/build.mk && \
    echo "INTEGER_LIBRARY      = integer-simple" >> mk/build.mk && \
    echo "HADDOCK_DOCS         = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_HTML   = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_PS     = NO" >> mk/build.mk && \
    echo "BUILD_DOCBOOK_PDF    = NO" >> mk/build.mk && \
    ./configure \
  --target=$target \
  --with-gcc=$crosscc \
  --with-ld=ld.gold \
  --with-nm=nm \
  --with-ar=ar \
  --with-ranlib=ranlib \
  --with-readelf=eu-readelf \
  --prefix=/usr
#    echo "UseSystemLibFFI      = NO" >> mk/build.mk && \

run make -j$(grep -c processor /proc/cpuinfo) || make -j1
run make -j1 install STRIP_CMD=$target-strip DESTDIR=$tardir

env triple arm-unknown-linux-musleabihf
# unlit and hp2ps both build using the stage0, not having luck
# getting the build patched right so for now lets just
# remove and rebuild these c helper programs
run rm $tardir/usr/bin/$triple-hp2ps $tardir/usr/lib/$triple-ghc-$ghc/unlit

# remove target prefix from stage2 binaries
# HACK, just build unlit with the cross compiler and move it to /usr/bin in the install dir
workdir /tmp/ghc-$ghc/utils/unlit
run $crosscc unlit.c -o $tardir/usr/lib/$triple-ghc-$ghc/unlit
run $crosscc unlit.c -o $tardir/usr/bin/unlit

# remove target prefix from stage2 binaries
workdir $tardir/usr/bin
run (for i in $triple-* ; do ln -s $i ${i#$triple-} ; done )
copy bootstrap/$arch/settings /tmp/settings
run mv /tmp/settings $(find $tardir -name settings -type f)
run rm -fr $tardir/usr/share/doc

workdir $tardir
# Compress to xz via pixz because xz is normally too
# old for -TN multithreads
run tar -I'pixz -9' -cf /tmp/ghc-$ghc-$triple.tar.xz .
