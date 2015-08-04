FROM alpine:3.2

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

RUN apk update && apk add git abuild docker perl

RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

ENV ghc /home/$builduser/aports/testing/ghc
# setup build user and clone alpine ports
RUN adduser -D $builduser && \
    addgroup $builduser abuild && \
    mkdir -p /var/cache/distfiles && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    echo $builduser  "ALL=(ALL) ALL" > /etc/sudoers

USER $builduser
WORKDIR /home/$builduser
RUN git config --global user.name '$username' && \
    git config --global user.email '$useremail' && \
    git clone --depth 1 git://dev.alpinelinux.org/aports && \
    mkdir -p $ghc && \
    abuild-keygen -a -i

RUN perl -pi -e "s/JOBS[=]2/JOBS\=8/" /etc/abuild.conf

WORKDIR $ghc
USER root
RUN cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
   echo /home/$builduser/packages/testing >> /etc/apk/repositories && \
   mkdir -p $ghc && \
   chown $builduser:abuild $ghc

USER $builduser
COPY ghc $ghc
#ENV bs_url http://bsd.lan:8000/ghc-x86_64-linux-musl-7.10.2.tar.xz
ENV bs_url https://s3-us-west-2.amazonaws.com/alpine-ghc/7.10/ghc-x86_64-linux-musl-7.10.2.tar.xz
RUN /usr/bin/env BOOTSTRAP=$bs_url abuild checksum && \
    /usr/bin/env BOOTSTRAP=$bs_url abuild -r

USER root
RUN apk update

USER $builduser
WORKDIR $ghc
RUN /usr/bin/env VIABOOTSTRAP=yes abuild checksum && \
    /usr/bin/env VIABOOTSTRAP=yes abuild -r

ENV cabal_install /home/$builduser/aports/testing/cabal-install
RUN mkdir -p $cabal_install
COPY cabal-install $cabal_install

USER root
RUN apk update

USER $builduser
WORKDIR $cabal_install
RUN /usr/bin/env BOOTSTRAP=yes abuild checksum && \
    /usr/bin/env BOOTSTRAP=yes abuild -r

USER root
RUN apk update

USER $builduser
WORKDIR $ghc
RUN abuild checksum && abuild -r

USER root
RUN apk update

USER $builduser
WORKDIR $cabal_install
RUN abuild checksum && abuild -r

ENV stack /home/$builduser/aports/testing/stack
RUN mkdir -p $stack
COPY stack $stack
USER $builduser
WORKDIR $stack
RUN abuild checksum && abuild -r
