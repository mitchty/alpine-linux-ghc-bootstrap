from ghcbootstrap:base
user root
env ghcllvm37 $testing/ghc-llvm37
run install -d $ghcllvm37
copy . $ghcllvm37
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghcllvm37
run abuild checksum
run abuild -r
