#-------------------------------------------------------------------------------
download_dbus()
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
install_deps_dbus()
#-------------------------------------------------------------------------------
{
  info "[Dependencies] No external dependencies need to be installed"
}

#-------------------------------------------------------------------------------
patch_dbus()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_dbus__generic()
#-------------------------------------------------------------------------------
{
  local autoconf_version="$(autoconf --version | head -1 | awk '{print $NF}' | sed 's/\.//g')"

  if [ "$autoconf_version" -lt 263 ]; then
    fail "${application} requires Autoconf version >= 2.63"
  elif [ -z "$(which cmake)" ]; then
    fail "${application} requires CMake -- please set your \$PATH"
  fi

  mkdir dbus-build-dir || exit 1
  cd dbus-build-dir || exit 1
}

#-------------------------------------------------------------------------------
configure_dbus__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${CC}'"

  configure_dbus__generic || exit 1

  set -x
      CC="$CC" cmake -G "Unix Makefiles" ../cmake/ || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_dbus__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='gcc'"

  configure_dbus__generic || exit 1

  set -x
      CC="gcc" cmake -G "Unix Makefiles" ../cmake/ || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_dbus()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
