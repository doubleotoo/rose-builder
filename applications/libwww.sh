compile_libwww()
{
  local translator="$1" parallelism="${parallelism:=1}"

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=5.4.0
  declare -r TARBALL="w3c-libwww-${VERSION}.tgz"
  declare -r DOWNLOAD_URL="http://www.w3.org/Library/Distribution/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "w3c-libwww"
  cd "w3c-libwww" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "w3c-libwww-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
