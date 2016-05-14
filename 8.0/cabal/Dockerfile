from ghcbootstrap:ghc-8.0
user root
env cabal $testing/cabal-8.0
run install -d $cabal
copy . $cabal
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $cabal
run abuild checksum
run abuild -r
