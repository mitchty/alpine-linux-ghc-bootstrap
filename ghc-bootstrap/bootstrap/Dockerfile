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
      python \
      pixz

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
copy bootstrap/llvm.sh /tmp/llvm.sh
run /tmp/llvm.sh

workdir /tmp

# Install stock bindist for cross compile, we use this
# to build a 7.10.3 compiler that includes the 3.6 patches.
env ghc 7.10.3
env arch x86_64
copy ghc-$ghc-$arch-deb8-linux.tar.xz /tmp/ghc.txz
run tar xJpf /tmp/ghc.txz
workdir /tmp/ghc-$ghc
run ./configure --prefix=/tmp/native && make -j1 install
run rm -fr /tmp/ghc-$ghc

env PATH $PATH:/tmp/native/bin

# HACK unlit/hp2ps gets compiled with stage0 c compiler
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
copy bootstrap/build.mk mk/build.mk
copy ghc-0001-no-dllsplit.patch ghc-0001-no-dllsplit.patch
copy ghc-0002-llvm-3.6.patch ghc-0002-llvm-3.6.patch
run patch -p1 < ghc-0001-no-dllsplit.patch
run patch -p1 < ghc-0002-llvm-3.6.patch
run ./configure \
  --with-ld=ld.gold \
  --with-readelf=eu-readelf \
  --prefix=/usr
run make -j$(grep -c processor /proc/cpuinfo) || make -j1
run make -j1 install

workdir /tmp
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
copy bootstrap/build.mk mk/build.mk
copy ghc-0001-no-dllsplit.patch ghc-0001-no-dllsplit.patch
copy ghc-0002-llvm-3.6.patch ghc-0002-llvm-3.6.patch
copy bootstrap/bootstrap.patch bootstrap.patch
run patch -p1 < ghc-0001-no-dllsplit.patch
run patch -p1 < ghc-0002-llvm-3.6.patch
run patch -p1 < bootstrap.patch
run ./configure \
  --target=$arch-pc-linux-musl \
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
run (for i in $arch-pc-linux-musl-* ; do ln -s $i ${i#$arch-pc-linux-musl-} ; done )
workdir $tardir
copy bootstrap/settings /tmp/settings
run mv /tmp/settings $(find $workdir -name settings -type f)

# Compress to xz via pixz because xz is normally too
# old for -TN multithreads
run tar -I'pixz -9' -cf /tmp/ghc-$ghc-$arch-unknown-linux-musl.tar.xz .

# armv7 hard float cross compiler, we basically rebuild ghc again here with
# the cross compiler, and the llvm we built for x86_64 as well
workdir /tmp
run git clone --depth 1 https://github.com/GregorR/musl-cross.git musl-cross
workdir /tmp/musl-cross
run apt-get -y install bison flex
run echo GCC_BUILTIN_PREREQS=yes >> config.sh && \
    echo ARCH=arm >> config.sh && \
    echo TRIPLE=arm-linux-musleabihf >> config.sh && \
    echo GCC_BOOTSTRAP_CONFFLAGS=\"--with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16\" >> config.sh && \
    echo GCC_CONFFLAGS=\"--with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16\" >> config.sh && \
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

env PATH /usr/arm-linux-musleabihf/bin:$PATH
# rebuild ghc the same way as we did x86_64, well mostly the same
# way... ish...
run rm -fr /tmp/ghc-ghc
# bootstrap ghc then prep for stage 2 with llvm 3.6
copy ghc-$ghc-src.tar.xz /tmp/ghc-src.txz
workdir /tmp
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
#copy bootstrap/build.mk mk/build.mk
copy ghc-0001-no-dllsplit.patch ghc-0001-no-dllsplit.patch
copy ghc-0002-llvm-3.6.patch ghc-0002-llvm-3.6.patch
copy bootstrap/bootstrap.patch bootstrap.patch
run patch -p1 < ghc-0001-no-dllsplit.patch
run patch -p1 < ghc-0002-llvm-3.6.patch
run patch -p1 < bootstrap.patch
run cp mk/build.mk.sample mk/build.mk
run echo "BuildFlavour = quick-cross" >> mk/build.mk
run echo "INTEGER_LIBRARY=integer-simple" >> mk/build.mk
run echo "V=1" >> mk/build.mk
run ./configure \
  --target=arm-linux-musleabihf \
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

# WIP
# # remove target prefix from stage2 binaries
# workdir $tardir/usr/bin
# run (for i in $arch-pc-linux-musl-* ; do ln -s $i ${i#$arch-pc-linux-musl-} ; done )
# workdir $tardir
# copy bootstrap/settings /tmp/settings
# run mv /tmp/settings $(find $workdir -name settings -type f)

# # Compress to xz via pixz because xz is normally too
# # old for -TN multithreads
# run tar -I'pixz -9' -cf /tmp/ghc-$ghc-$arch-unknown-linux-musl.tar.xz .
