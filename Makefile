# Master makefile used soon by Jenkins
DOCKER_NAME:=ghcbootstrap

# TODO: if bored, get 7.10 working again
# TODO: building from git daily.
all: 8.0

.PHONY: clean
clean:
	$(MAKE) -C 8.0 clean

.PHONY: distclean
distclean:
	$(MAKE) -C 8.0 distclean

.PHONY: clean-docker
clean-docker:
	$(MAKE) -C 8.0 clean-docker

.PHONY: clean-bootstrap
clean-bootstrap:
	$(MAKE) -C 8.0 clean-bootstrap

.PHONY: update
update:
	docker pull alpine:latest

.PHONY:8.0
8.0:
	cd 8.0 && $(MAKE) all sign

.PHONY: resync
resync: from-s3

.PHONY: from-s3
from-s3: alpine-ghc
	s3cmd sync --delete-removed s3://alpine-ghc/ alpine-ghc/

.PHONY: sync-from-s3
sync-from-s3: alpine-ghc
	s3cmd sync s3://alpine-ghc/ alpine-ghc/

.PHONY: promote
promote:
#	rsync -avz --delete alpine-ghc/next/7.10/x86_64/ alpine-ghc/7.10/x86_64
	rsync -avz --delete alpine-ghc/next/8.0/x86_64/ alpine-ghc/8.0/x86_64

.PHONY: next
next: all

.PHONY: rsync-next
rsync-next: 8.0/apk
	rsync -avz --progress --inplace 8.0/apk/ wip:/srv/www/mitchty.net/public_html/ghc/8.0.1

.PHONY: sync-s3
sync-s3:
	s3cmd sync --acl-public alpine-ghc/ s3://alpine-ghc/
