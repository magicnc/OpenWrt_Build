#
#!/bin/bash
# © 2022 GitHub, Inc.
#====================================================================
# Copyright (c) 2022 Ing
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/wjz304/OpenWrt_Build
# File name: diy.sh
# Description: OpenWrt DIY script
#====================================================================

repo=${1:-openwrt}
owner=${2:-Ing}

echo "OpenWrt DIY script"

echo "repo: ${repo}; owner: ${owner};"

# 修改默认 banner
if [ "${owner}" == "Ing" ]; then
  if [ "${repo}" == "openwrt" ]; then
    cat >package/base-files/files/etc/banner <<EOF
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__|                   Openwrt By ${owner} 
 -----------------------------------------------------
 %D %V, %C
 -----------------------------------------------------

EOF
  else
    cat >package/base-files/files/etc/banner <<EOF
     _________
    /        /\      _    ___ ___  ___
   /  LE    /  \    | |  | __|   \| __|
  /    DE  /    \   | |__| _|| |) | _|
 /________/  LE  \  |____|___|___/|___|        Lede By ${owner}  
 \        \   DE /
  \    LE  \    /  -------------------------------------------
   \  DE    \  /    %D %V, %C
    \________\/    -------------------------------------------

EOF
  fi
else
  cat >package/base-files/files/etc/banner <<EOF
 ██████╗ ██████╗ ███████╗███╗   ██╗██╗    ██╗██████╗ ████████╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██║    ██║██╔══██╗╚══██╔══╝
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║ █╗ ██║██████╔╝   ██║   
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║███╗██║██╔══██╗   ██║   
╚██████╔╝██║     ███████╗██║ ╚████║╚███╔███╔╝██║  ██║   ██║   
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   
  -------------------------------------------
  		%D %V, %C      By ${owner} 
  -------------------------------------------
EOF
fi

# lede    ==> ${defaultsettings}
# openwrt ==> feeds/ing/default-settings
defaultsettings=*/*/default-settings
[ "${repo}" == "openwrt" ] && language=zh_cn || language=zh_Hans

# 设置默认语言
#sed -i "s/en/${language}/g" ${defaultsettings}/files/zzz-default-settings
#sed -i "s/en/${language}/g" package/luci/modules/luci-base/root/etc/uci-defaults/luci-base
#sed -i "s/+@LUCI_LANG_en/+@LUCI_LANG_${language}/g" ${defaultsettings}/Makefile

#修改默认IP
#sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 修改默认hostname
sed -i 's/OpenWrt/OpenWrting/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 更改默认时区
#sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 删除ipv6前缀
sed -i 's/auto//' package/base-files/files/bin/config_generate

# 移除要替换的包
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/packages/net/msd_lite
#rm -rf feeds/packages/net/smartdns
#rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/luci/themes/luci-theme-netgear
#rm -rf feeds/luci/applications/luci-app-mosdns
#rm -rf feeds/luci/applications/luci-app-netdata
#rm -rf feeds/luci/applications/luci-app-serverchan
#rm -rf feeds/package/helloworld
#rm -rf feeds/packages/lang/golang
#rm -rf feeds/packages/net/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# DDNS.to
#git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
#git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 友善uboot
#sed -i '/^UBOOT_TARGETS := rk3528-evb rk3588-evb/s/^/#/' package/boot/uboot-rk35xx/Makefile

# x86 型号只显示 CPU 型号
#sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/${owner} buildR ${date_version} by OpenWrt/g" package/lean/default-settings/files/zzz-default-settings

# 修复 hostapd 报错
cp -f $GITHUB_WORKSPACE/script/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 修复 armv8 设备 xfsprogs 报错
sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# 修改 Makefile
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
#find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}


# Themes
#git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#git clone --depth=1 https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
#git_sparse_clone main https://github.com/haiibo/packages luci-theme-atmaterial luci-theme-opentomcat luci-theme-netgear

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 晶晨宝盒
#git_sparse_clone main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
#sed -i "s|firmware_repo.*|firmware_repo 'https://github.com/haiibo/OpenWrt'|g" package/luci-app-amlogic/root/etc/config/amlogic
# sed -i "s|kernel_path.*|kernel_path 'https://github.com/ophub/kernel'|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8_PLUS|g" package/luci-app-amlogic/root/etc/config/amlogic

# SmartDNS
#git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# msd_lite
#git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
#git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
#git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
#git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata


# 添加额外插件
# git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
# git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
#git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
#git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
#git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
#git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

# 科学上网插件
git clone --depth=1 https://github.com/fw876/helloworld.git package/luci-app-ssr-plus
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
# git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g'

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 调整 V2ray服务器 到 VPN 菜单
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/controller/*.lua
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/*.lua
# sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/view/v2ray_server/*.htm

# 将密码修改为空
#sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${defaultsettings}/files/zzz-default-settings

# 修改网络设置
#sed -i '$i uci set network.lan.ifname="eth1 eth2 eth3"' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci set network.wan.ifname="eth0"' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci set network.wan.proto=pppoe' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci set network.wan6.ifname="eth0"' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci commit network' ${defaultsettings}/files/zzz-default-settings

# 修改默认PPPOE设置
#sed -i '$i uci set network.wan.username=PPPOE_USERNAME' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci set network.wan.password=PPPOE_PASSWD' ${defaultsettings}/files/zzz-default-settings
#sed -i '$i uci commit network' ${defaultsettings}/files/zzz-default-settings

# 修改内核版本
#sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/x86/Makefile

# 修改最大连接数
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# 修改默认主题
#deftheme=bootstrap
#if [ "${owner}" == "Leeson" ]; then
  #deftheme=bootstrap
#elif [ "${owner}" == "Lyc" ]; then
  #deftheme=pink
#else
  #deftheme=argon
#fi
#echo deftheme: ${deftheme}
#sed -i "s/bootstrap/${deftheme}/g" feeds/luci/collections/luci/Makefile
#sed -i "s/bootstrap/${deftheme}/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 添加内核构建用户
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
  echo 'CONFIG_KERNEL_BUILD_USER="${owner}"' >>.config ||
  sed -i "s|\(CONFIG_KERNEL_BUILD_USER=\).*|\1$\"${owner}\"|" .config

# 添加内核构建域
#[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
#  echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
 # sed -i 's|\(CONFIG_KERNEL_BUILD_DOMAIN=\).*|\1$"GitHub Actions"|' .config

# 修改内核和rootfs大小
#sed -i 's/CONFIG_TARGET_KERNEL_PARTSIZE=.*$/CONFIG_TARGET_KERNEL_PARTSIZE=64/' .config
#sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*$/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/' .config

# 修改应用程序列表
#sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' package/feeds/luci/luci-app-ipsec-server/luasrc/controller/ipsec-server.lua # `grep "IPSec VPN Server" -rl ./`
#sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' package/feeds/luci/luci-app-ipsec-vpnd/luasrc/controller/ipsec-server.lua   # `grep "IPSec VPN Server" -rl ./`
#sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' package/feeds/ing/luci-app-zerotier/luasrc/controller/zerotier.lua          # `grep "ZeroTier" -rl ./`

# 修改应用程序名称
#sed -i 's/"IPSec VPN 服务器"/"IPSec VPN"/g' package/feeds/luci/luci-app-ipsec-server/po/*/ipsec-server.po # `grep "IPSec VPN 服务器" -rl ./`
#sed -i 's/"IPSec VPN 服务器"/"IPSec VPN"/g' package/feeds/luci/luci-app-ipsec-vpnd/po/*/ipsec.po          # `grep "IPSec VPN 服务器" -rl ./`
#sed -i 's/"挂载 SMB 网络共享"/"挂载 SMB"/g' package/feeds/luci/luci-app-cifs-mount/po/*/cifs.po            # `grep "挂载 SMB 网络共享" -rl ./`
#sed -i 's/"Turbo ACC 网络加速"/"Turbo ACC"/g' package/feeds/luci/luci-app-turboacc/po/*/turboacc.po       # `grep "Turbo ACC 网络加速" -rl ./`
#sed -i 's/"实时流量监测"/"监测"/g' package/feeds/luci/luci-app-wrtbwmon/po/*/wrtbwmon.po                   # `grep "实时流量监测" -rl ./`
#sed -i 's/"Argon 主题设置"/"主题设置"/g' package/feeds/ing/luci-app-argon-config/po/*/argon-config.po      # `grep "Argon 主题设置" -rl ./`

# Info
# luci-app-netdata 1.33.1汉化版 导致 web升级后 报错: /usr/lib/lua/luci/dispatcher.lua:220: /etc/config/luci seems to be corrupt, unable to find section 'main'

./scripts/feeds update -a
./scripts/feeds install -a

# CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Trojan-Go
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_IPT2Socks
# CONFIG_PACKAGE_trojan-go  导致 web升级后 报错: /usr/lib/lua/luci/dispatcher.lua:220: /etc/config/luci seems to be corrupt, unable to find section 'main'

# luci-app-beardropper 导致 web升级后 /etc/config/network 信息丢失
