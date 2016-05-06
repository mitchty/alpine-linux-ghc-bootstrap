from mitchty/alpine-ghc:latest

env srcdir /tmp/ghc
env PATH $srcdir/utils/lndir:$PATH
run apk update && \
    apk add ghc-dev ghc alpine-sdk cabal git autoconf automake coreutils xz binutils-gold && \
    cabal update && \
    cabal install alex happy --global
copy ghc.git $srcdir
workdir $srcdir
run git checkout ghc-8.0 && \
    git submodule update --init --recursive && \
    cp mk/build.mk.sample mk.build.mk && \
    echo "BuildFlavour         = quick" >> mk/build.mk && \
    echo "SRC_HC_OPTS         += -fPIC" >> mk/build.mk && \
    echo "SRC_CC_OPTS         += -fPIC" >> mk/build.mk && \
    echo "HADDOCK_DOCS         = NO" >> mk/build.mk && \
    perl boot && \
    ./configure && \
    ./mk/get-win32-tarballs.sh download all && \
    make -j6 && \
    (cd utils/lndir && make lndir)
run make sdist
