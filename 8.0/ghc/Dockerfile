from ghcbootstrap:ghc-bootstrap
user root
env major 8.0
copy . $ghc-$major
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghc-$major
run abuild checksum
run abuild -r
