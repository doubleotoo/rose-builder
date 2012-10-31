compile_zsh()
{
  local translator="$1" parallelism="${parallelism:=1}"

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=5.0.0
  declare -r TARBALL="zsh-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="ftp://ftp.zsh.org/pub/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "zsh"
  cd "zsh" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "zsh-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  # Use "--without-tcsetpgrp", otherwise error "no controlling TTY" when run in Jenkins
  CC="$translator" ./configure \
      --prefix="$(pwd)/install_tree" \
      --without-tcsetpgrp \
  || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
