# This module will properly configure the java JVM and SDK on a Linux machine
# that support the /etc/alternatives configuration abstraction.  This will also
# provide the JAVA_HOME environment variable for Java based projects that only
# support the environment style configuration.
class lightblue::java ($java_version = '1.7.0', $java_distribution = 'openjdk') {

  $java_jre_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/jre-${java_version}-${java_distribution}/bin/java",
    'x86_64' => "/usr/lib/jvm/jre-${java_version}-${java_distribution}.${::architecture}/bin/java"
  }

  $java_sdk_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/java-${java_version}-${java_distribution}",
    'x86_64' => "/usr/lib/jvm/java-${java_version}-${java_distribution}.${::architecture}"
  }

  $java_home = "/etc/alternatives/java_sdk_${java_distribution}"

  package { 'java':
    ensure => installed,
    name   => "java-${java_version}-${java_distribution}",
  }

  package { 'java-devel':
    ensure => installed,
    name   => "java-${java_version}-${java_distribution}-devel",
  }

  exec { "configure java_sdk_${java_distribution}":
    command => "/usr/sbin/alternatives --set java_sdk_${java_distribution} '${java_sdk_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "/usr/sbin/alternatives --display java_sdk_${java_distribution} | grep link | grep ${java_sdk_location}"
  }

  exec { 'configure java':
    command => "/usr/sbin/alternatives --set java '${java_jre_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java']],
    unless  => "/usr/sbin/alternatives --display java | grep link | grep ${java_jre_location}"
  }

  exec { 'configure javac':
    command => "/usr/sbin/alternatives --set javac '${java_sdk_location}/bin/javac'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "/usr/sbin/alternatives --display javac | grep link | grep ${java_sdk_location}/bin/javac"
  }

  file { '/etc/profile.d/java-env.sh':
    mode    => '0755',
    content => inline_template('export JAVA_HOME=<%= java_home %>'),
  }
}
