FROM alpine:3.2

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

RUN apk update && apk upgrade && apk add git abuild docker perl

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

WORKDIR $ghc
USER root
RUN perl -pi -e "s/JOBS[=]2/JOBS\=6/" /etc/abuild.conf
RUN cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
   echo /home/$builduser/packages/testing >> /etc/apk/repositories && \
   mkdir -p $ghc
COPY ghc $ghc
RUN chown -R $builduser:abuild $ghc
RUN apk update
USER $builduser
ENV bs_url https://s3-us-west-2.amazonaws.com/alpine-ghc/next/7.10/ghc-7.10.3-x86_64-unknown-linux-musl.tar.xz

# Build via the bootstrap compiler first
RUN /usr/bin/env BOOTSTRAP=$bs_url abuild checksum && \
    /usr/bin/env BOOTSTRAP=$bs_url abuild -r

USER root
RUN apk update

USER $builduser
WORKDIR $ghc
RUN abuild checksum && abuild -r

USER root
RUN apk update

# and build stack for good measure
ENV stack /home/$builduser/aports/testing/stack
USER root
RUN mkdir -p $stack
COPY stack $stack
RUN chown -R $builduser:abuild $stack
USER $builduser
WORKDIR $stack
RUN abuild checksum && abuild -r
