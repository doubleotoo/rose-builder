compile_epiphany()
{
# TODO:
#
# Is this the download?
# https://launchpad.net/epiphany-browser/trunk/3.0.4/+download/epiphany-3.0.4.tar.bz2
echo "Not implemented yet"
exit 1

  local translator="$1" parallelism="${parallelism:=1}"
  local autoconf_version="$(autoconf --version | head -1 | awk '{print $NF}' | sed 's/\.//g')"

  if [ -z "$translator" ]; then
    echo "Usage: compile_epiphany <name of rose translator>"
    exit 1
  elif [ "$autoconf_version" -lt 263 ]; then
    echo "compile_epiphany requires Autoconf version >= 2.63"
    exit 1
  elif [ -z "$(which cmake)" ]; then
    echo "compile_epiphany requires CMake -- please set your \$PATH"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.6.4
  declare -r TARBALL="epiphany-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://epiphany.freedesktop.org/releases/epiphany/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "epiphany"
  cd "epiphany" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "${TARBALL}" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "epiphany-${VERSION}" || exit 1

  mkdir epiphany-build-dir || exit 1
  cd epiphany-build-dir || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" cmake -G "Unix Makefiles" ../cmake/ || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
