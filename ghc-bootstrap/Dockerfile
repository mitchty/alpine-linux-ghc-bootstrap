from ghcbootstrap:ghc-llvm35
user root
env ghcbootstrap $testing/ghc-bootstrap
run install -d $ghcbootstrap
copy . $ghcbootstrap
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghcbootstrap
run abuild checksum
run abuild -r
