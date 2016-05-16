from ghc-8.0:ghc
user root
env cabal $testing/cabal
run install -d $cabal
copy . $cabal
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $cabal
run abuild checksum && abuild -r
