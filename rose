#!/usr/bin/env bash
set -e

source "$(dirname "$0")/utilities.sh"


#-------------------------------------------------------------------------------
# Source application build functions
#-------------------------------------------------------------------------------
export APPLICATIONS_DIR="$(dirname "$0")/applications"
export APPLICATION_SCRIPTS=$(ls "$APPLICATIONS_DIR")
export APPLICATION_NAMES=$(ls "$APPLICATIONS_DIR" | sed 's/\.sh//g')

for app in $APPLICATION_SCRIPTS; do
  source "${APPLICATIONS_DIR}/${app}"
done


#-------------------------------------------------------------------------------
# Set defaults
#-------------------------------------------------------------------------------
: ${translator:=identityTranslator}
: ${parallelism:=1}
: ${VERBOSE:=false}
: ${CLEAN:=false}


#-------------------------------------------------------------------------------
# CLI
# TODO: add --force to override existant workspace
#-------------------------------------------------------------------------------
usage()
{
  printf "%b" "
Usage
  $0 [options] [action]

Actions
  compile <application>   Build an <application> with your ROSE translator:

$(for app in $APPLICATION_NAMES; do \
      echo "\
                          $app";\
  done)

  help                    Display CLI help (this output)

Options
  --clean                 Clean workspace before build.
  --parallelism #         make -j#; default: '${parallelism}'
  --translator <name>     Name of your ROSE translator; default: '${translator}'
                          (Note: Your build environment must be pre-configured,
                          i.e. \$PATH and \$LD_LIBRARY_PATH)
  --workspace <path>      Workspace path to perform all builds


  Debugging:
  --trace                 Enables debugging for the script
  --verbose               Enables debugging for the functional operations

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

    --clean)
        export CLEAN=true
        ;;

    --parallelism)
        if test -n "${1:-}"; then
            export parallelism="$1"
            shift
        else
            usage
            fail "--parallelism must be followed by the number of parallel threads you want."
        fi
        ;;

    --trace)
        set -o xtrace
        ;;

    --verbose)
        export VERBOSE=true
        ;;

    --translator)
        if test -n "${1:-}"; then
            export translator="$1"
            shift
        else
            usage
            fail "--translator must be followed by the name of your ROSE translator."
        fi
        ;;

    --workspace)
        if test -n "${1:-}"; then
            export rose_workspace="$1"
            shift
        else
            usage
            fail "--workspace must be followed by a pathname."
        fi
        ;;

    help|usage)
        usage
        exit 0
        ;;

    -*)
        usage
        fail "Unknown command line option switch: '$token'"
        ;;

    compile|clean)
        export rose_command="$token"
          if test -n "${1:-}"; then
              export rose_command_args="$1"
              shift
          else
              usage
              fail "'${rose_command}' command must be followed by an <application> name"
          fi
          ;;

    *)
        export rose_command_args="$rose_command_args $token"
        ;;

    esac
done

if [ -z "$rose_command" ]; then
    usage
    fail "Please specify an action (command) to perform"
fi


#-------------------------------------------------------------------------------
# Compile Application
#-------------------------------------------------------------------------------
compile()
{

    #---------------------------------------------------------------------------
    # Usage
    #---------------------------------------------------------------------------
    local application="$1"; shift

    if test -z "$application"; then
        fail "Usage: compile <application_name>"
    fi


    if "$VERBOSE"; then
      (

        compile_${application} "$translator" $* || exit 1

      ) 2>&1 | while read; do log "[compile:${application}] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Compilation of ${application}" || true
    else
        compile_${application} "$translator" $*
    fi
}


#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main()
{

    # Build in a separate workspace, so we don't pollute
    # the user's current directory.
    create_workspace "${rose_workspace:=$(pwd)/rose_workspace}" false
    cd "$rose_workspace"

    case "$rose_command" in

      compile)
          compile "$rose_command_args"
          ;;

      clean)
          application="$rose_command_args"
          (

            log "Cleaning '${application}'..."
            if test -d "$application"; then
              rm -rf "$application"
              log "Removed '${application}.'"
            else
              log "[SKIP] '${application}' does not exist."
            fi

          ) 2>&1 | while read; do log "[clean:${application}] ${REPLY}"; done
          [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Clean of ${application}" || true
          ;;

      *)
          fail "Unknown command: '${rose_command}'."
          ;;
      esac
}

time main || fail "Main program execution failed"
