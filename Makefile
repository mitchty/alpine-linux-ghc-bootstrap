# First up you'll need Docker working to generate the cross compiler install
BOOTSTRAPXZ:=ghc-x86_64-linux-musl-7.10.2.tar.xz
BSDIR:=ghc
BSNAME:=alpine-ghc-bootstrap
ALPINENAME:=ghcapk
PKGXZ:=$(BSDIR)/$(BOOTSTRAPXZ)
TAR:=gtar
BACON:=next

.PHONY: test bacon stack

all: bootstrap apk test

bootstrap: $(PKGXZ)
#	cp $(BSDIR)/$(BOOTSTRAPXZ) /nfs/Developer/Vagrant

$(PKGXZ):
	cd $(BSDIR) && ./bootstrap.sh

clean:
	-rm $(PKGXZ)

apk:
	docker build -t $(ALPINENAME) .

test:
	cd test && docker build .


alpine-ghc:
	mkdir -p alpine-ghc

from-s3:
	s3cmd sync --delete-removed s3://alpine-ghc/ alpine-ghc/

stack: from-s3 stack-real

stack-real: alpine-ghc/$(BACON)
	docker build -t $(ALPINENAME):stack -f Dockerfile.stack .
	docker run -a stdout $(ALPINENAME):stack /bin/tar -cf - /home/build/aports/testing/stack/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)

stack-apk:
	docker run -a stdout $(ALPINENAME):stack /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)

alpine-ghc/$(BACON):
	mkdir -p alpine-ghc/$(BACON)

local-apks: alpine-ghc/$(BACON) stack-apk
	docker run -a stdout $(ALPINENAME):apkfiles /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)

rebuild-apks: alpine-ghc/$(BACON)
	docker run -a stdout $(ALPINENAME):latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/cabal-install/APKBUILD /home/build/aports/testing/stack/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
	docker build -t $(ALPINENAME):apkfiles -f Dockerfile.apk .
	-mkdir -p alpine-ghc/$(BACON)/x86_64
	docker run -a stdout $(ALPINENAME):apkfiles /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)

test-s3: local-apks sync-s3

sync-s3:
	s3cmd sync --acl-public alpine-ghc/ s3://alpine-ghc/

bacon: alpine-ghc
	docker run -a stdout ghcapk:latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/cabal-install/APKBUILD  /home/build/aports/testing/stack/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
	docker build -t apkfiles -f Dockerfile.apk .
	-mkdir -p alpine-ghc/$(BACON)/x86_64
	docker run -a stdout apkfiles:latest /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)
	s3cmd sync --acl-public alpine-ghc/$(BACON)/ s3://alpine-ghc/$(BACON)/
