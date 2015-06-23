# Ghc 7.10.1 on alpine linux

## How does one use it?

Use is pretty simple, just add the proper line into */etc/apk/repositories*, and add my signing key to */etc/apk/keys* and apk update && apk add ghc-dev cabal-install.

Abbreviated short version, note the pub key is also in examples.

```
FROM alpine:latest
RUN echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/7.10" >> /etc/apk/repositories
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub
RUN apk update
RUN apk add ghc-dev cabal-install bash linux-headers musl-dev gmp-dev zlib-dev
ENV PATH ${PATH}:/root/.cabal/bin
RUN cabal update 
RUN cabal install mtl network-uri parsec random stm text zlib network alex happy
CMD ["bash"]
```

## A quick note on ghci

If you don't install *gmp-dev* you'll need to set LD_LIBRARY_PATH to */usr/lib/engines* before you can use ghci.

```export LD_LIBRARY_PATH=/usr/lib/engines```

## Consider this an alpha port

I have looked at the Gentoo, Arch, Debian, and Fedora ports of ghc. I'll probably end up incorporating their strategies a bit more. What you see in this one is mostly Debian inspired.

# How did I port this?

Well everything is in stage1/2/3. Note, it would take a bit of modification to use the Dockerfiles within. They assume you're on my network.

Its really only useful if you want to see how I built the cross compiler and built the preliminary ghc on alpine linux.

A quick summary though, stage1 is an ubuntu image that uses the sabotage linux musl gcc cross compiler to build ghc as a cross compiler.

I take that entire compiler install, use that for the input to stage2 to compile ghc natively in alpine linux, then build a bootstrap apk of ghc and cabal-install.

Finally taking those apk's that essentially just don't require themselves to build, and built the "final" apks that are signed on s3.

Thats pretty much it really.

# Will this go upstream into Alpine proper?

Working on it. For now no, its not even been reviewed. Consider this alpha. Don't start running production stuff off this or you'll make kittens mew.

# Will you port 7.8.4?

I might, but I'm kinda sick of compiling ghc at this point. I have projects to do and this took ~3 weeks of my summer so not in a huge rush.
