FROM alpine:latest

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

COPY ghc-x86_64-linux-musl-7.10.1.tar.xz /tmp/ghc-x86_64-linux-musl-7.10.1.tar.xz
COPY ghc-fpic.patch /tmp/ghc-fpic.patch
COPY APKBUILD.ghc /tmp/APKBUILD

RUN \
   apk update && apk add git abuild xz && \
   adduser -D $builduser && \
   addgroup $builduser abuild && \
   mkdir -p /var/cache/distfiles && \
   chgrp abuild /var/cache/distfiles && \
   chmod g+w /var/cache/distfiles && \
   echo '$builduser  ALL=(ALL) ALL' > /etc/sudoers && \
   su -l $builduser -c "git config --global user.name '$username'" && \
   su -l $builduser -c "git config --global user.email '$useremail'" && \
   su -l $builduser -c "git clone --depth 1 git://dev.alpinelinux.org/aports" && \
   su -l $builduser -c "mkdir aports/testing/ghc" && \
   chown -R $builduser:abuild /usr/local/cross && \
   su -l $builduser -c "cp /tmp/APKBUILD ~/aports/testing/ghc" && \
   su -l $builduser -c "cp /tmp/ghc-fpic.patch ~/aports/testing/ghc" && \
   su -l $builduser -c "abuild-keygen -a -i" && \
   su -l $builduser -c "cd ~/aports/testing/ghc && abuild checksum"

RUN su -l $builduser -c "cd ~/aports/testing/ghc && abuild checksum && abuild -r"
