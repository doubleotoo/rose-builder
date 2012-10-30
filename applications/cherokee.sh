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
  declare -r CHEROKEE_URL="http://www.cherokee-project.com/download/1.2/${VERSION}/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "cherokee"
  cd "cherokee"

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$CHEROKEE_URL"
  tar   xvzf cherokee-${VERSION}.tar.gz
  cd    cherokee-${VERSION}

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism}  || exit 1
  make install -j${parallelism} || exit 1
}
