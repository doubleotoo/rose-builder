
# http://jmeter.apache.org/
#
# "The Apache JMeter™ desktop application is open source software, a 100% pure
# Java application designed to load test functional behavior and measure
# performance. It was originally designed for testing Web Applications but has
# since expanded to other test functions."
#
# == Getting Started
#
# See http://jmeter.apache.org/usermanual/get-started.html.
#
# === Requirements
#
# JMeter requires a fully compliant JVM 1.5 or higher. 
#
# === Installation
#
# To install a release build, simply unzip the zip/tar file into the directory
# where you want JMeter to be installed. Provided that you have a JRE/JDK
# correctly installed and the JAVA_HOME environment variable set, there is
# nothing more for you to do. 
#
# === Build Instructions
#
# See $JMETER/README and $JMETER/build.xml.
#
# JMeter is built using Ant.
#
# Change to the top-level directory and issue the command:
#
# ant download_jars ! only needs to be done once; will download any missing 3rd party jars
#
# ant [install]
#
# This will compile the application and enable you to run jmeter from the bin
# directory.
#
# Note: See Ant's "javac" Task http://ant.apache.org/manual/Tasks/javac.html.
#
#     Compiles a Java source tree.
#
compile_jmeter()
{
  local translator="$1" parallelism="${parallelism:=1}"

  if [ -z "$translator" ]; then
    echo "Usage: compile_jmeter <name of rose translator>"
    exit 1
  fi

  #-----------------------------------------------------------------------------
  # Configure  Meta Information
  #-----------------------------------------------------------------------------
  declare -r VERSION=2.8
  declare -r TARBALL="apache-jmeter-${VERSION}_src.tgz"
  declare -r DOWNLOAD_URL="http://www.alliedquotes.com/mirrors/apache/jmeter/source/${TARBALL}"


  #-----------------------------------------------------------------------------
  # Create Workspace
  #-----------------------------------------------------------------------------
  create_workspace "jmeter"
  cd "jmeter" || exit 1


  #-----------------------------------------------------------------------------
  # Download and Unpack
  #-----------------------------------------------------------------------------
  download "$TARBALL" "$DOWNLOAD_URL"
  tar xvf "${TARBALL}" || exit 1
  cd "apache-jmeter-${VERSION}" || exit 1


  #-----------------------------------------------------------------------------
  # Build
  #-----------------------------------------------------------------------------
  CC="$translator" ./configure --prefix="$(pwd)/install_tree" || exit 1

  make --keep-going -j${parallelism} || exit 1
  make install -j${parallelism} || exit 1
}
