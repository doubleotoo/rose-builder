#-------------------------------------------------------------------------------
download_tcpdump()
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
install_deps_tcpdump()
#-------------------------------------------------------------------------------
{
  info "Installing external dependencies"

  info "[Dependency] Installing libpcap"

  declare -r LIBPCAP_VERSION=1.3.0
  declare -r LIBPCAP_TARBALL="libpcap-${LIBPCAP_VERSION}.tar.gz"
  declare -r LIBPCAP_DOWNLOAD_URL="http://www.tcpdump.org/release/${LIBPCAP_TARBALL}"

  set -x
      # Workspace must be at the same level as tcpdump
      pushd ../
          tar xvf "tcpdump-src/${LIBPCAP_TARBALL}" || exit 1
          pushd "libpcap-${LIBPCAP_VERSION}"
              ./configure --prefix="$(pwd)/install_tree" || exit 1
              make -j${parallelism} install || exit 1
          popd
      popd
  set +x
}

#-------------------------------------------------------------------------------
patch_tcpdump()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_tcpdump__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      CC="${CC}" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_tcpdump__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_tcpdump()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
