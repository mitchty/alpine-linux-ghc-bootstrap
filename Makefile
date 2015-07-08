# First up you'll need Docker working to generate the cross compiler install
BOOTSTRAPXZ=ghc-x86_64-linux-musl-7.10.1.tar.xz
BSDIR=ghc
BSNAME=alpine-ghc-bootstrap
ALPINENAME=ghcapk
PKGXZ=$(BSDIR)/$(BOOTSTRAPXZ)

all: bootstrap apk

bootstrap: $(PKGXZ)

$(PKGXZ):
	cd $(BSDIR) && docker build -t $(BSNAME) .
	# never use -i or -t, never get the same file with those options
	docker run -a stdout $(BSNAME):latest /bin/cat /tmp/$(BOOTSTRAPXZ) > $(PKGXZ)

clean:
	-rm $(PKGXZ)

apk:
	docker build -t $(ALPINENAME) .
#	docker run -a stdout $(ALPINENAME):latest cat /tmp/apk.tar | tar xvf -
