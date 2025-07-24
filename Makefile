#
# Copyright (C) 2024 OpenWrt Developers
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy2
PKG_VERSION:=2.1.12
PKG_RELEASE:=1

# 使用Git获取源码
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/dnscrypt/dnscrypt-proxy.git
# 2.1.12版本对应的commit哈希值（请替换为实际值）
PKG_SOURCE_VERSION:=cc4c28ce4fec6589a4ef5294345610b1ee424314
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=OpenWrt Developers <openwrt-devel@lists.openwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

# Go编译配置 - 指向正确的主程序包
GO_PKG:=github.com/dnscrypt/dnscrypt-proxy/dnscrypt-proxy
GO_PKG_LDFLAGS_X:=$(GO_PKG)/dnscrypt-proxy.AppVersion=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/dnscrypt-proxy2
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=DNSCrypt proxy client
  URL:=https://dnscrypt.info/
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/dnscrypt-proxy2/description
  A flexible DNS proxy, with support for modern encrypted DNS protocols such as
  DNSCrypt v2, DNS-over-HTTPS (DoH), Anonymized DNSCrypt and ODoH (Oblivious DoH).
endef

define Package/dnscrypt-proxy2/conffiles
/etc/dnscrypt-proxy/dnscrypt-proxy.toml
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/dnscrypt-proxy2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/dnscrypt-proxy $(1)/usr/bin/dnscrypt-proxy2

	$(INSTALL_DIR) $(1)/etc/dnscrypt-proxy2
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/dnscrypt-proxy/example-dnscrypt-proxy.toml \
		$(1)/etc/dnscrypt-proxy2/dnscrypt-proxy.toml

	$(INSTALL_CONF) $(PKG_BUILD_DIR)/dnscrypt-proxy/example-*.txt \
		$(1)/etc/dnscrypt-proxy2/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnscrypt-proxy2.init $(1)/etc/init.d/dnscrypt-proxy2
endef

$(eval $(call BuildPackage,dnscrypt-proxy2))
