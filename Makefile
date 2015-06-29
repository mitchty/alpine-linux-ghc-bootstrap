# First up you'll need Docker working to do all this
BOOTSTRAPXZ=ghc-x86_64-linux-musl-7.10.1.tar.xz
BSDIR=bootstrap
BSNAME=ghcbootstrap
ALPINENAME=ghcapk

all: bootstrap apk

bootstrap: alpine/$(BOOTSTRAPXZ)

alpine/$(BOOTSTRAPXZ):
	cd $(BSDIR) && docker build -t $(BSNAME) .
	# never use -i or -t, never get the same file with those options
	docker run -a stdout $(BSNAME):latest /bin/cat /tmp/$(BOOTSTRAPXZ) > alpine/$(BOOTSTRAPXZ)

clean:
	-rm alpine/$(BOOSTRAPXZ)

apk:
	cd alpine && docker build -t $(ALPINENAME) .
	docker run -a stdout $(ALPINENAME):latest cat /tmp/apk.tar | tar xvf -
