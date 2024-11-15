
# TestPath='~/Desktop/share/yxscriptmgr'
TestPath='/home/emanon/Desktop/share/yxscriptmgr'

sudo rm -f "/usr/local/sbin/yxscrpmgr"

# test install
# sudo ./yxscrpmgr install --usr-local-sbin --script-path "${TestPath}"

# which yxscrpmgr

# pushd ~/Desktop
# PATH="$PATH:/usr/local/sbin"
# yxscriptmgr --help
# popod



#如果文件是一个安装脚本, 直接调用脚本
# sudo ./yxscrpmgr install --usr-local-sbin --script-path "${TestPath}/.yxscrpmgr.install.sh"

#如果没有找到安装脚本，但使用了--allow-no-script参数, 则直接安装文件
#sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}/yxscrpmgr"

# 如果脚本路径是一个目录, 目录中找到安装脚本, 直接掉用那个安装脚本
# sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}"

# 如果脚本路径是一个目录, 没找到那个安装脚本，但指定了--no-installer.查看是否是单脚本APP
# 测试是要先移除 .yxscrpmgr.install.sh
# sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}" --ignore 'bin'

