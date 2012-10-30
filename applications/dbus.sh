compile_dbus()
{
  local translator="$1" parallelism="${parallelism:=1}"
  local autoconf_version="$(autoconf --version | head -1 | awk '{print $NF}' | sed 's/\.//g')"

  if [ -z "$translator" ]; then
    echo "Usage: compile_dbus <name of rose translator>"
    exit 1
  elif [ "$autoconf_version" -lt 263 ]; then
    echo "compile_dbus requires Autoconf version >= 2.63"
    exit 1
  elif [ -z "$(which cmake)" ]; then
    echo "compile_dbus requires CMake -- please set your \$PATH"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.6.4
  declare -r TARBALL="dbus-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://dbus.freedesktop.org/releases/dbus/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "dbus"
  cd "dbus" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd dbus-${VERSION} || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" cmake -G "Unix Makefiles" ../cmake/ || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
