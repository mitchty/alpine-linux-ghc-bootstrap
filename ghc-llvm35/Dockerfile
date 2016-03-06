from ghcbootstrap:base
user root
env ghcllvm35 $testing/ghc-llvm35
run install -d $ghcllvm35
copy . $ghcllvm35
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghcllvm35
run abuild checksum
run abuild -r
