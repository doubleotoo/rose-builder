#!/usr/bin/env bash

PS4="+ \${BASH_SOURCE##\${rvm_path:-}} : \${FUNCNAME[0]:+\${FUNCNAME[0]}()}  \${LINENO} > "
export PS4
set -o errtrace
set -o errexit

#-------------------------------------------------------------------------------
# CLI
#-------------------------------------------------------------------------------
usage()
{
  printf "%b" "
Usage

  rose [options] [action]

Options

  --trace                 enables debugging for the script
  --workspace <path>      workspace path to perform all builds
  --translator <path>     name of your ROSE translator
                          (Note: Your build environment must be setup)

Actions

  help      - Display CLI help (this output)
  compile   - Build application:

  $(ls "$(dirname "$0")/applications" | sed 's/\.sh//g' | while read; do echo "\t\t$REPLY"; done)

"
}


if [ $# -lt 1 ]; then
  usage
  exit 1
fi
# Parse CLI arguments.
while (( $# > 0 ))
do
  token="$1"
  shift
  case "$token" in

    --trace)
        set -o xtrace
        ;;

    --translator)
        if test -n "${1:-}"; then
            export translator="$1"
            shift
        else
            fail "--translator must be followed by the name of your ROSE translator."
        fi
        ;;

    --workspace)
        if test -n "${1:-}"; then
            export rose_workspace="$1"
            shift
        else
            fail "--workspace must be followed by a pathname."
        fi
        ;;

    help|usage)
        usage
        exit 0
        ;;

    -*)
        usage
        exit 1
        ;;

    compile)
        export rose_command="$token"
          if test -n "${1:-}"; then
              export rose_command_args="$1"
              shift
          else
              fail "compile command must be followed by an application name."
          fi
          ;;
    *)
        export rose_command_args="$rose_command_args $token"
        ;;

    esac
done

if [ -z "$rose_command" ]; then
    usage
    exit 1
fi


#-------------------------------------------------------------------------------
# BEGIN - compile_cherokee
#-------------------------------------------------------------------------------
compile_cherokee()
{(

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.2.101
  declare -r TARBALL="cherokee-${VERSION}.tar.gz"
  declare -r CHEROKEE_URL="http://www.cherokee-project.com/download/1.2/${VERSION}/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "cherokee"
  cd "cherokee"

  test -e "${TARBALL}" || wget --no-check-certificate  "$CHEROKEE_URL"

  tar   xvzf cherokee-${VERSION}.tar.gz
  cd    cherokee-${VERSION}

  CC="$translator" ./configure --prefix="$(pwd)/install_tree"
  make --keep-going
  make install

) 2>&1 | while read; do log "[cherokee] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "[Error] Failed in compilation of Cherokee" || true
}
#-------------------------------------------------------------------------------
# END - compile_cherokee
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# BEGIN - compile
#-------------------------------------------------------------------------------
compile()
{(

    #---------------------------------------------------------------------------
    # Usage
    #---------------------------------------------------------------------------
    local application="$1"; shift

    if test -z "$application"; then
        fail "Usage: compile <application_name>"
    fi

    compile_${application} "$*"

) 2>&1 | while read; do log "[compile] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "[Error] Failed during Compile execution" || true
}
#-------------------------------------------------------------------------------
# END - compile
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main()
{(

    create_workspace "${rose_workspace:=$(pwd)/rose_workspace}"
    cd "$rose_workspace"

    case "$rose_command" in

      compile)
          compile "$rose_command_args"
          ;;

      *)
          fail "Unknown command: '${rose_command}'."
          ;;
      esac

) 2>&1 | while read; do log "[rose] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "[Error] Failed in main operation" || true
}

echo "--> $rose_command"
time main
