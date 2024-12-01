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

    # ignore yxct
    local searched_command=$(basename "${item}")
    if [[ "${searched_command}" == "${CMD}" ]]; then
      continue
    fi

    # search and copy install script in existing command.
    local install_script=$(search_file_by_reg_list "${item}" "^\s*\.${CMD}.setup(\.sh|\.py|\.rb)?\s*$")
    if [ -n "${install_script}" ]; then
      setup_cellar install "${searched_command}" --install-script "${item%\/}/${install_script}"
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



####################################################################################################
# Entry
####################################################################################################


# Force root
if [ "$(id -u)" -ne 0 ]; then
  yxct_fatal "'${CMD} should run with root"
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
else
  yxct_fatal "unknown sub command:'${sub_cmd}'."
fi

