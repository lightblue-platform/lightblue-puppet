# This module will properly configure the java JVM and SDK on a Linux machine
# that support the /etc/alternatives configuration abstraction.  This will also
# provide the JAVA_HOME environment variable for Java based projects that only
# support the environment style configuration.
# Note: the alternatives entries for java is made by the company who package the RPM, such as http://pkgs.fedoraproject.org/cgit/java-1.7.0-openjdk.git/tree/java-1.7.0-openjdk.spec?h=f17 for openjdk7 and http://pkgs.fedoraproject.org/cgit/java-1.8.0-openjdk.git/tree/java-1.8.0-openjdk.spec for openjdk8 (which can be useful for insights for this class)

# Examples of java package
# java-1.7.0-openjdk-devel-1.7.0.71-2.5.3.1.el6.x86_64
# java-1.8.0-openjdk-1.8.0.25-4.b18.fc21
# java-1.8.0-openjdk-devel-1.8.0.40-24.b25.fc21.x86_64
# java-majorVersion-destribution-IsSDK-specificVersion.arch
# specificVersion = MajorAndMinorVersion + ReleaseVersion + Repository
class lightblue::java ($java_version = '1.7.0', $java_distribution = 'openjdk', $java_specific_version = undef) {

  $java_jre_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/jre-${java_version}-${java_distribution}/bin/java",
    'x86_64' => "/usr/lib/jvm/jre-${java_version}-${java_distribution}.${::architecture}/bin/java"
  }
  $java_sdk_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/java-${java_version}-${java_distribution}",
    'x86_64' => "/usr/lib/jvm/java-${java_version}-${java_distribution}.${::architecture}"
  }
  $java_home = "/etc/alternatives/java_sdk_${java_distribution}"
  $java_version_distribution = $::architecture ? {
    'i386'   => "${java_version}-${java_distribution}",
    'x86_64' => "${java_version}-${java_distribution}.${::architecture}"
  }
  $jvm_dir = '/usr/lib/jvm/'
  $jvm_export = '/usr/lib/jvm-exports/'
  $jre_location = "${jvm_dir}jre-${java_version_distribution}"
  $alternative_priority = 9000000

  if($java_specific_version == 'latest' or $java_specific_version == 'installed'){
    $java_package_version = $java_specific_version
  }
  else{
    $java_package_version = $java_specific_version ? {
      undef       => 'latest',
      default     => $java_specific_version
    }
  }

  package { 'java':
    ensure => $java_package_version,
    name   => "java-${java_version}-${java_distribution}",
    alias  => 'java',
  }
  ->
  package { 'java-devel':
    ensure => $java_package_version,
    name   => "java-${java_version}-${java_distribution}-devel",
    alias  => 'java-devel',
  }
  ->
  file { '/etc/profile.d/java-env.sh':
    mode    => '0755',
    content => inline_template('export JAVA_HOME=<%= java_home %>'),
  }

  ->
#set alternatives to auto in all cases, just too messy to deal with otherwise
  exec { "configure jre_${java_version}":
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto jre_${java_version}",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "test /usr/sbin/alternatives --display jre_${java_version} | grep 'status is auto'",
  }
  ->
  exec { "configure jre_${java_distribution}":
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto jre_${java_distribution}",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "test /usr/sbin/alternatives --display jre_${java_distribution} | grep 'status is auto'",
  }
  ->
  exec { "configure java_sdk_${java_version}":
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto java_sdk_${java_version}",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "test /usr/sbin/alternatives --display java_sdk_${java_version} | grep 'status is auto'",
  }
  ->
  exec { "configure java_sdk_${java_distribution}":
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto java_sdk_${java_distribution}",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "test /usr/sbin/alternatives --display java_sdk_${java_distribution} | grep 'status is auto'",
  }
  ->
  exec { 'configure java':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto java",
    require => [File['/etc/profile.d/java-env.sh'],Package['java']],
    unless  => "test /usr/sbin/alternatives --display java | grep 'status is auto'",
  }
  ->
  exec { 'configure javac':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] ,
    command => "/usr/sbin/alternatives --auto javac",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless  => "test /usr/sbin/alternatives --display javac | grep 'status is auto'",
  }
}
