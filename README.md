# Ghc 7.10.3 on alpine linux

## How does one use it?

Two ways, you can either use this docker image:

```
docker run --rm -i -t mitchty/alpine-ghc:latest
```

Which is basically just the below Dockerfile. Also note to use on non docker one would just add the keys listed and the repository listed.

Use is pretty simple, just add the proper line into */etc/apk/repositories*, and add my signing key to */etc/apk/keys* and *apk update && apk add ghc cabal-install*.

Abbreviated short version, note the pub key is also in examples.

```
FROM alpine:latest
RUN echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/7.10" >> /etc/apk/repositories
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub
RUN apk update
RUN apk add ghc cabal-install linux-headers musl-dev gmp-dev zlib-dev
ENV PATH ${PATH}:/root/.cabal/bin
RUN cabal update
RUN cabal install mtl network-uri parsec random stm text zlib network alex happy
CMD ["bash"]
```

## Caveat emptor

Given the age and use of ghc on musl libc, I would treat this with a wary eye just to be sure. That doesn't mean binaries produced will do bad things, more that unfound dragons may reside.

I have looked at the Gentoo, Arch, Debian, and Fedora ports of ghc. I'll probably end up incorporating their strategies a bit more. What you see in this one is mostly Debian inspired.

# How did I port this?/how does this thing work?

Painfully really, look in the history for examples of the pain.

But as to how does this work, since this repo is primarily for porting ghc for x86_64 only at the moment, the underlying technology used is docker.

The overall process is as follows:
- you type make with docker running

So what actually happens underneath is as follows:
- I use ubuntu+musl-cross to build a ghc cross compiler and tar+xz that up
- Then I use that to build bootstrap apks for ghc/cabal-install
- Then I use those to build the actual apks you could use above.
- I take those final apks and sign them and put them up on s3

# Will this go upstream into Alpine proper?

Working on it. For now no, its not even been reviewed. Consider this alpha. Don't start running production stuff off this or you'll make kittens mew.

# Will you port 7.8.4?

I might, but I'm kinda sick of compiling ghc at this point. I have projects to do and this took ~3 weeks of my summer so not in a huge rush.

# Will you port to i386/arm?

Arm for sure after I get qemu up and working to run the arm version of alpine linux. i386... probably not, don't see a point at this time but it wouldn't be too hard to do to be honest.
