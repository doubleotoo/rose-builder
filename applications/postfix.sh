#-------------------------------------------------------------------------------
download_postfix()
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
patch_postfix__rose()
#-------------------------------------------------------------------------------
{
  info "ROSE patching not required"

  #-----------------------------------------------------------------------------
  # Hack
  #-----------------------------------------------------------------------------
  # Patch generated by:
  #
  #   diff -U 10 \
  #       ./src/global/memcache_proto.c \
  #       memcache_proto_modified_for_rose.c \
  #   > patch-memcache_proto.c
  #
#  curl --insecure \
#    https://raw.github.com/gist/3981468/62f9ccb80f2514b3aec7e6a2416564b5fa2ef625/patch-memcache_proto.c | \
#    patch -p1 -i -
  cat patches/patch-memcache_proto.c | patch -p1 -i - || exit 1
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "[FATAL] Failed to patch memcache_proto.c"
    exit 1
  fi
}

#-------------------------------------------------------------------------------
configure_postfix__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  set -x
      make makefiles CC="${CC} -rose:C89_only" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_postfix__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  set -x
      make makefiles CC="gcc" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_postfix()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
