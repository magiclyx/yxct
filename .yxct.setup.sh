#!/usr/bin/env bash



CMD=yxct


YXCT_COMMAND_PATH="$( cd -P "$( dirname "$0"  )" && pwd  )/${CMD}"
if ! [ -f "${YXCT_COMMAND_PATH}" ]; then
  YXCT_COMMAND_PATH=$(which "${CMD}")
  if [ -n "${YXCT_COMMAND_PATH}" ]; then
    YXCT_COMMAND_DIR=
    while [ -h "$YXCT_COMMAND_PATH"  ]; do
      YXCT_COMMAND_DIR="$( cd -P "$( dirname "$YXCT_COMMAND_PATH"  )" && pwd  )"
      YXCT_COMMAND_PATH="$(readlink "$YXCT_COMMAND_PATH")"
      [[ $YXCT_COMMAND_PATH != /*  ]] && YXCT_COMMAND_PATH="$YXCT_COMMAND_DIR/$YXCT_COMMAND_PATH"
    done
  fi
fi

if [ -n "${YXCT_COMMAND_PATH}" ]; then
  source "${YXCT_COMMAND_PATH}" -
fi


####################################################################################################
# command
####################################################################################################

function cmd_install()
{
  local script_path=$(pwd)
  local bin_path=
  local lib_path=
  local command=

  while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        bin_path=$1
      ;;

      --lib-path )
        shift
        lib_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;


      *)
        yxct_fatal "unknown params $1."
      ;;
    esac
    shift
  done


  if [[ -z "${command}" ]]; then
    yxct_fatal "command is empty"
  fi
  if [[ "${command}" != "${CMD}" ]]; then
    yxct_fatal "unknown command ${CMD}"
  fi

  if [ -z "${bin_path}" ]; then
    yxct_fatal "bin path is empty"
  fi
  if ! [[ -d "${bin_path}" ]]; then
    yxct_fatal "target directory not exist:${bin_path}"
  fi

  if [ -z "${lib_path}" ]; then
    yxct_fatal "failed to get library path"
  fi

  # verify the pwd
  if ! [ -f "${script_path}/.yxct.setup.sh" ]; then
    yxct_fatal "current working directory not correct:${script_path}"
  fi


  # remove old libpath if exist
  local cmd_lib_path="${lib_path%\/}/${command}"
  if [ -d "${cmd_lib_path}" ]; then
    if ! yxct_verbcmd "${RM} -rf ${cmd_lib_path}"; then
      yxct_fatal "failed to remove old lib"
    fi
  fi


  # create lib dir
  yxct_verbcmd "${MKDIR} -p ${cmd_lib_path}"
  if ! [ -d "${cmd_lib_path}" ]; then
    yxct_fatal "failed to make dir:${cmd_lib_path}"
  fi


  # copy whole dir to lib
  yxct_verbcmd "${CP} -R ${PWD}/. ${cmd_lib_path}"
  if [[ $? != 0 ]]; then
    yxct_fatal "failed to copy yxlib to ${cmd_lib_path}"
  fi
  yxct_verbcmd "${CHMOD} -R 755 ${cmd_lib_path}"
  if [[ $? != 0 ]]; then
    yxct_fatal "faild to change yxlib's authorization"
  fi


  # link command to bin path
  if ! yxct_verbcmd "${LN} -sf ${cmd_lib_path}/yxct ${bin_path%/}/${command}"; then
    yxct_fatal "faild to link command to ${bin_path}"
  fi


  # re-link all exist command to yxct
  for item in "${lib_path%\/}"/*; do

    # 以文件夹名当作command名
    local searched_command=$(basename "${item}")

    # ignore yxct
    if [[ "${searched_command}" == "${CMD}" ]]; then
      continue
    fi

    # 搜索安装脚本
    local install_script=$(search_file_by_reg_list "${item}" "^\s*\.${CMD}.setup(\.sh|\.py|\.rb)?\s*$")

    # 搜索单脚本文件
    # 但文件名不必与command名相同
    # command 必须在PATH中能搜到，且hash必须与但文件hash相同
    local install_command=
    local singl_app_name=$(file_name_if_single "${item}")
    local installed_cmd_path=$(which "${searched_command}")
    if [ -n "${singl_app_name}" ] && [ -n "${installed_cmd_path}" ]; then
      local single_cmd_path="${item%\/}/${singl_app_name}"
      local single_cmd_hash=$(shasum -a 256 "${single_cmd_path}" | awk '{print $1}')
      if check_file_hash "${installed_cmd_path}" "${single_cmd_hash}"; then
        install_command="${single_cmd_path}"
      fi
    fi


    # 连接至yxct
    if [ -n "${install_script}" ] || [ -n "${install_command}" ]; then
      local params=''
      if [ -n "${install_script}" ]; then
        params="--install-script ${item%\/}/${install_script}"
      fi
      if [ -n "${install_command}" ]; then
        params="${params} --install-file ${install_command}"
      fi

      setup_cellar install "${searched_command}" ${params}
    fi



  done



  return 0
  # yxct_msg "Install success. You need to logout and re-login to reload all environment."
}

function cmd_uninstall()
{

  local script_path=$(pwd)
  local command=
  local bin_path=
  local lib_path=

  while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        bin_path=$1
      ;;

      --lib-path )
        shift
        lib_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;

      *)
        yxct_fatal "Unknown params $1"
      ;;
    esac
    shift
  done



  if [[ -z "${command}" ]]; then
    yxct_fatal "Command is empty"
  fi
  if [[ "${command}" != 'yxct' ]]; then
    yxct_fatal "Unknown command ${command}"
  fi

  if [ -z "${bin_path}" ]; then
    yxct_fatal "bin path is empty"
  fi
  if ! [[ -d "${bin_path}" ]]; then
    yxct_fatal "target directory not exist:${bin_path}"
  fi

  if [ -z "${lib_path}" ]; then
    yxct_fatal "failed to get library path"
  fi


  # verify the pwd
  if ! [ -f "${script_path}/.yxct.setup.sh" ]; then
    yxct_fatal "Current working directory not correct:${script_path}"
  fi


  local has_err=false

  # remove ${CMD} from bin-path
  local execute_file="${bin_path}/${command}"
  if [ -x "${execute_file}" ]; then
    
    if ! yxct_verbcmd "${RM} -f ${execute_file}"; then
      yxct_err "failed to remove ${execute_file}"
      has_err=true
    fi
  else
    yxct_err "Can not found ${CMD} on path:${execute_file}"
    has_err=true
  fi


  # remove library
  local cmd_lib_path="${lib_path%\/}/${command}"
  if ! yxct_verbcmd "${RM} -rf ${cmd_lib_path}"; then
    has_err=true
    yxct_err "failed to remove library:${cmd_lib_path}"
  fi


  ${has_err} && return 1 || return 0

}

function cmd_upgrade()
{
  local script_path=$(pwd)
  local bin_path=
  local lib_path=
  local from_version=
  local to_version=
  local command=

  while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        bin_path=$1
      ;;

      --lib-path )
        shift
        lib_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;

      --from-version )
        shift
        from_version=$1
      ;;

      --to-version )
        shift
        to_version=$1
      ;;


      *)
        yxct_fatal "unknown params $1."
      ;;
    esac
    shift
  done



  if [[ -z "${command}" ]]; then
    yxct_fatal "command is empty"
  fi
  if [[ "${command}" != "${CMD}" ]]; then
    yxct_fatal "unknown command ${CMD}"
  fi

  if [ -z "${bin_path}" ]; then
    yxct_fatal "bin path is empty"
  fi
  if ! [[ -d "${bin_path}" ]]; then
    yxct_fatal "target directory not exist:${bin_path}"
  fi

  if [ -z "${lib_path}" ]; then
    yxct_fatal "failed to get library path"
  fi

  # verify the pwd
  if ! [ -f "${script_path}/.yxct.setup.sh" ]; then
    yxct_fatal "Current working directory not correct:${script_path}"
  fi


  # STEP 1.0
  # 确认 lib-path 存在
  # ##################################################
  # lib-path
  local cmd_lib_path="${lib_path%\/}/${command}"
  if ! [ -d "${cmd_lib_path}" ]; then
    yxct_fatal "command ${command} not exist"
  fi


  # STEP 2.0
  # 整备"临时更新目录" ${lib_path%\/}/.${command}.upgrade
  # ##################################################

  # 删除旧的"临时更新目录", 如果存在
  local cmd_upgrade_path="${lib_path%\/}/.${command}.upgrade"
  if [ -d "${cmd_upgrade_path}" ]; then
    if ! yxct_verbcmd "${RM} -rf ${cmd_upgrade_path}"; then
      yxct_fatal "failed to old upgrade temp directory:${cmd_upgrade_path}"
    fi
  fi

  # 创建新的"临时更新目录"
  yxct_verbcmd "${MKDIR} -p ${cmd_upgrade_path}"
  if ! [ -d "${cmd_upgrade_path}" ]; then
    yxct_fatal "failed to make dir:${cmd_upgrade_path}"
  fi

  # 拷贝所有内容到"临时更新目录"
  yxct_verbcmd "${CP} -R ${PWD}/. ${cmd_upgrade_path}"
  if [[ $? != 0 ]]; then
    yxct_fatal "failed to copy yxlib to ${cmd_upgrade_path}"
  fi
  yxct_verbcmd "${CHMOD} -R 755 ${cmd_upgrade_path}"
  if [[ $? != 0 ]]; then
    yxct_fatal "faild to change yxlib's authorization"
  fi



  # STEP 3.0
  # 将 lib-path 中 关键目录，拷贝到"临时更新目录"
  # ##################################################

  # cellar
  local cellar_path="${cmd_lib_path}/cellar"
  if [ -d "${cellar_path}" ]; then
    if ! yxct_verbcmd "${CP} -R ${cellar_path} ${cmd_upgrade_path}"; then
      yxct_fatal "failed to copy cellar to update-path"
    fi
  fi

  # index
  local index_path="${cmd_lib_path}/index"
  if [ -d "${index_path}" ]; then
    if ! yxct_verbcmd "${CP} -R ${index_path} ${cmd_upgrade_path}"; then
      yxct_fatal "failed to copy index to update-path"
    fi
  fi

  # cache
  local cache_path="${cmd_lib_path}/cache"
  if [ -d "${cache_path}" ]; then
    if ! yxct_verbcmd "${CP} -R ${cache_path} ${cmd_upgrade_path}"; then
      yxct_fatal "failed to copy cache to update-path"
    fi
  fi
  
  # STEP 4.0
  # 将 lib-path 更新为 buckup
  # 将 "临时更新目录" 更改为 lib-path
  # ##################################################
  local cmd_buckup_path="${lib_path%\/}/.${command}.buckup"
  if [ -e "${cmd_buckup_path}" ]; then
    yxct_warn "buckup file exist, try to remove it: ${cmd_buckup_path}"
    yxct_verbcmd "${RM} -rf ${cmd_buckup_path}"

    if [ -e "${cmd_buckup_path}" ]; then
      yxct_fatal "failed to remove old buckup file:${cmd_buckup_path}"
    fi
  fi

  if ! yxct_verbcmd "${MV}" "${cmd_lib_path}" "${cmd_buckup_path}"; then
    yxct_fatal "failed to mv command ${command}'s lip-path to buckup file"
  fi
  if ! yxct_verbcmd "${MV}" "${cmd_upgrade_path}" "${cmd_lib_path}"; then
    yxct_fatal "failed to mv command ${command}'s update-path to lib-path"
  fi

  # STEP 5.0
  # 删除 buckup-path
  # ##################################################
  yxct_verbcmd "${RM} -rf ${cmd_buckup_path}"
  if [ -d "${cmd_buckup_path}" ]; then
    yxct_fatal "failed to remove buckkup file:${cmd_buckup_path}"
  fi

  # STEP 6.0
  # 删除 更新bin-path中的软连接
  # ##################################################
  yxct_verbcmd "${RM} -rf ${bin_path%/}/${command}"
  if ! yxct_verbcmd "${LN} -sf ${cmd_lib_path}/yxct ${bin_path%/}/${command}"; then
    yxct_fatal "faild to link command to ${bin_path}"
  fi

  return 0
}


####################################################################################################
# Entry
####################################################################################################


# Force root
if [ "$(id -u)" -ne 0 ]; then
  yxct_fatal "'${CMD} should run with root"
fi

if [ -z "${YXCT}" ]; then
  yx_fatal "failed to find 'YXCT' environment."
fi


sub_cmd=$1
shift
if [[ -z ${sub_cmd} ]]; then
  yxct_fatal "param error."
fi

# echo "Here is setup script. sub-cmd:${sub_cmd}"


if [[ ${sub_cmd} == 'install' ]]; then
  cmd_install $@
elif [[ ${sub_cmd} == 'uninstall' ]]; then
  cmd_uninstall $@
elif [[ ${sub_cmd} == 'upgrade' ]]; then
  cmd_upgrade $@
else
  yxct_fatal "unknown sub command:'${sub_cmd}'."
fi

