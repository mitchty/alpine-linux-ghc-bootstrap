GHC_VERSION:=8.0.1
DOCKER_NAME:=alpine-ghc-bootstrap
TARGET_x86_64:=ghc-$(GHC_VERSION)-x86_64-unknown-linux-musl.tar.xz
TARGET_armhf:=ghc-$(GHC_VERSION)-armhf-unknown-linux-musleabihf.tar.xz


all: x86_64 armhf

.PHONY: git
git:
	rsync --progress --delete -avz ../ghc-git/ghc.git/ ghc.git

TARGET_x86_64: x86_64
TARGET_armhf: armhf

.PHONY: x86_64
x86_64:
	TARGET=ghc-$(GHC_VERSION)-$@-unknown-linux-musl.tar.xz
	docker build -t $(DOCKER_NAME):$@ -f bootstrap/$@/Dockerfile . | tee make-$@-$(shell date +%s).log
	docker run -a stdout "$(DOCKER_NAME):$@" /bin/cat "/tmp/ghc-$(GHC_VERSION)-x86_64-pc-linux-musl.tar.xz" > $(TARGET_x86_64)

.PHONY: armhf
armhf:
	TARGET=ghc-$(GHC_VERSION)-arm-unknown-linux-musleabihf.tar.xz
	docker build -t $(DOCKER_NAME):$@ -f bootstrap/$@/Dockerfile . | tee make-$@-$(shell date +%s).log
	docker run -a stdout "$(DOCKER_NAME):$@" /bin/cat "/tmp/ghc-$(GHC_VERSION)-arm-unknown-linux-musleabihf.tar.xz" > $(TARGET_armhf)

.PHONY: clean
clean:
	-rm $(TARGET)

.PHONY: cleanlogs
cleanlogs:
	-rm make-*.log

.PHONY: cleandocker
cleandocker:
	docker rmi $(DOCKER_NAME)

.PHONY: distclean
distclean: clean cleanlogs
