compile_nginx()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_nginx <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=1.2.3
  declare -r TARBALL="nginx-${VERSION}.tar.gz"
  declare -r DOWNLOAD_URL="http://nginx.org/download/${TARBALL}"

  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "nginx"
  cd "nginx" || exit 1

  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "nginx-${VERSION}" || exit 1

  #-----------------------------------------------------------------------------
  # Hack
  #-----------------------------------------------------------------------------
  # Hack: Replace space in header file include paths: "-I "to> "-I":
  files="$(grep -rn "\-I " * | awk '{print $1}' | sed 's/:.*:.*//g')"
  for f in $files; do
    echo "Hacking file '$f' to remove space in -I header file include paths..."
    mv $f $f-old
    cat "${f}-old" | sed 's/-I /-I/g' > "$f" 
  done

  # Hack: Remove "-Werror" so warnings won't be treated as errors:
  files="$(grep -rn "\-Werror" * | awk '{print $1}' | sed 's/:.*:.*//g')"
  for f in $files; do
    echo "Hacking file '$f' to remove the -Werror CFLAG..."
    mv $f $f-old
    cat "${f}-old" | sed 's/-Werror//g' > "$f" 
  done


  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
