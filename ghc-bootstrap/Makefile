CABAL_VERSION:=1.22.7.0
GHC_VERSION:=7.10.3
LLVM_VERSION:=3.5.2
ARCH:=x86_64
GHC_BS:=ghc-$(GHC_VERSION)-$(ARCH)-deb8-linux.tar.xz
GHC_SRC:=ghc-$(GHC_VERSION)-src.tar.xz
CABAL_BS:=cabal-install-$(CABAL_VERSION).tar.gz
LLVM_BS:=llvm-$(LLVM_VERSION).src.tar.xz
POLLY_BS:=polly-$(LLVM_VERSION).src.tar.xz
SRCS:= $(GHC_BS) $(GHC_SRC) $(CABAL_BS) $(LLVM_BS) $(POLLY_BS)

DOCKER_NAME:=alpine-ghc-bootstrap
TARGET:=ghc-$(GHC_VERSION)-$(ARCH)-unknown-linux-musl.tar.xz

.PHONY: clean distclean cleandocker x86_64

all: x86_64

dl: $(SRCS)

x86_64:
	TARGET=ghc-$(GHC_VERSION)-$@-unknown-linux-musl.tar.xz
	docker build -t $(DOCKER_NAME):$@ -f bootstrap/$@/Dockerfile . | tee make-$@-$(shell date +%s).log
	docker run -a stdout "$(DOCKER_NAME):$@" /bin/cat "/tmp/ghc-$(GHC_VERSION)-$(ARCH)-pc-linux-musl.tar.xz" > $(TARGET)

$(GHC_BS):
	curl -LO https://downloads.haskell.org/~ghc/$(GHC_VERSION)/$@

$(GHC_SRC):
	curl -LO https://www.haskell.org/ghc/dist/$(GHC_VERSION)/$@

$(CABAL_BS):
	curl -LO https://www.haskell.org/cabal/release/cabal-install-$(CABAL_VERSION)/$@

$(LLVM_BS):
	curl -LO http://llvm.org/releases/$(LLVM_VERSION)/$@

$(POLLY_BS):
	curl -LO http://llvm.org/releases/$(LLVM_VERSION)/$@

clean:
	-rm $(SRCS) $(TARGET)

cleanlogs:
	-rm make-*.log

cleandocker:
	docker rmi $(DOCKER_NAME)

distclean: clean cleanlogs
