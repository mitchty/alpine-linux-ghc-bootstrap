FROM ubuntu:14.04

# NOTE
#
# This Docker file will generate and build a ghc cross compiler for armhf
# with musl libc as the libc in use.
#
# Future enhancements to this build process for i386/arm are in order. Consider
# that a TODO item.
#
# The final result is a tar.gz file in /tmp with the output of:
# make install DESTDIR=/usr
#
# Also note, this is set to use make -j8 to speed things along. Every run
# of this container will yield a different result unfortunately.
#
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

ENV HOME /root

WORKDIR /root

ENV bootstrap_ghc_ver 7.10.3
ENV happy_ver 1.19.5
ENV alex_ver 3.1.4
ENV cabal_ver 1.20
# ARM related, wip
#ENV musl_triple arm-linux-musleabihf
#ENV arch arm
#ENV confflags "--with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16"
#ENV cross_triple armhf-pc-linux
# x86_64
ENV musl_triple x86_64-linux-musl
ENV arch x86_64
ENV confflags ""
ENV cross_triple x86_64-pc-linux
ENV ghc_path /opt/ghc/$bootstrap_ghc_ver/bin
ENV happy_path /opt/happy/$happy_ver/bin
ENV alex_path /opt/alex/$alex_ver/bin
ENV cabal_path /opt/cabal/$cabal_ver/bin
ENV cross_base /opt/cross
ENV crossmusl_tmp /tmp/musl-cross
ENV ghc_src_dir $cross_base/src/ghc
ENV bootstrap_dir /tmp/bootstrap
ENV cross_ghc_ver 7.10.3
ENV PATH $cross_base/$musl_triple/bin:$ghc_path:$happy_path:$alex_path:$cabal_path:$PATH

RUN \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    apt-get update

RUN apt-get install -y cabal-install-$cabal_ver ghc-$bootstrap_ghc_ver happy-$happy_ver alex-$alex_ver && \
    apt-get install -y git mercurial g++ gcc git autoconf ncurses-dev automake libtool make python bzip2 pixz flex bison cmake libffi6 libffi-dev libxml2-dev libxml2
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -
RUN apt-add-repository -y "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.6 main"
RUN apt-add-repository -y "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.5 main"
RUN apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
RUN apt-get update
RUN apt-get install -y llvm-3.6 llvm-3.5

#xRUN hg clone -r d72695b https://bitbucket.org/GregorR/musl-cross $crossmusl_tmp && \
RUN hg clone https://bitbucket.org/GregorR/musl-cross $crossmusl_tmp && \
    echo "GCC_BUILTIN_PREREQS=yes" >> $crossmusl_tmp/config.sh && \
    echo "ARCH=${arch}" >> $crossmusl_tmp/config.sh && \
    echo "TRIPLE=${musl_triple}" >> $crossmusl_tmp/config.sh && \
    echo "GCC_BOOTSTRAP_CONFFLAGS='${confflags}'" >> $crossmusl_tmp/config.sh && \
    echo "GCC_CONFFLAGS='${confflags}'" >> $crossmusl_tmp/config.sh && \
    echo "BINUTILS_CONFFLAGS='CXXFLAGS=-fpermissive --enable-gold --enable-plugins --disable-werror'" >> $crossmusl_tmp/config.sh && \
    echo "CFLAGS='-g -O2 -fPIC -DPIC'" >> $crossmusl_tmp/config.sh && \
    echo "CPPFLAGS='-fPIC -DPIC'" >> $crossmusl_tmp/config.sh && \
    echo "LDFLAGS='-fPIC -DPIC'" >> $crossmusl_tmp/config.sh
COPY gmplib-url.patch $crossmusl_tmp/gmplib-url.patch
COPY gmplib-url2.patch $crossmusl_tmp/gmplib-url2.patch
RUN cd $crossmusl_tmp && patch -p0 < gmplib-url.patch defs.sh && patch -p0 < gmplib-url2.patch extra/build-gcc-deps.sh && ./build.sh && \
    cd / && rm -fr $crossmusl_tmp

RUN cd /tmp && mkdir -p $ghc_src_dir && curl -L "https://www.haskell.org/ghc/dist/"$cross_ghc_ver"/ghc-"$cross_ghc_ver"-src.tar.xz" | tar xJf - -C $ghc_src_dir

ENV MAKEOPTS=-j6
RUN cd /tmp && curl -L http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz | \
    gunzip -c - | tar xf -
RUN perl -pi -e 's/linux\-uclibc/linux\-musl/g' /tmp/ncurses*/config.sub
RUN cd /tmp/ncurses-5.9 && ./configure --target=$musl_triple --with-gcc=$musl_triple-gcc --with-shared --host=$musl_triple --with-build-cpp=$musl_triple-g++ --prefix=$cross_base/$musl_triple/$musl_triple  --without-debug --without-ada --enable-overwrite CPPFLAGS=-P && \
    make $MAKEOPTS && make && \
    make install
#RUN cd $cross_base/$musl_triple/$musl_triple/include/ncurses && cp *.h ..

ENV LD_LIBRARY_PATH $cross_base/$musl_triple/$musl_triple/lib:$LD_LIBRARY_PATH
ENV ghc_src $ghc_src_dir/ghc-$cross_ghc_ver
ENV unlit_dir $ghc_src/utils/unlit
ENV settings_file $bootstrap_dir/lib/$cross_triple-musl-ghc-$bootstrap_ghc_ver/settings

WORKDIR $ghc_src
COPY build.mk $ghc_src/mk/build.mk
COPY ghc-0001-no-dllsplit.patch $ghc_src
COPY ghc-0002-llvm-3.6.patch $ghc_src
RUN patch -p1 ghc-0002-llvm-3.6.patch && patch -p1 < ghc-0001-no-dllsplit.patch
#RUN sed 's/#.* = quick-cross/BuildFlavour = quick-cross/' mk/build.mk.sample > mk/build.mk
RUN ./configure --target=$musl_triple \
    --prefix=/usr \
    --with-opt=opt-3.6 \
    --with-llc=llc-3.6 \
    --with-ld=ld.gold

RUN make ${MAKEOPTS} && make ${MAKEOPTS}

ENV unlit_dir $ghc_src/utils/unlit
ENV settings_file $bootstrap_dir/usr/lib/$cross_triple-musl-ghc-$bootstrap_ghc_ver/settings

WORKDIR $unlit_dir
RUN rm -fr dist && make GHC=$ghc_src/inplace/bin/ghc-stage1

WORKDIR $ghc_src
RUN make install -j1 DESTDIR=$bootstrap_dir

WORKDIR $bootstrap_dir/usr/bin
RUN $(for x in $(echo *); do y=$(echo $x | sed -e 's|.*musl-||'); ln -sf ${x} ${y}; done) && \
    perl -pi -e 's/.*C compiler command.*/ \(\"C compiler command\"\, \"gcc\"\)\,/' $settings_file && \
    perl -pi -e 's/.*Haskell CPP command.*/ \(\"Haskell CPP command\"\,\"gcc\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld command.*/ \(\"ld command\"\,\"ld\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ar command.*/ \(\"ar command\"\,\"ar\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld flags.*/ \(\"ld flags\"\,\"\-nopie\"\)\,/' $settings_file

WORKDIR $bootstrap_dir
RUN tar -Ipixz -cf /tmp/ghc-$musl_triple-$cross_ghc_ver.tar.xz . && \
    rm -fr $bootstrap_dir
