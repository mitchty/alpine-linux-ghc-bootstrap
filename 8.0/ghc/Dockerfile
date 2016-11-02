from ghc-8.0:ghc-bootstrap
user root
copy . $ghc
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghc
run abuild checksum && abuild -r
