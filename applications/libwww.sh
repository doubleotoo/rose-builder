#-------------------------------------------------------------------------------
download_libwww()
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
install_deps_libwww()
#-------------------------------------------------------------------------------
{
  info "[Dependencies] No external dependencies need to be installed"
}

#-------------------------------------------------------------------------------
patch_libwww()
#-------------------------------------------------------------------------------
{
  info "Patching application"

  #-----------------------------------------------------------------------------
  # xmltok.c
  #-----------------------------------------------------------------------------
  info "[Patch] Applying patch for xmltok.c"

  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./modules/expat/xmltok/xmltok.c \
  #       xmltok-modified_for_rose.c \
  #   > patch-xmltok.c
  #
  #curl --insecure \
  #  https://raw.github.com/gist/4025948/eb4845799311d22e986f302b29d7f411081b754b/patch-xmltok.c | \
  #  patch -p1 -i -
  cat patches/patch-xmltok.c | patch -p1 -i - || exit 1
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "[FATAL] Failed to patch xmltok.c"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # HTFile.c
  #-----------------------------------------------------------------------------
  info "[Patch] Applying patch for HTFile.c"
  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./Library/src/HTFile.c \
  #       HTFile-modified_for_rose.c
  #   > patch-HTFile.c
  #
  #curl --insecure \
  #  https://raw.github.com/gist/4025948/aa5e347f08b96682728677384f58050fb036525d/HTFile.c | \
  #  patch -p1 -i -
  cat patches/patch-HTFile.c | patch -p1 -i - || exit 1
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "[FATAL] Failed to patch HTFile.c"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # HTMulti.c
  #-----------------------------------------------------------------------------
  info "[Patch] Applying patch for HTMulti.c"
  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./Library/src/HTMulti.c \
  #       HTMulti-modified_for_rose.c \
  #   > patch-HTMulti.c
  #
  #curl --insecure \
  #  https://raw.github.com/gist/4025948/ad11c3d8dbbda4044b967158e857beaed82c6c51/HTMulti.c | \
  #  patch -p1 -i -
  cat patches/patch-HTMulti.c | patch -p1 -i - || exit 1
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "[FATAL] Failed to patch HTMulti.c"
    exit 1
  fi
}

#-------------------------------------------------------------------------------
configure_libwww__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      CC="${CC}" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_libwww__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      CC="gcc" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_libwww()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
