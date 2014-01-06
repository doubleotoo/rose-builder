#-------------------------------------------------------------------------------
download_mutt()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      git clone \
          "rose-dev@rosecompiler1.llnl.gov:rose/c/${application}.git" \
          "${application}-src" \
          || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_mutt()
#-------------------------------------------------------------------------------
{
  info "[Dependencies] No external dependencies need to be installed"
}

#-------------------------------------------------------------------------------
patch_mutt()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_mutt__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      CC="${CC}" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_mutt__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_mutt()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
