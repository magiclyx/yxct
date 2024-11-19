#!/bin/bash

# SOURCE="$0"
# while [ -h "$SOURCE"  ]; do
#   SRC_DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
#   SOURCE="$(readlink "$SOURCE")"
#   [[ $SOURCE != /*  ]] && SOURCE="$SRC_DIR/$SOURCE"
# done
# SRC_DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

function echo_fatal()
{
  echo "Fatal:$@"
  exit 1
}

SCRIPT_NAME=yxct

function cmd_install()
{
  # if [ -z "$*" ]; then
  #   echo "cmd_install: Empty"
  # else
  #   echo "cmd_install: $*"
  # fi

    local script_path=$(pwd)
    local bin_path=
    local command=
    local nono=

    while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        bin_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;

      --nono )
        shift
        nono=$1
      ;;

      *)
        echo_fatal "Unknown params $1. Use '${CMD} info --help' to show help information"
      ;;
    esac
    shift
  done


  if [[ -z "${command}" ]]; then
    echo_fatal "Command is empty"
  fi

  if [ -z "${bin_path}" ]; then
    echo_fatal "bin path is empty"
  fi

  if [ -z "${nono}" ]; then
    echo_fatal "nono is not here"
  fi

  if [[ "${nono}" != 'abc' ]]; then
    echo_fatal "Invalid nono: ${nono}"
  fi

  if [[ "${command}" != "${SCRIPT_NAME}" ]]; then
    echo_fatal "Invalid script:${command}"
  fi

  sudo cp -f "${script_path%/}/${SCRIPT_NAME}" "${bin_path%/}"
  chmod +x "${bin_path%/}/${SCRIPT_NAME}"
}

function cmd_uninstall()
{
  # if [ -z "$*" ]; then
  #   echo "cmd_uninstall: Empty"
  # else
  #   echo "cmd_uninstall: $*"
  # fi

  local command=
  local bin_path=
  local nono=

  while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        bin_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;

      --nono )
        shift
        nono=$1
      ;;

      *)
        echo_fatal "Unknown params $1. Use '${CMD} info --help' to show help information"
      ;;
    esac
    shift
  done


  if [[ -z "${command}" ]]; then
    echo_fatal "Command is empty"
  fi

  if [ -z "${bin_path}" ]; then
    echo_fatal "bin path is empty"
  fi

  if [ -z "${nono}" ]; then
    echo_fatal "nono is not here"
  fi

  if [[ "${nono}" != 'abc' ]]; then
    echo_fatal "Invalid nono: ${nono}"
  fi

  if [[ "${command}" != "${SCRIPT_NAME}" ]]; then
    echo_fatal "Invalid script:${command}"
  fi

  if [ -z "${bin_path}" ]; then
    local app_path=$(which "${SCRIPT_NAME}")
    if [ -n "${app_path}" ]; then
      bin_path=$(dirname "${app_path}")
    fi
  fi


  local execute_file="${bin_path}/${command}"
  if [ -x "${execute_file}" ]; then
    sudo rm -f "${execute_file}" > /dev/null
  else
    echo_fatal "Can not found script ${SCRIPT_NAME} on path:${execute_file}"
  fi

  return 0
}

function cmd_verify()
{
    echo "verify(install.sh)"
}





sub_cmd=$1
shift
if [[ -z ${sub_cmd} ]]; then
  echo_fatal "Param error. use '${CMD} --help' to show document"
fi

# echo "Here is setup script. sub-cmd:${sub_cmd}"


if [[ ${sub_cmd} == 'install' ]]; then
  cmd_install $@
elif [[ ${sub_cmd} == 'uninstall' ]]; then
  cmd_uninstall $@
elif [[ ${sub_cmd} == 'verify' ]]; then
  cmd_verify $@
else
  echo_fatal "Unknown sub command:'${sub_cmd}'."
fi

