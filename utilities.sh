#!/usr/bin/env bash
#
# Usage:
#
#   $ source utilities.sh

set -o errtrace
set -o errexit

log()  { printf "%b\n" "$*" ; return $? ;  }

fail() { log "\nERROR: $*\n" ; exit 1 ; }

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
[ ${PIPESTATUS[0]} -ne 0 ] && fail "[Error] Failed during Workspace creation" || true
}
