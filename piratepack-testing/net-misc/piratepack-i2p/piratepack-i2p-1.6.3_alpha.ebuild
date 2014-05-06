# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
DESCRIPTION="Enhance your digital freedom"
HOMEPAGE="https://piratelinux.org"
SRC_URI="https://piratelinux.org/repo/dist/${P}.tar.gz"
LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-devel/make-3
virtual/pkgconfig
>=sys-libs/zlib-1
>=virtual/jdk-1.5
>=app-arch/zip-2
>=app-arch/unzip-5
>=dev-java/commons-logging-1.1
>=dev-java/ant-core-1.7
www-servers/tomcat:6"

RDEPEND=">=sys-libs/zlib-1
>=www-client/firefox-3
>=virtual/jdk-1.5
>=dev-java/commons-logging-1.1
www-servers/tomcat:6"

src_compile() {
	mkdir dest || die
	mkdir dest/bin || die
	mkdir dest/share || die
	cp -r share/i2p-browser dest/share/ || die

	cd gentoo || die
	./configure.sh || die
	cd .. || die

	cd setup/i2p-browser || die
	./install_i2p-browser.sh "${S}"/dest /opt/piratepack/packages/i2p || die
}

src_install() {
	dodir /opt/piratepack/packages/

	mv dest "${D}"/opt/piratepack/packages/i2p || die

	dosym /opt/piratepack/packages/i2p/share/i2p-browser_build/eepget /opt/piratepack/packages/i2p/bin/eepget
	dosym /opt/piratepack/packages/i2p/share/i2p-browser_build/i2prouter /opt/piratepack/packages/i2p/bin/i2prouter
	dosym /opt/piratepack/packages/i2p/share/i2p-browser_build/i2psvc /opt/piratepack/packages/i2p/bin/i2psvc
	dosym /opt/piratepack/packages/i2p/share/i2p-browser_build/i2p-browser /opt/piratepack/packages/i2p/bin/i2p-browser
	dosym /opt/piratepack/packages/i2p/share/i2p-browser_build/i2p-irc /opt/piratepack/packages/i2p/bin/i2p-irc
}
