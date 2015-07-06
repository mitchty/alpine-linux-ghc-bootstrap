FROM alpine:latest

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

RUN apk update && apk add git abuild docker

RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

ENV ghcbootstrap /home/$builduser/aports/testing/ghc-bootstrap
# setup build user and clone alpine ports
RUN adduser -D $builduser && \
   addgroup $builduser abuild && \
   mkdir -p /var/cache/distfiles && \
   chgrp abuild /var/cache/distfiles && \
   chmod g+w /var/cache/distfiles && \
   echo $builduser  "ALL=(ALL) ALL" > /etc/sudoers && \
   su -l $builduser -c "git config --global user.name '$username'" && \
   su -l $builduser -c "git config --global user.email '$useremail'" && \
   su -l $builduser -c "git clone --depth 1 git://dev.alpinelinux.org/aports" && \
   su -l $builduser -c "mkdir $ghcbootstrap"

# need to run keygen or abuild whinges
RUN su -l $builduser -c "abuild-keygen -a -i"
COPY ghc-bootstrap $ghcbootstrap

RUN su -l $builduser -c "cd $ghcbootstrap && abuild checksum"

# NOTE
# We need to run our abuild -r in alpine, and my host docker is ubuntu
# SOOOOO, we run the docker in the APKBUILD by pointing it to our
# ubuntu docker daemon on the docker0 interface
#
# This is a total hack, but it works, and this bootstrap build
# is only needed to build the proper build. It isn't hugely useful otherwise.
#
RUN su -l $builduser -c "cd $ghcbootstrap && /usr/bin/env DOCKER_HOST='tcp://172.17.42.1:4243' abuild -r"

USER root
ENV ghc /home/$builduser/aports/testing/ghc
RUN cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
   echo /home/$builduser/packages/testing >> /etc/apk/repositories && \
   apk update && \
   mkdir -p $ghc && \
   chown $builduser:abuild $ghc
#   rm /home/$builduser/packages/testing/x86_64/APKINDEX.tar.gz

USER $builduser
COPY ghc $ghc
WORKDIR $ghc
RUN abuild checksum && \
    /usr/bin/env BOOTSTRAP=yes abuild -r

