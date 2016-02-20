from alpine-ghc-bootstrap:base

# Build our x86_64 ghc with musl-gcc
workdir /tmp
run rm -fr /tmp/ghc-$ghc
run tar xJpf /tmp/ghc-src.txz
workdir /tmp/ghc-$ghc
copy bootstrap/build.mk.x86_64 mk/build.mk
copy ghc-0001-no-dllsplit.patch ghc-0001-no-dllsplit.patch
copy ghc-0002-llvm-3.6.patch ghc-0002-llvm-3.6.patch
copy bootstrap/bootstrap.patch bootstrap.patch
run patch -p1 < ghc-0001-no-dllsplit.patch
run patch -p1 < ghc-0002-llvm-3.6.patch
run patch -p1 < bootstrap.patch
run perl -pi -e 's|LlvmVersion=3.5|LlvmVersion=3.6|g' configure.ac
run ./boot
run ./configure \
  --target=$arch-pc-linux-musl \
  --with-gcc=musl-gcc \
  --with-ld=ld.gold \
  --with-nm=nm \
  --with-ar=ar \
  --with-ranlib=ranlib \
  --with-readelf=eu-readelf \
  --prefix=/usr \
  --with-opt=opt \
  --with-llc=llc
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
