FROM alpine:latest

ENV username "Mitch Tishmack"
ENV useremail mitch.tishmack@gmail.com
ENV builduser build

# add our temporary internal http repo with our bootstrap ghc/cabal-install
RUN echo "http://10.11.12.2:8000/alpine-ghc-bootstrap" >> /etc/apk/repositories

COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub

RUN apk update && apk add git abuild

RUN echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

# setup build user and clone alpine ports
RUN adduser -D $builduser && \
   addgroup $builduser abuild && \
   mkdir -p /var/cache/distfiles && \
   chgrp abuild /var/cache/distfiles && \
   chmod g+w /var/cache/distfiles && \
   echo 'mitch  ALL=(ALL) ALL' > /etc/sudoers && \
   su -l $builduser -c "git config --global user.name '$username'" && \
   su -l $builduser -c "git config --global user.email '$useremail'" && \
   su -l $builduser -c "git clone git://dev.alpinelinux.org/aports" && \
   su -l $builduser -c "mkdir aports/testing/ghc"

# need to run keygen or abuild whinges
RUN su -l $builduser -c "abuild-keygen -a -i"
COPY APKBUILD.ghc /home/build/aports/testing/ghc/APKBUILD

RUN su -l $builduser -c "cd ~/aports/testing/ghc && abuild checksum"
RUN su -l $builduser -c "cd ~/aports/testing/ghc && abuild -r"

RUN su -l $builduser -c "mkdir aports/testing/cabal-install"
COPY APKBUILD.cabal-install /home/build/aports/testing/cabal-install/APKBUILD
RUN su -l $builduser -c "cd ~/aports/testing/cabal-install && abuild checksum"
RUN rm /home/build/packages/testing/x86_64/APKINDEX.tar.gz
RUN su -l $builduser -c "cd ~/aports/testing/cabal-install && abuild -r"

CMD ["bash"]
