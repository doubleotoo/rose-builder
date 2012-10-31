compile_irssi()
{
  local translator="$1" parallelism="${parallelism:=1}"

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=0.8.15
  declare -r TARBALL="irssi-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://www.irssi.org/files/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "irssi"
  cd "irssi" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "${TARBALL}" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "irssi-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
