#-------------------------------------------------------------------------------
download_nginx()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      git clone \
          "rose-dev@rosecompiler1.llnl.gov:rose/c/${application}.git" \
          "${application}-src" \
          || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
patch_nginx__rose()
#-------------------------------------------------------------------------------
{
  info "ROSE patching not required"

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
}

#-------------------------------------------------------------------------------
configure_nginx__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      CC="${CC} -rose:C89_only" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_nginx__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_nginx()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
