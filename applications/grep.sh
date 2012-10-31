compile_grep()
{

  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_grep <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=2.14
  declare -r TARBALL="grep-${VERSION}.tar.xz"
  declare -r DOWNLOAD_URL="http://mirrors.kernel.org/gnu/grep/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "grep"
  cd "grep" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "${TARBALL}" "$DOWNLOAD_URL"
  unxz --force "${TARBALL}" || exit 1 # TODO: optional force
  tar xvf "${TARBALL%%.xz}" || exit 1
  cd "grep-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
