#-------------------------------------------------------------------------------
download_cherokee()
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
patch_cherokee__rose()
#-------------------------------------------------------------------------------
{
  info "ROSE patching not required"
}

#-------------------------------------------------------------------------------
configure_cherokee__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${rose_compiler}'"

  set -x
      CC="${rose_compiler} -rose:C99" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_cherokee__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_cherokee()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
