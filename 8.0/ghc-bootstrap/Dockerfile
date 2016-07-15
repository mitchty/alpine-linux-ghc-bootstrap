from ghc-8.0:llvm3.7
user root
env ghcbootstrap $testing/ghc-bootstrap
run install -d $ghcbootstrap
copy . $ghcbootstrap
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghcbootstrap
run abuild checksum
run abuild -r
