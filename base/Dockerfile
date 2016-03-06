from alpine:latest

env username "Mitch Tishmack"
env useremail mitch.tishmack@gmail.com
env builduser build

run apk update && apk upgrade && apk add git abuild docker perl

run echo "PACKAGER='$username <$useremail>'" >> /etc/abuild.conf

# setup build user and clone alpine ports
run adduser -D $builduser && \
    addgroup $builduser abuild && \
    mkdir -p /var/cache/distfiles && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    echo $builduser  "ALL=(ALL) ALL" > /etc/sudoers

env testing /home/$builduser/aports/testing
env ghc $testing/ghc

user $builduser
workdir /home/$builduser
run git config --global user.name '$username' && \
    git config --global user.email '$useremail' && \
    git clone --depth 1 git://dev.alpinelinux.org/aports && \
    mkdir -p $ghc && \
    abuild-keygen -a -i

user root
run perl -pi -e "s/JOBS[=]2/JOBS\=6/" /etc/abuild.conf && \
    cp -p $(find /home/$builduser/.abuild -name "*.pub" -type f) /etc/apk/keys && \
    echo /home/$builduser/packages/testing >> /etc/apk/repositories && \
    mkdir -p $ghc
