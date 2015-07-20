FROM ghcapk:latest

USER root
ENV PATH ${PATH}:${HOME}/.cabal/bin
WORKDIR /tmp
RUN apk update

RUN apk add ghc cabal-install linux-headers musl-dev gmp-dev zlib-dev make \
    curl-dev openssl-dev ncurses-dev llvm sqlite-dev libstdc++ && \
    cabal update && \
    cd ~/.cabal && cp config config.prestackage && \
    cd ~/.cabal && curl -sS 'https://www.stackage.org/nightly-2015-07-18/cabal.config?global=true' >> ${HOME}/.cabal/config

RUN cabal install alex happy && \
    cabal install c2hs

# work around ncurses include assumptions
RUN cabal install ncurses -fforce-narrow-library

RUN cabal install mtl network-uri parsec random stm text zlib network \
    attoparsec haskell-src haskell-src-exts haskell-src-meta hashable html HUnit \
    parallel QuickCheck regex-base regex-compat regex-posix split syb \
    unordered-containers vector primitive async bytedump unix-bytestring colour \
    conduit criterion curl data-accessor-template \
    data-default data-memocombinators digest elerea filemanip foldl Glob \
    lens haskeline hflags hit hslogger HsOpenSSL hspec hybrid-vectors \
    kan-extensions lens-datetime linear MissingH modular-arithmetic \
    monad-loops netwire network-conduit pipes pipes-bytestring pipes-safe \
    pipes-zlib pretty-show random-fu \
    SafeSemaphore snap snap-blaze statistics statvfs \
    temporary test-framework test-framework-hunit test-framework-th \
    test-framework-quickcheck2 thyme tls trifecta tz tzdata unix-time \
    utf8-string utility-ht vector-algorithms vector-th-unbox zip-archive \
    direct-sqlite sqlite-simple \
    ncurses basic-prelude classy-prelude-conduit conduit-combinators \
    conduit-extra hamlet http-client \
    http-client-tls http-conduit http-types path-pieces \
    persistent persistent-template shakespeare \
    shakespeare-css uuid xml-conduit spock \
    zlib-conduit acid-state clock multimap \
    network-transport-tcp tasty tasty-hunit safecopy \
    sodium unbounded-delays shellcheck aeson optparse-applicative inline-c

# Ok this is messed up but cabal install stack doesn't work, its either a bug in
# cabal or ghc, i'm not 100% yet tbh. But if/when it starts to work make this fail
RUN cabal install stack || /bin/true

# It works, but... need to work around a rather interesting linker issue
RUN cabal get stack-0.1.2.0 && \
    cd stack-0.1.2.0 && cabal build || /bin/true && \
    cabal build || /bin/true && \
    cabal install

CMD ["bash"]
