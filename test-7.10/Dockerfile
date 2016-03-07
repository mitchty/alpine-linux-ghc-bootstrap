from ghcbootstrap:latest-7.10
user root
env PATH ${PATH}:${HOME}/.cabal/bin
workdir /tmp
run apk update

run apk add ghc ghc-dev cabal stack alpine-sdk openssl-dev \
    sqlite-dev curl-dev libstdc++ && \
    cabal update
run cd ~/.cabal && cp config config.prestackage && \
    cd ~/.cabal && curl -sS 'https://www.stackage.org/nightly-2016-01-06/cabal.config?global=true' >> ${HOME}/.cabal/config

run cabal install alex happy && \
    cabal install c2hs

# Work around a limitation of language-c/c2hs not being able to parse
# C11 _Noreturn in stdlib.h
copy stdlib.patch /tmp
run cd /usr/include && patch -p0 < /tmp/stdlib.patch

# work around ncurses include assumptions with -fforce-narrow-library
run cabal install ncurses -fforce-narrow-library

run cabal install mtl network-uri parsec random stm text zlib network \
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
    sodium unbounded-delays shellcheck aeson optparse-applicative inline-c stack

env PATH $HOME/.cabal/bin:$PATH
workdir "/tmp"
cmd ["bash"]
