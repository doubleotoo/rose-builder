#-------------------------------------------------------------------------------
download_wget()
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
install_deps_wget()
#-------------------------------------------------------------------------------
{
  info "[Dependencies] No external dependencies need to be installed"
}

#-------------------------------------------------------------------------------
patch_wget()
#-------------------------------------------------------------------------------
{
  info "Patching application"

  #-----------------------------------------------------------------------------
  # src/gnutls.c
  #-----------------------------------------------------------------------------
  info "[Patch] Replacing \"GNUTLS_TLS1_2\" by \"GNUTLS_TLS1_1\" so it will compile on our operating systems"

  f="src/gnutls.c"
  echo "Hacking file '$f' to change 'GNUTLS_TLS1_2' to 'GNUTLS_TLS1_1'..."
  mv $f $f-old
  cat "${f}-old" | sed 's/GNUTLS_TLS1_2/GNUTLS_TLS1_1/g' > "$f" 

  #-----------------------------------------------------------------------------
  # lib/utimens.c
  #-----------------------------------------------------------------------------
  info "[Patch] Change include to be local instead of system <sys/stat.h> to \"sys/stat.h\""

  cp lib/utimens.c lib/utimens.c-old
  cat lib/utimens.c-old | sed 's/#include <sys\/stat.h>/#include "sys\/stat.h"/g' > lib/utimens.c
}

#-------------------------------------------------------------------------------
configure_wget__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      CC="${CC} -rose:C89_only" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_wget__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_wget()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
