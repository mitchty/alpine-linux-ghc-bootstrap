# First up you'll need Docker working to generate the cross compiler install
BOOTSTRAPXZ=ghc-x86_64-linux-musl-7.10.2.tar.xz
BSDIR=ghc
BSNAME=alpine-ghc-bootstrap
ALPINENAME=ghcapk
PKGXZ=$(BSDIR)/$(BOOTSTRAPXZ)

all: bootstrap apk test

bootstrap: $(PKGXZ)

$(PKGXZ):
	cd $(BSDIR) && ./bootstrap.sh

clean:
	-rm $(PKGXZ)

apk:
	docker build -t $(ALPINENAME) .

test:
	cd test && docker build .
