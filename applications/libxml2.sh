compile_libxml2()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_libxml2 <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=2.9.1
  declare -r TARBALL="libxml2-git-snapshot.tar.gz"
  declare -r DOWNLOAD_URL="ftp://xmlsoft.org/libxml2/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "libxml2"
  cd "libxml2" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "libxml2-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure || exit 1

  # V=1 to enable verbose mode
  V=1 make -j${parallelism} || exit 1
}
