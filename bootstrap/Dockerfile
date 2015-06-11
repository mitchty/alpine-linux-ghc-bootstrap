FROM ubuntu:14.04

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

ENV HOME /root

WORKDIR /root

# versions of crap we need to cross compile
ENV bootstrap_ghc_ver 7.10.1
ENV happy_ver 1.19.5
ENV alex_ver 3.1.4
ENV cabal_ver 1.20
ENV musl_triple x86_64-linux-musl
ENV ghc_path /opt/ghc/$bootstrap_ghc_ver/bin
ENV happy_path /opt/happy/$happy_ver/bin
ENV alex_path /opt/alex/$alex_ver/bin
ENV cross_base /opt/cross
ENV crossmusl_tmp /tmp/musl-cross
ENV ghc_src_dir $cross_base/src/ghc
ENV target_stage2_ghc_dir /usr/local
ENV cross_ghc_ver 7.10.1
# export PATH=/opt/cross/x86_64-linux-musl/bin:/opt/ghc/7.10.1/bin:/opt/happy/1.19.5/bin:/opt/alex/3.1.4/bin:$PATH
ENV PATH=$cross_base/$musl_triple/bin:$ghc_path:$happy_path:$alex_path:$PATH

# make our ubuntu env... not suck
RUN \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    apt-get update && \
    apt-get install -y cabal-install-$cabal_ver ghc-$bootstrap_ghc_ver happy-$happy_ver alex-$alex_ver && \
    apt-get install -y git mercurial g++ gcc git autoconf ncurses-dev automake libtool make python bzip2 pixz

# gcc musl libc cross compiler installs to /opt/cross so we'll just use that
# cause IDGAF where this is located
# Note, only building x86_64 for now, research arm later.
RUN hg clone https://bitbucket.org/GregorR/musl-cross $crossmusl_tmp
RUN echo "GCC_BUILTIN_PREREQS=yes" >> $crossmusl_tmp/config.sh
RUN echo "ARCH=x86_64" >> $crossmusl_tmp/config.sh
RUN cd $crossmusl_tmp && ./build.sh

# ncurses needs to be in our cross compiler setup or terminfo won't build
RUN cd /tmp && curl -L http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz | \
    gunzip -c - | tar xf -

# musl libc isn't recognized by the default autoconf script for ncurses
# cause 5.9 is too damn old, so take over the uclibc versions and give a
# big middle finger to old autoconf crap
RUN perl -pi -e 's/linux\-uclibc/linux\-musl/g' /tmp/ncurses*/config.sub
RUN cd /tmp/ncurses-5.9 && ./configure --target=$musl_triple --with-gcc=$musl_triple-gcc --with-shared --host=$musl_triple --with-build-cpp=$musl_triple-g++ --prefix=$cross_base/$musl_triple/$musl_triple && \
    make && \
    make install

# ncurses installs headers to include/ncurses, /sigh
# so copy those headers up a dir cause who cares about this temp crap
# its only to get us to our end goal
RUN cd $cross_base/$musl_triple/$musl_triple/include/ncurses && cp *.h ..

# the wiki said so so I do
RUN git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/

# get our ghc version to build source code
RUN git clone -b ghc-$cross_ghc_ver-release --recursive git://git.haskell.org/ghc.git $ghc_src_dir

# need it or we can't link libcurses.5.so during build
ENV LD_LIBRARY_PATH $cross_base/$musl_triple/$musl_triple/lib:$LD_LIBRARY_PATH

# build our stage2 for our target
# -fPIC/SRC_CC_OPTS may not be needed, need to validate it yet
# also, don't build any documentation cause who gives a shit about
# that for temporary crap
RUN cd $ghc_src_dir && perl boot
ENV buildmk $ghc_src_dir/mk/build.mk
RUN echo "SRC_HC_OPTS = -H64m -O0" > $buildmk && \
    echo "GhcStage1HcOpts = -O" >> $buildmk && \
    echo "GhcStage2HcOpts = -O0 -fPIC" >> $buildmk && \
    echo "GhcLibHcOpts = -O -fPIC" >> $buildmk && \
    echo "SplitObjs = NO" >> $buildmk && \
    echo "SRC_CC_OPTS = -fPIC" >> $buildmk && \
    echo "HADDOCK_DOCS = NO" >> $buildmk && \
    echo "BUILD_DOCBOOK_HTML = NO" >> $buildmk && \
    echo "BUILD_DOCBOOK_PS   = NO" >> $buildmk && \
    echo "BUILD_DOCBOOK_PDF  = NO" >> $buildmk && \
    echo "INTEGER_LIBRARY    = integer-simple" >> $buildmk && \
    echo "DYNAMIC_BY_DEFAULT   = NO" >> $buildmk && \
    echo "DYNAMIC_GHC_PROGRAMS = NO" >> $buildmk
RUN cd $ghc_src_dir && ./configure --with-gcc=$musl_triple-gcc \
     --target=$musl_triple \
     --enable-unregisterised

# build our stage2
RUN cd $ghc_src_dir && make && make install

# so unlit which is a c program btw appears to be compiled with the host
# ghc and not the ghc stage1 like you'd think would happen for a stage2
# cross compile, so... fix it so that happy/alex will build later
#
# TODO: is this a BUG in the ghc cross compile setup?
#
ENV unlit_dir $ghc_src_dir/utils/unlit
RUN cd $unlit_dir && rm -fr dist && \
    cd $unlit_dir && make GHC=$ghc_src_dir/inplace/bin/ghc-stage1

# copy our rebuilt unlit binary into our target directory
RUN cp $unlit_dir/dist/build/tmp/unlit $target_stage2_ghc_dir/lib/x86_64-pc-linux-musl-ghc-$bootstrap_ghc_ver

# right so we're good with that crap, now we link the stage2 triple binaries
# into their "normal" counterparts, that is basically ln -s x86_64-linux-musl-blah blah
# so that if ghc should be called, its called with the right binary name you'd
# normally use
RUN cd $target_stage2_ghc_dir/bin && \
    $(for x in $(echo *); do y=$(echo $x | sed -e 's|.*musl-||'); ln -s ${x} ${y}; done)

# ok cool, now clean up the settings file to allow us to build ghc
# from this stage2 build on our target of alpine linux
#
# Note: we disable position independent code cause reasons
# reasons being the stage2 build we built can't determine the difference
# between a library an not, so we'll just hack around it for now
#
# This is JUST to natively build our compiler on alpine linux so whatever
#
# Also, we're changing the ghc settings file to not use the cross compiler
# binaries but the "normal" gcc/ld/ar on the native install
#
# One more thing, but also changing gcc/ld flags to not use PIC code
#
# I'm not 100% why yet but it might be related to alpine linux grsecurity stuff.
# LONG story short, ld will try to treat libraries as executables and say:
# recompile with -fPIC, which doesn't work, so whatever who gives a shit work
# around it.
#
# Regardless, if we don't do this we can't build ghc, so do it.
ENV settings_file $target_stage2_ghc_dir/lib/x86_64-pc-linux-musl-ghc-$bootstrap_ghc_ver/settings
RUN perl -pi -e 's/.*C compiler command.*/ \(\"C compiler command\"\, \"gcc\"\)\,/' $settings_file && \
    perl -pi -e 's/.*C compiler flags.*/ \(\"C compiler flags\"\, \"-fno-stack-protector -nopie\"\)\,/' $settings_file && \
    perl -pi -e 's/.*Haskell CPP command.*/ \(\"Haskell CPP command\"\,\"gcc\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld command.*/ \(\"ld command\"\,\"ld\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld flags.*/ \(\"ld flags\"\, \"-fno-PIC\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ar command.*/ \(\"ar command\"\,\"ar\"\)\,/' $settings_file

# Ok so tar/xz the stage2 compiler for use on our destination
RUN cd / && tar -Ipixz -cf /tmp/ghc-$musl_triple-$cross_ghc_ver.tar.xz $target_stage2_ghc_dir

# scp /tmp/ghc-$musl_triple-$cross_ghc_ver.tar.xz mitch@10.11.12.2:/nexus/afp/Developer/Vagrant

CMD ["bash"]
