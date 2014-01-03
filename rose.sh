#!/usr/bin/env bash
set -e

#-------------------------------------------------------------------------------
# Set defaults
#-------------------------------------------------------------------------------
: ${rose_compiler:="identityTranslator"}
: ${workspace:="$(pwd)/workspace"}
: ${parallelism:=1}
: ${application:=$1}
: ${application_workspace:="${workspace}/${application}"}

export ROSE_SH_HOME="$(cd "$(dirname "$0")" && pwd)"

export APPLICATIONS_DIR="${ROSE_SH_HOME}/applications"
export APPLICATION_SCRIPT="${APPLICATIONS_DIR}/${application}.sh"

#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------
info() { printf "[INFO] [${application}] $*\n" ; return 0 ; }
fail() { printf "\n[FATAL] [${application}] $*\n" ; exit 1 ; }

#-------------------------------------------------------------------------------
# Source application build function
#-------------------------------------------------------------------------------
if [ -z "${APPLICATION_SCRIPT}" -o ! -f "${APPLICATION_SCRIPT}" ]; then
    fail "Application script does not exist: '${APPLICATION_SCRIPT}'"
else
    info "Sourcing application script '${APPLICATION_SCRIPT}'"
    source "${APPLICATION_SCRIPT}" || exit 1
fi

#-------------------------------------------------------------------------------
phase_1()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 1"

  mkdir -p "${application_workspace}/phase_1" || fail "phase_1::create_workspace failed"
  pushd "${application_workspace}/phase_1"    || fail "phase_1::cd_into_workspace failed"
      "download_${application}"               || fail "phase_1::download failed with status='$?'"
      "patch_${application}__rose"            || fail "phase_1::patch_rose failed with status='$?'"
      "configure_${application}__rose"        || fail "phase_1::configure_with_rose failed with status='$?'"
      "compile_${application}"                || fail "phase_1::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
phase_2()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 2"

  mkdir -p "${application_workspace}/phase_2" || fail "phase_2::create_workspace failed"
  pushd "${application_workspace}/phase_2"    || fail "phase_2::cd_into_workspace failed"
      "download_${application}"               || fail "phase_2::download failed with status='$?'"

      # Replace application source code files with ROSE translated source code files
      "${ROSE_SH_HOME}/opt/stage_rose.sh" -f \
          "${application_workspace}/phase_1/${application}-src" \
          "${application_workspace}/phase_2/${application}-src" \
                                              || fail "phase2::stage_rose.sh failed"

      # Save the diff with the updated ROSE files
      pushd "${application_workspace}/phase_2/${application}-src" || fail "phase_2::cd_into_source_dir failed"
          git diff --patch > "add_rose_translated_sources.patch"  || fail "phase_2::generate_diff_patch failed"
          git add "add_rose_translated_sources.patch"             || fail "phase_2::git_add_diff_patch failed"
          git commit -a -m "Add ROSE translated sources"          || fail "phase_2::git_commit_rose_diff failed"
      popd
      tar czvf \
          "${application_workspace}/phase_2/${application}-src-rose.tgz" \
          "${application_workspace}/phase_2/${application}-src"   || fail "phase_2::create_application_tarball_containing_rose_sources failed"

      "configure_${application}__gcc"   || fail "phase_2::configure_with_gcc failed with status='$?'"
      "compile_${application}"          || fail "phase_2::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
main()
#-------------------------------------------------------------------------------
{
    info "Performing main()"

    # Build in a separate workspace, so we don't pollute the user's current directory.
    rm -rf "${application_workspace}"   || fail "main::remove_workspace failed"
    mkdir -p "${application_workspace}" || fail "main::create_workspace failed"
    pushd "${application_workspace}"    || fail "main::cd_into_workspace failed"

      phase_1 || exit 1
      phase_2 || exit 1

    popd
}


#-------------------------------------------------------------------------------
# Entry point for program execution
#-------------------------------------------------------------------------------
main || fail "Main program execution failed"
exit_status="$?"
info "[INFO] Exit status = '${exit_status}'"
exit "$exit_status"
