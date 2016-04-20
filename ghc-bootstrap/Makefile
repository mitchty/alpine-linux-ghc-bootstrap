GHC_VERSION:=8.0
ARCH:=x86_64

DOCKER_NAME:=alpine-ghc-bootstrap
TARGET:=ghc-$(GHC_VERSION)-$(ARCH)-unknown-linux-musl.tar.xz

.PHONY: clean distclean cleandocker x86_64 armhf git

all: x86_64 armhf

git:
	rsync --progress --delete -avz ../ghc-git/ghc.git/ ghc.git

x86_64:
	TARGET=ghc-$(GHC_VERSION)-$@-unknown-linux-musl.tar.xz
	docker build -t $(DOCKER_NAME):$@ -f bootstrap/$@/Dockerfile . | tee make-$@-$(shell date +%s).log
	docker run -a stdout "$(DOCKER_NAME):$@" /bin/cat "/tmp/ghc-$(GHC_VERSION)-$(ARCH)-pc-linux-musl.tar.xz" > $(TARGET)

armhf:
	TARGET=ghc-$(GHC_VERSION)-arm-unknown-linux-musleabihf.tar.xz
	docker build -t $(DOCKER_NAME):$@ -f bootstrap/$@/Dockerfile . | tee make-$@-$(shell date +%s).log
	docker run -a stdout "$(DOCKER_NAME):$@" /bin/cat "/tmp/ghc-$(GHC_VERSION)-arm-unknown-linux-musleabihf.tar.xz" > ghc-$(GHC_VERSION)-arm-unknown-linux-musleabihf.tar.xz

clean:
	-rm $(TARGET)

cleanlogs:
	-rm make-*.log

cleandocker:
	docker rmi $(DOCKER_NAME)

distclean: clean cleanlogs
