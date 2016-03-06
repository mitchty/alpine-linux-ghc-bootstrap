.PHONY: resync all base ghc-llvm35 ghc-llvm37 ghc-bootstrap ghc-7.10 cabal-7.10 stack-7.10 ghc-8.0 cabal-8.0 test-7.10 latest-7.10 test 7.10 8.0
DOCKER_NAME:=ghcbootstrap
TAR:=gtar
MAJOR:=7.10

BASEAPKS = ghc-llvm35 ghc-bootstrap
APKS7.10 = ghc-7.10 cabal-7.10 stack-7.10 latest-7.10
APKS8.0 = ghc-llvm37 ghc-8.0 cabal-8.0 stack-8.0 latest-8.0
APKS = $(BASEAPKS) $(APKS7.10) $(APKS8.0)
DOCKERS = base $(APKS)

all: 7.10 8.0

update:
	docker pull alpine:latest

$(DOCKERS):
	cd $@ && docker build -t $(DOCKER_NAME):$@ .
	docker run -a stdout $(DOCKER_NAME):$@ /bin/tar -cf - /home/build/aports/testing/$@/APKBUILD | $(TAR) xf - --strip-components=5 -C $@

7.10: base $(BASEAPKS) $(APKS7.10) test-7.10

8.0: base $(BASEAPKS) $(APKS8.0) test-8.0

test: test-7.10 test-8.0

test-7.10:
	cd $@ && docker build .

test-8.0:
	cd $@ && docker build .

# TODO.... all this crap again

resync: from-s3

resync-next: resync

from-s3: alpine-ghc
	s3cmd sync --delete-removed s3://alpine-ghc/ alpine-ghc/

clobber-next: resync-next
	rsync -avz --delete alpine-ghc/7.10/x86_64/ alpine-ghc/next/7.10/x86_64
# someday soon
#	rsync -avz --delete alpine-ghc/8.0/x86_64/ alpine-ghc/next/8.0/x86_64

alpine-ghc:
	mkdir -p $@

alpine-ghc/next/7.10/x86_64: alpine-ghc/7.10
	mkdir -p $@

alpine-ghc/next/8.0/x86_64: alpine-ghc/8.0
	mkdir -p $@

apk: alpine-ghc/next/8.0/x86_64 alpine-ghc/next/7.10/x86_64
#	docker run -a stdout $(DOCKER_NAME):latest-7.10 /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/next/8.0

rebuild-apks: alpine-ghc/$(BACON)/x86_64
#	docker run -a stdout $(ALPINENAME):latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/stack/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
#	docker build -t $(ALPINENAME):apkfiles -f Dockerfile.apk .
#	docker run -a stdout $(ALPINENAME):apkfiles /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)

test-s3: local-apks sync-s3

sync-s3:
	s3cmd sync --acl-public alpine-ghc/ s3://alpine-ghc/

bacon: alpine-ghc
	docker run -a stdout ghcapk:latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/stack/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
	docker build -t apkfiles -f Dockerfile.apk .
	-mkdir -p alpine-ghc/$(BACON)/x86_64
	docker run -a stdout apkfiles:latest /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)
	s3cmd sync --acl-public alpine-ghc/$(BACON)/ s3://alpine-ghc/$(BACON)/
