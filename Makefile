# First up you'll need Docker working to generate the cross compiler install
BOOTSTRAPXZ:=ghc-x86_64-linux-musl-7.10.2.tar.xz
BSDIR:=ghc
BSNAME:=alpine-ghc-bootstrap
ALPINENAME:=ghcapk
PKGXZ:=$(BSDIR)/$(BOOTSTRAPXZ)
TAR:=gtar
BACON:=next

.PHONY: test bacon

all: bootstrap apk test apkbuild

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
	mkdir alpine-ghc
	s3cmd sync s3://alpine-ghc/ alpine-ghc/

bacon: alpine-ghc
	docker run -a stdout ghcapk:latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/cabal-install/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
	docker build --no-cache -t apkfiles -f Dockerfile.apk .
	-mkdir -p alpine-ghc/$(BACON)/x86_64
	docker run -a stdout apkfiles:latest /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C alpine-ghc/$(BACON)
	s3cmd sync --acl-public alpine-ghc/$(BACON)/ s3://alpine-ghc/$(BACON)/
