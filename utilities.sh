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
    local workspace="$1"
    if test -z "$workspace"; then
        fail "Usage: create_workspace <path>"
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
    local url="$1" filename="$2"
    if test -z "$url"; then
        fail "Usage: download <url> [filename]"
    fi
    if test -z "$filename"; then
        filename="$(basename "$url")"
    fi

    #---------------------------------------------------------------------------
    # Download URL
    #---------------------------------------------------------------------------
    if test -e "$filename"; then
        log "[SKIP] File already exists: '${filename}'"
    else
        log "Downloading '${filename}'"
        wget --no-check-certificate  "$url" || exit 1
    fi

) 2>&1 | while read; do log "[download] ${REPLY}"; done
[ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Download" || true
}
