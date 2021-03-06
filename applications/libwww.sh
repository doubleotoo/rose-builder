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
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "w3c-libwww-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Hack
  #-----------------------------------------------------------------------------
  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./modules/expat/xmltok/xmltok.c \
  #       xmltok-modified_for_rose.c \
  #   > patch-xmltok.c
  #
  curl --insecure \
    https://raw.github.com/gist/4025948/eb4845799311d22e986f302b29d7f411081b754b/patch-xmltok.c | \
    patch -p1 -i -

  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./Library/src/HTFile.c \
  #       HTFile-modified_for_rose.c
  #   > patch-HTFile.c
  #
  curl --insecure \
    https://raw.github.com/gist/4025948/aa5e347f08b96682728677384f58050fb036525d/HTFile.c | \
    patch -p1 -i -

  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./Library/src/HTMulti.c \
  #       HTMulti-modified_for_rose.c \
  #   > patch-HTMulti.c
  #
  curl --insecure \
    https://raw.github.com/gist/4025948/ad11c3d8dbbda4044b967158e857beaed82c6c51/HTMulti.c | \
    patch -p1 -i -

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
