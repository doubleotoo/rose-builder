compile_wget()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_wget <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.14
  declare -r TARBALL="wget-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://ftp.gnu.org/gnu/wget/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "wget"
  cd "wget" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "wget-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Hack
  #-----------------------------------------------------------------------------
  # Hack: Replace "GNUTLS_TLS1_2" by "GNUTLS_TLS1_1" so it will compile
  # on our operating systems
  f="src/gnutls.c"
  echo "Hacking file '$f' to change 'GNUTLS_TLS1_2' to 'GNUTLS_TLS1_1'..."
  mv $f $f-old
  cat "${f}-old" | sed 's/GNUTLS_TLS1_2/GNUTLS_TLS1_1/g' > "$f" 

  # Hack: Change include to be local instead of system:
  # <sys/stat.h> to "sys/stat.h"
  cp lib/utimens.c lib/utimens.c-old
  cat lib/utimens.c-old | sed 's/#include <sys\/stat.h>/#include "sys\/stat.h"/g' > lib/utimens.c

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
