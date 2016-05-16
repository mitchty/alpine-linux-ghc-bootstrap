from ghc-8.0:base
user root
env ghcllvm $testing/ghc-llvm
copy . $ghcllvm
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $ghcllvm
run abuild checksum && abuild -r
