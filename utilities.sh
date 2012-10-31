#!/usr/bin/env bash
#
# Usage:
#
#   $ source utilities.sh

set -o errtrace
set -o errexit

log()  { printf "%b\n" "$*" ; return $? ;  }

fail() { log "\n[ERROR] $*\n" ; exit 1 ; }

#-------------------------------------------------------------------------------
# Workspace setup
#-------------------------------------------------------------------------------
create_workspace()
{(

    #---------------------------------------------------------------------------
    # Usage
    #---------------------------------------------------------------------------
    local workspace="$1" clean="$2"
    : ${clean:=${CLEAN}}
    if test -z "$workspace"; then
        fail "Usage: create_workspace <path>"
    fi

    if "$clean"; then
      log "[CLEAN] Removing Workspace before re-creating it"
      rm -rf "${workspace}"
    fi

    #---------------------------------------------------------------------------
    # Create workspace
    #---------------------------------------------------------------------------
    if test -e "$workspace"; then
        log "[SKIP] Workspace already exists: '${workspace}'"
    else
        log "Creating '${workspace}'"
        mkdir -p "${workspace}"
    fi

) 2>&1 | while read; do log "[workspace] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Workspace creation" || true
}


#-------------------------------------------------------------------------------
# Download package
#-------------------------------------------------------------------------------
download()
{(

    #---------------------------------------------------------------------------
    # Usage
    #---------------------------------------------------------------------------
    local filename="$1" direct_url="$2"
    if test -z "$filename"; then
        fail "Usage: download <filename> [direct-url]"
    fi
    if test -z "$filename"; then
        filename="$(basename "$url")"
    fi

    #---------------------------------------------------------------------------
    # Mirrors
    #---------------------------------------------------------------------------
    declare -r mirrors="
http://hudson-rose-30:8080/userContent/downloads
http://rosecompiler.org/tarballs
https://github.com/downloads/rose-compiler/rose"

    declare -r downloader="wget --no-check-certificate"

    #---------------------------------------------------------------------------
    # Download filename from direct-URL or mirror site
    #---------------------------------------------------------------------------
    if test -e "$filename"; then
        log "[SKIP] File already exists: '${filename}'"
    else
        log "Downloading '${filename}'"
        if test -z "$direct_url" || ! $(set -x; $downloader "$direct_url" && test -e "$filename"); then
          for mirror in $mirrors; do
            log "Trying mirror: '$mirror'"
            if $(set -x; $downloader "${mirror}/${filename}" && test -e "$filename"); then
              exit 0
            fi
          done
          false
        fi
    fi

) 2>&1 | while read; do log "[download] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Download" || true
}
