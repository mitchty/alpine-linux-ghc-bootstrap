from ghc-8.0:cabal
user root
env stack $testing/stack
copy . $stack
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $stack
run abuild checksum && abuild -r
