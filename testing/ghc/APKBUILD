#-*-mode: Shell-script; coding: utf-8;-*-
# Maintainer: Mitch Tishmack <mitch.tishmack@gmail.com>
pkgname=ghc
pkgver=8.0.2
pkgrel=0
pkgdesc="The Glasgow Haskell Compiler"
url="http://haskell.org"
subpackages="$pkgname-doc"
arch="x86_64 armhf"
builddir="$srcdir/$pkgname-$pkgver"
source="
	http://downloads.haskell.org/~ghc/${pkgver}/ghc-${pkgver}-src.tar.xz
	0001-Correct-issue-with-libffi-and-glibc.patch
"

# Note ghc's license is basically bsd3. If you'd like to know more visit:
# https://www.haskell.org/ghc/license
# https://ghc.haskell.org/trac/ghc/wiki/Licensing
#
# Note also that ghc is sensitive to the version of llvm used, hence the
# llvm3.7 package.
#
# Ref: https://ghc.haskell.org/trac/ghc/wiki/Status/GHC-8.0.1
#      https://ghc.haskell.org/trac/ghc/wiki/ImprovedLLVMBackend
license="custom:bsd3"
depends="bash gmp-dev libffi musl zlib ncurses perl gcc llvm3.7"
install=""

# ghc build dependencies
makedepends="
	$depends
	autoconf
	linux-headers
	musl-dev
	ncurses-dev
	gmp-dev
	libffi-dev
	zlib-dev
	binutils-dev
	binutils-gold
	ghc-bootstrap
	paxmark
"

_ghc_build_tmp="$builddir/tmp"

build() {
	cd "$builddir"
	cp mk/build.mk.sample mk/build.mk || return 1
	cat >> mk/build.mk <<-EOF
	BuildFlavour         = perf-llvm
	INTEGER_LIBRARY      = integer-gmp
	BeConservative       = YES
	V                    = 0
	GhcStage3HcOpts     += -O3
	SRC_CC_OPTS         += -fno-stack-protector
	SRC_CC_OPTS         += -fno-PIE
	SRC_HC_OPTS         += -fPIC
	SRC_CC_OPTS         += -fPIC
	SplitSections            = YES
	EOF

	# Due to patches to the configure script
	autoreconf || return 1

	./configure \
		CONF_CC_OPTS_STAGE2=-fno-PIE \
		CONF_GCC_LINKER_OPTS_STAGE2=-nopie \
		CONF_LD_LINKER_OPTS_STAGE2=-nopie \
		--prefix=/usr \
		--with-ld=ld.gold || return 1
	make || return 1
}

doc() {
	default_doc
	install -Dm644 "$builddir/LICENSE" "$subpkgdir/usr/share/licenses/$subpkgname/LICENSE" || return 1
}

package() {
	cd "$builddir"
	make -j1 DESTDIR="$pkgdir" install || return 1
	local settings="$(find $pkgdir -name settings -type f)"
	sed -i 's/.*C compiler link flags", "/& -nopie /' "$settings"
	paxmark -m "$pkgdir/usr/lib/ghc-$pkgver/bin/ghc"
	paxmark -m "$pkgdir/usr/lib/ghc-$pkgver/bin/ghc-iserv"
	paxmark -m "$pkgdir/usr/lib/ghc-$pkgver/bin/ghc-iserv-dyn"
	paxmark -m "$pkgdir/usr/lib/ghc-$pkgver/bin/ghc-iserv-prof"
}
md5sums="d0afb5ec441b14527a53d2445cc26ec3  ghc-8.0.2-src.tar.xz
13c68861fdbab7239c7b9d8d13592046  0001-Correct-issue-with-libffi-and-glibc.patch"
sha256sums="11625453e1d0686b3fa6739988f70ecac836cadc30b9f0c8b49ef9091d6118b1  ghc-8.0.2-src.tar.xz
fc35b8e669189a4e95069f901ce2b3132c36a292f1f23fb14c6123cd784afa15  0001-Correct-issue-with-libffi-and-glibc.patch"
sha512sums="58ea3853cd93b556ecdc4abd0be079b2621171b8491f59004ea4e036a4cba4470aaafe6591b942e0a50a64bdc47540e01fe6900212a1ef7087850112d9bfc5ef  ghc-8.0.2-src.tar.xz
6f90b0de1e34c286e54ef14514ffabe17f9012fbc5448b4aacb3687aac065942e0a3a2c1c57b6338121140369a8870b4ce2a6b355c83c43344d4de8909a253a4  0001-Correct-issue-with-libffi-and-glibc.patch"
