#!/bin/bash



SCRIPT_NAME=yxct



####################################################################################################
# utility
####################################################################################################


function _yxct_is_osx()
{
  local _is_osx=false

  if [ -n "${OSTYPE}" ]; then
    if [[ "${OSTYPE}" == "darwin"* ]]; then 
      _is_osx=true
    else
      _is_osx=false
    fi
  else
    if [[ $(uname | tr '[:upper:]' '[:lower:]') == "darwin"* ]]; then
      _is_osx=true
    else
      _is_osx=false
    fi
  fi

  ${_is_osx} && return 0 || return 1
}


function yxct_fatal()
{
  echo "Fatal: $@"
  exit 1
}

function yxct_verb()
{
  echo $@
}

function yxct_err()
{
  (>&2 echo "$(tput setaf 5)${1}$(tput sgr0)")
}

function yxct_verbcmd()
{
  yxct_verb "$*"
  $@
}

function yxct_msg()
{
  echo $*
}

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
        yxct_fatal "Unknown params $1. Use '${CMD} info --help' to show help information"
      ;;
    esac
    shift
  done

  echo "==>>${lib_path}"


  if [[ -z "${command}" ]]; then
    yxct_fatal "Command is empty"
  fi
  if [[ "${command}" != "${SCRIPT_NAME}" ]]; then
    yxct_fatal "Unknown command ${SCRIPT_NAME}"
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

  # copy ${SCRIPT_NAME} to bin path.
  if ! yxct_verbcmd "cp -f ${script_path%/}/${SCRIPT_NAME} ${bin_path%/}"; then
    yxct_fatal "failed to copy ${SCRIPT_NAME} to ${SCRIPT_NAME}"
  fi
  if ! yxct_verbcmd "chmod +x ${bin_path%/}/${SCRIPT_NAME}"; then
    yxct_fatal "failed to change yxct's authorization"
  fi


  # make library path
  local cmd_lib_path="${lib_path%\/}/${command}"
  yxct_verbcmd "mkdir -p ${cmd_lib_path}"
  if ! [ -d "${cmd_lib_path}" ]; then
    yxct_fatal "Failed to make dir:${cmd_lib_path}"
  fi

  # copy index path to library
  if ! yxct_verbcmd "cp -R ${script_path}/index ${cmd_lib_path}"; then
    yxct_fatal "failed to copy index path to ${cmd_lib_path}"
  fi


  # change library path auth to 755
  if ! yxct_verbcmd "chmod -R 755 ${cmd_lib_path}"; then
    yxct_fatal "faild to change ${SCRIPT_NAME}'s authorization"
  fi


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
        yxct_fatal "Unknown params $1. Use '${CMD} info --help' to show help information"
      ;;
    esac
    shift
  done



  if [[ -z "${command}" ]]; then
    yxct_fatal "Command is empty"
  fi
  if [[ "${command}" != 'yxct' ]]; then
    yxct_fatal "Unknown command ${SCRIPT_NAME}"
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

  # remove ${SCRIPT_NAME} from bin-path
  local execute_file="${bin_path}/${command}"
  if [ -x "${execute_file}" ]; then
    
    if ! yxct_verbcmd "rm -f ${execute_file}"; then
      yxct_err "failed to remove ${execute_file}"
      has_err=true
    fi
  else
    yxct_err "Can not found ${SCRIPT_NAME} on path:${execute_file}"
    has_err=true
  fi


  # remove library
  local cmd_lib_path="${lib_path%\/}/${command}"
  if ! yxct_verbcmd "rm -rf ${cmd_lib_path}"; then
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
  yxct_fatal "'${SCRIPT_NAME} should run with root"
fi


sub_cmd=$1
shift
if [[ -z ${sub_cmd} ]]; then
  yxct_fatal "Param error. use '${CMD} --help' to show document"
fi

# echo "Here is setup script. sub-cmd:${sub_cmd}"


if [[ ${sub_cmd} == 'install' ]]; then
  cmd_install $@
elif [[ ${sub_cmd} == 'uninstall' ]]; then
  cmd_uninstall $@
else
  yxct_fatal "Unknown sub command:'${sub_cmd}'."
fi

