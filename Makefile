# First up you'll need Docker working to do all this
BOOTSTRAPXZ=ghc-x86_64-linux-musl-7.10.1.tar.xz
BSDIR=bootstrapghc
BSNAME=ghcbootstrap

all: bootstrap apk

bootstrap: alpine/$(BOOTSTRAPXZ)

alpine/$(BOOTSTRAPXZ):
	cd $(BSDIR) && docker build -t $(BSNAME) .
	# never use -i or -t, never get the same file with those options
	docker run -a stdout $(BSNAME):latest /bin/cat /tmp/$(BOOTSTRAPXZ) > alpine/$(BOOTSTRAPXZ)

clean:
	-rm alpine/$(BOOSTRAPXZ)
