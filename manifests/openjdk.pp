# Copied from libjava
# This module will properly configure the java JVM and SDK on a Linux machine
# that support the /etc/alternatives configuration abstraction.  This will also
# provide the JAVA_HOME environment variable for Java based projects that only
# support the environment style configuration.
class lightblue::openjdk ($java_version = '1.7.0') {

  # The Sun RPM sets up alternatives to look
  # against the JRE directory for java
  $java_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/jre-${java_version}-openjdk/bin/java",
    'x86_64' => "/usr/lib/jvm/jre-${java_version}-openjdk.${::architecture}/bin/java"
  }

  $java_sdk_openjdk_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/java-${java_version}-openjdk",
    'x86_64' => "/usr/lib/jvm/java-${java_version}-openjdk.${::architecture}"
  }

  $java_home = '/etc/alternatives/java_sdk_openjdk'

  package { 'java':
    ensure => installed,
    name   => "java-${java_version}-openjdk",
  }

  package { 'java-devel':
    ensure => installed,
    name   => "java-${java_version}-openjdk-devel",
  }

  exec { 'configure java_sdk_openjdk':
    command => "/usr/sbin/alternatives --set java_sdk_openjdk '${java_sdk_openjdk_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java']],
    unless  => "/usr/sbin/alternatives --display java_sdk_openjdk | grep link | grep ${java_sdk_openjdk_location}"
  }

  exec { 'configure java':
    command => "/usr/sbin/alternatives --set java '${java_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java']],
    unless  => "/usr/sbin/alternatives --display java | grep link | grep ${java_location}"
  }

  exec { 'configure javac':
    command => "/usr/sbin/alternatives --set javac '${java_sdk_openjdk_location}/bin/javac'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "/usr/sbin/alternatives --display javac | grep link | grep ${java_sdk_openjdk_location}/bin/javac"
  }

  file { '/etc/profile.d/java-env.sh':
    mode    => '0755',
    content => inline_template("export JAVA_HOME=<%= java_home %>"),
  }
}
