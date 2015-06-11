FROM alpine:3.1

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

RUN apk add --update \
    curl \
    xz \
    alpine-sdk \
    perl \
    gmp-dev \
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
    zlib-dev

# apk build stuff, sort out later
RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

RUN adduser -D $builduser && \
    addgroup $builduser abuild && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    echo 'mitch  ALL=(ALL) ALL' > /etc/sudoers && \
    su -l $builduser -c "git config --global user.name '$username'" && \
    su -l $builduser -c "git config --global user.email '$useremail'" && \
    su -l $builduser -c "git clone git://dev.alpinelinux.org/aports"

RUN su -l $builduser -c "abuild-keygen -a -i"

# checkout ghc source release
RUN git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/ && \
    git clone -b ghc-7.10.1-release --recursive git://git.haskell.org/ghc.git /tmp/ghc

# get the phase2 compiler we built earlier, its in /usr/local
RUN cd / && curl -L 'http://10.11.12.2:8000/ghc-x86_64-linux-musl-7.10.1.tar.xz' | \
    xz -c -d - | tar xf - && echo ok again again

ENV PATH $PATH:/usr/local

# Right, so need to build cabal+cabal-install+happy+alex to build our real ghc

# First up, snag cabal-install and use bootstrap.sh to install to the global
# package db

# otherwise haddock is expected to exist, meh to that
ENV NO_DOCUMENTATION obviously

RUN cd /tmp && curl -L "https://www.haskell.org/cabal/release/cabal-install-1.22.3.0/cabal-install-1.22.3.0.tar.gz" | gunzip -c - | tar xf -
RUN cd /tmp/cabal-install-1.22.3.0 && ./bootstrap.sh --global

# pimp, we have cabal now
ENV PATH $PATH:/root/.cabal/bin

# and install happy+alex so we can build ghc
RUN cabal update && cabal install happy alex

# Right so I want a performance+llvm build, it'll take ages but whatever,
# as Richard Clarkson once said "MORE POWER!!!"
RUN cd /tmp/ghc && cp mk/build.mk.sample mk/buildmk && \
    perl -pi -e 's/^\#BuildFlavour\s+\=\s+perf\-cross/BuildFlavour \= perf-llvm/g'

# stick this in /usr/local alongside the stage2 ghc for now, we'll use this
# compiler to build our actual ghc apk
RUN cd /tmp/ghc && ./configure && make && make install

# make the same pie/PIC modifications to our native compiler so it can build
# our apk version
# TODO: find out why, and find a fix so we don't need it in future
ENV settings_file /usr/local/lib/ghc-7.10.1/settings
RUN perl -pi -e 's/.*C compiler flags.*/ \(\"C compiler flags\"\, \"-fno-stack-protector -nopie\"\)\,/' $settings_file && \
    perl -pi -e 's/.*ld flags.*/ \(\"ld flags\"\, \"-fno-PIC\"\)\,/' $settings_file

# ok nuke our user .cabal/.ghc dirs
RUN rm -fr /root/.cabal /root/.ghc

# Just make sure things work
RUN cd /tmp/ghc/bindisttest && ghc --make HelloWorld.lhs && ./HelloWorld && \
    ghc -optl -static --make HelloWorld.lhs && ./HelloWorld

CMD ["bash"]
