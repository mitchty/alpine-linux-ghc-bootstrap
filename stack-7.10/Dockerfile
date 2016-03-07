from ghcbootstrap:cabal-7.10
user root
env stack $testing/stack-7.10
run install -d $stack
copy . $stack
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $stack
run abuild checksum
run abuild -r
