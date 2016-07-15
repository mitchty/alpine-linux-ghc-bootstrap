from ghc-8.0:base
user root
env llvm $testing/llvm3.7
copy . $llvm
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \; && apk update
user $builduser
workdir $llvm
run abuild checksum && abuild -r
