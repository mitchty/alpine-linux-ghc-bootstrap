MAJOR:=8.0
DOCKER_NAME:=ghc-$(MAJOR)
TAR:=tar
ifeq ($(UNAME_S),Darwin)
	TAR=gtar
endif

BASEAPKS = llvm3.7 ghc-bootstrap
APKS_REAL = ghc cabal stack
APKS = $(APKS_REAL)
DOCKERS = base $(BASEAPKS) $(APKS)
.PHONY: $(DOCKERS)

.PHONY: all
all: bootstrap $(DOCKERS)

.PHONY: distclean
distclean: clean clean-docker clean-bootstrap

.PHONY: bootstrap
bootstrap:
	$(MAKE) -C ghc-bootstrap -j2 all

.PHONY: clean
clean:
	-rm -fr apk

.PHONY: clean-docker
clean-docker:
	@echo Force cleaning $(DOCKER_NAME) images
	for image in `docker images | grep $(DOCKER_NAME) | awk '{print $$2}'` ; do \
		echo docker rmi -f $(DOCKER_NAME):$$image; \
		docker rmi -f $(DOCKER_NAME):$$image; \
	done

.PHONY: clean-bootstrap
clean-bootstrap:
	@echo Force cleaning bootstrap images
	for image in `docker images | grep alpine-ghc-bootstrap | awk '{print $$2}'`; do \
		echo docker rmi -f alpine-ghc-bootstrap:$$image; \
		docker rmi -f alpine-ghc-bootstrap:$$image; \
	done

$(DOCKERS): apk
	cd $@ && docker build -t $(DOCKER_NAME):$@ .
	docker run -a stdout $(DOCKER_NAME):$@ /bin/tar -cf - /home/build/aports/testing/$@/APKBUILD | $(TAR) xf - --strip-components=5 -C $@
	docker run -a stdout $(DOCKER_NAME):$@ sh -c "/bin/tar -cf - /home/build/packages/testing/*/$@*" | $(TAR) xf - --strip-components=4 -C apk

# TODO: get testing working
test:
#	cd $@ && docker build .

apk:
	install -dm755 $@

latest:
	cd $@ && docker build -t $(DOCKER_NAME):$@ .
	docker run -a stdout $(DOCKER_NAME):$@ /bin/tar -cf - /home/build/packages | $(TAR) xf - --strip-components=4 -C apk

sign:
	docker build -t $(DOCKER_NAME):signed .
	docker run -a stdout $(DOCKER_NAME):signed /bin/tar -cf - /home/build/packages/x86_64/APKINDEX.tar.gz | $(TAR) xf - --strip-components=3 -C apk
	docker run -a stdout $(DOCKER_NAME):signed /bin/tar -cf - /home/build/packages/armhf/APKINDEX.tar.gz | $(TAR) xf - --strip-components=3 -C apk
