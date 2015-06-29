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

# How did I port this?/how does this thing work?

Painfully really, look in the history for examples of the pain.

But as to how does this work, since this port is for porting ghc for x86_64 only at the moment, the underlying use is of docker primarily.

The overall process is as follows:
- you type make with docker running
- you receive bacon, err finished apks after all is done

So what actually happens underneath is as follows:
- I use ubuntu+musl-cross to build a ghc cross compiler and tar+xz that sucker
- Then I use that to build bootstrap apks for ghc/cabal-install
- Then I use those to build the actual apks you use.
- Those apks get yoinked out of the docker container to PWD

# Will this go upstream into Alpine proper?

Working on it. For now no, its not even been reviewed. Consider this alpha. Don't start running production stuff off this or you'll make kittens mew.

# Will you port 7.8.4?

I might, but I'm kinda sick of compiling ghc at this point. I have projects to do and this took ~3 weeks of my summer so not in a huge rush.
