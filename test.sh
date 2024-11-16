
# TestPath='~/Desktop/share/yxscriptmgr'
TestPath='/home/emanon/Desktop/share/yxct'

sudo rm -f "/usr/local/sbin/yxct"


echo "####################################################################################################"
echo "# Test install command"
echo "####################################################################################################"

echo "如果提供了脚本路径 -> 脚本路径是一个文件 -> 文件是安装脚本, 直接调用脚本"
sudo ./yxct install yxct --usr-local-sbin --script-path "${TestPath}/.yxct.setup.sh"
sudo ./yxct uninstall yxct
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 脚本路径是一个文件 -> 文件不是安装脚本, 但使用了--no-installer参数, 则直接安装文件"
sudo ./yxct install yxct --no-installer --force --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 脚本路径是一个目录 -> 目录中找到安装脚本, 直接掉用那个安装脚本"
sudo ./yxct install yxct --no-installer --force --usr-local-sbin --script-path "${TestPath}"
sudo ./yxct uninstall yxct
echo '===================================================================================================='

# 如果脚本路径是一个目录, 没找到那个安装脚本，但指定了--no-installer.查看是否是单脚本APP
# 测试是要先移除 .yxct.setup.sh
# sudo ./yxct install yxct --no-installer --force --usr-local-sbin --script-path "${TestPath}" --ignore 'bin'
# sudo ./yxct uninstall yxct
# echo '===================================================================================================='

echo ""
echo ""
echo ""


echo "####################################################################################################"
echo "# Test uninstall command"
echo "####################################################################################################"


echo "如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件是一个安装脚本, 直接调用脚本"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct --script-path "${TestPath}/.yxct.setup.sh"
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件不上是安装脚本，但指定了--no-installer参数, 尝试查找文件相同的命令, 并删除"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct --no-installer --script-path "${TestPath}/yxct"
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 如果脚本路径是一个目录 -> 如果目录中找到安装脚本, 直接调用那个安装脚本"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct --script-path "${TestPath}"
echo '===================================================================================================='

# 如果提供了脚本路径 -> 如果脚本路径是一个目录 -> 没找到那个安装脚本，但指定了--no-installer.查看是否是单脚本APP
# 测试是要先移除 .yxct.setup.sh
#sudo ./yxct install yxct --usr-local-sbin --script-path "${TestPath}"
#sudo ./yxct uninstall yxct --no-installer --script-path "${TestPath}" --ignore 'bin'

echo "如果没提供脚本路径， 但bin_path不为空 -> 如果bin_path 是个文件, 直接删除， command 提供验证"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct --custom-dest "/usr/local/sbin/yxct"
echo '===================================================================================================='

echo "如果没提供脚本路径， 但bin_path不为空 -> 如果bin_path 是个目录, 则command 不能为空, 根据command删除"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct --usr-local-sbin
echo '===================================================================================================='

echo "如果没提供脚本路径和bin_path, 但提供了command"
sudo ./yxct install yxct --no-installer --usr-local-sbin --script-path "${TestPath}/yxct"
sudo ./yxct uninstall yxct
echo '===================================================================================================='


echo ""
echo ""
echo '===================================================================================================='
sudo which yxct