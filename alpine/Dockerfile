FROM alpine:3.1

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

# This isn't perfect, but its just an intermediate box for building the
# actual apks later
RUN apk add --update \
    curl \
    xz \
    alpine-sdk \
    perl \
    file \
    gmp-dev \
    openssh \
    openssl \
    python \
    automake \
    autoconf \
    libtool \
    make \
    g++ \
    ncurses-dev \
    bzip2 \
    git \
    mercurial \
    bash \
    libffi-dev \
    libxslt-dev \
    llvm-dev \
    zlib-dev \
    paxctl

# checkout ghc source release
RUN git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/ && \
    git clone -b ghc-7.10.1-release --recursive git://git.haskell.org/ghc.git /tmp/ghc

RUN touch /tmp && echo 0

# get the phase2 compiler we built earlier, its in /usr/local
RUN cd / && curl -L 'http://10.11.12.2:8000/ghc-x86_64-linux-musl-7.10.1.tar.xz' | \
    xz -c -d - | tar xf -

ENV PATH $PATH:/usr/local

ENV settings_file /usr/local/lib/x86_64-pc-linux-musl-ghc-7.10.1/settings
RUN perl -pi -e 's/.*C compiler flags.*/ \(\"C compiler flags\"\, \"-fno-stack-protector -nopie\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld flags.*/ \(\"ld flags\"\, \"-fnoPIC\"\)\,/' $settings_file

# Turn off PaX for ghc, or it can't call ld to relocate .text symbols and
# will send you down rabbit holes regarding -fPIC nonsense
RUN paxctl -cm /usr/local/lib/x86_64-pc-linux-musl-ghc-7.10.1/bin/ghc

# Just make sure we can build basic stuff quick.
RUN cd /tmp/ghc/bindisttest && ghc --make HelloWorld.lhs && ./HelloWorld && \
    ghc -optl -static --make HelloWorld.lhs && ./HelloWorld && \
    ghc -optl -static -fllvm --make HelloWorld.lhs && ./HelloWorld && \
    rm HelloWorld

# Right, so need to build cabal+cabal-install+happy+alex to build our real ghc

# First up, snag cabal-install and use bootstrap.sh to install to the global
# package db

# otherwise haddock is expected to exist, meh to that for now
ENV NO_DOCUMENTATION obviously

RUN cd /tmp && curl -L "https://www.haskell.org/cabal/release/cabal-install-1.22.3.0/cabal-install-1.22.3.0.tar.gz" | gunzip -c - | tar xf -
RUN cd /tmp/cabal-install-1.22.3.0 && ./bootstrap.sh --global

# pimp, we have cabal now
ENV PATH $PATH:/root/.cabal/bin

# and install happy+alex so we can build ghc
RUN cabal update && cabal install happy alex

COPY build.mk /tmp/ghc/mk/build.mk
RUN cd /tmp/ghc && perl boot

# stick this in /usr/local alongside the stage2 ghc for now, we'll use this
# compiler to build our actual ghc apk
RUN cd /tmp/ghc && ./configure
RUN cd /tmp/ghc && make
RUN cd /tmp/ghc && make install

# ok nuke our user .cabal/.ghc dirs from the stage2 boostrap compiler
RUN rm -fr /root/.cabal /root/.ghc

# Just make sure things still work
RUN cd /tmp/ghc/bindisttest && ghc --make HelloWorld.lhs && ./HelloWorld && \
    ghc -optl -static --make HelloWorld.lhs && ./HelloWorld && \
    ghc -optl -static -fllvm --make HelloWorld.lhs && ./HelloWorld

# Ok rebuild cabal with our now native compiler
RUN cd /tmp/cabal-install-1.22.3.0 && ./bootstrap.sh --global

# Cleanup the old and busted stuff used to get us a native compiler
RUN rm -fr /tmp/cabal-install-1.22.3.0 /tmp/cabal- /tmp/ghc

# right, cool, so lets build our bootstrap apk compiler and cabal at least
# after this is done we'll install this apk into another image and
# build our "real" apk there
# apk build stuff, sort this out later
RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

# setup build user and clone alpine ports
RUN adduser -D $builduser && \
   addgroup $builduser abuild && \
   chgrp abuild /var/cache/distfiles && \
   chmod g+w /var/cache/distfiles && \
   echo 'mitch  ALL=(ALL) ALL' > /etc/sudoers && \
   su -l $builduser -c "git config --global user.name '$username'" && \
   su -l $builduser -c "git config --global user.email '$useremail'" && \
   su -l $builduser -c "git clone git://dev.alpinelinux.org/aports" && \
   su -l $builduser -c "mkdir aports/testing/ghc"

# need to run keygen or abuild whinges
RUN su -l $builduser -c "abuild-keygen -a -i"
COPY APKBUILD /home/build/aports/testing/ghc/APKBUILD

# get checksums
RUN su -l $builduser -c "cd ~/aports/testing/ghc && abuild checksum"

# build the shit, hopefully
RUN su -l $builduser -c "cd ~/aports/testing/ghc && abuild -r"

CMD ["bash"]
