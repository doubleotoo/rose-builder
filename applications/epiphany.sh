compile_epiphany()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_epiphany <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=3.0.4
  declare -r TARBALL="epiphany-${VERSION}.tar.bz2"
  declare -r DOWNLOAD_URL="https://launchpad.net/epiphany-browser/trunk/3.0.4/+download/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "epiphany"
  cd "epiphany" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "${TARBALL}" "$DOWNLOAD_URL"
  tar xvfj "${TARBALL}" || exit 1
  cd "epiphany-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
