# First up you'll need Docker working to generate the cross compiler install
BOOTSTRAPXZ:=ghc-x86_64-linux-musl-7.10.2.tar.xz
BSDIR:=ghc
BSNAME:=alpine-ghc-bootstrap
ALPINENAME:=ghcapk
PKGXZ:=$(BSDIR)/$(BOOTSTRAPXZ)
TAR:=gtar

all: bootstrap apk test apkbuild

bootstrap: $(PKGXZ)

$(PKGXZ):
	cd $(BSDIR) && ./bootstrap.sh

clean:
	-rm $(PKGXZ)

apk:
	docker build -t $(ALPINENAME) .

test:
	cd test && docker build .

bacon:
	docker run -a stdout ghcapk:latest /bin/tar -cf - /home/build/aports/testing/ghc/APKBUILD /home/build/aports/testing/cabal-install/APKBUILD | $(TAR) xf - --strip-components=4 -C $(PWD)
	docker build -t apkfiles -f Dockerfile.apk .
	docker run -a stdout apkfiles:latest /bin/tar -cf - /home/build/packages/testing/x86_64 | $(tar) xf - --strip-components=5 -C $(PWD)
