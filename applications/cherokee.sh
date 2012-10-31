compile_cherokee()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_cherokee <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.2.101
  declare -r TARBALL="cherokee-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://www.cherokee-project.com/download/1.2/${VERSION}/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "cherokee"
  cd "cherokee" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "${TARBALL}" "$DOWNLOAD_URL"
  tar xvzf "${TARBALL}" || exit 1
  cd  "cherokee-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism}  || exit 1
  make install -j${parallelism} || exit 1
}
