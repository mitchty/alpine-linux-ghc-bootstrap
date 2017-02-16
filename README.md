# OBSOLETE: This is now upstreamed to alpine linux testing/edge

Please vote for it there and confirm it works for ghc to move to community. Thanks to everyone for all the help!

Original readme follows:

# Ghc 8.0.2 on alpine linux x86\_64 and armhf

## Will this go upstream into Alpine proper?

Hoping to, I've submitted 8.0.2 as a new port for the testing repository. Ideally it gets accepted and moved to the community repo. Until then I'll update this repo.

The pull request is here:
https://github.com/alpinelinux/aports/pull/205 

## How does one use it?

Two ways, you can either use this docker image:

```
docker run --rm -i -t mitchty/alpine-ghc:latest
```

Which is essentially the below Dockerfile. Also note to use on non docker one would just add the keys listed and the repository listed.

Use is pretty simple, just add the proper line into */etc/apk/repositories*, and add my signing key to */etc/apk/keys* and *apk update && apk add ghc cabal-install*.

Abbreviated short version, note the pub key is also in examples.

```
from alpine:latest
copy mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub
run echo "https://s4-us-west-2.amazonaws.com/alpine-ghc/8.0" >> /etc/apk/repositories; \
    apk update && \
    apk add ghc cabal stack
env PATH ${PATH}:/root/.cabal/bin
cmd ["bash"]
```

Note: the docker images are setup to reduce size, as such you may need to install header apk's etc... such as:

```
apk add alpine-sdk linux-headers musl-dev gmp-dev zlib-dev
```

etc...

You may also optionally use the *mitchty/alpine-ghc:large* image which contains the above apks as well, but is slightly larger. If a bit more useful for actual development.
## Caveat emptor

So I've been using this ghc port since originally porting 7.10.2 in 2015. I know a few others are using this successfully as well. I consider it "stable" at this point. Barring interesting issues like C11 in the musl libc headers confusing some things and other minor annoying issues things should be rather stable at this point.

# How did I port this?/how does this thing work? WARNING: out of date and I'm revamping this to pull from what I'm trying to upstream

Current build steps to reproduce what I've built (not all automatic yet):

## First up, you have to build the cross compilers from a debian x86\_64 docker host

Valid targets to build are:
- x86\_64
- armhf

The debian docker cross compiler hosts are isolated, so you can build x86_64 while armhf is building. You probably want to do this as the armhf cross-compiler takes a while to build via llvm. ~7 hours on an i7 skylake.

## Step 1
- cd 8.0/ghc-bootstrap && (. ./APKBUILD && snapshot)

This will get you the cross compiler bootstrap that will be used to build the native ghc apk package and thus the rest of cabal and stack.

## Put those bootstrap xz files somewhere accessible via http(s)://

Update the source variable to wherever you put those files.

## Step 2
- cd $REPO_BASE && make

This should now be able to build all of the apks, so the primary makefile should now just work. The *all* target basically tells docker to build things in order for x86_64 as needed, This would work as well for armhf but I've not yet tried to run docker on armhf yet so caveat emptor.

## Step 3

Once everything has built, you should be good to sign things.

### To sign

You will need a couple of things, first up you'll need the private/public signing keys you wish to sign with in a tar file with an abuild.conf file. The conf file should be setup to use /home/build and the keys you have. Mine is just:

```
PACKAGER_PRIVKEY="/root/.abuild/mitch.tishmack@gmail.com-55881c97.rsa"
```

And my personal alpine-keys.tar file just looks like:
```
$ tar tvf alpine-keys.tar                                                    
drwxr-xr-x  0 root   root        0 Jun 22  2015 ./
-rw-rw----  0 root   root     1679 Jun 22  2015 ./mitch.tishmack@gmail.com-55881c97.rsa
-rw-r--r--  0 root   root      451 Jun 22  2015 ./mitch.tishmack@gmail.com-55881c97.rsa.pub
-rw-r--r--  0 root   root       71 Jun 22  2015 ./abuild.conf
```

To sign things automatically, just put your apks into *apk/x86_64* or *apk/armhf* and run:
- make sign

This will copy the apk directory into the docker container, sign things via alpine-keys.tar and then extract the *APKINDEX.tar.gz* file(s) as needed.

Then you'll end up with signed apk files and the apk files you want. You can then say rsync the apk directory as you see fit to push things out to any host you need.

## Step 4 (if it doesn't work)

Probably open an issue and ask me why not. This is all a huge hack thats evolved a bit and could be improved.

NOTE: This process is still a bit janky, I need to improve it at some point.

# Will you port 7.8.4?

No. Too old and busted at this point. For arm 7.10.3 is too old and busted. Onwards and upwards! Besides, arm is one of the reasons for this port.

# Will you port to i386/other arch?

Me? Nope, I have no need for 32 bit x86 ghc. It wouldn't be hard to add into the fray however. Primarily it involves setting up the cross compiler docker to generate a new arch. *git diff --no-index Dockerfile.x86_64 Dockerfile.armhf* for an idea of what would need to happen. I tried making the bootstrap process as straightforward as possible.
