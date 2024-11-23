
# TestPath='~/Desktop/share/yxscriptmgr'
# TestPath='/home/emanon/Desktop/share/yxct'

##################################################################################
# 仅用于测试, 部分测试逻辑没运行安装脚本, 安装不全
##################################################################################

if [[ "${OSTYPE}" == "darwin"* ]]; then 
    TestPath='/Users/emanon/Desktop/share/yxct'
    TargetPath='/usr/local/bin/yxct'
else
    TestPath='/home/emanon/Desktop/share/yxct'
    TargetPath='/usr/local/sbin/yxct'
fi

sudo rm -f "${TargetPath}"


# additional_params="--info-level verbose --test"
additional_params="--info-level verbose --nono abc"


# exit 0

function check_yxct_not_exist() { if sudo which yxct > /dev/null; then (>&2 echo "$(tput setaf 1)Fatal!!!! yxct not exist$(tput sgr0)"); fi; }
function check_yxct_exist() { if ! sudo which yxct > /dev/null; then (>&2 echo "$(tput setaf 1)Fatal!!!! yxct exist$(tput sgr0)"); fi; }


# sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/.yxct.setup.py" ${additional_params}
# echo '===================================================================================================='
# sudo which yxct


# exit 0

# yxct install xxx --usr-local-sbin --path /a/path

# yxct uninstall xxx

# sudo ./yxct install yxct --strict --usr-local-sbin --path "${TestPath}/yxct" --test ${additional_params}

# exit 0


echo "####################################################################################################"
echo "# Test install command"
echo "####################################################################################################"

echo "如果提供了脚本路径 -> 脚本路径是一个文件 -> 文件是安装脚本, 直接调用脚本"
check_yxct_not_exist
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/.yxct.setup.sh" ${additional_params}
check_yxct_exist
sudo ./yxct uninstall yxct
check_yxct_not_exist
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 脚本路径是一个文件 -> 文件不是安装脚本, 则直接安装文件"
check_yxct_not_exist
sudo ./yxct install yxct --force --usr-local-sbin --path "${TestPath}/yxct" ${additional_params}
check_yxct_exist
sudo ./yxct uninstall yxct
check_yxct_not_exist
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 脚本路径是一个目录 -> 目录中找到安装脚本, 直接掉用那个安装脚本"
check_yxct_not_exist
sudo ./yxct install yxct --force --usr-local-sbin --path "${TestPath}" ${additional_params}
check_yxct_exist
sudo ./yxct uninstall yxct
check_yxct_not_exist
echo '===================================================================================================='

echo "测试简单命令"
check_yxct_not_exist
sudo ./yxct install yxct --path "${TestPath}"  ${additional_params}
check_yxct_exist
sudo ./yxct uninstall yxct ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='

# 如果脚本路径是一个目录, 没找到那个安装脚本，查看是否是单脚本APP
# 测试是要先移除 .yxct.setup.sh
# sudo ./yxct install yxct --force --usr-local-sbin --path "${TestPath}" --ignore 'bin'
# sudo ./yxct uninstall yxct
# echo '===================================================================================================='

echo ""
echo ""
echo ""

echo "####################################################################################################"
echo "# Test uninstall command"
echo "####################################################################################################"


echo "如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件是一个安装脚本, 直接调用脚本"
check_yxct_not_exist
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --path "${TestPath}/.yxct.setup.sh" ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 如果脚本路径是一个文件 -> 如果文件不上是安装脚本，尝试查找文件相同的命令, 并删除"
check_yxct_not_exist
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --path "${TestPath}/yxct" ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='

echo "如果提供了脚本路径 -> 如果脚本径是一个目录 -> 如果目录中找到安装脚本, 直接调用那个安装脚本"
check_yxct_not_exist
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --path "${TestPath}" ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='


# 如果提供了脚本路径 -> 如果脚本路径是一个目录 -> 没找到那个安装脚本，查看是否是单脚本APP
# 测试是要先移除 .yxct.setup.sh
#sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}"
#sudo ./yxct uninstall yxct --path "${TestPath}" --ignore 'bin'

echo "如果没提供脚本路径， 但path不为空 -> 如果path 是个文件, 直接删除， command 提供验证"
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct" 
check_yxct_exist
sudo ./yxct uninstall yxct --custom-dest "${TargetPath}" ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='

echo "如果没提供脚本路径， 但path不为空 -> 如果path 是个目录, 则command 不能为空, 根据command删除"
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --usr-local-sbin ${additional_params}
check_yxct_not_exist
echo '===================================================================================================='

echo "如果没提供脚本路径和path, 但提供了command"
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct ${additional_params} --all
check_yxct_not_exist
echo '===================================================================================================='

echo "测试安装脚本，删除多次"
sudo ./yxct install yxct --usr-local-bin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-bin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --path "${TestPath}" --all ${additional_params} 
check_yxct_not_exist
echo '===================================================================================================='

echo "测试无脚本，删除多次"
sudo ./yxct install yxct --usr-local-bin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-local-sbin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-bin --path "${TestPath}/yxct"
sudo ./yxct install yxct --usr-sbin --path "${TestPath}/yxct"
check_yxct_exist
sudo ./yxct uninstall yxct --all ${additional_params} 
check_yxct_not_exist
echo '===================================================================================================='



echo ""
echo ""
echo '===================================================================================================='
sudo which yxct

