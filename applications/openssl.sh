compile_openssl()
{
  local translator="$1" parallelism="${parallelism:=1}"

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.0.1c
  declare -r TARBALL="openssl-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://www.openssl.org/source/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "openssl"
  cd "openssl" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "openssl-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./config --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  #make test --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
