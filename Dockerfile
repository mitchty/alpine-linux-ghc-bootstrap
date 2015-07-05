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
RUN su -l $builduser -c "cd $ghcbootstrap && abuild -r"

CMD ["bash"]
