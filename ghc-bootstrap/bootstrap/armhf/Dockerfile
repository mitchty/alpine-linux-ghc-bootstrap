from alpine-ghc-bootstrap:base
run apt-get -y install bison flex

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

# add cross toolchain to PATH
env PATH /usr/arm-linux-musleabihf/bin:$PATH

# rebuild ghc the same way as we did x86_64, well mostly the same
# way... ish...
run rm -fr /tmp/ghc-$ghc
# bootstrap ghc then prep for stage 2 with llvm 3.6
copy ghc-$ghc-src.tar.xz /tmp/ghc-src.txz
workdir /tmp
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
copy bootstrap/build.mk.arm mk/build.mk
copy bootstrap/bootstrap-all.patch bootstrap.patch
run patch -p1 < bootstrap.patch
run ./boot
run ./configure \
  --target=arm-linux-musleabihf \
  --prefix=/usr \
  --with-opt=opt \
  --with-llc=llc
run make -j$(grep -c processor /proc/cpuinfo) || /bin/true

env tardir /tmp/root

run make -j1 install STRIP_CMD=arm-linux-musleabihf-strip DESTDIR=$tardir

# Not having good luck compiling this manually, don't need it to build ghc
# on the target so screw it, remove it.
run rm $tardir/usr/bin/arm-unknown-linux-musleabihf-hp2ps $tardir/usr/lib/arm-unknown-linux-musleabihf-ghc-7.10.3/unlit

# remove target prefix from stage2 binaries
# HACK, just build unlit with the cross compiler and move it to /usr/bin in the install dir
workdir /tmp/ghc-$ghc/utils/unlit
run arm-linux-musleabihf-gcc unlit.c -o $tardir/usr/lib/arm-unknown-linux-musleabihf-ghc-7.10.3/unlit
run arm-linux-musleabihf-gcc unlit.c -o $tardir/usr/bin/unlit

workdir $tardir/usr/bin
run (for i in arm-unknown-linux-musleabihf-* ; do ln -s $i ${i#arm-unknown-linux-musleabihf-} ; done ; exit 0)
workdir $tardir
copy bootstrap/settings.arm /tmp/settings
run mv /tmp/settings $(find . -name settings -type f)
run rm -fr $tardir/usr/share/doc

workdir $tardir
# Compress to xz via pixz because xz is normally too
# old for -TN multithreads
run tar -I'pixz -9' -cf /tmp/ghc-$ghc-arm-unknown-linux-musleabihf.tar.xz .
