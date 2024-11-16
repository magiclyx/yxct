
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



####################################################################################################
# Test install command
####################################################################################################

#如果文件是一个安装脚本, 直接调用脚本
# sudo ./yxscrpmgr install --usr-local-sbin --script-path "${TestPath}/.yxscrpmgr.install.sh"

#如果没有找到安装脚本，但使用了--no-installer参数, 则直接安装文件
#sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}/yxscrpmgr"

# 如果脚本路径是一个目录, 目录中找到安装脚本, 直接掉用那个安装脚本
# sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}"

# 如果脚本路径是一个目录, 没找到那个安装脚本，但指定了--no-installer.查看是否是单脚本APP
# 测试是要先移除 .yxscrpmgr.install.sh
# sudo ./yxscrpmgr install --no-installer --force --usr-local-sbin --script-path "${TestPath}" --ignore 'bin'


####################################################################################################
# Test uninstall command
sudo ./yxscrpmgr install --no-installer --usr-local-sbin --script-path "${TestPath}/yxscrpmgr"
####################################################################################################
# 如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件是一个安装脚本, 直接调用脚本
# sudo ./yxscrpmgr uninstall --script-path "${TestPath}/.yxscrpmgr.install.sh"

# 如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件不上是安装脚本，但指定了--no-installer参数, 尝试查找文件相同的命令, 并删除
# sudo ./yxscrpmgr uninstall --no-installer --script-path "${TestPath}/yxscrpmgr" --command 'yxscrpmgr'

# 如果提供了脚本路径 -> 如果脚本路径是一个目录 -> 如果目录中找到安装脚本, 直接调用那个安装脚本
# sudo ./yxscrpmgr uninstall --script-path "${TestPath}" --command 'yxscrpmgr'

# 如果提供了脚本路径 -> 如果脚本路径是一个目录 -> 没找到那个安装脚本，但指定了--no-installer.查看是否是单脚本APP
# 测试是要先移除 .yxscrpmgr.install.sh
# sudo ./yxscrpmgr uninstall --no-installer --script-path "${TestPath}" --command 'yxscrpmgr' --ignore 'bin'


# 如果没提供脚本路径， 但bin_path不为空 -> 如果bin_path 是个文件, 直接删除， command 提供验证
# sudo ./yxscrpmgr uninstall --custom-dest "/usr/local/sbin/yxscrpmgr" --command 'yxscrp'

# 如果没提供脚本路径， 但bin_path不为空 -> 如果bin_path 是个目录, 则command 不能为空, 根据command删除
# sudo ./yxscrpmgr uninstall --usr-local-sbin --command 'yxscrpmgr'


# 如果没提供脚本路径和bin_path, 但提供了command
sudo ./yxscrpmgr uninstall --command 'yxscrpmgr'


echo '===================================================================================================='
sudo which yxscrpmgr