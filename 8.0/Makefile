MAJOR:=8.0
DOCKER_NAME:=ghc-$(MAJOR)
TAR:=gtar

BASEAPKS = ghc-llvm ghc-bootstrap
APKS_REAL = ghc cabal stack
APKS = $(APKS_REAL) 
DOCKERS = base $(BASEAPKS) $(APKS)
.PHONY: $(DOCKERS) all test clean latest

all: $(DOCKERS) 

clean:
	-rm -fr apk

$(DOCKERS): apk
	cd $@ && docker build -t $(DOCKER_NAME):$@ .
	docker run -a stdout $(DOCKER_NAME):$@ /bin/tar -cf - /home/build/aports/testing/$@/APKBUILD | $(TAR) xf - --strip-components=5 -C $@
	docker run -a stdout $(DOCKER_NAME):$@ sh -c "/bin/tar -cf - /home/build/packages/testing/*/$@*" | $(TAR) xf - --strip-components=4 -C apk

# Not testing automatically till release
test:
#	cd $@ && docker build .

apk: 
	install -dm755 $@

latest:
	cd $@ && docker build -t $(DOCKER_NAME):$@ .
	docker run -a stdout $(DOCKER_NAME):$@ /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C apk

sign:
	rsync -avz apk/ apk.sign
	docker build -t $(DOCKER_NAME):signed .
	docker run -a stdout $(DOCKER_NAME):signed /bin/tar -cf - /home/build/packages/testing | $(TAR) xf - --strip-components=4 -C apk
	rsync -avz apk.sign apk
	rm -fr apk.sign
