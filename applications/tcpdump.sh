compile_tcpdump()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_tcpdump <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=4.3.0
  declare -r TARBALL="tcpdump-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://www.tcpdump.org/release/${TARBALL}"

  declare -r LIBPCAP_VERSION=1.3.0
  declare -r LIBPCAP_TARBALL="libpcap-${LIBPCAP_VERSION}.tar.gz"
  declare -r LIBPCAP_DOWNLOAD_URL="http://www.tcpdump.org/release/${LIBPCAP_TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "tcpdump"
  cd "tcpdump" || exit 1

  #-----------------------------------------------------------------------------
  # Pre-requisite
  #-----------------------------------------------------------------------------
  # libpcap
  download "$LIBPCAP_DOWNLOAD_URL"
  tar xvf "${LIBPCAP_TARBALL}" || exit 1
  pushd "libpcap-${LIBPCAP_VERSION}"
      ./configure --prefix="$(pwd)/install_tree" || exit 1
      make -j${parallelism} install || exit 1
  popd

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "tcpdump-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
