FROM alpine:latest

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build
ENV builduid 2000

COPY ghc-x86_64-linux-musl-7.10.1.tar.xz /tmp/ghc-x86_64-linux-musl-7.10.1.tar.xz
COPY ghc-fpic.patch /tmp/ghc-fpic.patch
COPY APKBUILD.ghc /tmp/APKBUILD.ghc
COPY APKBUILD.cabal-install /tmp/APKBUILD.cabal-install

RUN \
   apk update && apk add git abuild && \
   adduser -D $builduser -u $builduid && \
   addgroup $builduser abuild && \
   mkdir -p /var/cache/distfiles && \
   chgrp abuild /var/cache/distfiles && \
   chmod g+w /var/cache/distfiles && \
   echo $builduser  "ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
   mkdir -p /usr/local/cross && \
   chown -R $builduser:abuild /usr/local/cross && \
   su -l $builduser -c "abuild-keygen -a -i" && \
   cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
   apk update

# setup to bootstrap
ENV BOOTSTRAP /tmp/ghc-x86_64-linux-musl-7.10.1.tar.xz
USER $builduser
WORKDIR /home/$builduser
RUN \
    git config --global user.name '$username' && \
    git config --global user.email '$useremail' && \
    git clone --depth 1 git://dev.alpinelinux.org/aports && \
    mkdir aports/testing/ghc && \
    cp /tmp/APKBUILD.ghc ~/aports/testing/ghc/APKBUILD && \
    mkdir aports/testing/cabal-install && \
    cp /tmp/APKBUILD.cabal-install ~/aports/testing/cabal-install/APKBUILD && \
    cp /tmp/ghc-fpic.patch ~/aports/testing/ghc && \
    cd ~/aports/testing/ghc && \
    abuild checksum && \
    cd ~/aports/testing/cabal-install && \
    abuild checksum

# build our temporary bootstrap apks
WORKDIR /home/$builduser/aports/testing/ghc
RUN abuild -r

# bootstrap cabal-install apk
WORKDIR /home/$builduser/aports/testing/cabal-install
RUN \
    rm ~/packages/testing/x86_64/APKINDEX.tar.gz && \
    abuild -r

# build the "real" apk's that depend on the temporary
# bootstrap apks, also, nuke the cross compiler
# to be sure we don't use it unintentionally
USER root
RUN echo /home/$builduser/packages/testing >> /etc/apk/repositories && \
    apk update && \
    rm -fr /usr/local/cross

# unset $BOOTSTRAP so we build the real apks
ENV BOOTSTRAP ""
USER $builduser
WORKDIR /home/$builduser/aports/testing/ghc
RUN \
    rm ~/packages/testing/x86_64/APKINDEX.tar.gz && \
    abuild -r

WORKDIR /home/$builduser/aports/testing/cabal-install
RUN \
    rm ~/packages/testing/x86_64/APKINDEX.tar.gz && \
    abuild -r
