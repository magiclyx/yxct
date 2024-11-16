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
    local script_path=$(pwd)
    local install_path=
    local command=

    while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        install_path=$1
      ;;

      --command )
        shift
        command=$1
      ;;

      # --script-path )
      #   shift
      #   script_path=$1
      # ;;

      *)
        echo_fatal "Unknown params $1. Use '${CMD} info --help' to show help information"
      ;;
    esac
    shift
  done


  if [[ -z "${command}" ]]; then
    echo_fatal "Command is empty"
  fi

  if [[ "${command}" != "${SCRIPT_NAME}" ]]; then
    echo_fatal "Invalid script:${command}"
  fi

  sudo cp --force "${script_path}/${SCRIPT_NAME}" "${install_path}"
  chmod +x "${install_path}/${SCRIPT_NAME}"
}

function cmd_uninstall()
{
  if [ -z "$*" ]; then
    echo "cmd_uninstall: Empty"
  else
    echo "cmd_uninstall: $*"
  fi

  local command=
  local install_path=

  while [ $# -gt 0 ]; do
		case $1 in

      --bin-path )
        shift
        install_path=$1
      ;;

      --command )
        shift
        command=$1
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

  # if [[ -z "${install_path}" ]]; then
  #   echo_fatal "script path is empty"
  # fi

  if [[ "${command}" != "${SCRIPT_NAME}" ]]; then
    echo_fatal "Invalid script:${command}"
  fi

  if [ -z "${install_path}" ]; then
    local app_path=$(which "${SCRIPT_NAME}")
    if [ -n "${app_path}" ]; then
      install_path=$(dirname "${app_path}")
    fi
  fi


  local execute_file="${install_path}/${command}"
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

echo "Here is uninstall script. sub-cmd:${sub_cmd}"


if [[ ${sub_cmd} == 'install' ]]; then
  cmd_install $@
elif [[ ${sub_cmd} == 'uninstall' ]]; then
  cmd_uninstall $@
elif [[ ${sub_cmd} == 'verify' ]]; then
  cmd_verify $@
else
  echo_fatal "Unknown sub command:'${sub_cmd}'."
fi

