FROM alpine:3.2

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

RUN apk update && apk upgrade && apk add git abuild docker perl

RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

ENV testing /home/$builduser/aports/testing
ENV ghc $testing/ghc
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

USER root
RUN perl -pi -e "s/JOBS[=]2/JOBS\=6/" /etc/abuild.conf
RUN cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
   echo /home/$builduser/packages/testing >> /etc/apk/repositories
run mkdir -p $ghc

ENV ghcllvm35 $testing/ghc-llvm35
run install -d $ghcllvm35
COPY ghc-llvm35 $ghcllvm35
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
RUN apk update
USER $builduser

WORKDIR $ghcllvm35
RUN abuild checksum && abuild -r

USER root
RUN apk update

ENV ghcllvm37 $testing/ghc-llvm37
run install -d $ghcllvm37
COPY ghc-llvm37 $ghcllvm37
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
RUN apk update
USER $builduser

WORKDIR $ghcllvm37
RUN abuild checksum && abuild -r

USER root
RUN apk update

ENV ghcbootstrap $testing/ghc-bootstrap
COPY ghc-bootstrap $ghcbootstrap
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
RUN apk update
USER $builduser

# build ghc package via bootstrap compiler
WORKDIR $ghcbootstrap
RUN abuild checksum && abuild -r

USER root
RUN apk update

COPY ghc-7.10 $ghc
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
RUN apk update
USER $builduser
WORKDIR $ghc
RUN abuild checksum && abuild -r

USER root
RUN apk update

ENV cabal /home/$builduser/aports/testing/cabal
USER root
RUN mkdir -p $cabal
COPY cabal $cabal
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
USER $builduser
WORKDIR $cabal
RUN abuild checksum && abuild -r
USER root
RUN apk update

# and build stack for good measure
ENV stack /home/$builduser/aports/testing/stack
USER root
RUN mkdir -p $stack
COPY stack $stack
RUN find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
USER $builduser
WORKDIR $stack
RUN abuild checksum && abuild -r
