from ghc-8.0:stack
user root
env idris $testing/idris
copy . $idris
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $idris
run abuild checksum && abuild -r
